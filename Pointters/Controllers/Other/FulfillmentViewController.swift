//
//  FulfillmentViewController.swift
//  Pointters
//
//  Created by super on 5/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import MobileCoreServices
import AWSS3
import AWSCore
import AVFoundation
import AVKit
import MediaPlayer
import Photos
import UserNotifications
import Paystack

class FulfillmentViewController: UIViewController {

    @IBOutlet weak var consNavViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
        
    let actionTag = 101
    let changelocationTag = 102
    let cancelOrderTag = 103
    let changeScheduleTag = 104
    
    var orderId = ""
    var loginUserId = ""
    var orderFulfillment = OrderFulfillment.init()
        
    var isBuyer = true
    
    var descHeight : CGFloat = 65.0
    var selectDescFlag = false
    
    var timelineUnit = "Hours"
    var timelineAmount = "0"
    
    var fromCheckout = false
    
    var selectedData: Data!
    var uploadUrl = ""
    
    var extentions = ["pdf", "doc", "docx", "ppt", "pptx", "xls", "xlsx", "zip", "jpg", "png", "jpeg", "mov", "mp4", "avi"]
    
    var player:AVPlayer!
    let playerController = AVPlayerViewController()
    
    var isRefreshingPage = false
    
    var isNotOnline: Bool = false
    var displayPaypalSection: Bool = false
    var displayPaystackSection: Bool = false
    var buyerCountry = ""
    var sellerCountry = ""
    var card_number = ""
    var card_expiry_year: UInt!
    var card_expiry_month: UInt!
    var card_cvv = ""
    var paystackdone: Bool = false
    var paystack_access_code = ""
    var paystack_authorization_url = ""
    var paywithPaypal: Bool = false
    var paywithPaystack: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginUserId = UserCache.sharedInstance.getAccountData().id
        initUI()
        PointtersHelper.sharedInstance.sendAnalyticsToFirebase(event: kFirebaseEvents.screenOrderFulfillment)
//        self.popupPayment(controller: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setNotificationDelegate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.addNotificationReceiver()
    }

    func addNotificationReceiver() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
    }
    
    @objc func refreshPageForNotification() {
        self.callGetOrderFulfillmentAPI(orderId: self.orderId)
    }
    
    func initUI(){
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavViewHeight.constant = 85.0
        } else {
            consNavViewHeight.constant = 64.0
        }
        callGetOrderFulfillmentAPI(orderId: self.orderId)
    }
         
    //MARK:upload files to sw3
    
    func uploadImageOnAWS(fileExtension: String) {
        let accessKey = kAWSCredentials.kAccessKey
        let secretKey = kAWSCredentials.kSecretKey
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let remoteName = "order_file_deliver_" + self.orderFulfillment.id + "_filenumber_\(self.orderFulfillment.sellerDeliveredMedia.count)_" + String.random(length: 5)
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(remoteName)
        do {
            try selectedData?.write(to: fileURL)
        }
        catch {}
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = fileURL
        uploadRequest.key = remoteName
        uploadRequest.bucket = kAWSCredentials.kS3BucketName
        uploadRequest.contentType = PointtersHelper.sharedInstance.generateAWSContentType(withExtension: fileExtension)
        uploadRequest.acl = .publicRead
        
        let url = AWSS3.default().configuration.endpoint.url
        let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
        self.uploadUrl = (publicURL?.absoluteString)!
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest).continueWith { (task: AWSTask<AnyObject>) -> Any? in
            DispatchQueue.main.async {
                PointtersHelper.sharedInstance.stopLoader()
            }
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                print("Uploaded to:\(String(describing: publicURL))")
                var dict = [String: Any]()
                dict["mediaType"] = PointtersHelper.sharedInstance.generateMediaType(withExtension: fileExtension)
                dict["fileName"] = publicURL?.absoluteString
                dict["thumbnail"] = publicURL?.absoluteString
                dict["fileExtension"] = fileExtension
                var params = [String: Any]()
                params["sellerDeliveredMedia"] = [dict]
                self.uploadSellerDeliverMedia(params: params)
            }
            return nil
        }
        
    }
    
    func downloadFileFromS3(media: Media) {
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        let accessKey = kAWSCredentials.kAccessKey
        let secretKey = kAWSCredentials.kSecretKey
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        let downloadedFilePath = NSTemporaryDirectory().appendingFormat("downloaded-\(media.id).\(media.fileExtension)")
        let downloadedFileURL = URL.init(fileURLWithPath: downloadedFilePath)
        
        let downloadRequest = AWSS3TransferManagerDownloadRequest()!
        downloadRequest.key = media.fileName.replacingOccurrences(of: kAWSCredentials.kS3FullBucketUrl, with: "")
        downloadRequest.bucket = kAWSCredentials.kS3BucketName
        downloadRequest.downloadingFileURL = downloadedFileURL
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.download(downloadRequest).continueWith { (task: AWSTask<AnyObject>) -> Any? in
            if let error = task.error {
                print("Download failed with error: (\(error.localizedDescription))")
                DispatchQueue.main.async {
                    PointtersHelper.sharedInstance.stopLoader()
                }
            }
            
            if task.result != nil {
                let fileManager = FileManager.default
                let directory : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let destinationPath = directory.appendingFormat("/Pointters_delivered_file_\(media.id).\(media.fileExtension)")
                let destinationURL = URL.init(fileURLWithPath: destinationPath)
                do {
                    try fileManager.removeItem(at: destinationURL)
                } catch {
                    print("Error Removing Item At \(destinationURL.path)")
                }
                do {
                    try fileManager.copyItem(at: downloadedFileURL, to: destinationURL)
                } catch {
                    //This is line always printing. my try statement always throwing.
                    print("Error Copying Item from \(downloadedFileURL.path) to \(destinationURL.path)")
                }
                DispatchQueue.main.async {
                    PointtersHelper.sharedInstance.stopLoader()
                }
            }
            return nil
        }
        
    }
    
    func isValidFileExtension(fileExtension: String) -> Bool {
        if extentions.contains(fileExtension) {
            return true
        }
        return false
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        if self.fromCheckout{
            let viewControllers = self.navigationController?.viewControllers
            self.navigationController?.popToViewController(viewControllers![viewControllers!.count-3], animated: true)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func btnCallTapped(sender: UIButton) {
        PointtersHelper.sharedInstance.callByPhone(phone: self.orderFulfillment.contact.phone, ctrl: self)
    }
    
    @objc func btnAction(sender: UIButton) {
        print("sender tag is \(sender.tag)")
        if sender.tag == changelocationTag{
            let storyboard = UIStoryboard(name: "Account", bundle: nil)
            let newAddressVC = storyboard.instantiateViewController(withIdentifier: "ChangeLocationVC") as! ChangeLocationViewController
            newAddressVC.selectedLocation = self.orderFulfillment.buyerServiceLocation
            newAddressVC.newDelegate = self
            self.navigationController?.pushViewController(newAddressVC, animated: true)
        } else if sender.tag == cancelOrderTag{
            let vc = storyboard?.instantiateViewController(withIdentifier: "CancelOrderVC") as! CancelOrderViewController
            vc.orderId = self.orderId
            vc.isSeller = !self.isBuyer
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        } else if sender.tag == changeScheduleTag{
            let vc = storyboard?.instantiateViewController(withIdentifier: "RequestScheduleVC") as! RequestScheduleViewController
            vc.duration = self.orderFulfillment.totalWorkDurationHours
            vc.requestedTime = self.orderFulfillment.serviceScheduleDate
            vc.orderId = self.orderId
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender.tag == actionTag{
            if self.orderFulfillment.action.text == kOrderStatus.kOrderProposeSchedule {
                let vc = storyboard?.instantiateViewController(withIdentifier: "RequestScheduleVC") as! RequestScheduleViewController
                vc.duration = self.orderFulfillment.totalWorkDurationHours
                vc.requestedTime = self.orderFulfillment.serviceScheduleDate
                vc.orderId = self.orderId
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }else if self.orderFulfillment.action.text == kOrderStatus.kOrderProposeLocation {
                let storyboard = UIStoryboard(name: "Account", bundle: nil)
                let newAddressVC = storyboard.instantiateViewController(withIdentifier: "ChangeLocationVC") as! ChangeLocationViewController
                newAddressVC.newDelegate = self
                self.navigationController?.pushViewController(newAddressVC, animated: true)
            }else if self.orderFulfillment.action.text == kOrderStatus.kOrderAccept{
                PointtersHelper.sharedInstance.showAlertViewWithTitle("Are you sure?", message: "Please confirm to accept the schedule.", buttonTitles: ["OK", "Cancel"], viewController: self) { (index) in
                    if index == 0{
                        self.callAcceptScheduleLocation()
                    }
                }
            } else if self.orderFulfillment.action.text == kOrderActions.kMake_payment {
                if self.buyerCountry == "NG" {
                    if self.sellerCountry == "NG" {
                        if self.displayPaypalSection && self.displayPaystackSection {
                            self.popupPayment(controller: self)
                        } else {
                            if self.displayPaypalSection {
                                self.payWithPayPal()
                            }
                            if self.displayPaystackSection {
                                self.setPaystackAmount()
                            }
                        }
                    } else {
                        self.payWithPayPal()
                    }
                } else {
                    if self.displayPaypalSection && self.displayPaystackSection {
                        self.popupPayment(controller: self)
                    } else {
                        if self.displayPaypalSection {
                            self.payWithPayPal()
                        }
                        if self.displayPaystackSection {
                            self.setPaystackAmount()
                        }
                    }
                }
            } else if self.orderFulfillment.action.text == kOrderActions.kScheduled_Seller{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                var scheduleDate = dateFormatter.date(from:self.orderFulfillment.serviceScheduleDate)
                if self.orderFulfillment.fulfillmentMethod.online{
                    scheduleDate = Date()
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "d MMM yyyy hh:mm a"
                PointtersHelper.sharedInstance.showAlertViewWithTitle("Start Service", message: "Click Start to start working on this service.  \n\n \(formatter.string(from: scheduleDate!))", buttonTitles: ["Start", "Cancel"], viewController: self) { (type) in
                    if type == 0{
                        self.callGeneralOrderAction(endpoint: "start-service")
                    }
                }
            }else if self.orderFulfillment.action.text == kOrderActions.kStart_Seller{
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Are you sure you want to complete this order?", buttonTitles: ["OK", "Cancel"], viewController: self) { (index) in
                    if index == 0{
                        self.callGeneralOrderAction(endpoint: "completed-service")
                    }
                }
                
            }else if self.orderFulfillment.action.text == kOrderActions.kComplete_Buyer{
                let vc = storyboard?.instantiateViewController(withIdentifier: "ReviewOrderVC") as! ReviewOrderViewController
                vc.delegate = self
                vc.orderId = self.orderId
                vc.serviceId = self.orderFulfillment.serviceId
                vc.sellerId = self.orderFulfillment.sellerId
                self.navigationController?.pushViewController(vc, animated: true)
            }else if self.orderFulfillment.action.text == kOrderActions.kCancel_Seller{
                let vc = storyboard?.instantiateViewController(withIdentifier: "CancelOrderVC") as! CancelOrderViewController
                vc.orderId = self.orderId
                vc.isSeller = !self.isBuyer
                vc.delegate = self
                vc.isForApprove = true
                vc.cancelReason = self.orderFulfillment.buyerOrderDispute
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func btnChatTapped(sender: UIButton) {
        let userId = self.orderFulfillment.contact.id
        var sellerName = self.orderFulfillment.contact.firstName
        sellerName = sellerName + " " + self.orderFulfillment.contact.lastName
        let userName = sellerName
        let userPic = self.orderFulfillment.contact.profilePic
        if userId != self.loginUserId {
            UserCache.sharedInstance.setChatCredentials(id: "", userId: userId, name: userName, pic: userPic, verified: true)
            let storyboard = UIStoryboard(name: "Chats", bundle: nil)
            let privateChatVC = storyboard.instantiateViewController(withIdentifier: "PrivateChatVC") as! PrivateChatViewController
            privateChatVC.otherUserId = self.isBuyer ? self.orderFulfillment.sellerId : self.orderFulfillment.buyerId
            privateChatVC.otherUserPic = userPic
            privateChatVC.otherUsername = userName
            navigationController?.pushViewController(privateChatVC, animated:true)
        }
    }
    
    @objc func btnGetDirection(sender: UIButton) {
        let serviceLocation = isBuyer ? self.orderFulfillment.sellerServiceLocation[0] : self.orderFulfillment.buyerServiceLocation
        let getDirectionVC = storyboard?.instantiateViewController(withIdentifier: "GetDirectionVC") as! GetDirectionViewController
        getDirectionVC.serviceLocation = serviceLocation
        navigationController?.pushViewController(getDirectionVC, animated: true)
    }
    
    @objc func btnChangeSchedule(sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "RequestScheduleVC") as! RequestScheduleViewController
        vc.orderId = self.orderId
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - PayPal and Paystack function
    
    func popupPayment(controller: UIViewController) {
        let dialogController = AZDialogViewController(title: "Payment method!",
                                                      message: "Let us know your payment method?",
                                                      widthRatio: 0.8)
        dialogController.dismissDirection = .none
        dialogController.dismissWithOutsideTouch = false
        
        dialogController.addAction(AZDialogAction(title: "PayPal", handler: { (dialog) -> (Void) in
            dialog.dismiss(animated: true) {
                self.payWithPayPal()
            }
        }))
        
        dialogController.addAction(AZDialogAction(title: "Paystack", handler: { (dialog) -> (Void) in
            dialog.dismiss(animated: true) {
                self.setPaystackAmount()
            }
        }))
        
        dialogController.addAction(AZDialogAction(title: "Cancel", handler: { (dialog) -> (Void) in
            dialog.dismiss()
        }))
                
        dialogController.buttonStyle = { (button,height,position) in
            if position == 0 {
                button.setBackgroundImage(UIImage.imageWithColor(UIColor.white), for: .highlighted)
                button.setBackgroundImage(UIImage.imageWithColor(UIColor(hexString: "#00b4f1")), for: .normal)
                button.layer.masksToBounds = true
                button.layer.borderColor = UIColor(hexString: "#00b4f1").cgColor
            } else if position == 1 {
                button.setBackgroundImage(UIImage.imageWithColor(UIColor.white), for: .highlighted)
                button.setBackgroundImage(UIImage.imageWithColor(UIColor(hexString: "#3bb75e")), for: .normal)
                button.layer.masksToBounds = true
                button.layer.borderColor = UIColor(hexString: "#3bb75e").cgColor
            } else {
                button.setBackgroundImage(UIImage.imageWithColor(UIColor.white), for: .highlighted)
                button.setBackgroundImage(UIImage.imageWithColor(UIColor(hexString: "#00b4f1")), for: .normal)
                button.layer.masksToBounds = true
                button.layer.borderColor = UIColor(hexString: "#00b4f1").cgColor
            }
            button.setTitleColor(UIColor.black, for: .highlighted)
            button.setTitleColor(UIColor.white, for: .normal)
        }

        dialogController.show(in: controller)
    }
    
    func payWithPayPal() {
        
        let desc = self.orderFulfillment.desc
        let paymentObj = PayPalTranscation()
        let paymentrequest = PaymentRequest.init(marchantName: nil, itemName: "Pointters", price: NSDecimalNumber(value: self.orderFulfillment.totalAmount), quantity: 1, shipPrice: 0, taxPrice: 0, totalAmount: NSDecimalNumber(value: self.orderFulfillment.totalAmount), shortDesc: desc, currency: PaypalPrice.USD)
        paymentObj.configurePayPalPaymentsDetails(paymentRequest: paymentrequest, controller: self)
    }

    func payWithPaystack() {
        // Card view configuration
        let ngn_price = Float(self.orderFulfillment.totalAmount/0.0026)
        let popupView = MFCardView(withViewController: self, email: "test@example.com", price: "\(ngn_price)")
        popupView.delegate = self
        let popupConfig = STZPopupViewConfig()
        popupConfig.dismissAnimation = .custom
        popupConfig.dismissCustomAnimation = { containerView, popupView, completion in
            UIView.animate(withDuration: 0.3, animations: {
            }, completion: { finished in
                if self.paystackdone {
                    self.paystacktransaction()
                }
                completion()
            })
        }
        presentPopupView(popupView, config: popupConfig)
    }
    
    func paystacktransaction() {
        // building paystack card params
        let cardParams = PSTCKCardParams.init()
        cardParams.number = self.card_number
        cardParams.cvc = self.card_cvv
        cardParams.expYear = self.card_expiry_year
        cardParams.expMonth = self.card_expiry_month

        let desc = self.orderFulfillment.desc
        
        // building new Paystack Transaction
        let transactionParams = PSTCKTransactionParams.init()
        transactionParams.amount = UInt(self.orderFulfillment.totalAmount)
        let custom_filters: NSMutableDictionary = [
            "recurring": true
        ];
        let items: NSMutableArray = [desc]
        do {
            try transactionParams.setCustomFieldValue("iOS SDK", displayedAs: "Paid Via");
            try transactionParams.setCustomFieldValue("Pointters", displayedAs: "To Buy");
            try transactionParams.setMetadataValue("iOS SDK", forKey: "paid_via");
            try transactionParams.setMetadataValueDict(custom_filters, forKey: "custom_filters");
            try transactionParams.setMetadataValueArray(items, forKey: "items");
        } catch {
            print(error)
        }
        transactionParams.email = "test@gmail.com";
        let client = PSTCKAPIClient.init()

        PointtersHelper.sharedInstance.startLoader(view: self.view)
        client.chargeCard(cardParams, forTransaction: transactionParams, on: self,
               didEndWithError: { (error, reference) -> Void in
                PointtersHelper.sharedInstance.stopLoader()
                let userInfo = error.userInfo
                let theResult = userInfo["com.paystack.lib:ErrorMessageKey"] as! String
                PointtersHelper.sharedInstance.showAlertViewWithTitle("Error occured", message: theResult, buttonTitles: ["OK"], viewController: self, completion: nil)
            }, didRequestValidation: { (reference) -> Void in
                print("an OTP was requested, transaction has not yet succeeded: \(reference)")
            }, didTransactionSuccess: { (reference) -> Void in
                PointtersHelper.sharedInstance.stopLoader()
                // transaction may have succeeded, please verify on backend
                print("transaction success :\(reference)")
//                self.verifyPaystackTransaction(reference: reference)
                self.callPutOrderFulfillmentAPI(orderId: self.orderId)
        })
    }
    
    func setPaystackAmount() {
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        let ngn_price = Float(self.orderFulfillment.totalAmount/0.0026)
        ApiHandler.callSetPaystackAmountMethods(amount: ngn_price) { (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.paystack_access_code = responseDict["access_code"] as! String
                    self.paystack_authorization_url = responseDict["authorization_url"] as! String
                    self.paywithPaystack = true
                    self.paywithPaypal = false
                    self.payWithPaystack()
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        }
    }
    
    func verifyPaystackTransaction(reference: String) {
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.verifyPaystackTransaction(access_url: self.paystack_authorization_url, reference: reference) { (result, statusCode,response,error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String: Any]
                if statusCode == 200 {
                    print("response \(responseDict)")
                    self.callPutOrderFulfillmentAPI(orderId: self.orderId)
                }
            } else {
                print("error is \(error)")
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Transaction reference was not found.", buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        }
    }
    
    //MARK:- Add download function
    
    @objc func onClickDownload(sender: MyTapGesture){
        let alert = UIAlertController(title: "", message: "Please Select an Option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default , handler:{ (UIAlertAction)in
            self.openGalleryPicker()
        }))
        
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction)in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Files", style: .default , handler:{ (UIAlertAction)in
            self.openDocumentPicker()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func openGalleryPicker() {
        if self.checkMediaAccess(type: 0) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            imagePickerController.mediaTypes = ["public.image", "public.movie"]
            imagePickerController.videoQuality = .type640x480
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func openCamera() {
        if self.checkMediaAccess(type: 1) {
            DispatchQueue.main.async {
                let cameraPhotoController = UIImagePickerController()
                cameraPhotoController.sourceType = .camera
                cameraPhotoController.delegate = self
                cameraPhotoController.mediaTypes = ["public.image", "public.movie"]
                cameraPhotoController.videoQuality = .type640x480
                self.present(cameraPhotoController, animated: true, completion: nil)
            }
        }
    }
    
    func openDocumentPicker() {
        let menu = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF), String(kUTTypeData), String(kUTTypeBMP), String(kUTTypePNG), String(kUTTypeGIF)], in: .import)
        menu.delegate = self
        menu.modalPresentationStyle = .formSheet
        self.present(menu, animated: true, completion: nil)
    }
    
    func checkMediaAccess(type:Int) -> Bool {
        var flag = false
        if type == 0 {
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                return true
            } else {
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == PHAuthorizationStatus.authorized {
                        DispatchQueue.main.async {
                            let cameraPhotoController = UIImagePickerController()
                            cameraPhotoController.sourceType = .photoLibrary
                            cameraPhotoController.delegate = self
                            cameraPhotoController.mediaTypes = ["public.image", "public.movie"]
                            cameraPhotoController.videoQuality = .type640x480
                            self.present(cameraPhotoController, animated: true, completion: nil)
                        }
                        flag = false
                    } else {
                        DispatchQueue.main.async {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Turn on photo library usage permission in the app Settings", buttonTitles: ["Go to app settings"], viewController: self, completion: { (completion) in
                                if let url = URL(string:UIApplicationOpenSettingsURLString) {
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }
                            })
                        }
                    }
                }
            }
            
        } else {
            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                //already authorized
                return true
            } else {
                if AVCaptureDevice.authorizationStatus(for: .video) !=  .authorized {
                    AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                        if granted {
                            DispatchQueue.main.async {
                                let cameraVideoController = UIImagePickerController()
                                cameraVideoController.sourceType = .camera
                                cameraVideoController.delegate = self
                                cameraVideoController.mediaTypes = ["public.movie"]
                                cameraVideoController.videoQuality = .type640x480
                                self.present(cameraVideoController, animated: true, completion: nil)
                            }
                            flag = false
                        } else {
                            //access denied
                            DispatchQueue.main.async {
                                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Turn on camera usage permission in the app Settings", buttonTitles: ["Go to app settings"], viewController: self, completion: { (completion) in
                                    if let url = URL(string:UIApplicationOpenSettingsURLString) {
                                        if UIApplication.shared.canOpenURL(url) {
                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                        }
                                    }
                                })
                            }
                        }
                    })
                }
            }
        }
        return flag
    }
    
    @objc func onClickUser(sender: MyTapGesture) {
        UserCache.sharedInstance.setProfileUser(loginUser: false, userId: self.orderFulfillment.contact.userId)
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        navigationController?.pushViewController(userProfileVC, animated:true)
    }
    
    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    func callOrder() {
        var params = [String: Any]()
        
        let order_item = self.orderFulfillment.orderItems
        var orderItem: [[String: Any]] = []
        var index = 0
        var totalDuration = 0
        for item in order_item{
            var item_temp = [String: Any]()
            item_temp["quantity"] = item.quantity
            item_temp["currencyCode"] = self.orderFulfillment.currencyCode
            item_temp["currencySymbol"] = self.orderFulfillment.currencySymbol
            item_temp["price"] = item.price
            item_temp["description"] = item.description
            let time = item.time
            item_temp["time"] = time*item.quantity
            item_temp["timeUnitOfMeasure"] = item.timeUnitOfMeasure
            totalDuration = totalDuration + item.quantity*item.time
            index = index + 1
            orderItem.append(item_temp)
        }
        
        params["serviceId"] = self.orderFulfillment.serviceId
        params["orderItems"] = orderItem
        params["currencyCode"] = self.orderFulfillment.currencyCode
        params["currencySymbol"] = self.orderFulfillment.currencySymbol
        
        params["shippingFee"] = 0
        params["subtotalAmount"] = String(format: "%.2f", self.orderFulfillment.totalAmount)
        params["taxAmount"] = self.orderFulfillment.taxAmount
        params["transactionFee"] = self.orderFulfillment.transactionFee
        params["totalAmount"] = self.orderFulfillment.totalAmount
        params["totalWorkDurationHours"] = totalDuration
        params["buyerServiceLocation"] = self.orderFulfillment.buyerServiceLocation.dict()
        params["serviceScheduleDate"] = self.orderFulfillment.serviceScheduleDate
        params["serviceScheduleEndDate"] = self.orderFulfillment.serviceScheduleEndDate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let requestDateFormatterString = formatter.string(from: Date())
        params["buyerRequestedServiceScheduleDate"] = requestDateFormatterString
        
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callGetOrder(params: params) { (result, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    let resDic = response.result.value as! NSDictionary
                    let dict = resDic.value(forKey: "order") as! [String: Any]
                    let orderId = dict["_id"] as! String
                    self.orderId = orderId
                    self.self.callGetOrderFulfillmentAPI(orderId: orderId)
                }else {
                    let responseDict = response.result.value as! [String:Any]
                    let message = responseDict["message"] as! String
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: message, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                if let data = response.data {
                    let error = String(data: data, encoding: String.Encoding.utf8)
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error!, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
        }
    }
    
    func callPutOrderFulfillmentAPI(orderId: String) {
        if self.isRefreshingPage {
            return
        }
        self.isRefreshingPage = true
        var params = [String: Any]()
        var payment = [String: Any]()
        if self.paywithPaypal {
            payment["method"] = "paypal"
            params["paymentMethodToken"] = self.orderFulfillment.paymentMethod.token
        }
        if self.paywithPaystack {
            payment["method"] = "paystack"
            params["paymentMethodToken"] = self.paystack_authorization_url
        }
        params["paymentMethod"] = payment
        
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callPutOrderFulfillment(orderId: orderId, param: params, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            self.isRefreshingPage = false
            if result == true {
                let responseDict = response.value as! [String:Any]
                print(responseDict as NSDictionary)
                if statusCode == 200 {
                    if let order = responseDict["order"] as? [String:Any] {
                        self.buyerCountry = order["buyerCountry"] as! String
                        self.sellerCountry = order["sellerCountry"] as! String
                        self.displayPaypalSection = order["displayPaypalSection"] as! Bool
                        self.displayPaystackSection = order["displayPaystackSection"] as! Bool
                        self.orderFulfillment = OrderFulfillment.init(dict: order)
                        if self.orderFulfillment.buyerId == UserCache.sharedInstance.getAccountData().id{
                            self.isBuyer = true
                        } else{
                            self.isBuyer = false
                        }
                        self.tableView.reloadData()
                    }
                    self.callGetOrderFulfillmentAPI(orderId: self.orderId)
                    
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                print(response.error ?? "get order fulfillment failure")
            }
        })
    }
    
    func callGetOrderFulfillmentAPI(orderId: String) {
        if self.isRefreshingPage {
            return
        }
        self.isRefreshingPage = true
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callGetOrderFulfillment(orderId: orderId, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            self.isRefreshingPage = false
            if result == true {
                let responseDict = response.value as! [String:Any]
                print(responseDict as NSDictionary)
                if statusCode == 200 {
                    if let order = responseDict["order"] as? [String:Any] {
                        self.buyerCountry = order["buyerCountry"] as! String
                        self.sellerCountry = order["sellerCountry"] as! String
                        self.displayPaypalSection = order["displayPaypalSection"] as! Bool
                        self.displayPaystackSection = order["displayPaystackSection"] as! Bool
                        self.orderFulfillment = OrderFulfillment.init(dict: order)
                        if self.orderFulfillment.buyerId == UserCache.sharedInstance.getAccountData().id{
                            self.isBuyer = true
                        } else{
                            self.isBuyer = false
                        }
                        self.tableView.reloadData()                        
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                print(response.error ?? "get order fulfillment failure")
            }
        })
    }
    
    func callAcceptScheduleLocation() { // Seller action
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.AcceptScheduleLocationChange(orderId: self.orderId, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                self.callGetOrderFulfillmentAPI(orderId: self.orderId)
            }
            else {
                print(response.error ?? "accept schedule failure")
            }
        })
    }
    
    func callGeneralOrderAction(endpoint: String){
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callGeneralOrderService(orderId: self.orderId, endpoint: endpoint, withCompletionHandler:{ (result,statusCode,response,error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                self.callGetOrderFulfillmentAPI(orderId: self.orderId)
            }
            else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: { (type) in
                    self.navigationController?.popViewController(animated: true)
                })
            }
        })
    }
    
    func uploadSellerDeliverMedia(params: [String: Any]){ // Seller action
        ApiHandler.uploadSellerDeliverMedia(orderId: self.orderId, params: params, withCompletionHandler:{ (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    self.callGetOrderFulfillmentAPI(orderId: self.orderId)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("Network error", message: "Please refresh your screen.", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: { (type) in
                    self.callGetOrderFulfillmentAPI(orderId: self.orderId)
                })
            }
        })
    }
    
    func calculateTimeline(){
        let hours = self.orderFulfillment.totalWorkDurationHours
        if hours <= 24{
            if hours < 2{
                self.timelineUnit = "Hour"
            }else{
                self.timelineUnit = "Hours"
            }
            self.timelineAmount = "\(hours)"
        }else{
            self.timelineAmount = "\(hours/24)"
            if hours/24 < 2{
                self.timelineUnit = "Days"
            }else{
                self.timelineUnit = "Day"
            }
        }
    }

    //MARK:- Manage Media Action
    
    func openMedia(media: Media) {
        switch media.mediaType {
        case "image":
            let fullScreenImageVC = self.storyboard!.instantiateViewController(withIdentifier: "FullScreenImageVC") as! FullScreenImageViewController
            fullScreenImageVC.imageUrl = media.fileName
            navigationController?.pushViewController(fullScreenImageVC, animated:false)
        case "video":
            if let url = NSURL(string: media.fileName){
                player = AVPlayer(url: url as URL)
                playerController.player = player
                playerController.showsPlaybackControls = true
                self.present(playerController, animated: true, completion: {
                    self.player.play()
                })
            }
//            let fullScreenVC = self.storyboard!.instantiateViewController(withIdentifier: "FullScreenVC") as! FullScreenViewController
//            fullScreenVC.videoURL = media.fileName
//            navigationController?.pushViewController(fullScreenVC, animated: true)
        default:
            PointtersHelper.sharedInstance.showAlertViewWithTitle("Warning", message: "Not supported file type, please download or copy link.", buttonTitles: ["OK"], viewController: self, completion: nil)
        }
    }
    
    func copyMediaLink(media: Media) {
        UIPasteboard.general.string  = media.fileName
        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Copied to clipboard: \(media.fileName)", buttonTitles: ["OK"], viewController: self, completion: nil)
    }
    
    func downloadMedia(media: Media) {
        downloadFileFromS3(media: media)
    }
    
    func deleteMedia(media: Media) {
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.deleteDeliverMedia(orderId: self.orderId, mediaId: media.id, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                self.callGetOrderFulfillmentAPI(orderId: self.orderId)
            }
            else {
                print(response.error ?? "accept location failure")
            }
        })
    }
    
}

