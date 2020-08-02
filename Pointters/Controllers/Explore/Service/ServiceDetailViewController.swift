//
//  ServiceDetailViewController.swift
//  Pointters
//
//  Created by super on 3/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import SDWebImage
import CoreLocation
import AVFoundation
import AVKit

class ServiceDetailViewController: UIViewController {
    
    var deleteDelegate: DeleteServiceDelegate!
    var deleteIndex: Int!

    @IBOutlet var consCollectionTop: NSLayoutConstraint!
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet weak var pageCtrl: UIPageControl!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var btnBuy: UIButton!
    
    var fromPublicPage = false
    
    var loginUserId = ""
    var serviceId = ""
    var tagLine = ""
    var serviceDetail = [String:Any]()
    var serviceBgMedia = [[String:Any]]()
    var serviceInfo = [String:Any]()
    var serviceSeller = [String:Any]()
    var serviceMetrics = [String:Any]()
    var seviceRelated = [[String:Any]]()
    var servicePrices = [[String:Any]]()
    var serviceReviews = [[String:Any]]()
    var serviceLocation = [[String:Any]]()
    var arrAmount = [Int]()
    var totalPrice:Float = 0.0
    var currentMedaiPage = 0
    var isQuantityAtLeastOne: Int = 0
    
    var serviceLiked = false
    var serviceWatched = false
    
    var descHeight : CGFloat = 80.0
    var selectDescFlag = false
    
    var priceCellHeight:CGFloat = 70.0
    var priceFlags = [Bool]()
    var selPriceCellIndex = 0
    
    var showedReviewTip = false
    var showedRelatedTip = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
        PointtersHelper.sharedInstance.sendAnalyticsToFirebase(event: kFirebaseEvents.screenServiceDetail)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI() {
        mainTableView.rowHeight = UITableViewAutomaticDimension
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 80.0
            consCollectionTop.constant = -24
        } else {
            consNavBarHeight.constant = 64.0
            consCollectionTop.constant = -24
        }
        btnBuy.layer.cornerRadius = 5.0
        btnBuy.layer.masksToBounds = true
        
