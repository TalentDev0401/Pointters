//
//  PostUpdateViewController.swift
//  Pointters
//
//  Created by Mac on 2/25/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import AVFoundation
import AWSS3
import AWSCore
import Photos

protocol PostUpdateDelegate {
    func postUpdate()
}

class PostUpdateViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var consTableViewHieght: NSLayoutConstraint!
    @IBOutlet var btnPost: UIButton!
    @IBOutlet var consMediaBottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var separatorView: UIView!
    
    // post view
    @IBOutlet var postView: UIView!
    @IBOutlet var tvDesc: UITextView!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    @IBOutlet var btnDescClose: UIButton!
    @IBOutlet var videoPost1: AAPlayer!
    @IBOutlet var imvPost1: UIImageView!
    @IBOutlet var btnClose1: UIButton!
    @IBOutlet var videoPost2: AAPlayer!
    @IBOutlet var imvPost2: UIImageView!
    @IBOutlet var btnClose2: UIButton!
    @IBOutlet var videoPost3: AAPlayer!
    @IBOutlet var imvPost3: UIImageView!
    @IBOutlet var btnClose3: UIButton!
    @IBOutlet var postTableView: UITableView!
    @IBOutlet var consMediaToolsBottom: NSLayoutConstraint!
            
    var postUpdateDelegate : PostUpdateDelegate?
    
    var selTabIndex = 0
    var mediaIndex = 0
    
    var postMedia = [Media]()
    var postDesc = ""
    var isTagService = false
    var postCellCount = 1
    var postTagService = Service.init()
        
    var showedCameraTip = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
            consMediaBottomViewHeight.constant = 65.0
        } else {
            consNavBarHeight.constant = 64.0
            consMediaBottomViewHeight.constant = 44.0
        }
        consTableViewHieght.constant = 44
        tvDesc.becomeFirstResponder()
        postMedia.removeAll()
        setInitView()
    }
        
    func setInitView() {
        btnPost.alpha = 0.3
        btnPost.setTitle("Post", for: .normal)
        btnPost.isUserInteractionEnabled = false
        
        addToolBar(textView: tvDesc)
        initMediaView()
    }
    
    func checkMediaAccess(type:Int) -> Bool {
        var flag = false
        
        if postMedia.count >= 3 {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "You can't upload more than 3 medias", buttonTitles: ["OK"], viewController: self, completion: nil)
            return false
        }
        else {
            if type == 0 {
                if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                    return true
                } else {
                    PHPhotoLibrary.requestAuthorization { (status) in
                        if status == PHAuthorizationStatus.authorized {
                            DispatchQueue.main.async {
                                let imagePickerController = UIImagePickerController()
                                imagePickerController.sourceType = .photoLibrary
                                imagePickerController.delegate = self
                                imagePickerController.mediaTypes = ["public.image", "public.movie"]
                                imagePickerController.videoQuality = .type640x480
                                self.present(imagePickerController, animated: true, completion: nil)
                            }
                            flag = false
                        } else {
                            DispatchQueue.main.async {
                                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Turn on photo library usage permission in the app Settings", buttonTitles: ["Go to app settings"], viewController: self, completion: { (completion) in
                                    self.tvDesc.resignFirstResponder()
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
                
            } else if type == 1 {
                if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized && AVAudioSession.sharedInstance().recordPermission() == .granted {
                    //already authorized
                    return true
                } else {
                   
                    if AVCaptureDevice.authorizationStatus(for: .video) !=  .authorized {
                        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                            if granted {
                                DispatchQueue.main.async {
                                    let cameraPhotoController = UIImagePickerController()
                                    cameraPhotoController.sourceType = .camera
                                    cameraPhotoController.delegate = self
                                    cameraPhotoController.mediaTypes = ["public.image"]
                                    cameraPhotoController.videoQuality = .type640x480
                                    self.present(cameraPhotoController, animated: true, completion: nil)
                                }
                                flag = false
                            } else {
                                //access denied
                                DispatchQueue.main.async {
                                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Turn on camera usage permission in the app Settings", buttonTitles: ["Go to app settings"], viewController: self, completion: { (completion) in
                                        self.tvDesc.resignFirstResponder()
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
                
            } else {
                if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized && AVAudioSession.sharedInstance().recordPermission() == .granted {
                    //already authorized
                    return true
                } else {
                    
                    var isShowedPicker = false
                    
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
                                
                                isShowedPicker = true
                                flag = false
                            } else {
                                //access denied
                                DispatchQueue.main.async {
                                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Turn on camera usage permission in the app Settings", buttonTitles: ["Go to app settings"], viewController: self, completion: { (completion) in
                                        self.tvDesc.resignFirstResponder()
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
                    
                    if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized && AVAudioSession.sharedInstance().recordPermission() != .granted {
                        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                            if granted {
                                
                                if !isShowedPicker {
                                    DispatchQueue.main.async {
                                        let cameraVideoController = UIImagePickerController()
                                        cameraVideoController.sourceType = .camera
                                        cameraVideoController.delegate = self
                                        cameraVideoController.mediaTypes = ["public.movie"]
                                        cameraVideoController.videoQuality = .type640x480
                                        self.present(cameraVideoController, animated: true, completion: nil)
                                    }
                                }                                
                                flag = false
                            } else {
                                //access denied
                                DispatchQueue.main.async {
                                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Turn on microphone usage permission in the app Settings", buttonTitles: ["Go to app settings"], viewController: self, completion: { (completion) in
                                        self.tvDesc.resignFirstResponder()
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
                }
                
            }
        }
        
        return flag
    }
    
    func initMediaView() {
        videoPost1.isHidden = true
        videoPost2.isHidden = true
        videoPost3.isHidden = true
        btnClose1.isHidden = true
        btnClose2.isHidden = true
        btnClose3.isHidden = true
        
        imvPost1.isHidden = true
        imvPost2.isHidden = true
        imvPost3.isHidden = true
        imvPost1.image = nil
        imvPost2.image = nil
        imvPost3.image = nil
    }
    
    func reloadMediaView() {
        initMediaView()
        if postMedia.count > 0 {
            btnClose1.isHidden = false
            setVideoView(video: videoPost1, imv: imvPost1, index: 0)
        }
        if postMedia.count > 1 {
            btnClose2.isHidden = false
            setVideoView(video: videoPost2, imv: imvPost2, index: 1)
        }
        if postMedia.count > 2 {
            btnClose3.isHidden = false
            setVideoView(video: videoPost3, imv: imvPost3, index: 2)
        }
    }
    
    func setVideoView(video:AAPlayer, imv:UIImageView, index:Int) {
        if postMedia[index].mediaType == "video" {
            video.isHidden = false
            imv.isHidden = false
            imv.image = nil
            imv.layer.backgroundColor = UIColor.init(hex: 0x4CA9DE).cgColor
            
            video.tag = index
            video.delegate = self
            video.delegate2 = self
            
            if postMedia[index].fileName != "" {
                let thumbImage = generateThumbnailForVideoAtURL(filePathLocal: postMedia[index].fileName as NSString)
                imv.image = thumbImage
                video.playVideo(postMedia[index].fileName)
            }
        } else {
            video.isHidden = true
            imv.isHidden = false
            
            if postMedia[index].fileName != "" {
                imv.sd_imageTransition = .fade
                imv.sd_setImage(with: URL(string: postMedia[index].fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
            } else {
                imv.image = nil
            }
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
    
    func allowPostUpdate() {
        if selTabIndex == 0 {
            if postDesc != "" || postMedia.count > 0 {
                DispatchQueue.main.async {
                    self.btnPost.alpha = 1.0
                    self.btnPost.isUserInteractionEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    self.btnPost.alpha = 0.3
                    self.btnPost.isUserInteractionEnabled = false
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
        
//        let remoteName = "post_pic\(mediaIndex)" + UIDevice.current.identifierForVendor!.uuidString
        
        let remoteName = "post_pic_\(mediaIndex)_\(NSDate().timeIntervalSince1970)"
        
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
                
                self.postMedia.insert(Media.init(type:"image", path:(publicURL?.absoluteString)!), at: self.postMedia.count)
                self.allowPostUpdate()
                
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
        
        let remoteName = "post_video_\(mediaIndex)_\(NSDate().timeIntervalSince1970)"
        
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
                
                self.postMedia.insert(Media.init(type:"video", path:(publicURL?.absoluteString)!), at: self.postMedia.count)
                self.allowPostUpdate()
                
                DispatchQueue.main.async {
                    withCompletionHandler(true)
                }
            }
            return nil
        }
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//

    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPost(_ sender: Any) {
        var params = [String:Any]()
        if postDesc != "" {
            params["message"] = postDesc
        }
        if postMedia.count > 0 {
            var mediaArray = [[String:Any]]()
            for item in postMedia {
                var itemMedia = [String:Any]()
                itemMedia["mediaType"] = item.mediaType
                itemMedia["fileName"] = item.fileName
                mediaArray.append(itemMedia)
            }
            params["media"] = mediaArray
        }
        
        if postCellCount > 1 {
            var tags = [[String:Any]]()
            var itemTag = [String:Any]()
            itemTag["type"] = "service"
            itemTag["id"] = postTagService.id
            tags.append(itemTag)
            params["tags"] = tags
        }
        self.callPostUpdateAPI(paramDic:params)
    }
        
    @IBAction func btnPhotoTapped(_ sender: Any) {
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
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "You can't access the camera.", buttonTitles: ["OK"], viewController: self, completion: nil)
            return
        }
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
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "You can't access the camera.", buttonTitles: ["OK"], viewController: self, completion: nil)
            return
        }
        if checkMediaAccess(type: 2) {
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
    
    @IBAction func btnDescClearTapped(_ sender: Any) {
        tvDesc.text = ""
        postDesc = ""
        allowPostUpdate()
        btnDescClose.isHidden = true
    }
    
    @IBAction func deleteMediaBtnClick(_ sender: UIButton) {
        if sender.tag == 91 {
            self.imvPost1.image = nil
            self.postMedia.remove(at: 0)
        }else if sender.tag == 92 {
            self.imvPost2.image = nil
            self.postMedia.remove(at: 1)
        }else{
            self.imvPost3.image = nil
            self.postMedia.remove(at: 2)
        }
        reloadMediaView()
    }
    
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.consMediaToolsBottom?.constant = 0.0
            } else {
                if PointtersHelper.sharedInstance.checkiPhonX()  {
                    self.consMediaToolsBottom?.constant = (endFrame?.size.height)! + 0.0
                } else {
                    self.consMediaToolsBottom?.constant = endFrame?.size.height ?? 0.0
                }
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    @objc func btnDeleteTapped(sender: UIButton) {
        isTagService = false
        postCellCount = 1
        postTagService = Service.init()
        consTableViewHieght.constant = 44
        postTableView.reloadData()
    }

    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
        
    func callPostUpdateAPI(paramDic:[String:Any]){
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callPostUpdate(paramDic:paramDic, withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
//                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully posted!", buttonTitles: ["OK"], viewController: self, completion: nil)
//                    self.postCellCount = 1
//                    self.postTableView.reloadData()
//                    self.initMediaView()
//                    self.tvDesc.text = ""
//                    self.postDesc = ""
//                    self.postMedia = [Media]()
//                    self.allowPostUpdate()

                    if self.postUpdateDelegate != nil {
                        self.postUpdateDelegate?.postUpdate()
                    }
                    self.navigationController?.popViewController(animated: true)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: (responseDict["message"] as? String)!, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "post update failure")
            }
        })
    }
    
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// AAPlayerDelegate
extension PostUpdateViewController:AAPlayerDelegate {
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
extension PostUpdateViewController: AAPlayerModeDelegate {
    func callBackDownloadDidModeChange(_ status:Bool, tag:Int) {
        if postMedia[tag].fileName != "" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let fullScreenVC = storyboard.instantiateViewController(withIdentifier: "FullScreenVC") as! FullScreenViewController
            fullScreenVC.videoURL = postMedia[tag].fileName
            navigationController?.pushViewController(fullScreenVC, animated: true)
        }
    }
}

// TagServiceDelegate
extension PostUpdateViewController:TagServiceDelegate {
    func selectTagService(selected : Service) {
        isTagService = true
        postCellCount = 2
        postTagService = selected
        consTableViewHieght.constant = 154
        postTableView.reloadData()
        allowPostUpdate()
    }
}

// UITextViewDelegate
extension PostUpdateViewController: UITextViewDelegate {
    func addToolBar(textView: UITextView) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.backgroundColor = UIColor.getCustomGrayColor()
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let str = textView.text
        btnDescClose.isHidden = str == ""
        lblPlaceHolder.isHidden = str != ""
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let originText: NSString = (textView.text ?? "") as NSString
        let resultString = originText.replacingCharacters(in: range, with: text as String)
        postDesc = resultString
        allowPostUpdate()
        btnDescClose.isHidden = postDesc == ""
        lblPlaceHolder.isHidden = postDesc != ""
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView)  {
        btnDescClose.isHidden = true
    }
}

// UIImagePickerControllerDelegate
extension PostUpdateViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
                    self.reloadMediaView()
                }
            })
        }
        else if mediaType == "public.movie" {
            print(mediaURL!.relativePath!)
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
                        self.reloadMediaView()
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

// UITableViewDataSource
extension PostUpdateViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postCellCount
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == postCellCount-1 {
            return 44.0
        } else {
            return 110.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == postCellCount-1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectCell") as! TagServiceCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell") as! TagServiceCell
            
            cell.backView.layer.cornerRadius = 10.0
            cell.backView.layer.masksToBounds = false
            cell.backView.layer.shadowOffset = CGSize(width:0, height:2)
            cell.backView.layer.shadowColor = UIColor.black.cgColor
            cell.backView.layer.shadowOpacity = 0.23
            cell.backView.layer.shadowRadius = 4
            
            cell.imgService.layer.cornerRadius = 3.0
            cell.imgService.layer.masksToBounds = true
            cell.imgService.sd_imageTransition = .fade
            cell.imgService.sd_setImage(with: URL(string: self.postTagService.media.fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
            cell.lblDesc.text = self.postTagService.desc
            cell.lblPrice.text = "\(self.postTagService.prices.currencySymbol)\(self.postTagService.prices.price)"
            cell.lblWorkTime.text = "Per \(self.postTagService.prices.time) \(self.postTagService.prices.timeUnitOfMeasure)"
            cell.btnName.setTitle(self.postTagService.seller["firstName"] as? String, for: .normal)
            cell.btnDelete.tag = 1001
            cell.btnDelete.addTarget(self, action: #selector(btnDeleteTapped(sender:)), for: .touchUpInside)
            return cell
        }
    }
}

// UITableViewDelegate
extension PostUpdateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == postCellCount - 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tagServicesVC = storyboard.instantiateViewController(withIdentifier: "TagServiceVC") as! TagServiceViewController
            tagServicesVC.tagDelegate = self
            present(tagServicesVC, animated: true, completion: nil)
        }
    }
}

