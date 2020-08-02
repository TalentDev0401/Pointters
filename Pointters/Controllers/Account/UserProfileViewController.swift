//
//  UserProfileViewController.swift
//  Pointters
//
//  Created by Mac on 2/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import SDWebImage
import CoreLocation
import AVFoundation
import AVKit

protocol UserProfileVCDelegate {
    func isPushedFromQRScan()
}

class UserProfileViewController: UIViewController, ReadMoreTextViewDelegate {
    
    func didClickMoreText() {
        if !clickMore {
            clickMore = true
            
            let editProfileVC = storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileViewController
            editProfileVC.userId = userId
            editProfileVC.delegate = self
            navigationController?.pushViewController(editProfileVC, animated: true)
        }
    }
    
    @IBOutlet var consCollectionTop: NSLayoutConstraint!
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var pageCtrl: UIPageControl!
    @IBOutlet var imgBgCamera: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    
    var profileVCDelegate : UserProfileVCDelegate?

    var userLocation: CLLocation?
    
    var userProfile = Profile.init()
    var arrUserServices = [[String:Any]]()
    
    var limitCnt = 0
    var totalCnt = 0
    var lastDocId = ""
    
    var userId = ""
    var userType = false
    var isFollow = false
    
    var descHeight : CGFloat = 95.0
    var selectDescFlag = false
    var clickMore = false

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        initData()
        PointtersHelper.sharedInstance.sendAnalyticsToFirebase(event: kFirebaseEvents.screenProfile)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userId != "" {
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        clickMore = false
        callGetUserServiceApi(userId: userId, inited: true, lastId: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        tableView.reloadData()
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 80.0
            consCollectionTop.constant = -24.0
        } else {
            consNavBarHeight.constant = 64.0
            consCollectionTop.constant = -12.0
        }
    }
    