extension FulfillmentViewController : UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            if self.orderFulfillment.sellerId == self.loginUserId {
                if self.orderFulfillment.sellerDeliveredMedia.count == 0 {
                    return 1
                }
                return 2
            } else {
                if self.orderFulfillment.sellerDeliveredMedia.count == 0 {
                    return 0
                }
                return 1
            }
        case 2: return 2
        case 3: return self.orderFulfillment.orderItems.count + 1
        case 4:
            return 4
        case 5:
            return 4
        case 6: return 1
        case 7: return 1
        default: return 0
        }
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: return 80.0
            case 1:
                if self.orderFulfillment.action.type == ""{
                    return 0                                                                                                            //hide action button
                }else{
                    if (isBuyer && self.orderFulfillment.action.pendingOn == "seller") || (!isBuyer && self.orderFulfillment.action.pendingOn == "buyer"){
                        return 0
                    }
                    if isBuyer && (self.orderFulfillment.action.text == kOrderStatus.kOrderAccept || self.orderFulfillment.action.text == kOrderActions.kScheduled_Seller || self.orderFulfillment.action.text == kOrderActions.kStart_Seller){
                        return 0
                    }else{
                        if !isBuyer && self.orderFulfillment.action.text == kOrderActions.kComplete_Buyer{
                            return 0
                        }else{
                            if !isBuyer && (self.orderFulfillment.action.text == kOrderStatus.kOrderProposeSchedule || self.orderFulfillment.action.text == kOrderStatus.kOrderProposeLocation) {
                                return 0
                            }
                            return 45.0
                        }
                        
                    }
                }
                
            default: return 0.0
            }
        case 1:
            if self.orderFulfillment.sellerId == self.loginUserId {
                if self.orderFulfillment.sellerDeliveredMedia.count == 0 {
                    return 45.0
                }
                if indexPath.row == 0 {
                    return 120.0
                } else {
                    return 45.0
                }
            } else {
                if self.orderFulfillment.sellerDeliveredMedia.count == 0 {
                    return 0.0
                }
                return 120.0
            }
        case 2:
            switch indexPath.row {
            case 0: return 75.0
            case 1:
                if self.orderFulfillment.desc != "" {
                    let height = self.orderFulfillment.desc.height(withConstrainedWidth: CGFloat(UIScreen.main.bounds.size.width - 30), font: UIFont(name: "Helvetica", size: 17)!) + 20
                    if height >= self.descHeight {
                        if selectDescFlag {
                            return height + 17
                        } else {
                            return self.descHeight
                        }
                    } else {
                        return height + 17
                    }
                } else {
                    return 0.0
                }
            default: return 0.0
            }
        case 3:
            if indexPath.row >= self.orderFulfillment.orderItems.count {
                if Double(self.orderFulfillment.taxAmount) == 0 {
                    return 95.0
                }
                return self.orderFulfillment.fulfillmentMethod.shipment ? 180.0 : 135.0
            } else {
                return 45.0
            }
        case 4:
            if indexPath.row == 0 {
                if self.orderFulfillment.serviceScheduleDate != "" {
                    return 45
                }
                return 0
            } else if indexPath.row == 1{
                return 45.0
            } else if indexPath.row == 2{
                if self.orderFulfillment.sellerAcceptedScheduleTime{
                    return 45
                }else{
                    return 0
                }
            }else{
                if isBuyer{
                    if self.orderFulfillment.fulfillmentMethod.online || self.orderFulfillment.serviceStartDate != ""{
                        return 0
                    }else{
                        return 45
                    }
                }else{
                    return 0
                }
            }
        case 5:
            if indexPath.row == 0 {
                if self.orderFulfillment.fulfillmentMethod.online{
                    return 40
                }else{
                    return 280.0
                }
            } else if indexPath.row == 1{
                if self.orderFulfillment.fulfillmentMethod.online{
                    return 0
                }
                return 45
            } else if indexPath.row == 2{
                if self.orderFulfillment.fulfillmentMethod.online{
                    return 0
                }
                if self.orderFulfillment.sellerAcceptedBuyerServiceLocation{
                    return 45
                }else{
                    return 0
                }
            }else{
                if self.orderFulfillment.fulfillmentMethod.online || self.orderFulfillment.serviceStartDate != ""{
                    return 0
                }
                if self.isBuyer{
                    return 45
                }else{
                    return 0
                }
            }
            
        case 6:
            if !self.orderFulfillment.fulfillmentMethod.shipment{
                return 0
            }
            return 200.0
        case 7:
            if self.orderFulfillment.serviceCompleteDate != "" || self.orderFulfillment.statusDescription == kOrderStatus.kOrderCanceled{
                return 0
            }
            if self.orderFulfillment.buyerOrderDispute.cancellation == 1 || self.orderFulfillment.action.type == "reviewCancellation" {
                return 0
            }
            return 45.0
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        if section != 3 && section != 7{
            let headerLabel = UILabel(frame: CGRect(x: 15, y: 20, width: tableView.bounds.size.width / 2, height: 20))
            headerLabel.font = UIFont(name: "Helvetica", size: 14)
            headerLabel.textColor = UIColor.getCustomGrayTextColor()
            
            if section == 0 {
                headerLabel.text = "STATUS"
            } else if section == 1 {
                headerLabel.text = "FILES DELIVERED"
                let rightLabel = UILabel(frame: CGRect(x: tableView.bounds.size.width / 2, y: 20, width: tableView.bounds.size.width / 2 - 15, height: 20))
                rightLabel.font = UIFont(name: "Helvetica", size: 14)
                rightLabel.textColor = UIColor.getCustomGrayTextColor()
                rightLabel.sizeToFit()
                rightLabel.text = "\(self.orderFulfillment.sellerDeliveredMedia.count) TOTAL"
                rightLabel.textAlignment = .right
                headerView.addSubview(rightLabel)
            } else if section == 2 {
                headerLabel.text = "SERVICE ORDERED"
            } else if section == 4{
                headerLabel.text = "SERVICE SCHEDULE"
            } else if section == 5{
                headerLabel.text = "DELIVERY METHOD"
            } else if section == 6{
                headerLabel.text = "SHIPMENT TRACKING"
            }
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.groupTableViewBackground
        if section == 3 {
            let footerlabel = UILabel(frame: CGRect(x: 15, y: 10, width: tableView.bounds.size.width / 2, height: 20))
            footerlabel.font = UIFont(name: "Helvetica", size: 14)
            footerlabel.textColor = UIColor.getCustomGrayTextColor()
            if self.orderFulfillment.paymentDate != "" {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let paymentDate = dateFormatter.date(from:self.orderFulfillment.paymentDate)
                let formatter = DateFormatter()
                formatter.dateFormat = "d MMM yyyy"
                footerlabel.text = "Paid on: " + formatter.string(from: paymentDate!)
            } else {
                footerlabel.text = "Paid on: "
            }
            footerlabel.sizeToFit()
            footerView.addSubview(footerlabel)
        }
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell", for: indexPath) as! FulfillmentCell
                cell.lblStatusDesc.text = (self.orderFulfillment.statusDescription != "") ? self.orderFulfillment.statusDescription : "Order Status"
                if self.orderFulfillment.createdAt != "" {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let createdTime = dateFormatter.date(from:self.orderFulfillment.createdAt)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd"
                    cell.lblStarted.text = formatter.string(from: createdTime!)
                } else {
                    cell.lblStarted.text = ""
                }
                cell.lblOrderId.text = self.orderFulfillment.id
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "actionButtonCell", for: indexPath) as! FulfillmentCell
                cell.lblActionButton.tag = actionTag
                cell.lblActionButton.setTitle(self.orderFulfillment.action.text, for: .normal)
                cell.lblActionButton.addTarget(self, action: #selector(btnAction(sender:)), for: .touchUpInside)
                return cell
            }
        } else if indexPath.section == 1 {
            if !self.isBuyer {
                if self.orderFulfillment.sellerDeliveredMedia.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "addDownloadCell", for: indexPath) as! FulfillmentCell
                    let tapGesture = MyTapGesture(target: self, action: #selector(self.onClickDownload(sender:)))
                    cell.btnAddDownload.isUserInteractionEnabled = true
                    cell.btnAddDownload.addGestureRecognizer(tapGesture)
                    return cell
                }
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "deliveredMediaCell", for: indexPath) as! FulfillmentCell
                    cell.deliveredMedia = self.orderFulfillment.sellerDeliveredMedia
                    cell.delegate = self
                    cell.mediaCollectionView.reloadData()
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "addDownloadCell", for: indexPath) as! FulfillmentCell
                    let tapGesture = MyTapGesture(target: self, action: #selector(self.onClickDownload(sender:)))
                    cell.btnAddDownload.isUserInteractionEnabled = true
                    cell.btnAddDownload.addGestureRecognizer(tapGesture)
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "deliveredMediaCell", for: indexPath) as! FulfillmentCell
                cell.deliveredMedia = self.orderFulfillment.sellerDeliveredMedia
                cell.delegate = self
                cell.mediaCollectionView.reloadData()
                return cell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! FulfillmentCell
                cell.ivUserPic.layer.cornerRadius = cell.ivUserPic.frame.size.width / 2
                cell.lblUserName.text = "\(self.orderFulfillment.contact.firstName) \(self.orderFulfillment.contact.lastName)"
                
                let tapGesture1 = MyTapGesture(target: self, action: #selector(self.onClickUser(sender:)))
                cell.ivUserPic.isUserInteractionEnabled = true
                cell.ivUserPic.addGestureRecognizer(tapGesture1)
                
                let tapGesture2 = MyTapGesture(target: self, action: #selector(self.onClickUser(sender:)))
                cell.lblUserName.isUserInteractionEnabled = true
                cell.lblUserName.addGestureRecognizer(tapGesture2)
                
                
                cell.lblVerified.text = self.orderFulfillment.contact.verified ? "Verified" : "Unverified"
                if self.orderFulfillment.contact.phone == "" {
                    cell.btnCall.isHidden = true
                } else {
                    cell.btnCall.isHidden = false
                }
                cell.btnCall.addTarget(self, action: #selector(btnCallTapped(sender:)), for: .touchUpInside)
                cell.btnChat.addTarget(self, action: #selector(btnChatTapped(sender:)), for: .touchUpInside)
                cell.ivUserPic.sd_imageTransition = .fade
                cell.ivUserPic.sd_setImage(with: URL(string: self.orderFulfillment.contact.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "descCell", for: indexPath) as! FulfillmentCell
                cell.lblDescription.text = (self.orderFulfillment.tagLine != "") ? self.orderFulfillment.tagLine : self.orderFulfillment.desc
                return cell
            }
        } else if indexPath.section == 3 {
            if indexPath.row == self.orderFulfillment.orderItems.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalPriceCell", for: indexPath) as! FulfillmentCell
                cell.lblTotal.text = self.orderFulfillment.currencySymbol + String(format:"%.2f", self.orderFulfillment.totalAmount)
                if Double(self.orderFulfillment.taxAmount) == 0.0 {
                    cell.taxView.isHidden = true
                }else {
                    cell.taxView.isHidden = false
                }
                cell.lblTaxes.text = self.orderFulfillment.currencySymbol + String(format:"%.2f", self.orderFulfillment.taxAmount)
                cell.lblShippingFee.text = self.orderFulfillment.currencySymbol + String(format:"%.2f", self.orderFulfillment.shippingFee)
                cell.lblServiceFee.text = self.orderFulfillment.currencySymbol + String(format:"%.2f", self.orderFulfillment.transactionFee)
                cell.shippingFeeView.isHidden = !self.orderFulfillment.fulfillmentMethod.shipment
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "orderItemCell", for: indexPath) as! FulfillmentCell
                cell.lblPriceDesc.text = self.orderFulfillment.orderItems[indexPath.row].desc
                cell.lblPrice.text = self.orderFulfillment.currencySymbol + String(format:"%.2f", self.orderFulfillment.orderItems[indexPath.row].price)
                cell.lblQuantity.text = "\(self.orderFulfillment.orderItems[indexPath.row].quantity) x"
                return cell
            }
        } else if indexPath.section == 4 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "sellerScheduleCell", for: indexPath) as! FulfillmentCell
                if self.orderFulfillment.serviceScheduleDate != "" {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let scheduleDate = dateFormatter.date(from:self.orderFulfillment.serviceScheduleDate)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd MMM yyyy hh:mma"
                    cell.lblScheduleDate.text = formatter.string(from: scheduleDate!)
                } else {
                    cell.lblScheduleDate.text = ""
                }
                return cell
            } else if indexPath.row == 1 || indexPath.row == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "workCompleteCell", for: indexPath) as! FulfillmentCell
                if indexPath.row == 1 {
                    cell.ivLeftIcon.image = UIImage(named:"icon-recent")
                    self.calculateTimeline()
                    cell.lblWorkComplete.text = "Work to complete \(self.timelineAmount) \(self.timelineUnit) after start"
                } else {
                    cell.ivLeftIcon.image = UIImage(named:"icon-checkbox-blue")
                    cell.lblWorkComplete.text = "Schedule accepted by seller"
                }
                return cell
            } else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "actionButtonCell", for: indexPath) as! FulfillmentCell
                if self.orderFulfillment.serviceScheduleDate == ""{
                    cell.lblActionButton.setTitle("Propose Schedule", for: .normal)
                }else {
                    cell.lblActionButton.setTitle("Change Schedule", for: .normal)
                }
                cell.lblActionButton.tag = changeScheduleTag
                cell.lblActionButton.addTarget(self, action: #selector(btnAction(sender:)), for: .touchUpInside)
                return cell
            }
        } else if indexPath.section == 5 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryCell", for: indexPath) as! ServiceDetailCell
                
                var fulfillmentString = ""
                if self.orderFulfillment.fulfillmentMethod.online {
                    cell.mapViewHeight.constant = 0.0
                    cell.mapView.isHidden = true
                    fulfillmentString = "Servicing Online"
                }
                if self.orderFulfillment.fulfillmentMethod.local {
                    cell.localRadius = self.orderFulfillment.fulfillmentMethod.localServiceRadius
                    cell.isLocalService = true
                    fulfillmentString = "Servicing Locally Within \(self.orderFulfillment.fulfillmentMethod.localServiceRadius) Miles"
                }
                if self.orderFulfillment.fulfillmentMethod.store {
                    fulfillmentString = "Service at Store Locations"
                }
                cell.lblFulfillment.text = fulfillmentString
                
                if self.orderFulfillment.fulfillmentMethod.store{
                    if self.orderFulfillment.sellerServiceLocation.count > 0{
                        var locArr = [[String: Any]]()
                        for location in self.orderFulfillment.sellerServiceLocation {
                            locArr.append(location.dict())
                        }
                        cell.showStoreLocations(locations: locArr)
                    }
                }else{
                    if self.orderFulfillment.buyerServiceLocation.geoJson.coordinates.count > 0 {
                        cell.showFulfillmentMap(buyerLocation: self.orderFulfillment.buyerServiceLocation, sellerLocation: self.orderFulfillment.sellerServiceLocation[0])
                    }
                }
               