        self.reloadPriceAndAmount()
    }
    
    func initData() {
        loginUserId = UserCache.sharedInstance.getAccountData().id
        if serviceId != "" {
            callGetServiceDetailApi(serviceId: serviceId)
        }
    }
    
    func showInputDialog(){
        let alertController = UIAlertController(title: "Flag Inappropriate", message: "Tell us why you think this service is inappropriate", preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Submit", style: .cancel) { (_) in
            let commentText = alertController.textFields?[0].text
            self.callFlagInappropriateAPI(comment : commentText!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in }
    
        alertController.addTextField(
            configurationHandler: {(textField: UITextField!) in
                let heightConstraint = NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
                textField.addConstraint(heightConstraint)
                textField.placeholder = "Placeholder"
                textField.layer.backgroundColor = UIColor.clear.cgColor
//                textField.layer.borderWidth = 1.0
//                textField.layer.borderColor = UIColor.black.cgColor
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
//    *******************************************************//
//                  MARK: - IBAction Method                  //
//    *******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changePageControl(_ sender: UIPageControl) {
        if sender.currentPage > currentMedaiPage {
            self.mediaCollectionView.scrollToItem(at: IndexPath(item:sender.currentPage, section: 0), at: .right, animated: true)
        }else{
            self.mediaCollectionView.scrollToItem(at: IndexPath(item:sender.currentPage, section: 0), at: .left, animated: true)
        }
    }
    
    @IBAction func btnShareTapped(_ sender: Any) {
        var description = ""
        if let desc = self.serviceInfo["tagline"] as? String {
            description = desc
        }
        var sharelink = ""
        if let share = self.serviceDetail["shareLink"] as? String {
            sharelink = share
        }
        if description.count > 50 {
            description = String(description.prefix(50))
            description = description + "..."
        }
        let shareService = "Checkout this awesome service on Pointters app: " + description + "\n" + sharelink
        let shareViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [shareService], applicationActivities: nil)
        shareViewController.completionWithItemsHandler = { activity, success, items, error in
            if error != nil || !success{
                return
            }
            self.callShareServiceAPI()
        }
        DispatchQueue.main.async {
            self.present(shareViewController, animated: true, completion: nil)
        }
    }

    func gotoLogin() {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        loginVC.targetTapIndex = 2
        self.navigationController?.pushViewController(loginVC, animated: false)
    }
    
    @IBAction func btnBuyClicked(_ sender: Any) {
        if UserCache.sharedInstance.getUserAuthToken() == nil {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            loginVC.serviceId = self.serviceId
            loginVC.arrAmount = self.arrAmount
            loginVC.totalPrice = self.totalPrice
            self.navigationController?.pushViewController(loginVC, animated: false)
            return
        }
        if (self.serviceSeller["userId"] as! String) == UserCache.sharedInstance.getAccountData().id{
            PointtersHelper.sharedInstance.showAlertViewWithTitle("Warning", message: "You are not allowed to buy your own service.", buttonTitles: ["OK"], viewController: self) { (type) in
                return
            }
        }
        let checkoutVC = storyboard?.instantiateViewController(withIdentifier: "CheckoutVC") as! CheckoutViewController
        checkoutVC.serviceInfo = self.serviceInfo
        checkoutVC.servicePrices = self.servicePrices
        checkoutVC.serviceBgMedia = self.serviceBgMedia
        checkoutVC.serviceId = self.serviceId
        checkoutVC.serviceSeller = self.serviceSeller
        checkoutVC.arrAmount = self.arrAmount
        checkoutVC.isCustomOffer = false
        navigationController?.pushViewController(checkoutVC, animated: true)
    }
    
    @objc func btnFlagInappriateTapped(sender: UIButton) {
        if UserCache.sharedInstance.getUserAuthToken() == nil {
            self.gotoLogin()
            return
        }
        if serviceInfo["flaggedInappropriateByUser"] as! Bool {
            self.deleteFlagInappropriateAPI()
        }else{
            self.showInputDialog()
        }
        
    }
    
    // move to profile page
    @objc func btnNameTapped(sender: UIButton) {
        if UserCache.sharedInstance.getUserAuthToken() == nil {
            self.gotoLogin()
            return
        }
        var strOtherId = ""
        let dictService = self.seviceRelated[sender.tag]
        let itemSeller : [String:Any] = dictService["seller"] as! [String:Any]
        strOtherId = itemSeller["userId"] as! String
        if strOtherId == self.loginUserId {
            UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
        } else {
            UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
        }
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        navigationController?.pushViewController(userProfileVC, animated:true)
    }
    
    @objc func gotoUserProfile(guesture: MyTapGesture){
        if UserCache.sharedInstance.getUserAuthToken() == nil {
            self.gotoLogin()
            return
        }
        let strOtherId = guesture.param
        if strOtherId == self.loginUserId {
            UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
        } else {
            UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
        }
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        navigationController?.pushViewController(userProfileVC, animated:true)
    }
    
    @objc func btnAddTapped(sender: UIButton) {
        let item = self.servicePrices[sender.tag]
        self.arrAmount[sender.tag] += 1
        self.mainTableView.reloadData()
        let totalPriceNumber = item["price"] as! NSNumber
        self.totalPrice += totalPriceNumber.floatValue
        self.isQuantityAtLeastOne += 1
        self.btnBuy.setTitle("Buy for $\(String(format: "%.2f", self.totalPrice))", for: .normal)
        
        if self.isQuantityAtLeastOne > 0 {
            btnBuy.alpha = 1.0
            btnBuy.isUserInteractionEnabled = true
        } else {
            btnBuy.alpha = 0.3
            btnBuy.isUserInteractionEnabled = false
        }
    }
    
    @objc func btnDownTapped(sender: UIButton) {
        if self.arrAmount[sender.tag] > 0{
            let item = self.servicePrices[sender.tag]
            self.arrAmount[sender.tag] -= 1
            self.mainTableView.reloadData()
             let priceNumber = item["price"] as! NSNumber
            self.totalPrice -= priceNumber.floatValue
            self.btnBuy.setTitle("Buy for $\(String(format: "%.2f", self.totalPrice))", for: .normal)
        }
        
        if self.isQuantityAtLeastOne > 0 {
            self.isQuantityAtLeastOne -= 1
        }
        
        if self.isQuantityAtLeastOne > 0 {
            btnBuy.alpha = 1.0
            btnBuy.isUserInteractionEnabled = true
        } else {
            btnBuy.alpha = 0.3
            btnBuy.isUserInteractionEnabled = false
        }
    }
    
    func reloadPriceAndAmount() {
        self.btnBuy.setTitle("Buy for $\(String(format: "%.2f", self.totalPrice))", for: .normal)
        if self.isQuantityAtLeastOne > 0 {
            btnBuy.alpha = 1.0
            btnBuy.isUserInteractionEnabled = true
        } else {
            btnBuy.alpha = 0.3
            btnBuy.isUserInteractionEnabled = false
        }
    }
    
    @objc func btnCallTapped(sender: UIButton) {
        if UserCache.sharedInstance.getUserAuthToken() == nil {
            self.gotoLogin()
            return
        }
        if let phone = self.serviceSeller["phone"] as? String {
            PointtersHelper.sharedInstance.callByPhone(phone: phone, ctrl: self)
        }
    }
    
    @objc func btnEditTapped(sender: UIButton) {
        var serviceMedia = [Media]()
        for i in 0 ..< self.serviceBgMedia.count {
            serviceMedia.append(Media.init(dict: self.serviceBgMedia[i]))
        }
        var arrPrices = [Price]()
        for i in 0 ..< self.servicePrices.count {
            arrPrices.append(Price.init(dict: self.servicePrices[i]))
        }
        var serviceDesc = ""
        if let desc = self.serviceInfo["description"] as? String{
            serviceDesc = desc
        }
        var serviceCategory = Category.init()
        if let category = self.serviceInfo["category"] as? [String:Any]{
            serviceCategory = Category.init(dict: category)
        }
        var serviceFulfillment = FulFillment.init()
        if let fulfillmentMethod = self.serviceInfo["fulfillmentMethod"] as? [String:Any] {
            serviceFulfillment = FulFillment.init(dict: fulfillmentMethod)
        }
        let itemLocation = self.serviceLocation[0]
        let serviceAddress = Location.init(dict: itemLocation)
        let addServiceVC = storyboard?.instantiateViewController(withIdentifier: "AddServiceVC") as! AddServiceViewController
        if self.deleteDelegate != nil {
            addServiceVC.deleteDelegate = self.deleteDelegate ?? nil
        }
        addServiceVC.saveDelegate = self
        addServiceVC.deleteIndex = self.deleteIndex
        addServiceVC.serviceId = self.serviceId
        addServiceVC.serviceMedia = serviceMedia
        addServiceVC.arrPrices = arrPrices
        addServiceVC.serviceTitle = tagLine
        addServiceVC.serviceDesc = serviceDesc
        addServiceVC.serviceCategory = serviceCategory
        addServiceVC.serviceFulfillment = serviceFulfillment
        addServiceVC.serviceAddress = serviceAddress
        navigationController?.pushViewController(addServiceVC, animated: true)
    }
    
    @objc func btnChatTapped(sender: UIButton) {
        var userId = ""
        if let sellerId = self.serviceSeller["userId"] as? String {
            userId = sellerId
        }
        var sellerName = ""
        if let firstName = self.serviceSeller["firstName"] as? String {
            sellerName = firstName
        }
        if let lastName = self.serviceSeller["lastName"] as? String {
            sellerName = sellerName + " " + lastName
        }
        let userName = sellerName
        var userPic = ""
        if let profilePic = self.serviceSeller["profilePic"] as? String {
            userPic = profilePic
        }
        if UserCache.sharedInstance.getUserAuthToken() == nil {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            loginVC.chatUserId = userId
            loginVC.chatUserPic = userPic
            loginVC.chatUserName = userName
            self.navigationController?.pushViewController(loginVC, animated: false)
            return
        }
        if userId != self.loginUserId {
            UserCache.sharedInstance.setChatCredentials(id: "", userId: userId, name: userName, pic: userPic, verified: true)
            let storyboard = UIStoryboard(name: "Chats", bundle: nil)
            let privateChatVC = storyboard.instantiateViewController(withIdentifier: "PrivateChatVC") as! PrivateChatViewController
            privateChatVC.otherUserId = userId
            privateChatVC.otherUserPic = userPic
            privateChatVC.otherUsername = userName
            navigationController?.pushViewController(privateChatVC, animated:true)
        }
    }
    
    @objc func btnLikesTapped(sender: UIButton) {
        if UserCache.sharedInstance.getUserAuthToken() == nil {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            loginVC.serviceId = self.serviceId
            self.navigationController?.pushViewController(loginVC, animated: false)
            return
        }
        if self.serviceLiked {
            self.callServiceUnLikeAPI()
        } else {
            self.callServiceLikeAPI()
        }
        
    }
    
    @objc func btnWatchesTapped(sender: UIButton) {
        if UserCache.sharedInstance.getUserAuthToken() == nil {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            loginVC.serviceId = self.serviceId
            self.navigationController?.pushViewController(loginVC, animated: false)
            return
        }
        if self.serviceWatched {
            self.callServiceUnWatchAPI()
        } else {
            self.callServiceWatchAPI()
        }
    }
    
    @objc func btnGetDirection(sender: UIButton) {
        let itemLocation = self.serviceLocation[0]
        let serviceLocation = Location.init(dict: itemLocation)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let getDirectionVC = storyboard.instantiateViewController(withIdentifier: "GetDirectionVC") as! GetDirectionViewController
        getDirectionVC.serviceLocation = serviceLocation
        navigationController?.pushViewController(getDirectionVC, animated: true)
    }
    
    //*******************************************************//
    //                 MARK: - Call API Method               //
    //*******************************************************//
    
    func callGetServiceDetailApi(serviceId: String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetServiceDetail(serviceId: serviceId, withCompletionHandler:{ (result,statusCode,response) in
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    self.serviceDetail = responseDict["result"] as! [String:Any]
                    self.serviceInfo = self.serviceDetail["service"] as! [String:Any]
                    if let _ = self.serviceInfo["tagline"]{
                        self.tagLine = self.serviceInfo["tagline"] as! String
                    }else{
                        self.tagLine = ""
                    }
                    if let _ = self.serviceInfo["liked"]{
                        self.serviceLiked = self.serviceInfo["liked"] as! Bool
                    }
                    if let _ = self.serviceInfo["watched"] {
                        self.serviceWatched = self.serviceInfo["watched"] as! Bool
                    }
                    self.servicePrices = self.serviceInfo["prices"] as! [[String:Any]]
                    
                    self.arrAmount.removeAll()
                    self.totalPrice = 0
                    for _ in 0 ..< self.servicePrices.count {
                        self.arrAmount.append(0)
                        self.priceFlags.append(false)
                        //                        let item = self.servicePrices[i]
                        //                        self.totalPrice += item["price"] as! Int
                    }
                    self.btnBuy.setTitle("Buy for $\(String(format: "%.2f", self.totalPrice))", for: .normal)
                    
                    if self.isQuantityAtLeastOne > 0 {
                        self.btnBuy.alpha = 1.0
                        self.btnBuy.isUserInteractionEnabled = true
                    } else {
                        self.btnBuy.alpha = 0.3
                        self.btnBuy.isUserInteractionEnabled = false
                    }
                    
                    
                    if let _ = self.serviceDetail["seller"]{
                        self.serviceSeller = self.serviceDetail["seller"] as! [String:Any]
                    }
                    if let _ = self.serviceInfo["media"]{
                        self.serviceBgMedia = self.serviceInfo["media"] as! [[String:Any]]
                    }
                    if let _ = self.serviceInfo["location"]{
                        self.serviceLocation = self.serviceInfo["location"] as! [[String:Any]]
                    }
                    if let _ = self.serviceDetail["serviceMetrics"]{
                        self.serviceMetrics = self.serviceDetail["serviceMetrics"] as! [String:Any]
                    }
                    if let _ = self.serviceDetail["reviews"]{
                        self.serviceReviews = self.serviceDetail["reviews"] as! [[String:Any]]
                    }
                    self.pageCtrl.numberOfPages = self.serviceBgMedia.count
                    self.pageCtrl.hidesForSinglePage = true
                    self.mediaCollectionView.reloadData()
                    self.callRelatedServicesApi()
                }else {
                    PointtersHelper.sharedInstance.stopLoader()
                    let responseDict = response.value as! [String:Any]
                    let message = responseDict["message"] as! String
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: message, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.stopLoader()
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Error in finding service or deleted service.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                    self.navigationController?.popViewController(animated: true)
                })
            }
        })
    }
    
    func callRelatedServicesApi() {
        ApiHandler.callGetRelatedServices(serviceId: self.serviceId, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    self.seviceRelated = responseDict["docs"] as! [[String:Any]]
                    self.mainTableView.reloadData()
                    let sectionView = self.mainTableView.headerView(forSection: 4)
                    sectionView?.backgroundColor = UIColor.red
                }
            }
            else {
                print(response.error ?? "get service detail failure")
                self.mainTableView.reloadData()
            }
        })
    }
    
    func callFlagInappropriateAPI(comment:String){
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callFlagInappropriate(serviceId: self.serviceId, comment: comment, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    let message = responseDict["message"] as! String
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: message, buttonTitles: ["OK"], viewController: self, completion: nil)
                    self.serviceInfo["flaggedInappropriateByUser"] = true
                    self.mainTableView.reloadData()
                }
            }
            else {
                print(response.error ?? "flag inappropriate failure")
            }
        })
    }
    
    func deleteFlagInappropriateAPI(){
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.deleteFlagInappropriate(serviceId: self.serviceId, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    self.serviceInfo["flaggedInappropriateByUser"] = false
                    self.mainTableView.reloadData()
                }
            }
            else {
                print(response.error ?? "flag inappropriate failure")
            }
        })
    }
    
    func callShareServiceAPI(){
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callShareService(serviceId: self.serviceId, withCompletionHandler:{ (result,statusCode,response,error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    self.callGetServiceDetailApi(serviceId: self.serviceId)
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Service shared successfully", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        })
    }
    
    func callServiceLikeAPI() {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callLikeService(serviceId: self.serviceId, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    self.serviceLiked = true
                    self.serviceMetrics["numLikes"] = (self.serviceMetrics["numLikes"] as! Int) + 1
                    self.mainTableView.reloadData()
                }
            }
            else {
                print(response.error ?? "like service failure")
            }
        })
    }
    
    func callServiceUnLikeAPI() {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callUnLikeService(serviceId: self.serviceId, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    self.serviceLiked = false
                    self.serviceMetrics["numLikes"] = (self.serviceMetrics["numLikes"] as! Int) - 1
                    self.mainTableView.reloadData()
                }
            }
            else {
                print(response.error ?? "unlike service failure")
            }
        })
    }
    
    
    func callServiceWatchAPI() {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callWatchService(serviceId: self.serviceId, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    self.serviceWatched = true
                    self.serviceMetrics["numWatching"] = (self.serviceMetrics["numWatching"] as! Int) + 1
                    self.mainTableView.reloadData()
                }
            }
            else {
                print(response.error ?? "watch service failure")
            }
        })
    }
    
    func callServiceUnWatchAPI() {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callUnWatchService(serviceId: self.serviceId, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    self.serviceWatched = false
                    self.serviceMetrics["numWatching"] = (self.serviceMetrics["numWatching"] as! Int) - 1
                    self.mainTableView.reloadData()
                }
            }
            else {
                print(response.error ?? "unwatch service failure")
            }
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
extension ServiceDetailViewController: UICollectionViewDataSource, AAPlayerDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageCtrl.currentPage = indexPath.item
        self.currentMedaiPage = indexPath.item
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.serviceBgMedia.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgsCell", for: indexPath)
        
        let imgView = cell.viewWithTag(1001) as! UIImageView
        let playerView = cell.viewWithTag(1002) as! AAPlayer
        let itemMedia = self.serviceBgMedia[indexPath.item]
        let mediaType = itemMedia["mediaType"] as! String
        if mediaType == "image" {
            playerView.isHidden = true
            let fileName = itemMedia["fileName"] as! String
            imgView.sd_imageTransition = .fade
            imgView.sd_setImage(with: URL(string: fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
        } else {
            playerView.isHidden = false
            playerView.delegate = self
            let fileName = itemMedia["fileName"] as! String
            playerView.playVideo(fileName)
            
            let url = URL.init(string: fileName)
            DispatchQueue.global().async {
                let asset = AVAsset(url: url!)
                let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                assetImgGenerate.appliesPreferredTrackTransform = true
                let time = CMTimeMake(1, 2)
                let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                if img != nil {
                    let frameImg  = UIImage(cgImage: img!)
                    DispatchQueue.main.async(execute: {
                        imgView.image = frameImg
                    })
                }
            }
//            let thumgImage = generateThumbnailForVideoAtURL(filePathLocal: fileName as NSString)
//            imgView.image = thumgImage
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemMedia = self.serviceBgMedia[indexPath.item]
        let mediaType = itemMedia["mediaType"] as! String
        if mediaType == "image" {
            let fileName = itemMedia["fileName"] as! String
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let fullScreenImageVC = storyboard.instantiateViewController(withIdentifier: "FullScreenImageVC") as! FullScreenImageViewController
            fullScreenImageVC.imageUrl = fileName
            navigationController?.pushViewController(fullScreenImageVC, animated:false)
        } else {
            let fileName = itemMedia["fileName"] as! String
            let playURL = NSURL(string: fileName)
            let player = AVPlayer(url: playURL! as URL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    
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

// UICollectionViewDelegate
extension ServiceDetailViewController: UICollectionViewDelegate {
}

// UICollectionViewDelegateFlowLayout
extension ServiceDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = UIScreen.main.bounds.size.width
        let cellSize = CGSize(width: CGFloat(width), height: height)
        return cellSize
    }
}

extension ServiceDetailViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3
        case 1: return self.servicePrices.count
        case 2,3,4: return 1
        case 5:
            if self.serviceReviews.count > 2 {
                return 3
            } else {
                return self.serviceReviews.count
            }
        case 6: return self.seviceRelated.count
        case 7: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1: return 15.0
        case 3,4,5,6: return 40.0
        default: return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: return 75.0
            case 1:
                if let serviceDesc = self.serviceInfo["description"] as? String {
                    let height = serviceDesc.height(withConstrainedWidth: CGFloat(UIScreen.main.bounds.size.width - 30), font: UIFont(name: "Helvetica", size: 13)!) + 50
                    if height >= self.descHeight {
                        if selectDescFlag {
                            return height + 20
                        } else {
                            return self.descHeight + 30
                        }
                    } else {
                        return height + 20
                    }
                } else {
                    return 0.0
                }
            case 2: return 52.0
            default: return 0.0
            }
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            if (self.serviceSeller["userId"] != nil) && (self.serviceSeller["userId"] as! String) == UserCache.sharedInstance.getAccountData().id{
                return 0.0
            }
            return 45.0
        case 3: return 170.0
        case 4:
            if let _ = self.serviceInfo["fulfillmentMethod"] {
                let fulfillmentMethodDict = self.serviceInfo["fulfillmentMethod"] as! [String:Any]
                let fulfillmentMethod = FulFillment.init(dict: fulfillmentMethodDict)
                if fulfillmentMethod.online{
                    return 40
                }
            }
            return 280.0
        case 5:
            if self.serviceReviews.count > 2 {
                if indexPath.row != 2 {
                    return 150.0
                }else {
                    return 40.0
                }
            } else {
                return 150.0
            }
        case 6: return 123.0
        case 7: return 80.0
        default: return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        if section != 1{
            let headerLabel = UILabel(frame: CGRect(x: 15, y: 20, width: tableView.bounds.size.width - 30, height: 20))
            headerLabel.font = UIFont(name: "Helvetica", size: 14)
            headerLabel.textColor = UIColor.getCustomGrayTextColor()
            
            if section == 3 {
                headerLabel.text = "SERVICE METRICS"
            } else if section == 4 {
                headerLabel.text = "DELIVERY METHOD"
            } else if section == 5 {
                headerLabel.text = (self.serviceReviews.count > 0) ? "REVIEWS" : "NO REVIEWS"
            } else if section == 6 {
                headerLabel.text = "RELATED SERVICES"
            }
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! ProfileCell
                if self.serviceDetail.keys.contains("seller") == false{
                    return cell
                }
                if self.serviceSeller.keys.contains("firstName"){
                    cell.lblName.text = "\(self.serviceSeller["firstName"] as! String) \(self.serviceSeller["lastName"] as! String)"
                }
                if self.serviceSeller.keys.contains("verified") {
                    let verified = self.serviceSeller["verified"] as! Bool
                    if verified {
                        cell.lblVerfied.text = "Verified"
                    }else{
                        cell.lblVerfied.text = "Unverified"
                    }
                } else{
                    cell.lblVerfied.text = "Unverified"
                }
                if self.serviceSeller.keys.contains("profilePic") {
                    let profilePic = self.serviceSeller["profilePic"] as! String
                    cell.imgUser.sd_imageTransition = .fade
                    cell.imgUser.sd_setImage(with: URL(string: profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                }else{
                    cell.imgUser.image = UIImage(named:"user_avatar_placeholder")
                }
                cell.imgUser.layer.cornerRadius = 20.0
                cell.btnEdit.layer.cornerRadius = 5.0
                cell.btnEdit.layer.borderWidth = 1.0
                cell.btnEdit.layer.borderColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0).cgColor
                cell.btnEdit.layer.masksToBounds = false
                let sellerId = self.serviceSeller["userId"] as! String
                if sellerId == self.loginUserId {
                    cell.btnEdit.isHidden = false
                    cell.btnCall.isHidden = true
                    cell.btnChat.isHidden = true
                }else{
                    cell.btnEdit.isHidden = true
                    cell.btnChat.isHidden = false
                    cell.btnCall.isHidden = false
                }
                if self.serviceSeller.keys.contains("phone"){
                    cell.btnCall.isHidden = false
                    cell.btnCall.addTarget(self, action: #selector(btnCallTapped(sender:)), for: .touchUpInside)
                } else {
                    cell.btnCall.isHidden = true
                }
                cell.btnChat.addTarget(self, action: #selector(btnChatTapped(sender:)), for: .touchUpInside)
                cell.btnEdit.addTarget(self, action: #selector(btnEditTapped(sender:)), for: .touchUpInside)
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "descCell", for: indexPath) as! ProfileCell
                if self.serviceDetail.keys.contains("seller") == false{
                    return cell
                }
                cell.lblTag.text = self.tagLine
                cell.lblDesc.text = self.serviceInfo["description"] as? String
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! ProfileCell
                if self.serviceDetail.keys.contains("seller") == false{
                    return cell
                }
                let point_ns = self.serviceMetrics["pointValue"] as! Int
                cell.lblPoint.text = "\(point_ns) Points"
                cell.lblLikes.text = "\(self.serviceMetrics["numLikes"] as! Int) Likes"
                cell.lblWatching.text = "\(self.serviceMetrics["numWatching"] as! Int) Watching"
                cell.iconLikes.image = self.serviceLiked ? UIImage(named: "icon-like-selected") : UIImage(named: "icon-like-normal")
                cell.iconWatch.image = self.serviceWatched ? UIImage(named: "icon-watch-select") : UIImage(named: "icon-watch-normal")
                cell.btnLikes.addTarget(self, action: #selector(btnLikesTapped(sender:)), for: .touchUpInside)
                cell.btnWatch.addTarget(self, action: #selector(btnWatchesTapped(sender:)), for: .touchUpInside)
                return cell
            }
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pricesCell", for: indexPath) as! ServiceDetailCell
            if self.serviceDetail.keys.contains("service") == false{
                return cell
            }
            let itemPrice = self.servicePrices[indexPath.row]
            let itemPriceFloat = itemPrice["price"] as! NSNumber
            cell.lblPrice.text = "\(itemPrice["currencySymbol"] as! String)\(String(format: "%.2f", itemPriceFloat.floatValue)) For \(itemPrice["description"] as! String)"
            cell.lblAmount.text = "\(self.arrAmount[indexPath.row])"
            cell.btnAdd.tag = indexPath.row
            cell.btnDown.tag = indexPath.row
            cell.btnAdd.addTarget(self, action: #selector(btnAddTapped(sender:)), for: .touchUpInside)
            cell.btnDown.addTarget(self, action: #selector(btnDownTapped(sender:)), for: .touchUpInside)
            return cell
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "getOfferCell", for: indexPath) as! ServiceDetailCell
            return cell
        }else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "metricsCell", for: indexPath) as! ProfileCell
            if self.serviceDetail.keys.contains("seller") == false{
                return cell
            }
            cell.lblOnTime.text = "\(self.serviceMetrics["avgOnTime"] as! Int) %"
            cell.lblQuality.text = "\(self.serviceMetrics["avgQuality"] as! Int)"
            cell.lblResponse.text = "\(self.serviceMetrics["avgResponseTime"] as! Int) hrs"
            cell.lblMetricOrders.text = "\(self.serviceMetrics["numOrdersCompleted"] as! Int) Service Orders Completed"
            cell.lblMetricRatings.text = "\(self.serviceMetrics["avgRating"] as! Int) Average Ratings"
            cell.lblMetricCustomers.text = "\(self.serviceMetrics["avgWillingToBuyAgain"] as! Int)% Customers will buy this service again"
            return cell
        }else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryCell", for: indexPath) as! ServiceDetailCell
            if self.serviceDetail.keys.contains("seller") == false{
                return cell
            }
            if self.serviceLocation.count != 0 {
                let itemLocation = self.serviceLocation[0]
                if let geoJSON = itemLocation["geoJson"] as? [String:Any] {
                    let coordinates = geoJSON["coordinates"] as! [Double]
                    let fulfillmentMethodDict = self.serviceInfo["fulfillmentMethod"] as! [String:Any]
                    let fulfillmentMethod = FulFillment.init(dict: fulfillmentMethodDict)
                    if fulfillmentMethod.local == true {
                        cell.isLocalService = true
                        cell.localRadius = fulfillmentMethod.localServiceRadius
                    } else {
                        cell.isLocalService = false
                    }
                    if !fulfillmentMethod.online {
                        if fulfillmentMethod.store {
                            cell.showStoreLocations(locations: self.serviceLocation)
                        } else {
                            cell.showLocation(lat: coordinates[1], lng: coordinates[0])
                        }
                    }
                }
                let fulfillmentMethodDict = self.serviceInfo["fulfillmentMethod"] as! [String:Any]
                let fulfillmentMethod = FulFillment.init(dict: fulfillmentMethodDict)
                var fulfillmentString = ""
                if fulfillmentMethod.online == true{
                    fulfillmentString.append("Servicing Online")
                }
                if fulfillmentMethod.local == true {
                    if fulfillmentString != ""{
                        fulfillmentString.append(", Servicing Locally Within \(fulfillmentMethod.localServiceRadius) Miles")
                    } else {
                        fulfillmentString.append("Servicing Locally Within \(fulfillmentMethod.localServiceRadius) Miles")
                    }
                }
                if fulfillmentMethod.store == true {
                    if fulfillmentString != ""{
                        fulfillmentString.append(", Service Locally at Store Locations")
                    } else {
                        fulfillmentString.append("Service Locally at Store Locations")
                    }
                }
                if fulfillmentMethod.shipment == true{
                    if fulfillmentString != ""{
                        fulfillmentString.append(", Shipment")
                    } else {
                        fulfillmentString.append("Shipment")
                    }
                }
                cell.lblFulfillment.text = fulfillmentString
                cell.btnGetDirections.addTarget(self, action: #selector(btnGetDirection(sender:)), for: .touchUpInside)
            }
            return cell
        }else if indexPath.section == 5 {
            if self.serviceReviews.count > 2 && indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "readMoreCell", for: indexPath) as! ServiceDetailCell
                cell.lblReadMore.text = "Read \(self.serviceReviews.count) More Reviews"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ServiceDetailCell
                let cellItem = self.serviceReviews[indexPath.row]
                if cellItem.keys.contains("profilePic") {
                    let profilePic = cellItem["profilePic"] as! String
                    cell.imgBuyerPic.sd_imageTransition = .fade
                    cell.imgBuyerPic.sd_setImage(with: URL(string: profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                }else{
                    cell.imgBuyerPic.image = UIImage(named:"user_avatar_placeholder")
                }
                let tapGuesture = MyTapGesture(target: self, action: #selector(self.gotoUserProfile(guesture:)))
                tapGuesture.param = cellItem["userId"] as! String
                cell.imgBuyerPic.addGestureRecognizer(tapGuesture)
                cell.imgBuyerPic.isUserInteractionEnabled = true
                if cellItem.keys.contains("firstName"){
                    let firstName = cellItem["firstName"] as! String
                    let lastName = cellItem["lastName"] as! String
                    cell.lblBuyerName.text = firstName + " " + lastName
                }
                let tapGuesture2 = MyTapGesture(target: self, action: #selector(self.gotoUserProfile(guesture:)))
                tapGuesture2.param = cellItem["userId"] as! String
                cell.lblBuyerName.addGestureRecognizer(tapGuesture2)
                cell.lblBuyerName.isUserInteractionEnabled = true
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                let createdTime = dateFormatter.date(from:cellItem["createdAt"] as! String)!
                let calendar = Calendar.current
                if calendar.isDateInToday(createdTime){
                    cell.lblDate.text = "Today \(calendar.component(.hour, from: createdTime)):\(calendar.component(.minute, from: createdTime))"
                }else{
                    let days = Date().interval(ofComponent: .day, fromDate: createdTime)
                    if days == 1 {
                        cell.lblDate.text = "\(days) day ago"
                    } else{
                        cell.lblDate.text = "\(days) days ago"
                    }
                }
                if let comment = cellItem["comment"] as? String {
                    cell.lblComment.text = comment
                }
                if let qualityOfService = cellItem["qualityOfService"] as? Float {
                    cell.lblQuality.text = String(format:"%.1f", qualityOfService)
                }
                if let overallRating = cellItem["overallRating"] as? Int {
                    cell.lblRating.text = "\(overallRating)%"
                }
                if let onTime = cellItem["onTime"] as? Bool {
                    cell.imgOnTime.image = onTime ? UIImage(named:"icon-done") : UIImage(named:"icon-red-mask")
                }
                if let buyAgain = cellItem["willingToBuyServiceAgain"] as? Bool {
                    cell.imgBuyAgain.image = buyAgain ? UIImage(named:"icon-done") : UIImage(named:"icon-red-mask")
                }
                cell.imgBuyerPic.layer.cornerRadius = cell.imgBuyerPic.frame.size.width / 2
                return cell
            }
        }else if indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath) as! ProfileCell
            if self.serviceDetail.keys.contains("seller") == false{
                return cell
            }
            let item = self.seviceRelated[indexPath.row]
            let itemService = item["service"] as! [String:Any]
            let itemMedia = itemService["media"] as! [[String:Any]]
            let itemMediaType = itemMedia[0]["mediaType"] as! String
            let itemFileName = itemMedia[0]["fileName"] as! String
            if itemFileName != "" && itemMediaType != "video" {
                cell.imgService.sd_imageTransition = .fade
                cell.imgService.sd_setImage(with: URL(string: itemFileName), placeholderImage: UIImage(named:"photo_placeholder"))
            }else{
                cell.imgService.image = UIImage(named:"photo_placeholder")
            }
            cell.imgService.layer.cornerRadius = 5.0
            cell.imgService.layer.masksToBounds = true
            
            let description = itemService["description"] as! String
            let pointValue = itemService["pointValue"] as! Int
            let numOrders = itemService["numOrders"] as! Int
            let avgRating = itemService["avgRating"] as! NSNumber
            cell.lblServiceDesc.text = (itemService["tagline"] != nil) ? itemService["tagline"] as! String : description
            cell.lblServicePoint.text = String(format:"%d", pointValue)
            cell.lblServiceBusiness.text = String(format:"%d", numOrders)
            cell.lblServiceRating.text = String(format:"%.1f", avgRating.floatValue) + "%"
            
            let itemPrices = itemService["prices"] as! [[String:Any]]
            if itemPrices.count > 0 {
                let itemCurrency = itemPrices[0]["currencySymbol"] as! String
                let itemPrice = itemPrices[0]["price"] as! NSNumber
                let itemTime = itemPrices[0]["time"] as! Int
                let itemTimeUnit = itemPrices[0]["timeUnitOfMeasure"] as! String
                cell.lblServiceTime.text = "\(itemTime) \(itemTimeUnit)"
                cell.lblServicePrice.text = "\(itemCurrency)\(String(format: "%.2f", itemPrice.floatValue))"
            }else{
                print("no data")
            }
            
            let seller = item["seller"] as! [String:Any]
            if seller.keys.contains("firstName"){
                let firstName = seller["firstName"] as! String
                let lastName = seller["lastName"] as! String
                cell.btnSellerName.setTitle(firstName + " " + lastName, for: .normal)
                cell.btnSellerName.tag = indexPath.row
                cell.btnSellerName.addTarget(self, action: #selector(btnNameTapped(sender:)), for: .touchUpInside)
            }
            if itemService.keys.contains("promoted"){
                let promoted = itemService["promoted"] as! Bool
                if promoted  {
                    cell.iconPromotion.isHidden = false
                    cell.lblPromotion.isHidden = false
                }else {
                    cell.iconPromotion.isHidden = true
                    cell.lblPromotion.isHidden = true
                }
            } else {
                cell.iconPromotion.isHidden = true
                cell.lblPromotion.isHidden = true
            }
            
            let itemLocations = itemService["location"] as! [[String:Any]]
            if itemLocations.count > 0 {
                let itemLocation : [String:Any] = itemLocations[0]
                let geoJson = itemLocation["geoJson"] as! [String:Any]
                let coordinates = geoJson["coordinates"] as! [Double]
                let serviceCoord = CLLocation(latitude: coordinates[1],  longitude:coordinates[0])
                let userCoord = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
                let distanceInMeter = userCoord.distance(from: serviceCoord)
                let distanceInKilo = Double(round(10*(distanceInMeter / 1000)/10))
                let fulfillmentMethod = itemService["fulfillmentMethod"] as! [String:Any]
                let online = fulfillmentMethod["online"] as! Bool
                if online  == true{
                    cell.lblServiceAddress.text = "Online Service"
                } else {
                    cell.lblServiceAddress.text = "\(distanceInKilo)km \(itemLocation["city"] as! String), \(itemLocation["state"] as! String)"
                }
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "section6", for: indexPath) as! ServiceDetailCell
            if let flag = self.serviceInfo["flaggedInappropriateByUser"] as? Bool{
                cell.imageFlag.image = UIImage(named: (flag) ? "icon-flag-red" : "icon-flag")
            }
            cell.btnFlagInappriate.addTarget(self, action: #selector(btnFlagInappriateTapped(sender:)), for: .touchUpInside)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                var userId = ""
                if let sellerId = self.serviceSeller["userId"] as? String {
                    userId = sellerId
                }
                if userId == self.loginUserId {
                    UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
                } else {
                    UserCache.sharedInstance.setProfileUser(loginUser: false, userId: userId)
                }
                if UserCache.sharedInstance.getUserAuthToken() == nil {
                    let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                    let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                    loginVC.userId = userId
                    self.navigationController?.pushViewController(loginVC, animated: false)
                    return
                }
                let storyboard = UIStoryboard(name: "Account", bundle: nil)
                let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
                navigationController?.pushViewController(userProfileVC, animated:true)
            } else if indexPath.row == 1 {
                self.selectDescFlag = !self.selectDescFlag
                tableView.reloadData()
            }
        } else if indexPath.section == 1 {
            self.priceFlags[indexPath.row] = !self.priceFlags[indexPath.row]
            self.selPriceCellIndex = indexPath.row
            tableView.reloadData()
        } else if indexPath.section == 2 {
            self.btnChatTapped(sender: UIButton())
        } else if indexPath.section == 5 {
            if self.serviceReviews.count > 2 && indexPath.row == 2 {
                let serviceReviewsVC = storyboard?.instantiateViewController(withIdentifier: "ServiceReviewsVC") as! ServiceReviewsViewController
                serviceReviewsVC.arrServiceReviews = self.serviceReviews
                navigationController?.pushViewController(serviceReviewsVC, animated: true)
            }
        } else if indexPath.section == 6 {
            let item = self.seviceRelated[indexPath.row]
            let itemService = item["service"] as! [String:Any]
            let selectedServiceId = itemService["id"] as! String
            let serviceDetailVC = storyboard?.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
            serviceDetailVC.serviceId = selectedServiceId
            navigationController?.pushViewController(serviceDetailVC, animated: true)
        }
    }
}

extension ServiceDetailViewController: SaveServiceDelegate {
    func onSaveService() {
        self.initData()
    }
}