    func initData() {
        let lat = UserCache.sharedInstance.getUserLatitude()
        let lng = UserCache.sharedInstance.getUserLongitude()
        userLocation = CLLocation(latitude: lat!, longitude: lng!)
        
        userType = UserCache.sharedInstance.getProfileLoginUser()!
        if userType {
            userId = UserCache.sharedInstance.getAccountData().id
        } else {
            userId = UserCache.sharedInstance.getProfileUserId()!
        }
        
        if userId != "" {
            callGetUserProfileApi(userId: userId)
            if !userType {
                callGetUserFollowingStatusApi(id: userId)
            }
        } else {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Can't find user profile!", buttonTitles: ["OK"], viewController: self, completion: { (index) in
                if index == 0 {
                    if self.profileVCDelegate != nil {
                        self.profileVCDelegate?.isPushedFromQRScan()
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    func getAddress(location:Location) -> String {
        var address = ""
        
        if location.city != "" {
            address = address + location.city + " "
        }
        if location.state != "" {
            address = address + location.state + ", "
        }
        if location.postalCode != "" {
            address = address + location.postalCode + ", "
        }
        if location.country != "" {
            address = address + location.country
        }
        
        return address
    }

    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        if self.profileVCDelegate != nil {
            self.profileVCDelegate?.isPushedFromQRScan()
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnShareTapped(_ sender: Any) {
        let firstName = self.userProfile.firstName
        let lastName = self.userProfile.lastName
        let shareService = "Checkout this awesome user on Pointters app: " + "\(firstName) \(lastName). " + self.userProfile.shareLink
        let shareViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [shareService], applicationActivities: nil)
        shareViewController.completionWithItemsHandler = { activity, success, items, error in
            if error != nil || !success{
                return
            }
        }
        DispatchQueue.main.async {
            self.present(shareViewController, animated: true, completion: nil)
        }
    }
    
    @objc func btnFollowTapped(sender: UIButton) {
        if userType {
            let editProfileVC = storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileViewController
            editProfileVC.delegate = self
            navigationController?.pushViewController(editProfileVC, animated: true)
        } else {
            if isFollow {
                callDeleteUserFollowingStatusApi(id: userId)
            } else {
                callPostUserFollowingStatusApi(id: userId)
            }
        }
    }
    
    @objc func btnChatTapped(sender: UIButton) {
        let userName = userProfile.firstName + " " + userProfile.lastName
        let userPic = userProfile.profilePic
        let userVerified = userProfile.verified
        UserCache.sharedInstance.setChatCredentials(id: "", userId: userId, name: userName, pic: userPic, verified: userVerified)
        let storyboard = UIStoryboard(name: "Chats", bundle: nil)
        let privateChatVC = storyboard.instantiateViewController(withIdentifier: "PrivateChatVC") as! PrivateChatViewController
        privateChatVC.otherUserId = userId
        privateChatVC.otherUserPic = userPic
        privateChatVC.otherUsername = userName
        navigationController?.pushViewController(privateChatVC, animated:true)
    }
    
    @objc func btnCallTapped(sender: UIButton) {
        PointtersHelper.sharedInstance.callByPhone(phone: userProfile.phone, ctrl: self)
    }

    //*******************************************************//
    //                 MARK: - Call API Method               //
    //*******************************************************//
    
    func callGetUserProfileApi(userId: String) {
        //  PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetUserProfile(userId: userId, withCompletionHandler:{ (result,statusCode,response) in
            // PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    print(responseDict as NSDictionary)
                    if let dict = responseDict["result"] as? [String:Any] {
                        self.userProfile = Profile.init(dict: dict)
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Can't find user profile!", buttonTitles: ["OK"], viewController: self, completion: { (index) in
                        if index == 0 {
                            if self.profileVCDelegate != nil {
                                self.profileVCDelegate?.isPushedFromQRScan()
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            }
            else {
                print(response.error ?? "profile failure")
            }
            
            self.pageCtrl.numberOfPages = self.userProfile.profileBgMedia.count
            self.pageCtrl.hidesForSinglePage = true
            self.collectionView.reloadData()
            self.tableView.reloadData()
        })
    }
    
    func callGetUserServiceApi(userId: String, inited: Bool, lastId: String) {
        if inited {
            arrUserServices.removeAll()
        }
        
        // PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetUserServices(userId: userId, categoryId: "", lastId: lastId, withCompletionHandler:{ (result,statusCode,response, error) in
            // PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    self.limitCnt = responseDict["limit"] as! Int
                    self.totalCnt = responseDict["total"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String
                    
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for service in arr {
                            self.arrUserServices.append(service)
                        }
                    }
                }
            }
            else {
                print(response.error ?? "user service failure")
            }
            self.tableView.reloadData()
        })
    }
    