//                if self.orderFulfillment.fulfillmentMethod.shipment{
//                    if fulfillmentString != ""{
//                        fulfillmentString.append(", Shipment")
//                    } else {
//                        fulfillmentString.append("Shipment")
//                    }
//                }
                cell.btnGetDirections.addTarget(self, action: #selector(btnGetDirection(sender:)), for: .touchUpInside)
                return cell
            } else if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "workCompleteCell", for: indexPath) as! FulfillmentCell
                cell.ivLeftIcon.image = UIImage(named:"icon-address")
                if self.orderFulfillment.buyerId == self.loginUserId {
                    cell.lblWorkComplete.text = self.orderFulfillment.sellerServiceLocation[0].city + ", " + self.orderFulfillment.sellerServiceLocation[0].state + " " + self.orderFulfillment.sellerServiceLocation[0].postalCode
                } else {
                    cell.lblWorkComplete.text = self.orderFulfillment.buyerServiceLocation.city + ", " + self.orderFulfillment.buyerServiceLocation.state + " " + self.orderFulfillment.buyerServiceLocation.postalCode
                }
                return cell
            } else {
                if self.orderFulfillment.sellerAcceptedBuyerServiceLocation {
                    if indexPath.row == 2 {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "workCompleteCell", for: indexPath) as! FulfillmentCell
                        cell.ivLeftIcon.image = UIImage(named:"icon-checkbox-blue")
                        cell.lblWorkComplete.text = "Location accepted by seller"
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "actionButtonCell", for: indexPath) as! FulfillmentCell
                        cell.lblActionButton.setTitle("Confirm Location", for: .normal)
                        cell.lblActionButton.tag = changelocationTag
                        return cell
                    }
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "actionButtonCell", for: indexPath) as! FulfillmentCell
                    cell.lblActionButton.setTitle("Confirm Location", for: .normal)
                    cell.lblActionButton.tag = changelocationTag
                    cell.lblActionButton.addTarget(self, action: #selector(btnAction(sender:)), for: .touchUpInside)
                    return cell
                }
            }
        } else if indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shipmentCell", for: indexPath) as! FulfillmentCell
