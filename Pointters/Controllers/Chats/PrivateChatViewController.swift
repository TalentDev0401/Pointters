//
//  PrivateChatViewController.swift
//  Pointters
//
//  Created by super on 4/9/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import AWSS3
import AWSCore
import AVFoundation
import UserNotifications

class PrivateChatViewController: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var chatTableView: TPKeyboardAvoidingTableView!

    @IBOutlet weak var msgTextView: UITextView!
    @IBOutlet weak var msgTextField: UITextField!
    @IBOutlet weak var msgInputView: UIView!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var imgSendMsg: UIImageView!
    @IBOutlet weak var btnSendText: UIButton!
    @IBOutlet weak var msgViewBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var consNavBarHeight: NSLayoutConstraint!

    let vPadding:CGFloat = 8.0
    let vBottom:CGFloat = 20.0
    let vSeparatorHeight:CGFloat = 20.0

    var arrMessages = [[String:Any]]()
    var conversationId = ""
    var loginUserId = ""
    var loginUserPic = ""
    var loginUserFirst = ""
    var loginUserLast = ""
    var otherUserId = ""
    var otherUserPic = ""
    var otherUsername = ""
    var strMsg = ""

    var limitCnt = 0
    var totalCnt = 0
    var lastDocId = ""
    var isPagination = false

    var videoURL: NSURL?
    var videoLinkUrl = ""
    var photoLinkUrl = ""

    var selectedData: Data!
    var fileUrl = ""

    var extentions = ["pdf", "doc", "docx", "ppt", "pptx", "xls", "xlsx", "zip"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginUserId = UserCache.sharedInstance.getAccountData().id
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 111.0
        } else {
            consNavBarHeight.constant = 90.0
        }
        msgTextView.isScrollEnabled = false
        //msgInputView.layer.cornerRadius = msgInputView.frame.size.height / 2
        //msgInputView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        //msgInputView.layer.borderWidth = 1.0
        setUserImage()
        self.lblName.text = self.otherUsername
        self.msgViewBottomHeight.constant = 60.0
        self.imgSendMsg.image = UIImage(named: "icon-send")
        self.btnSendText.isUserInteractionEnabled = false

        self.callGetMessages(inited: true, lastID: "", userId: self.otherUserId)

        self.chatTableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0)
        self.chatTableView.register(UINib.init(nibName: "ChatMessageCell", bundle: nil), forCellReuseIdentifier: "ChatMessageCell")
        self.chatTableView.register(UINib.init(nibName: "ChatPhotoCell", bundle: nil), forCellReuseIdentifier: "ChatPhotoCell")
        self.chatTableView.register(UINib.init(nibName: "ChatServiceCell", bundle: nil), forCellReuseIdentifier: "ChatServiceCell")
        self.chatTableView.register(UINib.init(nibName: "ChatCustomCell", bundle: nil), forCellReuseIdentifier: "ChatCustomCell")
        self.chatTableView.register(UINib.init(nibName: "ChatSendRequestCell", bundle: nil), forCellReuseIdentifier: "ChatSendRequestCell")
        self.chatTableView.register(UINib.init(nibName: "ChatSendRequestOfferCell", bundle: nil), forCellReuseIdentifier: "ChatSendRequestOfferCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        self.callGetMessages(inited: true, lastID: "", userId: self.otherUserId)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadChatHistory), name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showRequestMenu() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let customOffer: UIAlertAction = UIAlertAction(title: "Send Custom Offer", style: .default) { action -> Void in
            
            UserDefaults.standard.set(1, forKey: "Custom_Offer_Message")
            UserDefaults.standard.synchronize()
            let storyboard = UIStoryboard(name: "Explore", bundle: nil)
            let sendCustomOfferVC = storyboard.instantiateViewController(withIdentifier: "SendOfferVC") as! SendOfferViewController
            sendCustomOfferVC.buyerId = self.otherUserId
            sendCustomOfferVC.customOfferDelegate = self
            self.navigationController?.pushViewController(sendCustomOfferVC, animated:true)
        }
        let request: UIAlertAction = UIAlertAction(title: "Send Request", style: .default) { action -> Void in
            let storyboard = UIStoryboard(name: "Explore", bundle: nil)
            let sendRequestVC = storyboard.instantiateViewController(withIdentifier: "SendRequestVC") as! SendRequestViewController
            sendRequestVC.isEdit = false
            sendRequestVC.pageFlag = 1
            sendRequestVC.sellerId = self.otherUserId
            sendRequestVC.sendRequestDelegate = self
            self.navigationController?.pushViewController(sendRequestVC, animated: true)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

        // add actions
        actionSheetController.addAction(customOffer)
        actionSheetController.addAction(request)
        actionSheetController.addAction(cancelAction)

        // present an actionSheet
        present(actionSheetController, animated: true, completion: nil)
    }
    
    // MARK: - IBAction methods
    
    @IBAction func btnMsgSendTapped(_ sender: Any) {
        self.msgTextView.resignFirstResponder()

        // send message to server
        var dictSend:[String:Any] = [:]

        dictSend["userId"] = self.loginUserId
        dictSend["conversationId"] = self.conversationId
        dictSend["messageText"] = self.strMsg

        dictSend["toUserId"] = self.otherUserId
        self.sendMessageToApi(dict: dictSend)

        // show the message
        var dictMessage = [String:Any]()
        dictMessage["messageText"] = self.strMsg
        dictMessage["createdAt"] = getCurrentDateTime()

        var dictUser = [String:Any]()
        dictUser["userId"] = self.loginUserId
        dictUser["profilePic"] = self.loginUserPic

        var dictResult = [String:Any]()
        dictResult["message"] = dictMessage
        dictResult["user"] = dictUser

        var dictInfo = [String:Any]()
        dictInfo["result"] = dictResult

        addMessageBySocket(dict: dictInfo)

        // initialize after sending
        self.strMsg = ""
        self.msgTextView.text = "Enter message here"
        self.msgTextView.isScrollEnabled = false
        self.imgSendMsg.image = UIImage(named: "icon-send")
        self.btnSendText.isUserInteractionEnabled = false
        
        let size = CGSize(width: self.msgTextView.frame.width, height: 100)
        let estimatedSize = self.msgTextView.sizeThatFits(size)
        self.msgTextView.isScrollEnabled = true
        self.msgTextView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        
        self.msgInputView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        
        self.msgView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        
    }

    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func btnProfileTapped(_ sender: Any) {
        UserCache.sharedInstance.setProfileUser(loginUser: false, userId: otherUserId)
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        navigationController?.pushViewController(userProfileVC, animated:true)
    }

    @IBAction func btnSendTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        let sendServiceVC = storyboard.instantiateViewController(withIdentifier: "SendServicesVC") as! SendServicesViewController
        sendServiceVC.toUserId = otherUserId
        sendServiceVC.sendDelegate = self
        navigationController?.pushViewController(sendServiceVC, animated:true)
    }

    @IBAction func btnCustomTapped(_ sender: Any) {
        self.showRequestMenu()
    }

    @IBAction func btnCameraTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = .camera
            cameraPicker.delegate = self
            cameraPicker.mediaTypes = ["public.image"]
            cameraPicker.videoQuality = .type640x480
            present(cameraPicker, animated: false, completion: nil)
        }
    }

    @IBAction func btnVideoTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = .camera
            cameraPicker.delegate = self
            cameraPicker.mediaTypes = ["public.movie"]
            cameraPicker.videoQuality = .type640x480
            present(cameraPicker, animated: false, completion: nil)
        }
    }
    @IBAction func btnFileTapped(_ sender: Any) {
        let menu = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF), String(kUTTypeData), String(kUTTypeBMP), String(kUTTypePNG), String(kUTTypeJPEG), String(kUTTypeGIF)], in: .import)
        menu.delegate = self
        menu.modalPresentationStyle = .formSheet
        self.present(menu, animated: true, completion: nil)
    }

    @IBAction func btnPhotoTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.mediaTypes = ["public.image", "public.movie"]
            imagePicker.videoQuality = .type640x480
            present(imagePicker, animated: false, completion: nil)
        }
    }

    // MARK: - Private methods
    
    func setUserImage() {
        imgProfile.sd_imageTransition = .fade
        imgProfile.sd_setImage(with: URL(string: otherUserPic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2
    }

    func processMessage(result: [String: Any]) {
        DispatchQueue.main.async { () -> Void in
            if let dict = result["result"] as? [String:Any] {
                let dictMessage = dict["message"] as! [String:Any]
                var dictUser = [String:Any]()
                dictUser["userId"] = self.otherUserId
                dictUser["profilePic"] = self.otherUserPic

                var dictResult = [String:Any]()
                dictResult["message"] = dictMessage
                dictResult["user"] = dictUser

                var dictInfo = [String:Any]()
                dictInfo["result"] = dictResult

                self.addMessageBySocket(dict: dictInfo)
            }
        }
    }

    // MARK: - API calls
    
    func callGetMessages(inited: Bool, lastID: String, userId: String){
        if !inited {
            PointtersHelper.sharedInstance.startLoader(view: view)
        }

        ApiHandler.callGetMessagesWithUserId(lastId: lastID, userId: userId, withCompletionHandler:{ (result,statusCode,response) in

            if inited {
                self.arrMessages.removeAll()
            } else {
                PointtersHelper.sharedInstance.stopLoader()
            }

            let prevCount = self.arrMessages.count
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    self.limitCnt = responseDict["limit"] as! Int
                    self.totalCnt = responseDict["total"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String

                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for message in arr {
                            self.arrMessages.insert(message, at: 0)
                        }
                        print("All messages is \(self.arrMessages)")
                    }
                }
            }
            else {
                //print(response.error ?? "")
            }

            self.chatTableView.reloadData()
            if (inited && self.arrMessages.count > 0) {
                self.chatTableView.scrollToRow(at: IndexPath(item: 0, section: self.arrMessages.count-1), at: .bottom, animated: false)
            } else {
                if prevCount > 0 {
                    self.chatTableView.scrollToRow(at: IndexPath(item: 0, section: self.arrMessages.count-1-prevCount), at: .top, animated: false)
                }
            }

            self.isPagination = true
        })
    }

    func sendMessageToApi(dict: [String: Any]) {
        ApiHandler.sendMessage(params: dict, withCompletionHandler:{ (result,statusCode,response) in
            if result == true {
                if statusCode == 200 {
                    print("message sent")
                }
            }
            else {
                print(response.error?.localizedDescription ?? "")
            }
        })
    }

    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.msgViewBottomHeight?.constant = 60.0
            } else {
                if PointtersHelper.sharedInstance.checkiPhonX()  {
                    self.msgViewBottomHeight?.constant = -25
                } else {
                    self.msgViewBottomHeight?.constant = endFrame?.size.height ?? 60.0
                }
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }

    @objc func reloadChatHistory() {
        msgTextView.resignFirstResponder()
        callGetMessages(inited: true, lastID: "", userId: self.otherUserId)
    }

    // MARK: - Send messages with various type
    
    func sendMessageForMedia(type: String, link: String, videoThumb: String) {
        // send message to server
        var dict:[String:Any] = [:]
        dict["mediaType"] = type
        dict["fileName"] = link
        if videoThumb != "" {
            dict["videoThumbnail"] = videoThumb
        }

        var dictMedia = [[String:Any]]()
        dictMedia.append(dict)

        var dictSend = [String:Any]()
        dictSend["userId"] = self.loginUserId
        dictSend["conversationId"] = self.conversationId
        dictSend["media"] = dictMedia

        dictSend["toUserId"] = self.otherUserId
        self.sendMessageToApi(dict: dictSend)

        // show the message
        var dictMessage = [String:Any]()
        dictMessage["media"] = dictMedia
        dictMessage["createdAt"] = getCurrentDateTime()

        var dictUser = [String:Any]()
        dictUser["userId"] = self.loginUserId
        dictUser["profilePic"] = self.loginUserPic

        var dictResult = [String:Any]()
        dictResult["message"] = dictMessage
        dictResult["user"] = dictUser

        var dictInfo = [String:Any]()
        dictInfo["result"] = dictResult

        addMessageBySocket(dict: dictInfo)
    }

    func sendMessageForDoc(type: String, link: String, fileExtension: String) {
        // send message to server
        var dict:[String:Any] = [:]
        dict["mediaType"] = type
        dict["fileName"] = link
        dict["fileExtension"] = fileExtension

        var dictMedia = [[String:Any]]()
        dictMedia.append(dict)

        var dictSend = [String:Any]()
        dictSend["userId"] = self.loginUserId
        dictSend["conversationId"] = self.conversationId
        dictSend["media"] = dictMedia

        dictSend["toUserId"] = self.otherUserId
        self.sendMessageToApi(dict: dictSend)

        // show the message
        var dictMessage = [String:Any]()
        dictMessage["media"] = dictMedia
        dictMessage["createdAt"] = getCurrentDateTime()

        var dictUser = [String:Any]()
        dictUser["userId"] = self.loginUserId
        dictUser["profilePic"] = self.loginUserPic

        var dictResult = [String:Any]()
        dictResult["message"] = dictMessage
        dictResult["user"] = dictUser

        var dictInfo = [String:Any]()
        dictInfo["result"] = dictResult

        addMessageBySocket(dict: dictInfo)
    }

    func uploadImageOnAWS(imgData: Data,image: UIImage,withCompletionHandler:@escaping (_ result:Bool) -> Void){

        let accessKey = kAWSCredentials.kAccessKey
        let secretKey = kAWSCredentials.kSecretKey
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        let index = Int64(Date().timeIntervalSince1970 * 1000)
        let remoteName = "service_pic \(index)" + UIDevice.current.identifierForVendor!.uuidString
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
                //print("Upload failed with error: (\(error.localizedDescription))")
                withCompletionHandler(false)
            }

            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)

                self.photoLinkUrl = (publicURL?.absoluteString)!

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

        let index = Int64(Date().timeIntervalSince1970 * 1000)
        let remoteName = "service_video \(index)" + UIDevice.current.identifierForVendor!.uuidString

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

                self.videoLinkUrl = (publicURL?.absoluteString)!

                DispatchQueue.main.async {
                    withCompletionHandler(true)
                }
            }
            return nil
        }
    }

    @objc func onTapOffer(_ sender: UITapGestureRecognizer) {
        let cell_point:CGPoint = sender.location(in: self.chatTableView)
        let indexPath = self.chatTableView.indexPathForRow(at: cell_point)

        if indexPath != nil {
            let dictInfo = arrMessages[(indexPath?.section)!]
            let dictResult = dictInfo["result"] as! [String: Any]
            let dictMsg = dictResult["message"] as! [String:Any]
            let dictUser = dictResult["user"] as! [String:Any]

            if let dictOffer = dictMsg["offer"] as? [String:Any] {
                if let offerId = dictOffer["offerId"] as? String, offerId != ""  {
                    if let userId = dictUser["userId"] as? String, userId == self.loginUserId {
                        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
                        let sendCustomOfferVC = storyboard.instantiateViewController(withIdentifier: "SendOfferVC") as! SendOfferViewController
                        sendCustomOfferVC.customOfferDelegate = self
                        sendCustomOfferVC.offerId = offerId
                        sendCustomOfferVC.buyerId = self.otherUserId
                        navigationController?.pushViewController(sendCustomOfferVC, animated:true)
                    } else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let customOfferDetailsVC = storyboard.instantiateViewController(withIdentifier: "OfferDetailVC") as! OfferDetailViewController
                        customOfferDetailsVC.offerId = offerId
                        navigationController?.pushViewController(customOfferDetailsVC, animated:true)
                    }
                } else {
                    return
                }
            }
        }
    }

    @objc func onTapService(_ sender: UITapGestureRecognizer) {
        let cell_point:CGPoint = sender.location(in: self.chatTableView)
        let indexPath = self.chatTableView.indexPathForRow(at: cell_point)

        if indexPath != nil {
            let dictInfo = arrMessages[(indexPath?.section)!]
            let dictResult = dictInfo["result"] as! [String: Any]
            let dictMsg = dictResult["message"] as! [String:Any]

            if let dictService = dictMsg["service"] as? [String:Any] {
                if let serviceId = dictService["serviceId"] as? String, serviceId != ""  {
                    let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
                    let serviceDetailsVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
                    serviceDetailsVC.serviceId = serviceId
                    navigationController?.pushViewController(serviceDetailsVC, animated:true)
                } else {
                    return
                }
            }
        }
    }
    
    @objc func onTapRequestOffer(_ sender: UITapGestureRecognizer) {
        let cell_point:CGPoint = sender.location(in: self.chatTableView)
        let indexPath = self.chatTableView.indexPathForRow(at: cell_point)
        
        if indexPath != nil {
            let dictInfo = arrMessages[(indexPath?.section)!]
            let dictResult = dictInfo["result"] as! [String: Any]
            let dictMsg = dictResult["message"] as! [String:Any]
           
            if let dictService = dictMsg["offer"] as? [String:Any] {
                if let requestId = dictService["requestId"] as? String, requestId != ""  {
                    UserDefaults.standard.set(1, forKey: "Custom_Offer_Message")
                    UserDefaults.standard.synchronize()
                    let storyboard = UIStoryboard(name: "Explore", bundle: nil)
                    let sendRequestOfferVC = storyboard.instantiateViewController(withIdentifier: "SendOfferVC") as! SendOfferViewController
                    sendRequestOfferVC.requestId = dictService["requestId"] as! String
                    sendRequestOfferVC.buyerId = self.otherUserId
                    sendRequestOfferVC.isJobOffer = true
                    sendRequestOfferVC.isFromRequest = false
                    sendRequestOfferVC.offerId = dictService["requestOfferId"] as! String
                    sendRequestOfferVC.isEdit = true
                    sendRequestOfferVC.customOfferDelegate = self
                    self.navigationController?.pushViewController(sendRequestOfferVC, animated:true)
                }
            }
        }
    }
    
    @objc func onTapRequest(_ sender: UITapGestureRecognizer) {
        let cell_point:CGPoint = sender.location(in: self.chatTableView)
        let indexPath = self.chatTableView.indexPathForRow(at: cell_point)
        
        if indexPath != nil {
            let dictInfo = arrMessages[(indexPath?.section)!]
            let dictResult = dictInfo["result"] as! [String: Any]
            let dictMsg = dictResult["message"] as! [String:Any]
            let dictUser = dictResult["user"] as! [String:Any]

            if let dictService = dictMsg["request"] as? [String:Any] {
                if let requestId = dictService["requestId"] as? String, requestId != ""  {
                    if let userId = dictUser["userId"] as? String, userId == self.loginUserId {
                        
                        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
                        let sendRequestVC = storyboard.instantiateViewController(withIdentifier: "SendRequestVC") as! SendRequestViewController
                        sendRequestVC.isEdit = true
                        sendRequestVC.requestId = requestId
                        sendRequestVC.pageFlag = 1
                        sendRequestVC.sellerId = self.otherUserId
                        sendRequestVC.sendRequestDelegate = self
                        self.navigationController?.pushViewController(sendRequestVC, animated: true)
                        
                    } else {
                        
                        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
                        let sendRequestVC = storyboard.instantiateViewController(withIdentifier: "SendRequestVC") as! SendRequestViewController
                        sendRequestVC.isJobOffer = true
                        sendRequestVC.isEdit = false
                        sendRequestVC.requestId = requestId
                        sendRequestVC.sellerId = self.otherUserId
                        sendRequestVC.pageFlag = 1
                        sendRequestVC.sendRequestDelegate = self
                        
                        if let requestOfferDict = dictService["requestOffer"] as? [String:Any] {
                            if let requestOfferId = requestOfferDict["_id"] as? String {
                                sendRequestVC.isEdit = true
                                sendRequestVC.offerId = requestOfferId
                            }
                        }
                        self.navigationController?.pushViewController(sendRequestVC, animated: true)
                    }
                } else {
                    return
                }
            }
        }
    }

    @objc func onTapMedia(_ sender: UITapGestureRecognizer) {
        let cell_point:CGPoint = sender.location(in: self.chatTableView)
        let indexPath = self.chatTableView.indexPathForRow(at: cell_point)

        if indexPath != nil {
            let dictInfo = arrMessages[(indexPath?.section)!]
            let dictResult = dictInfo["result"] as! [String: Any]
            let dictMsg = dictResult["message"] as! [String:Any]

            if let arrMedia = dictMsg["media"] as? [[String:Any]], arrMedia.count > 0 {
                var strType = "image", strPic = ""
                if let _ = arrMedia[0]["mediaType"] {
                    strType = arrMedia[0]["mediaType"] as! String
                }
                if let _ = arrMedia[0]["fileName"] {
                    strPic = arrMedia[0]["fileName"] as! String
                }

                if strPic != "" {
                    if strType == "video" {
                        videoPlayer(url: strPic)
                    } else if strType == "image" {
                        imagePlayer(url: strPic)
                    } else if strType == "document" {
                        fileOpener(url: strPic, fileExtention: arrMedia[0]["fileExtension"] as! String)
                    }
                }
            }
        }
    }
    @objc func onTapMessage(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let cell_point:CGPoint = sender.location(in: self.chatTableView)
            let indexPath = self.chatTableView.indexPathForRow(at: cell_point)

            if indexPath != nil {
                let dictInfo = arrMessages[(indexPath?.section)!]
                let dictResult = dictInfo["result"] as! [String: Any]
                let dictMsg = dictResult["message"] as! [String:Any]
                let message = dictMsg["messageText"] as? String
                UIPasteboard.general.string = message
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Copied message. \(message ?? "")", buttonTitles: ["OK"], viewController: self, completion: nil)
            }

        }
    }

    func videoPlayer(url: String) {
        let playURL = NSURL(string: url)
        let player = AVPlayer(url: playURL! as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }

    func imagePlayer(url: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fullScreenImageVC = storyboard.instantiateViewController(withIdentifier: "FullScreenImageVC") as! FullScreenImageViewController
        fullScreenImageVC.imageUrl = url
        navigationController?.pushViewController(fullScreenImageVC, animated:false)
    }

    func fileOpener(url: String, fileExtention: String) {
        let alert = UIAlertController(title: "", message: "Please Select an Option", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Copy Link", style: .default , handler:{ (UIAlertAction)in
            UIPasteboard.general.string  = url
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Copied to clipboard: \(url)", buttonTitles: ["OK"], viewController: self, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: "Download", style: .default , handler:{ (UIAlertAction)in
            let media = Media.init()
            media.fileName = url
            media.fileExtension = fileExtention
            media.id = String.random(length: 5)
            self.downloadFileFromS3(media: media)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            //print("User click Dismiss button")
        }))

        self.present(alert, animated: true, completion: {
            //print("completion block")
        })
    }

    func getServiceInfo(service:[String:Any], id:String) -> [String:Any] {
        var strDesc = ""
        if let _ = service["description"] {
            strDesc = service["description"] as! String
        }

        var dictMedia = [String:Any]()
        if let _ = service["media"] {
            if service["media"] is Dictionary<AnyHashable,Any> {
                dictMedia = service["media"] as! [String:Any]
            } else {
                let arrMedia = service["media"] as! [[String:Any]]
                if arrMedia.count > 0 {
                    dictMedia = arrMedia[0]
                }
            }
        }

        var dictPrice = [String:Any]()
        if let _ = service["prices"] {
            if service["prices"] is Dictionary<AnyHashable,Any> {
                dictPrice = service["prices"] as! [String:Any]
            } else {
                let arrPrices = service["prices"] as! [[String:Any]]
                if arrPrices.count > 0 {
                    dictPrice = arrPrices[0]
                }
            }
        }

        var dictSeller = [String:Any]()
        dictSeller["firstName"] = self.loginUserFirst
        dictSeller["lastName"] = self.loginUserLast

        var dictService = [String:Any]()
        dictService["serviceId"] = id
        dictService["description"] = strDesc
        dictService["media"] = dictMedia
        dictService["price"] = dictPrice
        dictService["seller"] = dictSeller

        return dictService
    }

    func sendMessageForService(service: [String:Any], serviceType: Bool) {
        var serviceId = ""
        var dictService = [String:Any]()

        // send message to server
        if serviceType {
            serviceId = service["id"] as! String
            dictService = service
        } else {
            dictService = service["service"] as! [String:Any]
            if let _ = dictService["id"] {
                serviceId = dictService["id"] as! String
            }
        }

        var dictSend = [String:Any]()
        dictSend["userId"] = self.loginUserId
        dictSend["conversationId"] = self.conversationId
        dictSend["serviceId"] = serviceId

        dictSend["toUserId"] = self.otherUserId
        self.sendMessageToApi(dict: dictSend)

        // show the message
        var dictMessage = [String:Any]()
        dictMessage["service"] = getServiceInfo(service: dictService, id: serviceId)
        dictMessage["createdAt"] = getCurrentDateTime()

        var dictUser = [String:Any]()
        dictUser["userId"] = self.loginUserId
        dictUser["profilePic"] = self.loginUserPic

        var dictResult = [String:Any]()
        dictResult["message"] = dictMessage
        dictResult["user"] = dictUser

        var dictInfo = [String:Any]()
        dictInfo["result"] = dictResult

        addMessageBySocket(dict: dictInfo)
    }
    
    func sendMessageForRequest(request: [String:Any]) {
        var requestId = ""
        
        // send message to server
        if let reId = request["_id"] as? String {
            requestId = reId
        }

        var dictSend = [String:Any]()
        dictSend["userId"] = self.loginUserId
        dictSend["conversationId"] = self.conversationId
        dictSend["requestId"] = requestId
        dictSend["toUserId"] = self.otherUserId
        self.sendMessageToApi(dict: dictSend)

        // show the message
        var dictMessage = [String:Any]()
        dictMessage["request"] = request
        dictMessage["createdAt"] = getCurrentDateTime()

        var dictUser = [String:Any]()
        dictUser["userId"] = self.loginUserId
        dictUser["profilePic"] = self.loginUserPic

        var dictResult = [String:Any]()
        dictResult["message"] = dictMessage
        dictResult["user"] = dictUser

        var dictInfo = [String:Any]()
        dictInfo["result"] = dictResult

        addMessageBySocket(dict: dictInfo)
    }
    
    func sendMessageForRequestOffer(offerId: String, offerPrice:[String:Any], linkService:[String:Any], isLinked:Bool) {
        
        // send message to server
        var dictSend = [String:Any]()
        dictSend["userId"] = self.loginUserId
        dictSend["conversationId"] = self.conversationId
        dictSend["requestOfferId"] = offerId

        dictSend["toUserId"] = self.otherUserId
        self.sendMessageToApi(dict: dictSend)
        
        // show the message
        var dictMessage = [String:Any]()
        dictMessage["requestOffer"] = linkService
        dictMessage["createdAt"] = getCurrentDateTime()

        var dictUser = [String:Any]()
        dictUser["userId"] = self.loginUserId
        dictUser["profilePic"] = self.loginUserPic

        var dictResult = [String:Any]()
        dictResult["message"] = dictMessage
        dictResult["user"] = dictUser

        var dictInfo = [String:Any]()
        dictInfo["result"] = dictResult

        //addMessageBySocket(dict: dictInfo)
        reloadChatHistory()
    }

    func sendMessageForOffer(offerId: String, offerPrice:[String:Any], linkService:[String:Any], isLinked:Bool) {
        // send message to server
        var dictSend = [String:Any]()
        dictSend["userId"] = self.loginUserId
        dictSend["conversationId"] = self.conversationId
        dictSend["offerId"] = offerId

        dictSend["toUserId"] = self.otherUserId
        self.sendMessageToApi(dict: dictSend)

        // show the message
        var dictOffer = [String:Any]()
        dictOffer["offerId"] = offerId
        dictOffer["price"] = offerPrice["price"] as! Float
        dictOffer["currencySymbol"] = offerPrice["currencySymbol"] as! String
        dictOffer["workDuration"] = offerPrice["workDuration"] as! Int
        dictOffer["workDurationUom"] = offerPrice["workDurationUom"] as! String
        if isLinked {
            dictOffer["service"] = linkService
        }

        var dictMessage = [String:Any]()
        dictMessage["offer"] = dictOffer
        dictMessage["createdAt"] = getCurrentDateTime()

        var dictUser = [String:Any]()
        dictUser["userId"] = self.loginUserId
        dictUser["profilePic"] = self.loginUserPic

        var dictResult = [String:Any]()
        dictResult["message"] = dictMessage
        dictResult["user"] = dictUser

        var dictInfo = [String:Any]()
        dictInfo["result"] = dictResult

        addMessageBySocket(dict: dictInfo)
    }

    func getCurrentDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.string(from: Date())
    }

    func addMessageBySocket(dict:[String:Any]) {
        self.arrMessages.insert(dict, at: self.arrMessages.count)
        self.chatTableView.reloadData()
        self.chatTableView.scrollToRow(at: IndexPath(item: 0, section: self.arrMessages.count-1), at: .bottom, animated: false)
    }

    func thumbnailForVideoAtURL(_ url: URL) -> UIImage? {

        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)

        var time = asset.duration
        time.value = min(time.value, 2)

        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            //print("error")
            return nil
        }
    }

    //MARK:upload files to sw3

    func uploadFilesOnAWS(fileExtension: String) {
        let accessKey = kAWSCredentials.kAccessKey
        let secretKey = kAWSCredentials.kSecretKey
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        let remoteName = "chat_file_deliver_"  + String.random(length: 5)
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
        self.fileUrl = (publicURL?.absoluteString)!

        let transferManager = AWSS3TransferManager.default()

        transferManager.upload(uploadRequest).continueWith { (task: AWSTask<AnyObject>) -> Any? in
            if let error = task.error {
                //print("Upload failed with error: (\(error.localizedDescription))")
                DispatchQueue.main.async {
                    PointtersHelper.sharedInstance.stopLoader()
                }
            }

            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)

                let mediaType = PointtersHelper.sharedInstance.generateMediaType(withExtension: fileExtension)
                DispatchQueue.main.async {
                    self.sendMessageForDoc(type: mediaType, link: self.fileUrl, fileExtension: fileExtension)
                    self.fileUrl = ""
                    PointtersHelper.sharedInstance.stopLoader()
                }
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
                //print("Download failed with error: (\(error.localizedDescription))")
                DispatchQueue.main.async {
                    PointtersHelper.sharedInstance.stopLoader()
                }
            }

            if task.result != nil {
                //print(downloadedFileURL)
                let fileManager = FileManager.default
                let directory : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let destinationPath = directory.appendingFormat("/Pointters_chat_file_\(media.id).\(media.fileExtension)")
                let destinationURL = URL.init(fileURLWithPath: destinationPath)
                do {
                    try fileManager.removeItem(at: destinationURL)
                } catch {
                    //print("Error Removing Item At \(destinationURL.path)")
                }
                do {
                    try fileManager.copyItem(at: downloadedFileURL, to: destinationURL)
                    //print(destinationURL)
                } catch {
                    //This is line always //printing. my try statement always throwing.
                    //print("Error Copying Item from \(downloadedFileURL.path) to \(destinationURL.path)")
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
}

// ServiceDetailDetailsDelegate
//extension PrivateChatViewController:ServiceDetailsDelegate {
//    func returnFromServiceDetails(reload: Bool) {
//        if reload {
//            reloadChatHistory()
//        }
//    }
//}

// CustomOfferDetailsDelegate
//extension PrivateChatViewController:CustomOfferDetailsDelegate {
//    func returnFromCustomOfferDetails(reload: Bool) {
//        if reload {
//            reloadChatHistory()
//        }
//    }
//}

// MARK: - SendServiceDelegate

extension PrivateChatViewController: SendServiceDelegate {
    func returnFromSendService(reload: Bool) {
        if reload {
            reloadChatHistory()
        }
    }

    func selectSendService(selected: [String : Any], serviceType: Bool) {
        sendMessageForService(service: selected, serviceType: serviceType)
    }
}

// MARK: - SendCustomOfferDelegate

extension PrivateChatViewController: SendCustomOfferDelegate {
    func returnFromRequestOffers(reload: Bool) {
        if reload {
            reloadChatHistory()
        }
    }
    
    func selectSendRequestOffers(selId:String, selPrice:[String:Any], linkedService: [String:Any], link:Bool) {
        sendMessageForRequestOffer(offerId: selId, offerPrice: selPrice, linkService: linkedService, isLinked: link)
    }
    func selectSendCustomOffer(selId:String, selPrice:[String:Any], linkedService: [String:Any], link:Bool) {
        sendMessageForOffer(offerId: selId, offerPrice:selPrice, linkService:linkedService, isLinked:link)
    }
    func returnFromCustomOffer(reload: Bool) {
        if reload {
            reloadChatHistory()
        }
    }
}

// MARK: - SendRequestDelegate

extension PrivateChatViewController: SendRequestDelegate {
    func selectSendRequestOffer(selId: String, selPrice: [String : Any], linkedService: [String : Any], link: Bool) {
        sendMessageForRequestOffer(offerId: selId, offerPrice: selPrice, linkService: linkedService, isLinked: link)
    }
    
    func returnFromSendRequestOffer(reload: Bool) {
        if reload {
            reloadChatHistory()
        }
    }
    
    func selectSendRequest(request: [String:Any]) {
        sendMessageForRequest(request: request)
    }
    
    func returnFromRequest(reload: Bool) {
        if reload {
            reloadChatHistory()
        }
    }
}

// MARK: - UITextViewDelegate
extension PrivateChatViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text=="Enter message here" {
        textView.text = ""
    }
  }

  func textViewDidChange(_ textView: UITextView) {
    //print("textView.frame.width " + (NSString(format: "%.2f", textView.frame.width) as String) as String)
    let size = CGSize(width: textView.frame.width, height: 100)
    let estimatedSize = textView.sizeThatFits(size)
    //print("textView width  " + (NSString(format: "%.2f", estimatedSize.width) as String) as String)
    //print("textView height  " + (NSString(format: "%.2f", estimatedSize.height) as String) as String)
    if estimatedSize.height >= 120 {
      msgTextView.isScrollEnabled = true
    } else {
      textView.constraints.forEach { (constraint) in
          if constraint.firstAttribute == .height {
              //print("constraint height  " + (NSString(format: "%.2f", constraint.constant) as String) as String)
              constraint.constant = estimatedSize.height
          }
      }

      msgInputView.constraints.forEach { (constraint) in
          if constraint.firstAttribute == .height && estimatedSize.height > constraint.constant && estimatedSize.height < 120 {
              //print("msgInputView.frame.size.height  " + (NSString(format: "%.2f", msgInputView.frame.size.height) as String) as String)
              constraint.constant = estimatedSize.height
          }
      }

      msgView.constraints.forEach { (constraint) in
          if constraint.firstAttribute == .height && estimatedSize.height > constraint.constant && estimatedSize.height < 120 {
              //print("msgView.frame.size.height  " + (NSString(format: "%.2f", msgView.frame.size.height) as String) as String)
              constraint.constant = estimatedSize.height
          }
      }
    }

  }

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        self.strMsg = currentText.replacingCharacters(in: stringRange, with: text)
        if self.strMsg != "" {
            self.imgSendMsg.image = UIImage(named: "icon-send-blue")
            self.btnSendText.isUserInteractionEnabled = true
        } else {
            self.imgSendMsg.image = UIImage(named: "icon-send")
            self.btnSendText.isUserInteractionEnabled = false
        }

        return true
  }
}

