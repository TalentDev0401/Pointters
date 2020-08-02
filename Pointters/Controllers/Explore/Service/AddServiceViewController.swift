//
//  AddServiceViewController.swift
//  Pointters
//
//  Created by Mac on 2/24/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import AVFoundation
import AWSS3
import AWSCore
import CoreLocation
import LNICoverFlowLayout

protocol DeleteServiceDelegate {
    func onClickDeleteService(index: Int)
}

protocol SaveServiceDelegate {
    func onSaveService()
}

class AddServiceViewController: UIViewController {
    
    var saveDelegate: SaveServiceDelegate!
    
    var deleteDelegate: DeleteServiceDelegate!
    var deleteIndex: Int!
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet weak var consBottomViewHeight: NSLayoutConstraint!
    @IBOutlet var tableView: TPKeyboardAvoidingTableView!
    @IBOutlet var mediaCollectionView: UICollectionView!
    @IBOutlet var mediaCoverFlowLayout: LNICoverFlowLayout!
    @IBOutlet var mediaHeaderView: UIView!
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var lblNavTitle: UILabel!
    
    var userLocation: CLLocation?
    
    var serviceId = ""
    
    var serviceMedia = [Media]()
    var arrPrices = [Price]()
    var serviceTitle = ""
    var serviceDesc = ""
    var serviceCategory = Category.init()
    var deliveryStatus = 0
    var serviceFulfillment = FulFillment.init()
    var serviceAddress = Location.init()

    var mediaIndex = 0
    
    var originalItemSize = CGSize.zero
    var originalCollectionViewSize = CGSize.zero
    
    var numStores: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.callSellerEligabilityAPI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.serviceFulfillment.localServiceRadius == 0 {
            deliveryStatus = 0
            tableView.reloadSections(IndexSet(integer: 3), with: .none)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mediaCoverFlowLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Now we should calculate new item size depending on new collection view size.
        mediaHeaderView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: (315/667.0) * UIScreen.main.bounds.height)
        tableView.tableHeaderView = mediaHeaderView
        
        mediaCoverFlowLayout.itemSize = CGSize(
            width: mediaCollectionView.bounds.size.width * originalItemSize.width / originalCollectionViewSize.width,
            height: mediaCollectionView.bounds.size.height * originalItemSize.height / originalCollectionViewSize.height
        )
        
        self.setInitialValues()
        
        mediaCollectionView.layoutIfNeeded()
        mediaCollectionView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = mediaCollectionView.frame.size.width
        let fractionalPage = mediaCollectionView.contentOffset.x/pageWidth
        let page = lroundf(Float(fractionalPage))
        