//            cell.lblShipInfo.text = kShippingInfoItems[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionButtonCell", for: indexPath) as! FulfillmentCell
            cell.lblActionButton.tag = cancelOrderTag
            cell.lblActionButton.setTitle("Request to cancel order", for: .normal)
            cell.lblActionButton.addTarget(self, action: #selector(btnAction(sender:)), for: .touchUpInside)
            return cell
        }
    }
    
}

extension FulfillmentViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            if isBuyer && self.orderFulfillment.sellerDeliveredMedia.count == 0 {
                return 0
            }else {
                return 40
            }
        case 3: return 0.0
        case 5:
                return 40
        case 6:
            if !self.orderFulfillment.fulfillmentMethod.shipment{
                return 0
            } else{
                return 40
            }
        case 7: return 15.0
        default: return 40.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 3: return 30.0
        case 7: return 100.0
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if indexPath.row == 0{
                let orderMilestoneVC = storyboard?.instantiateViewController(withIdentifier: "OrderMilestoneVC") as! OrderMilestoneViewController
                orderMilestoneVC.orderFulfillment = self.orderFulfillment
                orderMilestoneVC.currentAction = self.orderFulfillment.action.text
                orderMilestoneVC.orderStatus = self.orderFulfillment.orderMilestoneStatuses
                navigationController?.pushViewController(orderMilestoneVC, animated: true)
            }
        }
    }
    
}

