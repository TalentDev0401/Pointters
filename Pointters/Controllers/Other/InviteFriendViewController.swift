//
//  InviteFriendViewController.swift
//  Pointters
//
//  Created by super on 4/26/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class InviteFriendViewController: UIViewController {
    
    @IBOutlet weak var consNavViewHeight: NSLayoutConstraint!
    @IBOutlet weak var suggestedView: UIView!
    @IBOutlet weak var qrcodeView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segCtrl: UISegmentedControl!
    @IBOutlet weak var lblTopMyCode: UILabel!
    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var qrScanView: UIView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var btnScanQR: UIButton!
    @IBOutlet weak var lblScanQR: UILabel!
    
    var shareContent = "Please visit following link and install Pointters. \nhttps://www.pointters.com"
    
    let imagePicker = UIImagePickerController()
    
    var loginUserId = ""
    var arrInviteSuggested = [[String:Any]]()
    var myQrcodeImage : CIImage!
    var scanFlag = false
    
    var captureSession : AVCaptureSession!
    var previewLayer : AVCaptureVideoPreviewLayer!
    var arrFollowStatus = [Bool]()
    var selectedIndex = 0
    
    var lastDocId = ""
    var currentPage = 0
    var totalPages = 0
    
    var endPage = false
    
    var waitingResponse = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginUserId = UserCache.sharedInstance.getAccountData().id
        initUI()

    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavViewHeight.constant = 137.0
        } else {
            consNavViewHeight.constant = 116.0
        }
        setView()
        callGetInviteSuggestedAPI(inited: true)
    }
    
    func setView(){
        suggestedView.isHidden = segCtrl.selectedSegmentIndex == 1
        qrcodeView.isHidden = segCtrl.selectedSegmentIndex == 0
        lblTopMyCode.isHidden = !scanFlag
        imgQRCode.isHidden = scanFlag
        qrScanView.isHidden = !scanFlag
        lblScanQR.text = !scanFlag ? "Scan QR Code" : "Scan from Gallery"
    }
    
    func setMyQRCodeView() {
        if myQrcodeImage == nil {
            let data = self.loginUserId.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            let filter = CIFilter(name:"CIQRCodeGenerator")
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("H", forKey: "inputCorrectionLevel")
            myQrcodeImage = filter?.outputImage
            displayQRCodeImage()
        }
    }
    
    func displayQRCodeImage() {
        let scaleX = imgQRCode.frame.size.width / myQrcodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.height / myQrcodeImage.extent.size.height
        let transformedImage = myQrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        imgQRCode.image = UIImage(ciImage: transformedImage)
    }
    
    func addScanQRCode() {
        qrScanView.isHidden = false
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput : AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)){
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = qrScanView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        qrScanView.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    
    // open photo library
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.imagePicker.modalPresentationStyle = .fullScreen
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device not support scanning a code from an item. Please use a device with a camera", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func moveToProfilePage(userId : String) {
        if userId == self.loginUserId {
            UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
        } else {
            UserCache.sharedInstance.setProfileUser(loginUser: false, userId: userId)
        }
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        userProfileVC.profileVCDelegate = self
        navigationController?.pushViewController(userProfileVC, animated:true)
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    @IBAction func onClickInvite(_ sender: Any) {
        var shareService = [Any]()
        shareService.append(self.shareContent)
        let shareViewController : UIActivityViewController = UIActivityViewController(
            activityItems: shareService, applicationActivities: nil)
        shareViewController.completionWithItemsHandler = { activity, success, items, error in
            if error != nil || !success{
                return
            }
        }
        
        DispatchQueue.main.async {
            self.present(shareViewController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func btnbackPressed(_ sender: Any) {
        if scanFlag {
            if (captureSession.isRunning == true) {
                captureSession.stopRunning()
            }
            qrScanView.isHidden = true
            scanFlag = false
            setView()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func segChangeAction(_ sender: UISegmentedControl) {
        setView()
        view.endEditing(true)
        if sender.selectedSegmentIndex == 0 {
            
        } else {
            tfSearch.resignFirstResponder()
            setMyQRCodeView()
        }
    }
    
    @IBAction func btnScanTapped(_ sender: Any) {
        if !scanFlag {
            scanFlag = true
            setView()
            addScanQRCode()
        }else{
            scanFlag = false
            setView()
            openGallery()
        }
    }
    
    @objc func btnFollowTapped(sender: UIButton) {
        self.selectedIndex = sender.tag
        let inviteItem = InviteUser.init(dict: self.arrInviteSuggested[sender.tag])
        if self.arrFollowStatus[selectedIndex] == true {
            callDeleteUserFollowingStatusApi(id: inviteItem.userId)
        } else {
            callPostUserFollowingStatusApi(id: inviteItem.userId)
        }
    }
    
    //*******************************************************//
    //                 MARK: - Call API Method               //
    //*******************************************************//
    
    func callGetInviteSuggestedAPI(inited: Bool) {
        if waitingResponse {
            return
        }else{
            waitingResponse = true
        }
        if inited {
            self.endPage = false
            PointtersHelper.sharedInstance.startLoader(view: view)
            self.currentPage = 0
            self.arrInviteSuggested.removeAll()
            self.arrFollowStatus.removeAll()
        }else {
            if self.endPage{
                return
            }
        }
        
        ApiHandler.callGetInviteSuggested(currentPage: self.currentPage, withCompletionHandler:{ (result,statusCode,response) in
            if inited {
                PointtersHelper.sharedInstance.stopLoader()
            }
            if result == true {
                if statusCode == 200 {
                    self.waitingResponse = false
                    if let responseArray = response.value as? [[String:Any]]{
                        for item in responseArray {
                            self.arrInviteSuggested.append(item)
                            let inviteItem = InviteUser.init(dict: item)
                            self.arrFollowStatus.append(inviteItem.hasFollowed)
                        }
                        self.currentPage = self.currentPage + 1
                        if responseArray.count < 10{
                            self.endPage = true
                        }
                    }
                } else {
                    let responseDict = response.value as! [String:Any]
                    let message = responseDict["message"] as! String
                    print(message)
                }
            }
            else {
                print(response.error ?? "load failure")
            }
            self.tableView.reloadData()
        })
    }
    
    func callGetInviteSearchAPI(filterString: String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetInviteSearch(filterString: filterString, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            self.arrInviteSuggested.removeAll()
            self.arrFollowStatus.removeAll()
            if result == true {
                if statusCode == 200 {
                    if let responseArray = response.value as? [[String:Any]]{
                        for item in responseArray {
                            self.arrInviteSuggested.append(item)
                            let inviteItem = InviteUser.init(dict: item)
                            self.arrFollowStatus.append(inviteItem.hasFollowed)
                        }
                    }
                } else {
                    let responseDict = response.value as! [String:Any]
                    let message = responseDict["message"] as! String
                    print(message)
                }
            }
            else {
                print(response.error ?? "load failure")
            }
            self.tableView.reloadData()
        })
    }
    
    // Post follow
    func callPostUserFollowingStatusApi(id:String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callPostUserFollowingStatus(userId:id, withCompletionHandler:{ (result,statusCode,response,error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let _ = response.value as! [String:Any]
                if statusCode == 200 {
                    self.arrFollowStatus.remove(at: self.selectedIndex)
                    self.arrFollowStatus.insert(true, at: self.selectedIndex)
                }
            }
            else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
            
            self.tableView.reloadData()
        })
    }
    
    // Delete follow
    func callDeleteUserFollowingStatusApi(id:String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callDelUserFollowingStatus(userId:id, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let _ = response.value as! [String:Any]
                if statusCode == 200 {
                    self.arrFollowStatus.remove(at: self.selectedIndex)
                    self.arrFollowStatus.insert(false, at: self.selectedIndex)
                }
            }
            else {
                print(response.error ?? "delete follow failure")
            }
            
            self.tableView.reloadData()
        })
    }

}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

extension InviteFriendViewController : AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        scanFlag = false
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringResult = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            moveToProfilePage(userId : stringResult)
        }
    }
    
}