        if page >= serviceMedia.count && serviceMedia.count > 0 {
            mediaCollectionView.scrollToItem(at: IndexPath(row: serviceMedia.count-1, section: 0), at: .right, animated: true)
        }
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
            consBottomViewHeight.constant = 91.0
        } else {
            consNavBarHeight.constant = 64.0
            consBottomViewHeight.constant = 70.0
        }
        
        btnAdd.layer.cornerRadius = 10.0
        btnAdd.layer.masksToBounds = true
        
        if serviceId != "" {
            lblNavTitle.text = "Edit Service Detail"
        } else {
            lblNavTitle.text = "Add Service Detail"
        }
        
        originalItemSize = mediaCoverFlowLayout.itemSize
        originalCollectionViewSize = mediaCollectionView.bounds.size
    }
    
    func initData() {
        let lat:Double = UserCache.sharedInstance.getUserLatitude()!
        let lng:Double = UserCache.sharedInstance.getUserLongitude()!
        userLocation = CLLocation(latitude: lat, longitude: lng)
        getCurrentLocation()
        if serviceId == "" {
            serviceFulfillment.localServiceRadius = 15
            serviceFulfillment.localServiceRadiusUom = "mile"
            setDeliveryMethod(index: 0)
        } else {
            if serviceFulfillment.online {
                deliveryStatus = 0
            } else if serviceFulfillment.shipment {
                deliveryStatus = 1
            } else if serviceFulfillment.local {
                deliveryStatus = 2
            } else if serviceFulfillment.store {
                deliveryStatus = 3
            }
        }
        allowAddService()
        tableView.reloadData()
    }
    
    fileprivate func setInitialValues() {
        // Setting some nice defaults, ignore if you don't like them
        mediaCoverFlowLayout.maxCoverDegree = 1.0
        mediaCoverFlowLayout.coverDensity = 0.065
        mediaCoverFlowLayout.minCoverScale = 0.9
        mediaCoverFlowLayout.minCoverOpacity = 1
    }
    
    func checkMediaAccess(type:Int) -> Bool {
        var flag = false
        
        if serviceMedia.count >= 5 {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "You can't upload more than 5 medias", buttonTitles: ["OK"], viewController: self, completion: nil)
        }
        else {
            if type == 0 {
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    flag = true
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "You can't access the photo library", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    flag = true
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "You can't access the camera", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
        }
        
        return flag
    }
    
    func setDeliveryMethod(index:Int) {
        
        serviceFulfillment.online = false
        serviceFulfillment.shipment = false
        serviceFulfillment.local = false
        serviceFulfillment.store = false
        switch index {
            case 0:
                serviceFulfillment.online = true
                deliveryStatus = index
                break
            case 1:
                deliveryStatus = index
                serviceFulfillment.shipment = true
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let shippingDetailVC = storyboard.instantiateViewController(withIdentifier: "ShippingDetailVC") as! ShippingDetailViewController
                shippingDetailVC.shippingDetailDelegate = self
                shippingDetailVC.street = serviceFulfillment.shipmentAddress.street1
                shippingDetailVC.apt = serviceFulfillment.shipmentAddress.apt
                shippingDetailVC.city = serviceFulfillment.shipmentAddress.city
                shippingDetailVC.state = serviceFulfillment.shipmentAddress.state
                shippingDetailVC.zip = serviceFulfillment.shipmentAddress.zip
                shippingDetailVC.country = serviceFulfillment.shipmentAddress.country
                shippingDetailVC.length = serviceFulfillment.shipmentParcel.length
                shippingDetailVC.width = serviceFulfillment.shipmentParcel.width
                shippingDetailVC.height = serviceFulfillment.shipmentParcel.height
                shippingDetailVC.weight = serviceFulfillment.shipmentParcel.weight
                navigationController?.pushViewController(shippingDetailVC, animated: true)
                break
            case 2:
                deliveryStatus = index
                serviceFulfillment.local = true
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let radiusSettingVC = storyboard.instantiateViewController(withIdentifier: "RadiusSettingVC") as! RadiusSettingViewController
                radiusSettingVC.radiusDelegate = self
                radiusSettingVC.radius = serviceFulfillment.localServiceRadius
                navigationController?.pushViewController(radiusSettingVC, animated: true)
                break
            case 3:
                if self.numStores != 0 {
                    deliveryStatus = index
                    serviceFulfillment.store = true
                } else {
                    let storyboard = UIStoryboard(name: "Account", bundle: nil)
                    let newAddressVC = storyboard.instantiateViewController(withIdentifier: "EnterNewAddressVC") as! EnterNewAddressViewController
                    self.navigationController?.pushViewController(newAddressVC, animated: true)
                }
                break
            default:
                break
        }
        tableView.reloadSections(IndexSet(integer: 3), with: .none)
    }
    
    func getCurrentLocation() {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation!, completionHandler: {
            placemarks, error in
            
            if let err = error {
                self.serviceAddress = Location.init()
                self.serviceAddress.geoJson.coordinates = [(self.userLocation?.coordinate.longitude)!, (self.userLocation?.coordinate.latitude)!]

                print(err.localizedDescription)
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    print(placemark)
                    self.serviceAddress.city = placemark.locality ?? "NA"
                    self.serviceAddress.country = placemark.country ?? "NA"
                    self.serviceAddress.postalCode = placemark.postalCode ?? "NA"
                    self.serviceAddress.province = placemark.subAdministrativeArea ?? "NA"
                    self.serviceAddress.state = placemark.administrativeArea ?? "NA"
                    self.serviceAddress.geoJson.type = "Point"
                    self.serviceAddress.geoJson.coordinates = [(self.userLocation?.coordinate.longitude)!, (self.userLocation?.coordinate.latitude)!]
                } else {
                    self.serviceAddress = Location.init()
                    self.serviceAddress.geoJson.coordinates = [(self.userLocation?.coordinate.longitude)!, (self.userLocation?.coordinate.latitude)!]

                    print("Placemark was nil")
                }
            } else {
                self.serviceAddress = Location.init()
                self.serviceAddress.geoJson.coordinates = [(self.userLocation?.coordinate.longitude)!, (self.userLocation?.coordinate.latitude)!]

                print("Unknown error")
            }
        })
    }
    
    func allowAddService() {
        DispatchQueue.main.async {
            if self.serviceId != "" {
                self.btnAdd.setTitle("Save", for: .normal)
                if self.serviceTitle != "" && self.serviceDesc != "" && self.serviceMedia.count > 0 && self.arrPrices.count > 0 {
                    self.btnAdd.backgroundColor = UIColor.getCustomBlueColor()
                    self.btnAdd.isUserInteractionEnabled = true
                } else {
                    self.btnAdd.backgroundColor = UIColor.lightGray
                    self.btnAdd.isUserInteractionEnabled = false
                }
            } else {
                if self.serviceTitle != "" && self.serviceDesc != "" && self.serviceMedia.count > 0 && self.arrPrices.count > 0 {
                    self.btnAdd.backgroundColor = UIColor.getCustomBlueColor()
                    self.btnAdd.isUserInteractionEnabled = true
                } else {
                    self.btnAdd.backgroundColor = UIColor.lightGray
                    self.btnAdd.isUserInteractionEnabled = false
                }
            }
        }
        
    }
    
    //*******************************************************//
    //             MARK: - Media Upload Method               //
    //*******************************************************//
    
    func uploadImageOnAWS(imgData: Data,image: UIImage,withCompletionHandler:@escaping (_ result:Bool) -> Void){
        PointtersHelper.sharedInstance.startLoader(view: view)
        
        let accessKey = kAWSCredentials.kAccessKey
        let secretKey = kAWSCredentials.kSecretKey
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
//        let remoteName = "service_pic\(mediaIndex)" + UIDevice.current.identifierForVendor!.uuidString
        
        let remoteName = "service_pic_\(mediaIndex)_\(NSDate().timeIntervalSince1970)"
        
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(remoteName)
        do {
            try imgData.write(to: fileURL)
        }
        catch {}
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = fileURL
        uploadRequest.key = remoteName
        uploadRequest.bucket = kAWSCredentials.kS3BucketName
        uploadRequest.contentType = "image/jpeg"
        uploadRequest.acl = .publicRead
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest).continueWith { (task: AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
                withCompletionHandler(false)
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                print("Uploaded to:\(String(describing: publicURL))")
                
                self.serviceMedia.insert(Media.init(type:"image", path:(publicURL?.absoluteString)!), at: self.serviceMedia.count)
                self.allowAddService()
                
                DispatchQueue.main.async {
                    withCompletionHandler(true)
                }
            }
            
            return nil
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    func uploadVideoOnAWS(outputURL: URL,withCompletionHandler:@escaping (_ result:Bool) -> Void){
        let accessKey = kAWSCredentials.kAccessKey
        let secretKey = kAWSCredentials.kSecretKey
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let remoteName = "service_video_\(mediaIndex)_\(NSDate().timeIntervalSince1970)"
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = outputURL
        uploadRequest.key = remoteName
        uploadRequest.bucket = kAWSCredentials.kS3BucketName
        uploadRequest.contentType = "video/mp4"
        uploadRequest.acl = .publicRead
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest).continueWith { (task: AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
                withCompletionHandler(false)
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                print("Uploaded to:\(String(describing: publicURL))")
                
                self.serviceMedia.insert(Media.init(type:"video", path:(publicURL?.absoluteString)!), at: self.serviceMedia.count)
                self.allowAddService()
                
                DispatchQueue.main.async {
                    withCompletionHandler(true)
                }
            }
            return nil
        }
    }
    
    func generateThumbnailForVideoAtURL(filePathLocal: NSString) -> UIImage? {
        
        let vidURL = NSURL(fileURLWithPath:filePathLocal as String)
        let asset = AVURLAsset(url: vidURL as URL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
        
    }
    
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnCancelTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func btnAddTapped(_ sender: Any) {
        var dictService = [String:Any]()
        dictService["tagline"] = serviceTitle
        dictService["description"] = serviceDesc
        dictService["category"] = serviceCategory.dict()
        
        var arrServicePrices = [[String:Any]]()
        for obj in arrPrices {
            arrServicePrices.append(obj.dict())
        }
        dictService["prices"] = arrServicePrices
        
        var arrServiceMedia = [[String:String]]()
        for media in serviceMedia {
            arrServiceMedia.append(media.dict())
        }
        dictService["media"] = arrServiceMedia
        dictService["fulfillmentMethod"] = serviceFulfillment.dict()

        if serviceAddress != Location.init() {
            var location =  [[String:Any]]()
            location.append(serviceAddress.dict())
            dictService["location"] = location
        }
        if serviceId != "" {
            callEditServiceApi(dictService: dictService)
        } else {
            callAddServiceApi(dictService: dictService)
        }
    }
    
    @IBAction func btnLibraryTapped(_ sender: Any) {
        if checkMediaAccess(type: 0) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            imagePickerController.mediaTypes = ["public.image", "public.movie"]
            imagePickerController.videoQuality = .type640x480
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCameraTapped(_ sender: Any) {
        if checkMediaAccess(type: 1) {
            DispatchQueue.main.async {
                let cameraPhotoController = UIImagePickerController()
                cameraPhotoController.sourceType = .camera
                cameraPhotoController.delegate = self
                cameraPhotoController.mediaTypes = ["public.image"]
                cameraPhotoController.videoQuality = .type640x480
                self.present(cameraPhotoController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func btnVideoTapped(_ sender: Any) {
        if checkMediaAccess(type: 1) {
            DispatchQueue.main.async {
                let cameraVideoController = UIImagePickerController()
                cameraVideoController.sourceType = .camera
                cameraVideoController.delegate = self
                cameraVideoController.mediaTypes = ["public.movie"]
                cameraVideoController.videoQuality = .type640x480
                self.present(cameraVideoController, animated: true, completion: nil)
            }
        }
    }
    
    @objc func btnCrossTapped(sender:UIButton) {
        if serviceMedia.count == 0 {
            return
        }
        
        let pageWidth = mediaCollectionView.frame.size.width
        let fractionalPage = mediaCollectionView.contentOffset.x/pageWidth
        let page = lroundf(Float(fractionalPage))
        
        serviceMedia.remove(at: page)
        mediaCollectionView.reloadData()
        
        if serviceMedia.count > 0 {
            if page == serviceMedia.count {
                mediaCollectionView.scrollToItem(at: IndexPath(row: page-1, section: 0), at: .right, animated: false)
            } else if page < serviceMedia.count {
                mediaCollectionView.scrollToItem(at: IndexPath(row: page, section: 0), at: .right, animated: false)
            }
        }
        allowAddService()
    }
    
    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    func callAddServiceApi(dictService: [String:Any]) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callPostService(dict:dictService, withCompletionHandler: { (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Service added successfully!", buttonTitles: ["OK"], viewController: self, completion: { (index) in
                        if index == 0 {
                            self.serviceTitle = ""
                            let tagView = self.view.viewWithTag(301) as! UITextView
                            tagView.text = ""
                            
                            self.serviceDesc = ""
                            let descView = self.view.viewWithTag(300) as! UITextView
                            descView.text = ""
                            
                            self.arrPrices.removeAll()
                            self.serviceMedia.removeAll()
                            
                            self.tableView.reloadData()
                            self.mediaCollectionView.reloadData()
                            self.allowAddService()
                            let post = responseDict["service"] as! [String:Any]
                            let serviceId = post["_id"] as! String
                            let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
                            let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
                            serviceDetailVC.serviceId = serviceId
                            self.navigationController?.pushViewController(serviceDetailVC, animated: true)
                        }
                    })
                }
                else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["Goto Setup", "Cancel"], viewController: self, completion: { (index) in
                    if index == 0 {
                        let storyboard = UIStoryboard(name: "Account", bundle: nil)
                        let paymentMethodVC = storyboard.instantiateViewController(withIdentifier: "HowPaidVC") as! HowPaidViewController
                        self.navigationController?.pushViewController(paymentMethodVC, animated: true)
                    }
                })
            }
        })
    }
    
    func callEditServiceApi(dictService: [String:Any]) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callEditService(serviceId: self.serviceId, dict:dictService, withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if result == true {
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Service updated successfully!", buttonTitles: ["OK"], viewController: self, completion: { (index) in
                        if index == 0 {
                            self.saveDelegate.onSaveService()
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
                else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Add service failed", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
        })
    }
    
    func callDeleteServiceApi(serviceId: String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callDeleteService(serviceId: self.serviceId, withCompletionHandler: { (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if result == true {
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Service deleted successfully!", buttonTitles: ["OK"], viewController: self, completion: { (index) in
                        if index == 0 {
                            let viewControllers = self.navigationController?.viewControllers
                            if self.deleteDelegate != nil {
                                self.deleteDelegate.onClickDeleteService(index: self.deleteIndex)
                            }
                            self.navigationController?.popToViewController(viewControllers![(viewControllers?.count)! - 3 ], animated: true)
                        }
                    })
                }
                else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
        })
    }

    func callSellerEligabilityAPI() {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callSellerEligability(withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    print(responseDict)
                    
                    self.numStores = responseDict["numStores"] as! Int
                    self.tableView.reloadData()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        })
    }
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// AddPriceDelegate
extension AddServiceViewController:AddPriceDelegate {
    func updatePricingOption(price:Price, index:Int) {
        if index == -1 {
            arrPrices.insert(price, at:arrPrices.count)
        } else {
            arrPrices[index] = price
        }

        allowAddService()
        tableView.reloadSections(IndexSet(integer: 2), with: .none)
    }
    