    // Get follow
    func callGetUserFollowingStatusApi(id:String) {
        //  PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetUserFollowingStatus(userId:id, withCompletionHandler:{ (result,statusCode,response) in
            // PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    if let _ = responseDict["followed"] {
                        self.isFollow = responseDict["followed"] as! Bool
                    }
                }
            }
            else {
                print(response.error ?? "get follow failure")
            }
            
            self.tableView.reloadData()
        })
    }
    
    // Post follow
    func callPostUserFollowingStatusApi(id:String) {
        //  PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callPostUserFollowingStatus(userId:id, withCompletionHandler:{ (result,statusCode,response,error) in
            // PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let _ = response.value as! [String:Any]
                if statusCode == 200 {
                    self.isFollow = true
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
        //  PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callDelUserFollowingStatus(userId:id, withCompletionHandler:{ (result,statusCode,response) in
            // PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let _ = response.value as! [String:Any]
                if statusCode == 200 {
                    self.isFollow = false
                }
            }
            else {
                print(response.error ?? "delete follow failure")
            }
            
            self.tableView.reloadData()
        })
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
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UICollectionViewDataSource, AAPlayerDelegate
extension UserProfileViewController: UICollectionViewDataSource, AAPlayerDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageCtrl.currentPage = indexPath.item
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userProfile.profileBgMedia.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgsCell", for: indexPath)
        
        let imgView = cell.viewWithTag(1001) as! UIImageView
        let playerView = cell.viewWithTag(1002) as! AAPlayer
        
        if userProfile.profileBgMedia[indexPath.item].mediaType == "image" {
            imgView.isHidden = false
            playerView.isHidden = true
            imgView.sd_imageTransition = .fade
            imgView.sd_setImage(with: URL(string: userProfile.profileBgMedia[indexPath.item].fileName), placeholderImage: UIImage(named: "photo_placeholder"))
        } else {
            imgView.isHidden = true
            playerView.isHidden = false
            playerView.delegate = self
            playerView.playVideo(userProfile.profileBgMedia[indexPath.row].fileName)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemMedia = self.userProfile.profileBgMedia[indexPath.item]
        let mediaType = itemMedia.mediaType
        if mediaType == "image" {
            let fileName = itemMedia.fileName
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let fullScreenImageVC = storyboard.instantiateViewController(withIdentifier: "FullScreenImageVC") as! FullScreenImageViewController
            fullScreenImageVC.imageUrl = fileName
            navigationController?.pushViewController(fullScreenImageVC, animated:false)
        } else {
            let fileName = itemMedia.fileName
            let playURL = NSURL(string: fileName)
            let player = AVPlayer(url: playURL! as URL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
}

// UICollectionViewDelegate
extension UserProfileViewController: UICollectionViewDelegate {
}

// UICollectionViewDelegateFlowLayout
extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = UIScreen.main.bounds.size.width
        let cellSize = CGSize(width: CGFloat(width), height: height)
        return cellSize
    }
}