extension InviteFriendViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == self.arrInviteSuggested.count - 1) {
            callGetInviteSuggestedAPI(inited: false)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrInviteSuggested.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellItem = InviteUser.init(dict: self.arrInviteSuggested[indexPath.section])
        switch indexPath.row {
        case 0: return 60.0
        case 1: return 40.0
        case 2:
            if cellItem.services.count > 0 {
                return 100.0
            } else {
                return 0.0
            }
        default: return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellItem = InviteUser.init(dict: self.arrInviteSuggested[indexPath.section])
        print(self.arrInviteSuggested[indexPath.section] as NSDictionary)
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! InviteSuggestedCell
            cell.ivUser.layer.cornerRadius = cell.ivUser.frame.size.height/2
            cell.ivUser.layer.masksToBounds = true
            if cellItem.profilePic != "" {
                cell.ivUser.sd_imageTransition = .fade
                cell.ivUser.sd_setImage(with: URL(string: cellItem.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
            }
            cell.lblName.text = cellItem.firstName + " " + cellItem.lastName
            if cellItem.numServices > 0 {
                cell.lblServiceCount.text = "+\(cellItem.numServices) Services"
            }else{
                cell.lblServiceCount.text = "0 Service"
            }
            cell.btnFollow.tag = indexPath.section
            cell.btnFollow.layer.cornerRadius = 5.0
            cell.btnFollow.layer.masksToBounds = true
            cell.btnFollow.layer.borderWidth = 1.0
            let followStatus = self.arrFollowStatus.count > 0 ? self.arrFollowStatus[indexPath.section] : false
            if followStatus == true {
                if #available(iOS 10.0, *) {
                    cell.btnFollow.layer.borderColor = UIColor(displayP3Red: 0, green: 122/255, blue: 1, alpha: 1).cgColor
                    cell.btnFollow.setTitleColor(UIColor(displayP3Red: 0, green: 122/255, blue: 1, alpha: 1), for: .normal)
                } else {
                    cell.btnFollow.layer.borderColor = UIColor(red: 0, green: 122/255, blue:1, alpha: 1).cgColor
                    cell.btnFollow.setTitleColor(UIColor(red: 0, green: 122/255, blue:1, alpha: 1), for: .normal)
                }
                cell.btnFollow.setTitle("Following", for: .normal)
            } else {
                cell.btnFollow.layer.borderColor = UIColor.black.cgColor
                cell.btnFollow.setTitleColor(UIColor.black, for: .normal)
                cell.btnFollow.setTitle("Follow", for: .normal)
            }
            cell.btnFollow.addTarget(self, action: #selector(btnFollowTapped(sender:)), for: .touchUpInside)
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! InviteSuggestedCell
            cell.lblPointValue.text = "\(cellItem.pointValue)"
            cell.lblNumFollower.text = "\(cellItem.numFollowers)"
            cell.lblNumOrder.text = "\(cellItem.numOrders)"
            cell.lblAvgRate.text = String(format:"%.1f", cellItem.avgRating) + "%"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell") as! InviteSuggestedCell
            cell.arrServices.removeAll()
            cell.arrServices = cellItem.services
            cell.parentVC = self
            cell.setCollectionView()
            return cell
        }
    }
    
}

extension InviteFriendViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellItem = InviteUser(dict: self.arrInviteSuggested[indexPath.section])
        if cellItem.userId == self.loginUserId {
            UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
        } else {
            UserCache.sharedInstance.setProfileUser(loginUser: false, userId: cellItem.userId)
        }
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        navigationController?.pushViewController(userProfileVC, animated:true)
    }
}

extension InviteFriendViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            self.callGetInviteSuggestedAPI(inited: true)
        }else{
            self.callGetInviteSearchAPI(filterString: textField.text!)
        }
        return textField.resignFirstResponder()
    }
}

extension InviteFriendViewController : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tfSearch.resignFirstResponder()
    }
}

extension InviteFriendViewController : UserProfileVCDelegate {
    func isPushedFromQRScan() {
        if !scanFlag {
            scanFlag = true
            setView()
            addScanQRCode()
        }
    }
}

extension InviteFriendViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let qrcodeImg = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            let ciImage:CIImage=CIImage(image:qrcodeImg)!
            var qrCodeLink=""
            
            let features=detector.features(in: ciImage)
            for feature in features as! [CIQRCodeFeature] {
                qrCodeLink += feature.messageString!
            }
            
            if qrCodeLink=="" {
                print("nothing")
            }else{
                self.moveToProfilePage(userId: qrCodeLink)
            }
        }
        else{
            print("Something went wrong")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