    func removePricingOption(index:Int) {
        arrPrices.remove(at:index)
        allowAddService()
        tableView.reloadSections(IndexSet(integer: 2), with: .none)
    }
}

extension AddServiceViewController : SettingRadiusDelegate {
    func updateRadius(radius: Int) {
        self.serviceFulfillment.localServiceRadius = radius
    }
    func cancelRadius() {
        deliveryStatus = 0
        tableView.reloadSections(IndexSet(integer: 3), with: .none)
    }
}

extension AddServiceViewController : ShippingDetailDelegate {
    func updateDetail(addressDict: [String : Any], measurementDict: [String : Any]) {
        serviceFulfillment.shipmentAddress = ShipAddress.init(dict: addressDict)
        serviceFulfillment.shipmentParcel = ShipParcel.init(dict: measurementDict)
    }
}

// AAPlayerDelegate
extension AddServiceViewController:AAPlayerDelegate {
    func callBackDownloadDidFinish(_ status: playerItemStatus?) {
        let status:playerItemStatus = status!
        switch status {
        case .readyToPlay:
            break
        case .failed:
            break
        default:
            break
        }
    }
}

// AAPlayerModeDelegate
extension AddServiceViewController: AAPlayerModeDelegate {
    func callBackDownloadDidModeChange(_ status:Bool, tag:Int) {
        if serviceMedia[tag].fileName != "" {
            let fullScreenVC = storyboard?.instantiateViewController(withIdentifier: "FullScreenVC") as! FullScreenViewController
            fullScreenVC.videoURL = serviceMedia[tag].fileName
            navigationController?.pushViewController(fullScreenVC, animated: true)
        }
    }
}

