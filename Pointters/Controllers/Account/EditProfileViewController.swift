//
//  EditProfileViewController.swift
//  Pointters
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import AVFoundation
import AWSS3
import AWSCore
import CoreLocation
import LNICoverFlowLayout

protocol EditProfileDelegate {
    func onSuccessSave()
}

class EditProfileViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var tableView: TPKeyboardAvoidingTableView!
    @IBOutlet var mediaHeaderView: UIView!
    @IBOutlet var mediaCollectionView: UICollectionView!
    @IBOutlet var mediaCoverFlowLayout: LNICoverFlowLayout!
    @IBOutlet var btnSave: UIButton!
    @IBOutlet var labelTitle: UILabel!
    
    var delegate: EditProfileDelegate!

    var userLocation: CLLocation?
    
    var userProfile = Profile.init()
    var backgroundMedia = [Media]()
    
    var userId = ""
    var userFirstName = ""
    var userLastName = ""
    var userProfilePic = ""
    var userDesc = ""
    var userCompany = ""
    var userEducation = ""
    var userLicense = ""
    var userInsurance = ""
    var userAwards = ""
    var userPhone = ""
    var txtAddress = ""
    var userAddress = Location.init()
    
    var mediaIndex = 0
    let txtOffsetIndex = 10
    var picType = false
    var isLoading = false
    var isMyProfile = false
    
    var originalItemSize = CGSize.zero
    var originalCollectionViewSize = CGSize.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initData()
        
        if userId == UserCache.sharedInstance.getAccountData().id {
            isMyProfile = true
            self.btnSave.isHidden = false
            self.labelTitle.text = "Edit Profile"
        } else {
            self.btnSave.isHidden = true
            self.labelTitle.text = "Profile Details"
        }        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mediaCoverFlowLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

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
        
        if page >= backgroundMedia.count && backgroundMedia.count > 0 {
            mediaCollectionView.scrollToItem(at: IndexPath(row: backgroundMedia.count-1, section: 0), at: .right, animated: true)
        }
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        
        originalItemSize = mediaCoverFlowLayout.itemSize
        originalCollectionViewSize = mediaCollectionView.bounds.size
    }
    
    func initData() {
        let lat:Double = UserCache.sharedInstance.getUserLatitude()!
        let lng:Double = UserCache.sharedInstance.getUserLongitude()!
        userLocation = CLLocation(latitude: lat, longitude: lng)
        
        if userId == "" {
            userId = UserCache.sharedInstance.getAccountData().id
            isMyProfile = true
        }
        callGetUserProfileApi(userId: userId)
    }
    
    func checkMediaAccess(type:Int) -> Bool {
        var flag = false
        
        if backgroundMedia.count >= 5 {
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
    
    fileprivate func setInitialValues() {
        // Setting some nice defaults, ignore if you don't like them
        mediaCoverFlowLayout.maxCoverDegree = 1.0
        mediaCoverFlowLayout.coverDensity = 0.065
        mediaCoverFlowLayout.minCoverScale = 0.9
        mediaCoverFlowLayout.minCoverOpacity = 1
    }
    
    func getUserInfo() {
        userFirstName = userProfile.firstName
        userLastName = userProfile.lastName
        userProfilePic = userProfile.profilePic
        userDesc = userProfile.desc
        userCompany = userProfile.companyName
        userEducation = userProfile.education
        userLicense = userProfile.license
        userInsurance = userProfile.insurance
        userAwards = userProfile.awards
        userPhone = userProfile.phone
        backgroundMedia = userProfile.profileBgMedia
        mediaIndex = backgroundMedia.count + 1
        if backgroundMedia.count == 0 {
            mediaHeaderView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 105)
        }else {
            mediaHeaderView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: (315/667.0) * UIScreen.main.bounds.height)
        }
        
        tableView.tableHeaderView = mediaHeaderView
        if !isMyProfile {
            tableView.tableHeaderView = nil
        }
        
        userAddress = userProfile.location
        showLocation(code: userAddress.postalCode, city: userAddress.city, state: userAddress.state)
        
    }
    
    func showLocation(code:String?, city:String?, state:String?) {
        var strLocation = ""
        
        if code != nil && code != "" {
            strLocation = strLocation + code! + ", "
        }
        if city != nil && city != "" {
            strLocation = strLocation + city! + " "
        }
        if state != nil && state != "" {
            strLocation = strLocation + state!
        }
        
        if strLocation != "" {
            txtAddress = strLocation
        } else {
            txtAddress = "Unknown address"
        }
    }
    
    func getCurrentLocation() {
        PointtersHelper.sharedInstance.startLoader(view: view)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation!, completionHandler: {
            placemarks, error in
            PointtersHelper.sharedInstance.stopLoader()
            self.isLoading = false
            
            if let err = error {
                self.userAddress = Location.init()
                self.txtAddress = "Unknown address"
                self.tableView.reloadRows(at: [IndexPath(row:kUserProfileItems.count+1, section: 0)], with: .none)
                print(err.localizedDescription)
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    print(placemark)
                    self.userAddress.city = placemark.locality ?? "NA"
                    self.userAddress.country = placemark.country ?? "NA"
                    self.userAddress.postalCode = placemark.postalCode ?? "NA"
                    self.userAddress.province = placemark.subAdministrativeArea ?? "NA"
                    self.userAddress.state = placemark.administrativeArea ?? "NA"
                    self.userAddress.geoJson.coordinates = [(self.userLocation?.coordinate.longitude)!, (self.userLocation?.coordinate.latitude)!]
                    self.userAddress.geoJson.type = "Point"
                    self.showLocation(code: self.userAddress.postalCode, city: self.userAddress.city, state: self.userAddress.state)
                    self.tableView.reloadRows(at: [IndexPath(row:kUserProfileItems.count+1, section: 0)], with: .none)
                } else {
                    self.userAddress = Location.init()
                    self.txtAddress = "Unknown address"
                    self.tableView.reloadRows(at: [IndexPath(row:kUserProfileItems.count+1, section: 0)], with: .none)
                    print("Placemark was nil")
                }
            } else {
                self.userAddress = Location.init()
                self.txtAddress = "Unknown address"
                self.tableView.reloadRows(at: [IndexPath(row:kUserProfileItems.count+1, section: 0)], with: .none)
                print("Unknown error")
            }
        })
    }
    
    func allowSave() -> Bool {
        if userProfilePic != "" && userFirstName != "" && userLastName != ""{
            return true
        } else {
            return false
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
        
        var remoteName = ""
        if picType {
            remoteName = "profile_pic_" + userFirstName + "_\(NSDate().timeIntervalSince1970)"
        } else {
            remoteName = "profile_pic_\(mediaIndex)_\(NSDate().timeIntervalSince1970)"
        }
        
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
                
                if self.picType {
                    self.userProfilePic = (publicURL?.absoluteString)!
                } else {
                    self.backgroundMedia.insert(Media.init(type:"image", path:(publicURL?.absoluteString)!), at: self.backgroundMedia.count)
                }
                
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
        
        let remoteName = "profile_video_\(mediaIndex)_\(NSDate().timeIntervalSince1970)"
        
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
                
                if !self.picType {
                    self.backgroundMedia.insert(Media.init(type:"video", path:(publicURL?.absoluteString)!), at: self.backgroundMedia.count)
                }
                
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
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSaveTapped(_ sender: Any) {
        if allowSave() {
            var dictUser = [String:Any]()
            dictUser["firstName"] = userFirstName
            dictUser["lastName"] = userLastName
            dictUser["profilePic"] = userProfilePic
            
            if userDesc != ""           { dictUser["description"] = userDesc }
            if userCompany != ""        { dictUser["companyName"] = userCompany }
            if userEducation != ""      { dictUser["education"] = userEducation }
            if userInsurance != ""      { dictUser["insurance"] = userInsurance }
            if userLicense != ""        { dictUser["license"] = userLicense }
            if userAwards != ""         { dictUser["awards"] = userAwards }
            if userPhone != ""          { dictUser["phone"] = userPhone }
            
            var arrBackgroundMedia = [[String:String]]()
            for obj in backgroundMedia {
                var dict = [String:String]()
                dict["mediaType"] = obj.mediaType
                dict["fileName"] = obj.fileName
                arrBackgroundMedia.append(dict)
            }
//            if arrBackgroundMedia.count > 0 {
//                dictUser["profileBackgroundMedia"] = arrBackgroundMedia
//            }
            
            dictUser["profileBackgroundMedia"] = arrBackgroundMedia
            
            if userAddress != Location.init() {
                dictUser["location"] = userAddress.dict()
            }
            
            dictUser["completedRegistration"] = true
            dictUser["completedRegistrationDate"] = PointtersHelper.sharedInstance.getCurrentDateTime()
            
            callSaveUserProfileApi(dictUser: dictUser)
        } else {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Enter your full name and profile picture!", buttonTitles: ["OK"], viewController: self, completion: nil)
        }
    }
    
    @IBAction func btnLibraryTapped(_ sender: Any) {
        if checkMediaAccess(type: 0) {
            picType = false
            
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
            picType = false
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
            picType = false
            
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
    
    @objc func btnUserPicTapped(sender:UIButton) {
        if checkMediaAccess(type: 0) {
            picType = true
            
            let userPickerController = UIImagePickerController()
            userPickerController.sourceType = .photoLibrary
            userPickerController.delegate = self
            userPickerController.mediaTypes = ["public.image"]
            userPickerController.videoQuality = .type640x480
            present(userPickerController, animated: true, completion: nil)
        }
    }
    
    @objc func btnCrossTapped(sender:UIButton) {
        if backgroundMedia.count == 0 {
            return
        }
        
        let pageWidth = mediaCollectionView.frame.size.width
        let fractionalPage = mediaCollectionView.contentOffset.x/pageWidth
        let page = lroundf(Float(fractionalPage))
        
        backgroundMedia.remove(at: page)
        if backgroundMedia.count == 0 {
            mediaHeaderView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 105)
            self.tableView.tableHeaderView = self.mediaHeaderView
        }
        mediaCollectionView.reloadData()
        
        if backgroundMedia.count > 0 {
            if page == backgroundMedia.count {
                mediaCollectionView.scrollToItem(at: IndexPath(row: page-1, section: 0), at: .right, animated: false)
            } else if page < backgroundMedia.count {
                mediaCollectionView.scrollToItem(at: IndexPath(row: page, section: 0), at: .right, animated: false)
            }
        }
    }
    
    //*******************************************************//
    //                 MARK: - Call API Method               //
    //*******************************************************//
    
    func callGetUserProfileApi(userId: String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetUserProfile(userId: userId, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    if let dict = responseDict["result"] as? [String:Any] {
                        self.userProfile = Profile.init(dict: dict)
                        self.getUserInfo()
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Can't find user profile!", buttonTitles: ["OK"], viewController: self, completion: { (index) in
                        if index == 0 {
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            }
            else {
                print(response.error ?? "profile failure")
            }
            
            self.mediaCollectionView.reloadData()
            self.tableView.reloadData()
        })
    }
  
    func callSaveUserProfileApi(dictUser: [String:Any]) {
        print(dictUser)
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callUpdateUser(dict: dictUser, withCompletionHandler:{ (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    let userDict = responseDict["user"] as! [String:Any]
                    self.parseAPIResponse(userDict : userDict)
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Saved successfully!", buttonTitles: ["OK"], viewController: self, completion: { (index) in
                        if index == 0 {
                            if self.delegate != nil {
                                self.delegate.onSuccessSave()
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        })
    }
    func parseAPIResponse(userDict:[String:Any]) {
        let user = User()
        
        if let val = userDict["_id"] {
            user.id = val as! String
        }
        if let val = userDict["firstName"] {
            user.firstName = val as! String
        }
        if let val = userDict["lastName"] {
            user.lastName = val as! String
        }
        if let val = userDict["birthday"] {
            user.birthday = val as! String
        }
        if let val = userDict["profilePic"] {
            user.profilePic = val as! String
        }
        if let val = userDict["profileBackgroundMedia"] {
            user.profileMedia = val as! [[String : String]]
        }
        
        if let val = userDict["email"] {
            user.email = val as! String
        }
        if let val = userDict["phone"] {
            user.phone = val as! String
        }
        if let val = userDict["verified"] {
            user.verified = val as! Bool
        }
        if let val = userDict["description"] {
            user.desc = val as! String
        }
        if let val = userDict["companyName"] {
            user.companyName = val as! String
        }
        
        if let val = userDict["education"] {
            user.education = val as! String
        }
        if let val = userDict["license"] {
            user.license = val as! String
        }
        if let val = userDict["insurance"] {
            user.insurance = val as! String
        }
        if let val = userDict["awards"] {
            user.awards = val as! String
        }
        
        if let val = userDict["isAdmin"] {
            user.isAdmin = val as! Bool
        }
        if let val = userDict["isActive"] {
            user.isActive = val as! Bool
        }
        
        UserCache.sharedInstance.setAccountData(userData: user)
    }
}

//*******************************************************//
//            MARK: - Extensions Methods                 //
//*******************************************************//

// AAPlayerDelegate
extension EditProfileViewController:AAPlayerDelegate {
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
extension EditProfileViewController: AAPlayerModeDelegate {
    func callBackDownloadDidModeChange(_ status:Bool, tag:Int) {
        if backgroundMedia[tag].fileName != "" {
            let fullScreenVC = storyboard?.instantiateViewController(withIdentifier: "FullScreenVC") as! FullScreenViewController
            fullScreenVC.videoURL = backgroundMedia[tag].fileName
            navigationController?.pushViewController(fullScreenVC, animated: true)
        }
    }
}

// UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typeCasteToStringFirst = textField.text as NSString?
        let newString = typeCasteToStringFirst?.replacingCharacters(in: range, with: string)
        
        if textField.tag == txtOffsetIndex+1 {
            userFirstName = newString!
            tableView.reloadRows(at: [IndexPath(row:0, section:0)], with: .none)
        } else if textField.tag == txtOffsetIndex+2 {
            userLastName = newString!
            tableView.reloadRows(at: [IndexPath(row:0, section:0)], with: .none)
        } else if textField.tag == txtOffsetIndex+4 {
            userCompany = newString!
        } else if textField.tag == txtOffsetIndex+5 {
            userEducation = newString!
        } else if textField.tag == txtOffsetIndex+6 {
            userLicense = newString!
        } else if textField.tag == txtOffsetIndex+7 {
            userInsurance = newString!
        } else if textField.tag == txtOffsetIndex+8 {
            userAwards = newString!
        } else if textField.tag == txtOffsetIndex+9 {
            userPhone = newString!
        }
        
        return true
    }
}

// UITextViewDelegate
extension EditProfileViewController: UITextViewDelegate {
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
        userDesc = resultString
        return true
    }
}

// UIImagePickerControllerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
                    if !self.picType {
                        self.mediaIndex = self.mediaIndex + 1
                    }
                    self.mediaHeaderView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: (315/667.0) * UIScreen.main.bounds.height)
                    self.tableView.tableHeaderView = self.mediaHeaderView
                    self.mediaCollectionView.reloadData()
                    self.tableView.reloadData()
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
                            
                            if !self.picType {
                                self.mediaIndex = self.mediaIndex + 1
                            }
                            self.mediaHeaderView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: (315/667.0) * UIScreen.main.bounds.height)
                            self.tableView.tableHeaderView = self.mediaHeaderView
                            self.mediaCollectionView.reloadData()
                            self.tableView.reloadData()
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
extension EditProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return backgroundMedia.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgsCCell", for: indexPath) as! MediaCollectionCell

        if indexPath.row < backgroundMedia.count {
            let media = backgroundMedia[indexPath.row]
            
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
extension EditProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize = CGSize(width: CGFloat(0), height: 0)
        
        let height = collectionView.frame.height
        let width = collectionView.frame.width/3.0
        cellSize = CGSize(width: CGFloat(width), height: height)
        
        return cellSize
    }
}