// MARK: Extensions

extension FulfillmentViewController: PayPalPaymentDelegate {
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        paymentViewController.dismiss(animated: true) { () -> Void in
            print("and Dismissed")
        }
        print("Payment cancel")
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print(completedPayment.confirmation)
        // set paypal authorization code to server
        for item in completedPayment.confirmation {
            if item.key == AnyHashable("response") {
                if let authorization_code = item.value as? [String:String] {
                    let code = authorization_code["id"]!
                    self.paywithPaypal = true
                    self.paywithPaystack = false
                    self.orderFulfillment.paymentMethod.token = code
                }
            }
        }
        paymentViewController.dismiss(animated: true) { () -> Void in
            self.callPutOrderFulfillmentAPI(orderId: self.orderId)
        }
        print("Payment is going on")
    }
}

extension FulfillmentViewController: MFCardDelegate {
    func didEdit(number: String) {
        print("card number : \(number)")
        self.card_number = number.formattedCardNumber()
    }
    
    func didEdit(expiryDate: String) {
        print("expiryDate: \(expiryDate)")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        guard let date = formatter.date(from: expiryDate) else {
            return
        }
        formatter.dateFormat = "MM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        self.card_expiry_month = UInt(month)
        self.card_expiry_year = UInt(year)
    }
    