// UITextViewDelegate
extension AddServiceViewController: UITextViewDelegate {
    func addToolBar(textView: UITextView) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textView.delegate = self
        textView.inputAccessoryView = toolBar
    }
    
    @objc func donePressed() {
        view.endEditing(true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let originText: NSString = (textView.text ?? "") as NSString
        let resultString = originText.replacingCharacters(in: range, with: text as String)
        if textView.tag == 301{
            serviceTitle = resultString
        }else{
            serviceDesc = resultString
        }
        allowAddService()
        return true
    }
}

// UIImagePickerControllerDelegate
extension AddServiceViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaURL = info[UIImagePickerControllerMediaURL] as? NSURL
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == "public.image" {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage?
            let data : Data = UIImageJPEGRepresentation(image!, 0.4)!
            
            self.uploadImageOnAWS(imgData: data,image: image!, withCompletionHandler : { (result) in
                
                DispatchQueue.main.async {
                    PointtersHelper.sharedInstance.stopLoader()
                }
                
                if result == true {
                    self.mediaIndex = self.mediaIndex + 1
                    self.mediaCollectionView.reloadData()
                }
            })
        }
        else if mediaType == "public.movie" {
            PointtersHelper.sharedInstance.startLoader(view: view)
            guard NSData(contentsOf: mediaURL! as URL) != nil else {
                return
            }
            
            let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
            compressVideo(inputURL:mediaURL! as URL, outputURL: compressedURL) { (exportSession) in
                guard let session = exportSession else {
                    return
                }
                
                switch session.status {
                case .unknown:
                    break
                case .waiting:
                    break
                case .exporting:
                    break
                case .completed:
                    guard NSData(contentsOf: compressedURL) != nil else {
                        return
                    }
                    
                    self.uploadVideoOnAWS(outputURL: compressedURL, withCompletionHandler : { (result) in
                        
                        DispatchQueue.main.async {
                            PointtersHelper.sharedInstance.stopLoader()
                        }
                        
                        self.mediaIndex = self.mediaIndex + 1
                        self.mediaCollectionView.reloadData()
                    })
                    break
                case .failed:
                    break
                case .cancelled:
                    break
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

// UICollectionViewDataSource
extension AddServiceViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return serviceMedia.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgsCCell", for: indexPath) as! MediaCollectionCell
        
        if indexPath.row < serviceMedia.count {
            let media = serviceMedia[indexPath.row]
            
            if media.mediaType == "image" {
                cell.playerView.isHidden = true
                cell.photoView.isHidden = false
                cell.photoView.layer.cornerRadius = 7.0
                cell.photoView.layer.masksToBounds = true
                
                if media.fileName != "" {
                    cell.photoView.sd_imageTransition = .fade
                    cell.photoView.sd_setImage(with: URL(string:media.fileName)!, placeholderImage: UIImage(named:"photo_placeholder"), options: .refreshCached)
                } else {
                    cell.photoView.image = UIImage(named:"photo_placeholder")
                }
            } else {
                cell.photoView.isHidden = false
                cell.photoView.image = nil
                cell.photoView.layer.backgroundColor = UIColor.init(hex: 0x4CA9DE).cgColor
                cell.playerView.isHidden = false
                cell.playerView.layer.cornerRadius = 7.0
                cell.playerView.layer.masksToBounds = true
                
                cell.playerView.delegate = self
                cell.playerView.delegate2 = self
                cell.playerView.tag = indexPath.row

                if media.fileName != "" {
                    let thumbImage = generateThumbnailForVideoAtURL(filePathLocal: media.fileName as NSString)
                    cell.photoView.image = thumbImage
                    cell.playerView.playVideo(media.fileName)
                }
            }
            
            cell.btnCross.isHidden = false
            cell.btnCross.addTarget(self, action: #selector(btnCrossTapped(sender:)), for: .touchUpInside)
        } else {
            cell.photoView.isHidden = true
            cell.playerView.isHidden = true
            cell.btnCross.isHidden = true
        }
        
        return cell
    }
}

// UICollectionViewDelegateFlowLayout
extension AddServiceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize = CGSize(width: CGFloat(0), height: 0)
        
        let height = collectionView.frame.height
        let width = collectionView.frame.width/3.0
        cellSize = CGSize(width: CGFloat(width), height: height)
        
        return cellSize
    }
}