// UICollectionViewDelegate
extension EditProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = mediaCollectionView.cellForItem(at:indexPath) as? MediaCollectionCell
        cell?.playerView.startPlay()
    }
}

// UITableViewDataSource
extension EditProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kUserProfileItems.count + 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 76.0
        } else if indexPath.row == 3 {
            return 122.0
        } else if indexPath.row == kUserProfileItems.count+1 {
            return 44.0
        } else {
            return 60.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userImgCell") as! ProfileCell
            
            cell.imgUser.layer.cornerRadius = cell.imgUser.frame.height/2
            cell.imgUser.layer.masksToBounds = true
            cell.btnPic.layer.cornerRadius = cell.btnPic.frame.height/2
            cell.btnPic.layer.masksToBounds = true
            
            if userProfilePic != "" {
                cell.imgUser.sd_imageTransition = .fade
                cell.imgUser.sd_setImage(with: URL(string:userProfilePic), placeholderImage: UIImage(named: "user_avatar_placeholder"), options: .refreshCached)
            } else {
                cell.imgUser.image = UIImage(named: "user_avatar_placeholder")
            }
            if !isMyProfile {
                cell.btnPic.isHidden = true
            } else {
                cell.btnPic.isHidden = false
            }
            cell.btnPic.addTarget(self, action: #selector(btnUserPicTapped(sender:)), for: .touchUpInside)
            
            cell.lblName.text = userFirstName + " " + userLastName
            cell.lblVerfied.text = (userProfile.verified) ? "Verified" : "Not verified"
            
            return cell
        } else if indexPath.row == kUserProfileItems.count+1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell") as! ProfileCell
            cell.lblLocation.text = txtAddress
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelViewCell") as! ProfileCell
            cell.tfDesc.placeholder = kUserProfileItems[indexPath.row - 1]
            cell.tfDesc.floatingLabel.backgroundColor = UIColor.white
            cell.tfDesc.text = userDesc
            if isMyProfile {
                cell.tfDesc.isUserInteractionEnabled = true
            } else {
                cell.tfDesc.isUserInteractionEnabled = false
            }
            addToolBar(textView: cell.tfDesc)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelFieldCell") as! ProfileCell
            cell.tfTitle.placeholder = kUserProfileItems[indexPath.row - 1]
            cell.tfTitle.tag = txtOffsetIndex + indexPath.row
            
            if isMyProfile {
                cell.tfTitle.isUserInteractionEnabled = true
            } else {
                cell.tfTitle.isUserInteractionEnabled = false
            }
            
            switch indexPath.row {
                case 1:
                    cell.tfTitle.text = userFirstName
                    cell.tfTitle.keyboardType = .default
                    break
                case 2:
                    cell.tfTitle.text = userLastName
                    cell.tfTitle.keyboardType = .default
                    break
                case 4:
                    cell.tfTitle.text = userCompany
                    cell.tfTitle.keyboardType = .default
                    break
                case 5:
                    cell.tfTitle.text = userEducation
                    cell.tfTitle.keyboardType = .default
                    break
                case 6:
                    cell.tfTitle.text = userLicense
                    cell.tfTitle.keyboardType = .default
                    break
                case 7:
                    cell.tfTitle.text = userInsurance
                    cell.tfTitle.keyboardType = .default
                    break
                case 8:
                    cell.tfTitle.text = userAwards
                    cell.tfTitle.keyboardType = .default
                    break
                case 9:
                    cell.tfTitle.text = userPhone
                    cell.tfTitle.keyboardType = .phonePad
                    break
                default:
                    break
            }
            
            return cell
        }
    }
}

// UITableViewDelegate
extension EditProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isMyProfile {
            if indexPath.row == kUserProfileItems.count+1 && !isLoading {
                isLoading = true
                getCurrentLocation()
            }
        }
    }
}