    func didEdit(cvc: String) {
        print("cvc: \(cvc)")
        self.card_cvv = cvc
    }
    
    func cardPayButtonClicked() {
        self.paystackdone = true
        dismissPopupView()
        
    }
    
    func cardDidClose() {
        self.paystackdone = false
        dismissPopupView()
    }
}

// NewAddressDelegate
extension FulfillmentViewController: ChangeAddressDelegate {
    func edittedAddress(addressDict: [String : Any], selectedLocation: Location) {
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.requestChangeLocation(orderId: self.orderId, params: ["buyerServiceLocation": addressDict]) { (result, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.callGetOrderFulfillmentAPI(orderId: self.orderId)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                print(response.error ?? "get order fulfillment failure")
            }
        }
    }
}

// schedule request delegate

extension FulfillmentViewController: RequestScheduleDelegate{
    func onSuccessRequestSchedule() {
        self.callGetOrderFulfillmentAPI(orderId: self.orderId)
    }
}

// review order delegate

extension FulfillmentViewController: ReviewOrderDelegate{
    func onSuccess() {
        self.callGetOrderFulfillmentAPI(orderId: self.orderId)
    }
}

// cancel order delegate

extension FulfillmentViewController: CancelOrderDelegate{
    func onSuccessCancelOrder(description: String) {
        self.callGetOrderFulfillmentAPI(orderId: self.orderId)
    }
    func onSuccessApproveCancel(description: String, newAction: ActionButton) {
        self.callGetOrderFulfillmentAPI(orderId: self.orderId)
    }
}