// UITableViewDataSource
extension UserProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return 4
            case 1: return 1
            case 2: return 1
            case 3: return arrUserServices.count
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
            case 1: return 45.0
            case 2:
                if !userType {
                    return 20.0
                }else{
                    return 0
                }
            case 3: return 45.0
            default: return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            case 0:
                switch indexPath.row {
                    case 0: return 75.0
                    case 1:
                        if userProfile.desc != "" {
                            let height = userProfile.desc.height(withConstrainedWidth: CGFloat(UIScreen.main.bounds.size.width - 30), font: UIFont(name: "Helvetica", size: 13)!) + 20
                            if height > self.descHeight {
                                if selectDescFlag {
                                    return height
                                } else {
                                    return self.descHeight
                                }
                            } else {
                                return height
                            }
                        } else {
                            return 0.0
                        }
                    case 2: return 100.0
                    case 3: return 52.0
                    default: return 0.0
                }
            case 1: return 170.0
            case 2:
                if !userType {
                    return 44.0
                }else{
                    return 0
                }
            case 3: return 123.0
            default: return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        if section == 1 || section == 3 {
            let headerLabel = UILabel(frame: CGRect(x: 13, y: 25, width: tableView.bounds.size.width - 30, height: 20))
            headerLabel.font = UIFont(name: "Helvetica", size: 14)
            headerLabel.textColor = UIColor.getCustomGrayTextColor()
            
            if section == 1 {
                headerLabel.text = "SERVICE METRICS"
            } else {
                headerLabel.text = (arrUserServices.count > 0) ? "SERVICES" : "NO SERVICES"
            }
            
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! ProfileCell
                
                cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height/2
                cell.imgUser.layer.masksToBounds = true

                if userProfile.profilePic != "" {
                    cell.imgUser.sd_imageTransition = .fade
                    cell.imgUser.sd_setImage(with: URL(string: userProfile.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                }
                
                cell.lblName.text = userProfile.firstName + " " + userProfile.lastName
                cell.lblVerfied.text = (userProfile.verified) ? "Verified" : "Not verified"
                
                cell.btnFollow.layer.borderWidth = 1.0
                cell.btnFollow.layer.borderColor = UIColor.getCustomLightBlueColor().cgColor
                cell.btnFollow.layer.cornerRadius = 3.0
                cell.btnFollow.layer.masksToBounds = true
                
                if userType {
                    cell.btnFollow.setTitle("Edit Profile", for: .normal)
                } else {
                    if isFollow {
                        cell.btnFollow.setTitle("Following", for: .normal)
                    } else {
                        cell.btnFollow.setTitle("Follow", for: .normal)
                    }
                }
                
                cell.btnFollow.addTarget(self, action: #selector(btnFollowTapped(sender:)), for: .touchUpInside)
                
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "descCell") as! ProfileCell
                cell.moreTvDesc.text = userProfile.desc
                cell.moreTvDesc.maximumNumberOfLines = 4
                
                let readMoreTextAttributes: [NSAttributedStringKey: Any] = [
                    NSAttributedStringKey.foregroundColor: UIColor(red: 0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0),
                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)
                ]
                
                cell.moreTvDesc.attributedReadMoreText = NSAttributedString(string: " ..more", attributes: readMoreTextAttributes)
                cell.moreTvDesc.del = self
                cell.moreTvDesc.shouldTrim = true
                
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell") as! ProfileCell
                
                cell.lblCompany.text = userProfile.companyName
                cell.imageCompany.isHidden = userProfile.companyName.isEmpty
                cell.lblAddress.text = getAddress(location: userProfile.location)
                cell.lblPhone.text = userProfile.phone
                if userProfile.phone == "" {
                    cell.imgPhone.isHidden = true
                    cell.lblPhone.isHidden = true
                }else{
                    cell.imgPhone.isHidden = false
                    cell.lblPhone.isHidden = false
                }
                if userProfile.location.geoJson.coordinates.count == 0 {
                    cell.imgAddress.isHidden = true
                    cell.lblAddress.isHidden = true
                }else{
                    cell.imgAddress.isHidden = false
                    cell.lblAddress.isHidden = false
                }
                if !userType {
                    cell.btnChat.isHidden = false
                    cell.btnCall.isHidden = (userProfile.phone != "") ? false : true
                    cell.btnChat.addTarget(self, action: #selector(btnChatTapped(sender:)), for: .touchUpInside)
                    cell.btnCall.addTarget(self, action: #selector(btnCallTapped(sender:)), for: .touchUpInside)
                } else {
                    cell.btnChat.isHidden = true
                    cell.btnCall.isHidden = true
                }
                return cell
            } else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! ProfileCell
                cell.lblPoint.text = PointtersHelper.sharedInstance.formatCount(value: userProfile.userMetrics.pointValue) + " Points"
                cell.lblLikes.text = PointtersHelper.sharedInstance.formatCount(value: userProfile.userMetrics.numLikes) + " Likes"
                cell.lblWatching.text = PointtersHelper.sharedInstance.formatCount(value: userProfile.userMetrics.numWatching) + " Watching"
                return cell
            } else {
                return UITableViewCell()
            }
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "metricsCell") as! ProfileCell
            cell.lblOnTime.text = String(format:"%.1f", userProfile.userMetrics.avgOnTime) + "%"
            cell.lblQuality.text = String(format:"%.1f", userProfile.userMetrics.avgQuality)
            cell.lblResponse.text = String(format:"%.1f", userProfile.userMetrics.avgResponseTime) + " hr"
            cell.lblMetricOrders.text = PointtersHelper.sharedInstance.formatCount(value: userProfile.userMetrics.numOrdersCompleted) + " Service Orders Completed"
            cell.lblMetricRatings.text = PointtersHelper.sharedInstance.formatCount(value: userProfile.userMetrics.avgRating) + " Average Ratings"
            cell.lblMetricCustomers.text = String(format:"%.1f", userProfile.userMetrics.avgWillingToBuyAgain) + "% Customers will buy this service again"
            return cell
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "offerCell") as! ProfileCell
            return cell
        }
        else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell") as! ProfileCell
            let result = UserService.init(dict: arrUserServices[indexPath.row])
            
            cell.imgService.layer.cornerRadius = 5.0
            cell.imgService.layer.masksToBounds = true

            if result.service.media.fileName != "" && result.service.media.mediaType != "video" {
                cell.imgService.sd_imageTransition = .fade
                cell.imgService.sd_setImage(with: URL(string: result.service.media.fileName)!, placeholderImage: UIImage(named:"photo_placeholder"))
            } else {
                cell.imgService.image = UIImage(named:"photo_placeholder")
            }
            
            if result.service.media.mediaType == "image" {
                if result.service.media.fileName != "" {
                    cell.imgService.sd_imageTransition = .fade
                    cell.imgService.sd_setImage(with: URL(string: result.service.media.fileName)!, placeholderImage: UIImage(named:"photo_placeholder"))
                }
            } else {
                if result.service.media.fileName != "" {
                    let thumbImage = generateThumbnailForVideoAtURL(filePathLocal: result.service.media.fileName as NSString)
                    cell.imgService.image = thumbImage
                }
            }
            
            cell.lblServiceDesc.text = (result.service.tagline != "") ? result.service.tagline : result.service.desc
            
            let strSymbol = (result.service.prices.currencySymbol != "") ? result.service.prices.currencySymbol : "$"
            cell.lblServicePrice.text = strSymbol + String(format:"%.2f", result.service.prices.price)
            
            let strUnit = (result.service.prices.timeUnitOfMeasure != "hour") ? result.service.prices.timeUnitOfMeasure : "hr"
            cell.lblServiceTime.text = String(format:"%d", result.service.prices.time) + " " + strUnit
                
            var strKm = "NA"
            if result.service.location.geoJson.coordinates.count > 1 {
                let serviceLocation = CLLocation(latitude: result.service.location.geoJson.coordinates[1], longitude: result.service.location.geoJson.coordinates[0])
                let kilometers = (userLocation?.distance(from: serviceLocation))! / 1000
                strKm = String(format: "%.2f", kilometers) + "km"
            }
            if result.service.fulfillmentMethod.online  == true {
                cell.lblServiceAddress.text = "Online Service"
            } else {
                cell.lblServiceAddress.text = strKm + " " + result.service.location.city + ", " + result.service.location.state
            }
            
            cell.btnSellerName.setTitle(userProfile.firstName + " " + userProfile.lastName, for: .normal)
            
            cell.lblServicePoint.text = String(format:"%d", result.pointValue)
            cell.lblServiceBusiness.text = String(format:"%d", result.numOrders)
            cell.lblServiceRating.text = String(format:"%.1f", result.avgRating) + "%"
            let item = arrUserServices[indexPath.row]
            if item.keys.contains("promoted") {
                cell.iconPromotion.isHidden = item["promoted"] as! Bool == false
                cell.lblPromotion.isHidden = item["promoted"] as! Bool == false
            }else{
                cell.iconPromotion.isHidden = true
                cell.lblPromotion.isHidden = true
            }
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
}

// UITableViewDelegate
extension UserProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == 3 && indexPath.row == arrUserServices.count-1) && (self.totalCnt > self.limitCnt) {
            callGetUserServiceApi(userId: userId, inited: false, lastId: self.lastDocId)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                self.selectDescFlag = !self.selectDescFlag
                tableView.reloadData()
            }
        }
        if indexPath.section == 2 && !userType {
            btnChatTapped(sender: UIButton())
        } else if indexPath.section == 3 {
            let result = UserService.init(dict: arrUserServices[indexPath.row])
            let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
            let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
            serviceDetailVC.serviceId = result.service.id
            navigationController?.pushViewController(serviceDetailVC, animated: true)
        }
    }
    
}

extension UserProfileViewController: EditProfileDelegate{
    func onSuccessSave() {
        initUI()
        initData()
        callGetUserServiceApi(userId: userId, inited: true, lastId: "")
    }
}