// MARK: - UITextFieldDelegate
extension PrivateChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }

        self.strMsg = currentText.replacingCharacters(in: stringRange, with: string)
        if self.strMsg != "" {
            self.imgSendMsg.image = UIImage(named: "icon-send-blue")
            self.btnSendText.isUserInteractionEnabled = true
        } else {
            self.imgSendMsg.image = UIImage(named: "icon-send")
            self.btnSendText.isUserInteractionEnabled = false
        }

        return true
    }
}

// MARK: - UITableViewDataSource
extension PrivateChatViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrMessages.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell") as? ChatBaseCell
        let dictInfo = arrMessages[indexPath.section]
        if indexPath.section == arrMessages.count-1 {
//            //print(dictInfo)
        }
        let dictResult = dictInfo["result"] as! [String: Any]

        // user info
        var incoming = false, strPic = ""
        if let dictUser = dictResult["user"] as? [String: Any] {
            if let userId = dictUser["userId"] as? String {
                incoming = (userId == self.otherUserId) ? true : false
            }
            if let _ = dictUser["profilePic"] {
                strPic = dictUser["profilePic"] as! String
                if !strPic.contains("https://s3.amazonaws.com"){
                    strPic = "https://s3.amazonaws.com" + strPic
                }
            }
        }

        var userData = [String:Any]()
        userData["income"] = incoming
        userData["sender_photo"] = self.otherUserPic

        // message info
        if let dictMsg = dictResult["message"] as? [String:Any] {
            if let msgPhoto = dictMsg["media"] as? [[String:Any]], msgPhoto.count > 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "ChatPhotoCell") as? ChatBaseCell
                let tapMedia = UITapGestureRecognizer(target: self, action: #selector(onTapMedia(_:)))
                cell?.viewMessage.addGestureRecognizer(tapMedia)
            }
            else if let _ = dictMsg["service"] as? [String:Any] {
                cell = tableView.dequeueReusableCell(withIdentifier: "ChatServiceCell") as? ChatBaseCell
                let tapService = UITapGestureRecognizer(target: self, action: #selector(onTapService(_:)))
                cell?.viewMessage.addGestureRecognizer(tapService)
            }
            else if let dictOffer = dictMsg["offer"] as? [String:Any] {
                if let _ = dictOffer["requestOfferId"] as? String {
                    cell = tableView.dequeueReusableCell(withIdentifier: "ChatSendRequestOfferCell") as? ChatBaseCell
                    let tapRequestOffer = UITapGestureRecognizer(target: self, action: #selector(onTapRequestOffer(_:)))
                    cell?.viewMessage.addGestureRecognizer(tapRequestOffer)
                } else {
                    if let _ = dictOffer["service"] as? [String:Any] {
                        cell = tableView.dequeueReusableCell(withIdentifier: "ChatCustomCell") as? ChatBaseCell
                    }
                    let tapOffer = UITapGestureRecognizer(target: self, action: #selector(onTapOffer(_:)))
                    cell?.viewMessage.addGestureRecognizer(tapOffer)
                }
            }
            else if let _ = dictMsg["request"] as? [String:Any] {
                cell = tableView.dequeueReusableCell(withIdentifier: "ChatSendRequestCell") as? ChatBaseCell
                let tapRequest = UITapGestureRecognizer(target: self, action: #selector(onTapRequest(_:)))
                cell?.viewMessage.addGestureRecognizer(tapRequest)
            }
            else {
                let tapMessage = UILongPressGestureRecognizer(target: self, action: #selector(onTapMessage(_:)))
                cell?.viewMessage.addGestureRecognizer(tapMessage)
            }

            cell?.setUserData(userData: userData)
            cell?.setData(message: dictMsg)
        }

        cell?.backgroundColor = UIColor.clear

        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dictInfo = arrMessages[indexPath.section]
        let dictResult = dictInfo["result"] as! [String: Any]

        var height:CGFloat = 100.0
        if let dictMsg = dictResult["message"] as? [String:Any] {
            if let msgText = dictMsg["messageText"] as? String, msgText != "" {
                let preferredWidth = UIScreen.main.bounds.size.width - 130.0
                //print("preferredWidth " + (NSString(format: "%.2f", preferredWidth) as String))
                let boundsHeight = msgText.height(withConstrainedWidth: preferredWidth, font: UIFont(name: "Helvetica", size: 17)!)
                //print("boundsHeight " + (NSString(format: "%.2f", boundsHeight) as String))
                height = boundsHeight + 2 * vPadding + vBottom
                //print("height " + (NSString(format: "%.2f", height) as String))
            }
            if let msgPhoto = dictMsg["media"] as? [[String:Any]], msgPhoto.count > 0 {
                let nMsgWidth = UIScreen.main.bounds.size.width - 80.0 * 2
                height = nMsgWidth + vSeparatorHeight
                if(height > 220.0){
                    height = 220.0;
                }
            }
            if let _ = dictMsg["service"] as? [String:Any] {
                height = 100.0
            }
            if let dictOffer = dictMsg["offer"] as? [String:Any] {
                if let _ = dictOffer["requestOfferId"] as? String {
                    height = 125
                } else {
                    if let _ = dictOffer["service"] as? [String:Any] {
                        height = 130.0
                    }
                    else {
                        var valPrice = 0
                        if let _ = dictOffer["price"] {
                            valPrice = dictOffer["price"] as! Int
                        }
                        var strSymbol = "$"
                        if let _ = dictOffer["currencySymbol"] {
                            strSymbol = dictOffer["currencySymbol"] as! String
                        }
                        var valWorkTime = 1
                        if let _ = dictOffer["workDuration"] {
                            valWorkTime = dictOffer["workDuration"] as! Int
                        }
                        var strWorkUnit = "hour"
                        if let _ = dictOffer["workDurationUom"] {
                            strWorkUnit = dictOffer["workDurationUom"] as! String
                        }

                        var strOffer = ""
                        if valWorkTime > 1 {
                            strOffer = "Custom offer " + strSymbol + String(valPrice) + " Service for " + String(valWorkTime) + " " + strWorkUnit + "s"
                        } else {
                            strOffer = "Custom offer " + strSymbol + String(valPrice) + " Service for " + String(valWorkTime) + " " + strWorkUnit
                        }

                        let preferredWidth = UIScreen.main.bounds.size.width - 130.0
                        let boundsHeight = strOffer.height(withConstrainedWidth: preferredWidth, font: UIFont(name: "Helvetica", size: 17)!)
                        height = boundsHeight + 2 * vPadding + vBottom
                    }
                }
            }
            
            if let _ = dictMsg["request"] as? [String:Any] {
                height = 135
            }
        }

        return height;
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 6.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear

        return view
    }
}

// MARK: - UITableViewDelegate
extension PrivateChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) && (self.totalCnt > self.limitCnt) && self.isPagination {
            self.isPagination = false
            callGetMessages(inited: false, lastID: self.lastDocId, userId: self.otherUserId)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension PrivateChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        videoURL = info[UIImagePickerControllerMediaURL] as? NSURL
        let mediaType = info[UIImagePickerControllerMediaType] as! String

        if mediaType == "public.image" {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage?
            let data : Data = UIImageJPEGRepresentation(image!, 0.4)!
            PointtersHelper.sharedInstance.startLoader(view: self.view)
            self.uploadImageOnAWS(imgData: data, image: image!, withCompletionHandler : { (result) in
                DispatchQueue.main.async {
                    PointtersHelper.sharedInstance.stopLoader()
                }

                if result == true {
                    self.sendMessageForMedia(type: "image", link: self.photoLinkUrl, videoThumb: "")
                    self.photoLinkUrl = ""
                }
            })
        }
        else if mediaType == "public.movie" {
            //print(videoURL!.relativePath!)
            guard NSData(contentsOf: videoURL! as URL) != nil else {
                return
            }

            let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")

            let thumbnailImage = thumbnailForVideoAtURL(videoURL! as URL)
            let thumbnailImageData : Data = UIImageJPEGRepresentation(thumbnailImage!, 0.4)!

            compressVideo(inputURL:videoURL! as URL, outputURL: compressedURL) { (exportSession) in
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
                    DispatchQueue.main.async {
                        PointtersHelper.sharedInstance.startLoader(view: self.view)
                    }
                    self.uploadVideoOnAWS(outputURL: compressedURL, withCompletionHandler : { (result) in

                        if result == true {

                            self.uploadImageOnAWS(imgData: thumbnailImageData, image: thumbnailImage!, withCompletionHandler : { (result) in
                                DispatchQueue.main.async {
                                    PointtersHelper.sharedInstance.stopLoader()
                                }

                                if result == true {
                                    self.sendMessageForMedia(type: "video", link: self.videoLinkUrl, videoThumb: self.photoLinkUrl)
                                    self.videoLinkUrl = ""
                                    self.photoLinkUrl = ""
                                }
                            })
                        } else {
                            DispatchQueue.main.async {
                                PointtersHelper.sharedInstance.stopLoader()
                            }
                        }
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

extension PrivateChatViewController: UIDocumentPickerDelegate{

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        if !self.isValidFileExtension(fileExtension: myURL.pathExtension){
            PointtersHelper.sharedInstance.showAlertViewWithTitle("Warning", message: "We don't support this file type, please select another file types.", buttonTitles: ["OK"], viewController: self, completion: nil)
            return
        }
        do {
            self.selectedData = try Data(contentsOf: myURL)

        } catch {
            //print("error loading file")
        }

        if self.selectedData != nil {
            PointtersHelper.sharedInstance.startLoader(view: self.view)
            DispatchQueue.global(qos: .background).async {
                self.uploadFilesOnAWS(fileExtension: myURL.pathExtension)
            }
        } else {
            return
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        //print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
}

extension PrivateChatViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        //print(userInfo)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        //print(userInfo as NSDictionary)

        if let payload_key = userInfo[kFCMMessageIDKey.fcmPayloadKey] as? String{
            if payload_key == kRedirectKey.chatKey || payload_key == kRedirectKey.serviceKey || payload_key == kRedirectKey.offerKey{
                self.callGetMessages(inited: true, lastID: "", userId: self.otherUserId)
                return
//                if let fromUserId = userInfo["userId"] as? String {
//                    if fromUserId == self.otherUserId {
//                        self.callGetMessages(inited: true, lastID: "", userId: self.otherUserId)
//                        return
//                    }
//                }
            }
        }
        completionHandler([.alert, .badge, .sound])
    }
}