// UICollectionViewDelegate
extension AddServiceViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = mediaCollectionView.cellForItem(at:indexPath) as? MediaCollectionCell
        cell?.playerView.startPlay()
    }
}

// UITableViewDataSource
extension AddServiceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return 1
            case 1: return 1
            case 2: return arrPrices.count + 1
            case 3: return 4
            case 4: return 1
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            case 0:
                return 60
            case 1:
                return 85.0
            case 2:
                return 44.0
            case 3:
                switch indexPath.row {
                    case 0:
                        return 44.0
                    case 1:
                        return 0.0                                      //hide shipment option
                    case 2,3: return 60.0
                    default:  return 0.0
                }
            case 4:
                return (self.serviceId != "") ? 50 : 0
            default:
                return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground

        let headerLabel = UILabel(frame: CGRect(x: 15, y: 25, width: tableView.bounds.size.width - 30, height: 20))
        headerLabel.font = UIFont(name: "Helvetica", size: 14)
        headerLabel.textColor = UIColor.getCustomGrayTextColor()
        
        switch section {
            case 0:
                headerLabel.text = "TAGLINE"
            case 1:
                headerLabel.text = "SERVICE DESCRIPTION"
                break
            case 2:
                headerLabel.text = "PRICING"
                break
            case 3:
                headerLabel.text = "DELIVERY METHOD"
                break
            default:
                break
        }
        
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 4 {
            return 10.0
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell") as! AddServiceCell
            cell.tagTitle.text = self.serviceTitle
            cell.tagTitle.tag = 301
            addToolBar(textView: cell.tagTitle)
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "descCell") as! AddServiceCell
            cell.tfDesc.text = self.serviceDesc
            cell.tfDesc.tag = 300
            addToolBar(textView: cell.tfDesc)
            return cell
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "addPriceCell") as! AddServiceCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "priceCell") as! AddServiceCell
                let result = arrPrices[indexPath.row-1]
                let strSymbol = (result.currencySymbol != "") ? result.currencySymbol : "$"
                
                var strUnit = (result.timeUnitOfMeasure != "") ? result.timeUnitOfMeasure : "hour"
                if result.time > 1 {
                    strUnit = strUnit + "s"
                }
                cell.lblPrice.text = strSymbol + String(format:"%.2f", result.price) + " per " + String(format:"%d", result.time) + " " + strUnit
                
                return cell
            }
        }
        else if indexPath.section == 3 {
            if indexPath.row < 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "onlineCell") as! AddServiceCell
                cell.lblTitle.text = kDeliveryMethodItems[indexPath.row]
                let img1 = (indexPath.row == deliveryStatus) ? "icon-checkbox-blue" : "icon-checkbox-normal"
                cell.imgCheck.image = UIImage(named: img1)
                return cell
            } else if indexPath.row == 2 || indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "localCell") as! AddServiceCell
                cell.lblTitle.text = kDeliveryMethodItems[indexPath.row]
                if indexPath.row == 2 {
                    cell.lblSubTitle.text = "anywhere in the city you service"
                    let img2 = (indexPath.row == deliveryStatus) ? "icon-checkbox-blue" : "icon-checkbox-normal"
                    cell.imgCheck.image = UIImage(named: img2)
                }
                if indexPath.row == 3 {
                    if self.numStores != 0 {
                        cell.lblSubTitle.text = ""
                        let img2 = (indexPath.row == deliveryStatus) ? "icon-checkbox-blue" : "icon-checkbox-normal"
                        cell.imgCheck.image = UIImage(named: img2)
                    } else {
                        cell.lblSubTitle.text = "Add Store Location"
                        cell.imgCheck.setImageColor(color: UIColor.darkGray)
                    }
                }                         
                return cell
            } else {
                return UITableViewCell()
            }
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deleteCell") as! AddServiceCell
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
}

// UITableViewDelegate
extension AddServiceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let priceOptionVC = self.storyboard?.instantiateViewController(withIdentifier: "PriceOptionVC") as! PriceOptionViewController
            
            if indexPath.row == 0 {
                priceOptionVC.editType = false
                priceOptionVC.editIndex = -1
                priceOptionVC.updateDelegate = self
                present(priceOptionVC, animated: true, completion: nil)
            } else {
                priceOptionVC.editType = true
                priceOptionVC.editIndex = indexPath.row - 1
                priceOptionVC.price = arrPrices[indexPath.row - 1]
                priceOptionVC.updateDelegate = self
                navigationController?.pushViewController(priceOptionVC, animated: true)
            }
        } else if indexPath.section == 3 {
            setDeliveryMethod(index: indexPath.row)
        } else if indexPath.section == 4 {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("Confirm", message: "Are you sure you want to delete this service?", buttonTitles: ["Delete", "Cancel"], viewController: self) { (index) in
                if index == 0 {
                    self.callDeleteServiceApi(serviceId: self.serviceId)
                }
            }
        }
    }
}