extension FulfillmentViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate{
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        if !self.isValidFileExtension(fileExtension: myURL.pathExtension){
            PointtersHelper.sharedInstance.showAlertViewWithTitle("Warning", message: "We don't support this file type, please select another file types.", buttonTitles: ["OK"], viewController: self, completion: nil)
            return
        }
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        do{
            self.selectedData = try Data(contentsOf: myURL)
            
        } catch {
            print("error loading file")
        }
        
        if self.selectedData != nil {
            DispatchQueue.global(qos: .background).async {
                self.uploadImageOnAWS(fileExtension: myURL.pathExtension)
            }
        } else {
            return
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
}

extension FulfillmentViewController: FulfillmentCellDelegate {
    func onSelectMedia(media: Media) {
        let alert = UIAlertController(title: "", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Open", style: .default , handler:{ (UIAlertAction)in
            self.openMedia(media: media)
        }))
        
        alert.addAction(UIAlertAction(title: "Copy Link", style: .default , handler:{ (UIAlertAction)in
            self.copyMediaLink(media: media)
        }))
        
//        if self.isBuyer{
            alert.addAction(UIAlertAction(title: "Download", style: .default , handler:{ (UIAlertAction)in
                self.downloadMedia(media: media)
            }))
//        }
    
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler:{ (UIAlertAction)in
            PointtersHelper.sharedInstance.showAlertViewWithTitle("Confirm Delete", message: "Are you sure?", buttonTitles: ["OK", "Cancel"], viewController: self, completion: { (code) in
                if code == 0{
                    self.deleteMedia(media: media)
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
}

extension FulfillmentViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        let mediaURL = info[UIImagePickerControllerMediaURL] as? URL
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if mediaType == "public.image" {
            let imgName = "image.jpg"
            let documentDirectory = NSTemporaryDirectory()
            let localPath = documentDirectory.appending(imgName)
            
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            let data = UIImageJPEGRepresentation(image, 0.3)! as NSData
            data.write(toFile: localPath, atomically: true)
            let photoURL = URL.init(fileURLWithPath: localPath)
            do{
                self.selectedData = try Data(contentsOf: photoURL)
                
            } catch {
                print("error loading file")
            }
            
            if self.selectedData != nil {
                DispatchQueue.global(qos: .background).async {
                    self.uploadImageOnAWS(fileExtension: photoURL.pathExtension)
                }
            } else {
                return
            }
            
        }
        else if mediaType == "public.movie" {
            do{
                self.selectedData = try Data(contentsOf: mediaURL!)
                
            } catch {
                print("error loading file")
            }
            if self.selectedData != nil {
                DispatchQueue.global(qos: .background).async {
                    self.uploadImageOnAWS(fileExtension: mediaURL!.pathExtension)
                }
            } else {
                return
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension FulfillmentViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let payload_key = userInfo[kFCMMessageIDKey.fcmPayloadKey] as? String{
            switch payload_key{
            case kRedirectKey.orderKey:
                self.refreshPageForNotification()
            default:
                break
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let payload_key = userInfo[kFCMMessageIDKey.fcmPayloadKey] as? String{
            switch payload_key{
            case kRedirectKey.orderKey:
                self.refreshPageForNotification()
            default:
                break
            }
        }
    }
}
