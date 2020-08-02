//
//  ExploreServiceViewController.swift
//  Pointters
//
//  Created by Mac on 2/14/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import MapKit
import STPopup
import AVFoundation
import SDWebImage
import UserNotifications

class ExploreServiceViewController: UIViewController {

    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet var consNavViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var jobFilterView: UIView!
    @IBOutlet weak var liveOfferView: UIView!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var btnNeed: UIButton!
    @IBOutlet weak var btnRedoSearch: UIButton!
    @IBOutlet weak var bottomContentView: UIView!
    @IBOutlet weak var stickView: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnRequestText: UIButton!
    @IBOutlet weak var bottomTableView: UITableView!
    @IBOutlet weak var consBottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ivSellerPic: UIImageView!
    @IBOutlet weak var lblSellerName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var detailContentView: UIView!
    @IBOutlet weak var btnLocationNew: UIButton!
    @IBOutlet weak var btnNeedNew: UIButton!
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var jobMarkView: UIView!
    @IBOutlet weak var labelIncomingTotal: UILabel!
    @IBOutlet weak var labelNewIncomingBadge: UILabel!

    @IBOutlet weak var viewIncomingAlert: UIView!
    @IBOutlet weak var btnSeeNewOffer: UIButton!

    @IBOutlet weak var viewEmpty: UIView!
    @IBOutlet weak var labelEmptyText: UILabel!
    @IBOutlet weak var imageEmpty: UIImageView!

    var selectedTabIndex = 0
    var selectedUserId = ""
    var selectedRequestId = ""
    var selectedServiceId = ""
    var arrAmount = [Int]()
    var totalPrice:Float = 0.0

    var chatUserId = ""
    var chatUserPic = ""
    var chatUserName = ""

    var popularServicesList = [[String:Any]]()
    var onlineServicesList = [[String:Any]]()
    var localServicesList = [[String:Any]]()
    var popularJobsList = [[String:Any]]()
    var onlineJobsList = [[String:Any]]()
    var localJobsList = [[String:Any]]()
    
    var exploreLiveOffersList = [[String:Any]]()
    var selectedRequest: RequestDetail?
    var savedRequests: [RequestDetail] = []
    var liveRange: [Any] = []
    var viewSwipedUp = false

    var loginUserId = ""

    var currentPage = 1
    var totalPages = 0
    var offerIndex = 1

    var pinZindex = 0

    var totalIncomingOffer = 0
    var newIncomingOffer = 0

    var distanceLimit: Double = 50.0
    var selectedPinView: CustomPinAnnotationView!

    var tabChanged = false
    var type = ""
    var isService = false
    var liveOffer = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginUserId = UserCache.sharedInstance.getAccountData().id
        initUI()
        initData()
        if self.selectedUserId != "" {
            self.gotoUserProfile(userId: self.selectedUserId)
        }
        if self.selectedRequestId != "" {
            self.gotoRequestView(requestId: self.selectedRequestId)
        }
        if self.selectedServiceId != "" {
            self.gotoServiceDetail(serviceId: self.selectedServiceId)
        }
        if self.chatUserId != "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                self.gotoChatPage()
            })
        }
        if self.selectedTabIndex == 0 {
            PointtersHelper.sharedInstance.sendAnalyticsToFirebase(event: kFirebaseEvents.screenServices)
        } else if self.selectedTabIndex == 1{
            PointtersHelper.sharedInstance.sendAnalyticsToFirebase(event: kFirebaseEvents.screenLiveOffers)
            if selectedRequest != nil {
                self.newIncomingOffer = (selectedRequest?.numNewOffers)!
                self.showIncomingNotification(show: (self.newIncomingOffer > 0) ? true: false)
                self.initLiveOfferView(request: selectedRequest!)
            }
        } else {
            PointtersHelper.sharedInstance.sendAnalyticsToFirebase(event: kFirebaseEvents.screenJobs)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeNotificationReceiver()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.addNotificationReceiver()
    }

    func showEmptyView() {
        self.viewEmpty.isHidden = false
        if self.selectedTabIndex == 0 {
            self.labelEmptyText.text = "There aren’t any services for you at the moment."
            self.imageEmpty.image = UIImage(named: "icon-buy-order")
        } else if self.selectedTabIndex == 2 {
            self.labelEmptyText.text = "There aren’t any jobs for you at the moment."
            self.imageEmpty.image = UIImage(named: "icon-job-search")
        } else {
            self.hideEmptyView()
        }
    }

    func hideEmptyView() {
        self.viewEmpty.isHidden = true
    }

    func addNotificationReceiver() {
        print("added notification handler...............")
        let center = UNUserNotificationCenter.current()
        center.delegate = self
    }

    func removeNotificationReceiver() {
        print("removed notification handler....................")
        NotificationCenter.default.removeObserver(self)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setNotificationDelegate()
    }

    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//

    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavViewHeight.constant = 105.0
        } else {
            consNavViewHeight.constant = 105.0
        }
        if self.liveOffer {
            consNavViewHeight.constant = 50
            liveOfferView.isHidden = false
            mainTableView.isHidden = true
            detailContentView.isHidden = false
            btnRequestText.isHidden = false
        } else {
            mainTableView.isHidden = false
            mainTableView.tableFooterView = UIView()
            liveOfferView.isHidden = true
        }
                
        customButton(button: self.btnRedoSearch)
        customButton(button: self.btnNeedNew)
        customButton(button: self.btnLocationNew)
        stickView.layer.cornerRadius = 10.0
        addShadow(view: detailContentView)
        ivSellerPic.layer.cornerRadius = ivSellerPic.frame.size.width / 2
        detailContentView.isHidden = true
        requestView.isHidden = true
        btnRedoSearch.isHidden = true
        bottomTableView.isScrollEnabled = false
        self.mapView.delegate = self

        btnNeedNew.isHidden = false
        btnLocationNew.isHidden = false
        
        self.showIncomingNotification(show: false)

        let userLocation = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
        getUserAddress(location: userLocation)

        let swipeUpGesture = UISwipeGestureRecognizer.init(target: self, action: #selector(showBottomView))
        swipeUpGesture.direction = .up
        stickView.addGestureRecognizer(swipeUpGesture)

        let swipeDownGesture = UISwipeGestureRecognizer.init(target: self, action: #selector(hideBottomView))
        swipeDownGesture.direction = .down
        stickView.addGestureRecognizer(swipeDownGesture)

        let mapTouchGuester = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard))
        mapTouchGuester.numberOfTapsRequired = 1
        self.mapView.addGestureRecognizer(mapTouchGuester)
        self.bottomTableView.tableFooterView = UIView()
        self.visibleBottomView()
    }

    func initData(){
        
        self.showIncomingNotification(show: false)
        self.tabChanged = true
        self.removeNotificationReceiver()
        if liveOffer {
            mainTableView.isHidden = true
            liveOfferView.isHidden = false
            self.navTitle.text = "Live Offer"
            callExploreLiveOffersAPI(inited: false, currentPage: self.currentPage)
        } else {
            mainTableView.isHidden = false
            liveOfferView.isHidden = true
            if isService {
                if type == "online" {
                    self.navTitle.text = "Online Services"
                    callServicesAPI(filter: "online")
                } else if type == "local" {
                    self.navTitle.text = "Local Services"
                    callServicesAPI(filter: "local")
                } else {
                    self.navTitle.text = "Popular Services"
                    callServicesAPI(filter: "")
                }
            } else {
                if type == "online" {
                    self.navTitle.text = "Online Jobs"
                    callJobsAPI(filter: "online")
                } else if type == "local" {
                    self.navTitle.text = "Local Jobs"
                    callJobsAPI(filter: "local")
                } else {
                    self.navTitle.text = "Popular Jobs"
                    callJobsAPI(filter: "")
                }
            }
        }
    }

    func initLiveOfferView(request: RequestDetail) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.savedRequests.append(request)
            self.btnRedoSearch.isHidden = false
            self.btnLocation.isHidden = request.onlineJob
            self.callGetOffersForRequest(requestId: request.id)
        }
    }

    func gotoChatPage() {
        UserCache.sharedInstance.setChatCredentials(id: "", userId: chatUserId, name: chatUserName, pic: chatUserPic, verified: true)
        let storyboard = UIStoryboard(name: "Chats", bundle: nil)
        let privateChatVC = storyboard.instantiateViewController(withIdentifier: "PrivateChatVC") as! PrivateChatViewController
        privateChatVC.otherUserId = chatUserId
        privateChatVC.otherUserPic = chatUserPic
        privateChatVC.otherUsername = chatUserName
        navigationController?.pushViewController(privateChatVC, animated:true)
        self.chatUserId = ""
        self.chatUserPic = ""
        self.chatUserName = ""
    }

    func gotoServiceDetail(serviceId: String) {
        let serviceDetailVC = storyboard?.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
        serviceDetailVC.arrAmount = self.arrAmount
        serviceDetailVC.totalPrice = self.totalPrice
        serviceDetailVC.deleteIndex = 0
        serviceDetailVC.serviceId = serviceId
        navigationController?.pushViewController(serviceDetailVC, animated: true)
    }

    func gotoUserProfile(userId: String) {
        let storyboard = UIStoryboard.init(name: "Account", bundle: nil)
        let strOtherId = userId
        if strOtherId == UserCache.sharedInstance.getAccountData().id {
            UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
        } else {
            UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
        }
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }

    func gotoRequestView(requestId: String) {
        let requestDetailVC = storyboard?.instantiateViewController(withIdentifier: "RequestDetailVC") as! RequestDetailViewController
        requestDetailVC.pageFlag = 0
        requestDetailVC.requestId = requestId
        navigationController?.pushViewController(requestDetailVC, animated: true)
    }

    func getUserAddress(location:CLLocation) {
        let viewRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
        self.mapView?.setRegion(viewRegion, animated:true)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
            if let err = error {
                print(err.localizedDescription)
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    self.btnLocation.isHidden = false
                    self.btnLocation.setTitle(placemark.locality, for: .normal)
                    self.btnLocation.layoutIfNeeded()
                    self.btnLocationNew.setTitle(placemark.locality, for: .normal)
                    self.btnLocationNew.layoutIfNeeded()
                } else {
                    print("Placemark was nil")
                }
            } else {
                print("Unknown error")
            }
        })
    }

    func customButton(button:UIButton){
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 0.0
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 15.0
    }

    func addShadow(view:UIView) {
        view.layer.cornerRadius = 10.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.init(width: 2.0, height: 2.0)
        view.layer.shadowRadius = 5.0
    }

    func showIncomingNotification(show: Bool) {
        self.viewIncomingAlert.isHidden = !show
    }

    func visibleBottomView() {
        self.stickView.isHidden = (self.exploreLiveOffersList.count > 0) ? false : true
        self.bottomContentView.isHidden = (self.exploreLiveOffersList.count > 0) ? false : true
        self.labelNewIncomingBadge.isHidden = (self.newIncomingOffer > 0) ? false: true
        self.labelIncomingTotal.text = "\(self.totalIncomingOffer)"
        self.labelNewIncomingBadge.text = "\(self.newIncomingOffer)"
        self.bottomTableView.reloadData()
    }

    func showLocations(){

        self.mapView.removeAnnotations(self.mapView.annotations)

        var pointIndex = 1

        for item in exploreLiveOffersList {
            let locations = item["location"] as! [String:Any]
            let itemLocation = Location.init(dict: locations)
            let point: CustomPointAnnotation = CustomPointAnnotation()
            point.coordinate = CLLocationCoordinate2DMake(itemLocation.geoJson.coordinates[1], itemLocation.geoJson.coordinates[0])
            point.number = pointIndex
            point.type = "offer"
            pointIndex += 1
            self.mapView?.addAnnotation(point)
        }
    }

    func openDetailView(resultArray: [[String: Any]], index: Int) {
        let storyboard = UIStoryboard(name: "Public", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "searchPopupViewController") as! SearchPopupViewController
        vc.resultArr = resultArray
        vc.type = "liveOffer"
        vc.parentOfferView = self
        vc.index = index-1
        vc.contentSizeInPopup = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        let popupController = STPopupController(rootViewController: vc)
        popupController.style = .bottomSheet
        popupController.navigationBarHidden = true
        popupController.containerView.backgroundColor = UIColor.clear
        popupController.present(in: self)
    }

    func removeSelectedPinImage() {
        if (self.selectedPinView != nil) {
            self.selectedPinView.image = UIImage(named:"icon-pin-normal")
        }
        let pins = self.mapView.selectedAnnotations
        for pin in pins {
            self.mapView.deselectAnnotation(pin, animated: true)
        }
    }

    func onSelectMapPin(pin: CustomPointAnnotation) -> Bool{
        let point = CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude)
        var mergedPins = [[String: Any]]()

        for offer in self.exploreLiveOffersList {
            let locationObj = offer["location"] as! [String: Any]
            let s_location = Location.init(dict: locationObj)
            let otherPoint = CLLocation(latitude: s_location.geoJson.coordinates[1], longitude: s_location.geoJson.coordinates[0])
            if point.distance(from: otherPoint) < self.distanceLimit {
                mergedPins.append(offer)
            }
        }

        openDetailView(resultArray: mergedPins, index: pin.number)
        return (mergedPins.count > 1) ? false: true
    }

    @objc func showBottomView() {
        self.viewSwipedUp = true
        UIView.animate(withDuration: 0.2, animations: {
            self.btnMenu.setImage(UIImage(named: "icon-close-gray"), for: .normal)
            self.consBottomViewHeight.constant = self.liveOfferView.frame.size.height - 75
            self.bottomTableView.isScrollEnabled = true
            self.view.layoutIfNeeded()
        })
    }

    @objc func hideBottomView() {
        self.viewSwipedUp = false
        UIView.animate(withDuration: 0.2, animations: {
            self.btnMenu.setImage(UIImage(named: "menu-icon"), for: .normal)
            self.consBottomViewHeight.constant = 70
            if self.bottomTableView.visibleCells.count > 0 {
                self.bottomTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
            self.bottomTableView.isScrollEnabled = false
            self.view.layoutIfNeeded()
        })
    }

    @objc func hideKeyboard() {
        self.searchBar.endEditing(true)
    }
    @IBAction func onClickSeeIt(_ sender: Any) {
        self.showIncomingNotification(show: false)
        let request = self.exploreLiveOffersList.last
        if request == nil {
            return
        }
        let offerId = request!["offerId"] as! String
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let customOfferDetailsVC = storyboard.instantiateViewController(withIdentifier: "OfferDetailVC") as! OfferDetailViewController
        customOfferDetailsVC.exploreVC = self
        customOfferDetailsVC.offerId = offerId
        customOfferDetailsVC.offerFlag = 0
        navigationController?.pushViewController(customOfferDetailsVC, animated:true)
    }

    func callServicesAPI(filter: String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callServices(filter: filter, withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            self.popularServicesList.removeAll()
            self.onlineServicesList.removeAll()
            self.localServicesList.removeAll()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for itemService in arr {
                            if filter == "online" {
                                self.onlineServicesList.append(itemService)
                            } else if filter == "local" {
                                self.localServicesList.append(itemService)
                            } else {
                                self.popularServicesList.append(itemService)
                            }
                        }
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
            self.mainTableView.reloadData()
            if filter == "online" {
                if self.onlineServicesList.count > 0 {
                    self.hideEmptyView()
                }else {
                    self.showEmptyView()
                }
            } else if filter == "local" {
                if self.localServicesList.count > 0 {
                    self.hideEmptyView()
                }else {
                    self.showEmptyView()
                }
            } else {
                if self.popularServicesList.count > 0 {
                    self.hideEmptyView()
                }else {
                    self.showEmptyView()
                }
            }
        })
    }

    func callJobsAPI(filter: String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callJobs(filter: filter, withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            self.popularJobsList.removeAll()
            self.onlineJobsList.removeAll()
            self.localJobsList.removeAll()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for itemJob in arr {
                            if filter == "online" {
                                self.onlineJobsList.append(itemJob)
                            } else if filter == "local" {
                                self.localJobsList.append(itemJob)
                            } else {
                                self.popularJobsList.append(itemJob)
                            }
                        }
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
            self.mainTableView.reloadData()
            if filter == "online" {
                if self.onlineJobsList.count > 0 {
                    self.hideEmptyView()
                }else {
                    self.showEmptyView()
                }
            } else if filter == "local" {
                if self.localJobsList.count > 0 {
                    self.hideEmptyView()
                }else {
                    self.showEmptyView()
                }
            } else {
                if self.popularJobsList.count > 0 {
                    self.hideEmptyView()
                }else {
                    self.showEmptyView()
                }
            }
        })
    }

    func callExploreLiveOffersAPI(inited: Bool, currentPage: Int) {
        if selectedRequest != nil {
            self.mapView.removeAnnotations(self.mapView.annotations)
            if selectedRequest?.id == "" {
                btnLocationNew.isHidden = false
                btnNeedNew.isHidden = false
                requestView.isHidden = true
                btnRequestText.isHidden = true
            } else {
                requestView.isHidden = false
                btnRequestText.isHidden = false
                btnRequestText.setTitle(selectedRequest?.category.name, for: .normal)
                btnNeed.setTitle(selectedRequest?.desc, for: .normal)
                btnLocation.setTitle(selectedRequest?.location.province, for: .normal)
                btnLocationNew.isHidden = true
                btnNeedNew.isHidden = true
                if (selectedRequest?.location.geoJson.coordinates.count)! > 0 {
                    let newCordinate = CLLocationCoordinate2DMake((selectedRequest?.location.geoJson.coordinates[1])!, (selectedRequest?.location.geoJson.coordinates[0])!)
                    let newRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(newCordinate, 500, 500)
                    self.mapView?.setRegion(newRegion, animated:false)

                    let bottomLeft = self.mapView.convert(CGPoint(x: 0, y: self.mapView.frame.size.height), toCoordinateFrom: self.mapView)
                    let topRight = self.mapView.convert(CGPoint(x: self.mapView.frame.size.width, y: 0), toCoordinateFrom: self.mapView)

                    liveRange = [[bottomLeft.longitude, bottomLeft.latitude], [topRight.longitude, topRight.longitude]]
                }

                self.callGetOffersForRequest(requestId: (self.selectedRequest?.id)!)
            }
        }else {
            self.showLocations()
            self.bottomTableView.reloadData()
        }
    }

    func callGetOffersForRequest(requestId: String) {

        ApiHandler.callExploreOffersForRequest(requestId: requestId, withCompletionHandler: { (result,statusCode,response, error) in
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.currentPage = responseDict["page"] as! Int + 1
                    self.totalPages = responseDict["pages"] as! Int
                    if responseDict["total"] != nil {
                        self.totalIncomingOffer = responseDict["total"] as! Int
                    }
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        self.exploreLiveOffersList.removeAll()
                        for itemLiveOffer in arr {
                            self.exploreLiveOffersList.append(itemLiveOffer)
                        }
                        self.visibleBottomView()
                        
                        // Display bottom table as default instead of map view
                        self.viewSwipedUp = true
                        self.detailContentView.isHidden = true
                        self.btnMenu.setImage(UIImage(named: "icon-close-gray"), for: .normal)
                        self.consBottomViewHeight.constant = self.liveOfferView.frame.size.height - 75
                        self.bottomTableView.isScrollEnabled = true
                        self.view.layoutIfNeeded()
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
                self.showIncomingNotification(show: false)
            }
            self.showLocations()
            self.bottomTableView.reloadData()
        })
    }

    func catureVideoThumbnail(imageView: UIImageView, url: URL) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time = CMTimeMake(1, 2)
            let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            if img != nil {
                let frameImg  = UIImage(cgImage: img!)
                DispatchQueue.main.async(execute: {
                    imageView.image = frameImg
                })
            } else {
                imageView.image = UIImage(named: "photo_placeholder")
            }
        }
    }

    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
   
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnMenuAction(_ sender: Any) {
        detailContentView.isHidden = true
        if viewSwipedUp{
            self.viewSwipedUp = false
            UIView.animate(withDuration: 0.2, animations: {
                self.btnMenu.setImage(UIImage(named: "menu-icon"), for: .normal)
                self.consBottomViewHeight.constant = 70
                if self.bottomTableView.visibleCells.count > 0 {
                    self.bottomTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
                self.bottomTableView.isScrollEnabled = false
                self.view.layoutIfNeeded()
            })
        }
        else{
            self.viewSwipedUp = true
            UIView.animate(withDuration: 0.2, animations: {
                self.btnMenu.setImage(UIImage(named: "icon-close-gray"), for: .normal)
                self.consBottomViewHeight.constant = self.liveOfferView.frame.size.height - 75
                self.bottomTableView.isScrollEnabled = true
                self.view.layoutIfNeeded()
            })
        }
    }

    @IBAction func btnNeedRequestAction(_ sender: UIButton) {

        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editRequestAction: UIAlertAction = UIAlertAction(title: "Edit", style: .default) { action -> Void in
            let requestDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "RequestDetailVC") as! RequestDetailViewController
            requestDetailVC.pageFlag = 2
            if self.selectedRequest != nil {
                requestDetailVC.requestId = (self.selectedRequest?.id)!
            }
            requestDetailVC.requestDelegate = self
            self.navigationController?.pushViewController(requestDetailVC, animated: true)
        }
        let newRequestAction: UIAlertAction = UIAlertAction(title: "Post New Job", style: .default) { action -> Void in
            let requestDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "RequestDetailVC") as! RequestDetailViewController
            requestDetailVC.pageFlag = 1
            requestDetailVC.requestDelegate = self
            self.navigationController?.pushViewController(requestDetailVC, animated: true)
        }
        let seeRequestsAction: UIAlertAction = UIAlertAction(title: "See My Jobs", style: .default) { action -> Void in
            let storyboard = UIStoryboard(name: "Account", bundle: nil)
            let aboutMeVC = storyboard.instantiateViewController(withIdentifier: "AboutMeVC") as! AboutMeViewController
            aboutMeVC.vcDelegate = self
            aboutMeVC.selTabIndex = 0
            aboutMeVC.segmentIndex = 2
            self.navigationController?.pushViewController(aboutMeVC, animated: true)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

        if self.selectedRequest != nil {
            if self.selectedRequest?.id != "" {
                actionSheetController.addAction(editRequestAction)
            }
        }
        actionSheetController.addAction(newRequestAction)
        actionSheetController.addAction(seeRequestsAction)
        actionSheetController.addAction(cancelAction)

        present(actionSheetController, animated: true, completion: nil)
    }

    @IBAction func btnLocationAction(_ sender: Any) {
        self.selectedRequest = nil
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SetLocationVC") as! SetLocationViewController
        vc.locationDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func btnLocationNewAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SetLocationVC") as! SetLocationViewController
        vc.locationDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func btnRedoSearchAction(_ sender: Any) {
        let userLocation = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
        getUserAddress(location: userLocation)
        self.requestView.isHidden = true
        self.btnLocationNew.isHidden = false
        self.btnNeedNew.isHidden = false
        selectedRequest = nil
        savedRequests.removeAll()
        self.exploreLiveOffersList.removeAll()
        self.visibleBottomView()
        self.bottomTableView.isHidden = true
        self.btnRedoSearch.isHidden = true
        self.mapView.removeAnnotations(self.mapView.annotations)
    }

    @IBAction func btnDogWalkingAction(_ sender: Any) {

    }

    @IBAction func onClickJobFilter(_ sender: Any) {
        
    }

    func showRequestMenu() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let editAction: UIAlertAction = UIAlertAction(title: "Edit", style: .default) { action -> Void in
            print("Edit Action pressed")
        }
        let newRequestAction: UIAlertAction = UIAlertAction(title: "Post New Job", style: .default) { action -> Void in
            print("Post New Job Action pressed")
        }
        let seeRequestsAction: UIAlertAction = UIAlertAction(title: "See My Jobs", style: .default) { action -> Void in
            print("See My Jobs Action pressed")
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

        // add actions
        actionSheetController.addAction(editAction)
        actionSheetController.addAction(newRequestAction)
        actionSheetController.addAction(seeRequestsAction)
        actionSheetController.addAction(cancelAction)

        // present an actionSheet
        present(actionSheetController, animated: true, completion: nil)
    }

    // move to profile page
    @objc func btnNameTapped(sender: UIButton) {
        var strOtherId = ""
        var dictService = [String:Any]()
        if type == "online" {
            dictService = self.onlineServicesList[sender.tag]
        } else if type == "local" {
            dictService = self.localServicesList[sender.tag]
        } else {
            dictService = self.popularServicesList[sender.tag]
        }
        
        let itemSeller : [String:Any] = dictService["seller"] as! [String:Any]
        strOtherId = itemSeller["id"] as! String
        if strOtherId == self.loginUserId {
            UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
        } else {
            UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
        }
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        navigationController?.pushViewController(userProfileVC, animated:true)
    }

    // move to send custom offer page
    @objc func btnMakeOfferTapped(sender: UIButton) {
        var dictJob = [String:Any]()
        if type == "online" {
            dictJob = self.onlineJobsList[sender.tag]
        } else if type == "local" {
            dictJob = self.localJobsList[sender.tag]
        } else {
            dictJob = self.popularJobsList[sender.tag]
        }
        
        let jobId = dictJob["id"] as! String
        let jobOwner = dictJob["user"] as! [String:Any]
        let ownerId = jobOwner["id"] as! String
        var categoryId = ""
        if let category = dictJob["category"] as? [String: Any] {
            categoryId = category["id"] as! String
        }
        let sendOfferVC = storyboard?.instantiateViewController(withIdentifier: "SendOfferVC") as! SendOfferViewController
        sendOfferVC.isJobOffer = true
        sendOfferVC.requestId = jobId
        sendOfferVC.categoryId = categoryId
        sendOfferVC.buyerId = ownerId
        sendOfferVC.customOfferDelegate = self
        navigationController?.pushViewController(sendOfferVC, animated:true)
    }

    // move to edit offer page
    @objc func btnEditOfferTapped(sender: UIButton) {
        var item = [String:Any]()
        if type == "online" {
            item = self.onlineJobsList[sender.tag]
        } else if type == "local" {
            item = self.localJobsList[sender.tag]
        } else {
            item = self.popularJobsList[sender.tag]
        }
        let offerId = item["offerSentId"] as! String
        let user = item["user"] as! [String: Any]
        let buyerId = user["id"] as! String
        let sendCustomOfferVC = storyboard?.instantiateViewController(withIdentifier: "SendOfferVC") as! SendOfferViewController
        sendCustomOfferVC.customOfferDelegate = self
        sendCustomOfferVC.offerId = offerId
        sendCustomOfferVC.buyerId = buyerId
        sendCustomOfferVC.isJobOffer = true
        navigationController?.pushViewController(sendCustomOfferVC, animated:true)
    }

    @objc func btnSentOfferTapped(sender: MyTapGesture) {
        var item = [String:Any]()
        if type == "online" {
            item = self.onlineJobsList[Int(sender.param)!]
        } else if type == "local" {
            item = self.localJobsList[Int(sender.param)!]
        } else {
            item = self.popularJobsList[Int(sender.param)!]
        }
        let offerId = item["offerSentId"] as! String
        let user = item["user"] as! [String: Any]
        let buyerId = user["id"] as! String
        let sendCustomOfferVC = storyboard?.instantiateViewController(withIdentifier: "SendOfferVC") as! SendOfferViewController
        sendCustomOfferVC.customOfferDelegate = self
        sendCustomOfferVC.offerId = offerId
        sendCustomOfferVC.buyerId = buyerId
        sendCustomOfferVC.isJobOffer = true
        navigationController?.pushViewController(sendCustomOfferVC, animated:true)
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
extension UIView {

    public func removeAllConstraints() {
        var _superview = self.superview

        while let superview = _superview {
            for constraint in superview.constraints {

                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }

                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }

            _superview = superview.superview
        }

        self.removeConstraints(self.constraints)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
}

extension ExploreServiceViewController : UITableViewDelegate, UITableViewDataSource {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0)
        {
            self.searchBar.endEditing(true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == mainTableView {
            if isService {
                return 130
            } else {
                return 120
            }
        } else {
            return 70
        }
    }

//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if self.searchBar.selectedScopeButtonIndex == 0 {
//            if (indexPath.row == exploreServicesList.count - 1) && (self.currentPage - 1 < self.totalPages) {
//                callExploreServicesAPI(inited: false, currentPage: self.currentPage)
//            }
//        }
//        else if self.searchBar.selectedScopeButtonIndex == 1 {
//            if (indexPath.row == exploreLiveOffersList.count - 1) && (self.currentPage - 1 < self.totalPages) {
//                callExploreLiveOffersAPI(inited: false, currentPage: self.currentPage)
//            }
//        }
//        else if self.searchBar.selectedScopeButtonIndex == 2 {
//            if (indexPath.row == exploreJobsList.count - 1) && (self.currentPage - 1 < self.totalPages) {
//                callExploreJobsAPI(inited: false, currentPage: self.currentPage, filter: "")
//            }
//        }
//    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == mainTableView {
            if isService {
                if type == "online" {
                    return onlineServicesList.count
                } else if type == "local" {
                    return localServicesList.count
                } else {
                    return popularServicesList.count
                }
            } else {
                if type == "online" {
                    return onlineJobsList.count
                } else if type == "local" {
                    return localJobsList.count
                } else {
                    return popularJobsList.count
                }
            }
        } else {
            return self.exploreLiveOffersList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == mainTableView {
            if isService {
                let cell : ExploreServiceCell = tableView.dequeueReusableCell(withIdentifier: "exploreServiceCell", for: indexPath) as! ExploreServiceCell
                var item = [String:Any]()
                if type == "online" {
                    item = self.onlineServicesList[indexPath.row]
                } else if type == "local" {
                    item = self.localServicesList[indexPath.row]
                } else {
                    item = self.popularServicesList[indexPath.row]
                }
                
                if item.keys.contains("media"){
                    let itemMedia : [String:Any] = item["media"] as! [String : Any]
                    if itemMedia["fileName"] as! String != "" && itemMedia["mediaType"] as! String == "image"{
                        let fileName : String = itemMedia["fileName"] as! String
                        cell.ivService.sd_imageTransition = .fade
                        cell.ivService.sd_setImage(with: URL(string: fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                    } else if itemMedia["fileName"] as! String != "" && itemMedia["mediaType"] as! String == "video" {
                        let url = URL.init(string: itemMedia["fileName"] as! String)
                        DispatchQueue.global().async {
                            let asset = AVAsset(url: url!)
                            let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                            assetImgGenerate.appliesPreferredTrackTransform = true
                            let time = CMTimeMake(1, 2)
                            let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                            if img != nil {
                                let frameImg  = UIImage(cgImage: img!)
                                DispatchQueue.main.async(execute: {
                                    cell.ivService.image = frameImg
                                })
                            }
                        }
//                            if let thumbnailImage = generateThumbnailForVideoAtURL(filePathLocal: itemMedia["fileName"] as! NSString) {
//                                cell.ivService.image = thumbnailImage
//                            }
                    } else {
                        cell.ivService.image = UIImage(named:"photo_placeholder")
                    }
                }
                cell.lblDescription.text = item["tagline"] as? String
                cell.lblDescription.sizeToFit()

                if let itemPrices = item["prices"] as? [String:Any] {
                    if let price = itemPrices["price"] as? NSNumber, let time = itemPrices["time"] as? Int, let currentSymbol = itemPrices["currencySymbol"] as? String, var timeOfUnit = itemPrices["timeUnitOfMeasure"] as? String{
                        cell.lblPrice.text = currentSymbol + String(format: "%.2f", price.floatValue)
                        if timeOfUnit == "hour" {
                            timeOfUnit = "hr"
                        }
                        cell.lblTimeUnit.text = "\(time) \(timeOfUnit)"
                    }
                }

                let itemLocations = item["location"] as! [[String:Any]]
                if itemLocations.count > 0 {
                    let itemLocation : [String:Any] = itemLocations[0]
                    print("-----itemLocation-----")
                    print(itemLocation)
                    let geoJson = itemLocation["geoJson"] as! [String:Any]
                    let coordinates = geoJson["coordinates"] as! [Double]
                    let serviceCoord = CLLocation(latitude: coordinates[1],  longitude:coordinates[0])
                    let userCoord = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
                    print("----item id----")
                    print(item)
                    print("---user coordinate")
                    print(userCoord)
                    let distanceInMeter = userCoord.distance(from: serviceCoord)
                    print("distanceInMeter="+String(format:"%f", distanceInMeter))
                    let distanceInKilo = Double(round(10*(distanceInMeter / 1000)/10))
                    print("distanceInKilo="+String(format:"%f", distanceInKilo))
                    let fulfillmentMethod = item["fulfillmentMethod"] as! [String:Any]
                    let online = fulfillmentMethod["online"] as! Bool
                    if online  == true{
                        cell.lblLocation.text = "Online Service"
                    } else {
                        let itemLocationCity = itemLocation["city"] as! String
                        print("itemLocationCity ="+itemLocationCity )
                        let itemLocationState = itemLocation["state"] as! String
                        print("itemLocationState ="+itemLocationState )
                        cell.lblLocation.text = "\(distanceInKilo)km \(itemLocation["city"] as! String), \(itemLocation["state"] as! String)"
                    }
                }

                if item.keys.contains("promoted") {
                    cell.promotedView.isHidden = item["promoted"] as! Bool == false
                }else{
                    cell.promotedView.isHidden = true
                }
                if item.keys.contains("seller"){
                    let itemSeller = item["seller"] as! NSDictionary
                    if let _ = itemSeller["firstName"], let _ = itemSeller["lastName"] {
                        cell.btnSellerName.setTitle("\(itemSeller["firstName"] as! String) \(itemSeller["lastName"] as! String)", for: .normal)
                        cell.btnSellerName.tag = indexPath.row
                        cell.btnSellerName.addTarget(self, action: #selector(btnNameTapped(sender:)), for: .touchUpInside)
                    }
                }
                cell.lblPoitValue.text = "\(item["pointValue"] as! Int)"
                if item["numOrders"] is Int {
                    cell.lblNumOrders.text = "\(item["numOrders"] as! Int)"
                } else {
                    cell.lblNumOrders.text = "0"
                }
                let avgRat = item["avgRating"] as! NSNumber
                cell.lblAvgRating.text = "\(String(format: "%.2f", avgRat.floatValue))%"
                return cell
            } else {
                let cell : ExploreJobCell = tableView.dequeueReusableCell(withIdentifier: "exploreJobCell", for: indexPath) as! ExploreJobCell
                var item = [String:Any]()
                if type == "online" {
                    item = self.onlineJobsList[indexPath.row]
                } else if type == "local" {
                    item = self.localJobsList[indexPath.row]
                } else {
                    item = self.popularJobsList[indexPath.row]
                }
                
                if item.keys.contains("media") {
                    let itemMedia : [String:Any] = item["media"] as! [String : Any]
                    if itemMedia["fileName"] as! String != "" && itemMedia["mediaType"] as! String == "image"{
                        let fileName : String = itemMedia["fileName"] as! String
                        cell.ivJob.sd_imageTransition = .fade
                        cell.ivJob.sd_setImage(with: URL(string: fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                    }else{
                        cell.ivJob.image = UIImage(named:"photo_placeholder")
                    }
                }
                let createdTimeString = item["createdAt"] as! String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                let createdTime = dateFormatter.date(from:createdTimeString)!
                let calendar = Calendar.current
                if calendar.isDateInToday(createdTime){
                    cell.lblPostDate.text = "Today \(Int.formatedTimeString(number: calendar.component(.hour, from: createdTime))):\(Int.formatedTimeString(number: calendar.component(.minute, from: createdTime)))"
                }else{
                    let days = Date().interval(ofComponent: .day, fromDate: createdTime)//calendar.component(.day, from: createdTime)
                    cell.lblPostDate.text = "\(days)d"
                }
                var onlineJob = true
                if let _ = item["onlineJob"]{
                    onlineJob = item["onlineJob"] as! Bool
                }
                var jobType = ""
                if onlineJob {
                    jobType = "Online"
                } else {
                    jobType = "Local"
                }
                let expirationDateString = item["expirationDate"] as! String
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                dateFormatter1.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                let expirationDate = dateFormatter1.date(from:expirationDateString)!
//                    let daysDiff = calendar.component(.day, from: expirationDate)
                let daysDiff = expirationDate.interval(ofComponent: .day, fromDate: Date())
                if daysDiff < 0 {
                    cell.lblExpireDate.text = "Expired(" + jobType + ")"
                } else {
                    cell.lblExpireDate.text = jobType + " job expires in \(daysDiff) days"
                }

                cell.lblDescription.text = item["description"] as? String
                if item.keys.contains("minPrice") {
                    if item.keys.contains("maxPrice"){
                        let minPrice = item["minPrice"] as! NSNumber
                        let maxPrice = item["maxPrice"] as! NSNumber
                        cell.lblPriceRange.text = "$\(String.init(format: "%.2f", minPrice.floatValue)) - $\(String.init(format: "%.2f", maxPrice.floatValue))"
                    }else {
                        cell.lblPriceRange.text = "$0 - $0"
                    }

                } else {
                    let maxPrice = item["maxPrice"] as! NSNumber
                    if item.keys.contains("maxPrice") {
                        cell.lblPriceRange.text = "$0 - $\(String.init(format: "%.2f", maxPrice.floatValue))"
                    }else {
                        cell.lblPriceRange.text = "$0 - $0"
                    }
                }

                cell.lblNumOffers.text = "\(item["numOffers"] as! Int)"
                cell.lblOfferSent.isHidden = true
                if item["offerSentAt"]  == nil{
                    cell.btnEditOffer.isHidden = true
                    cell.lblOfferSent.isHidden = true
                    cell.btnMakeOffer.isHidden = false
                    cell.btnMakeOffer.tag = indexPath.row
                }else{
                    cell.btnEditOffer.isHidden = false
                    cell.btnMakeOffer.isHidden = true
                    cell.lblOfferSent.isHidden = false
                    cell.btnEditOffer.tag = indexPath.row
                }
                let sentGesture = MyTapGesture(target: self, action: #selector(btnSentOfferTapped(sender: )))
                sentGesture.param = String(indexPath.row)
                cell.lblOfferSent.addGestureRecognizer(sentGesture)
                cell.lblOfferSent.isUserInteractionEnabled = true
                cell.btnEditOffer.addTarget(self, action: #selector(btnEditOfferTapped(sender:)), for: .touchUpInside)
                cell.btnMakeOffer.addTarget(self, action: #selector(btnMakeOfferTapped(sender:)), for: .touchUpInside)
                return cell
            }
        } else {
            let cell : LiveOfferCell = tableView.dequeueReusableCell(withIdentifier: "liveOfferCell", for: indexPath) as! LiveOfferCell
            var item = [String: Any]()
            if indexPath.section == 0 {
                if exploreLiveOffersList.count > 0 {
                    item = self.exploreLiveOffersList[indexPath.row]
                    let seller = item["seller"] as! [String: Any]
                    let location = Location.init(dict: item["location"] as! [String: Any])
                    let price = item["price"] as! NSNumber
                    if seller["profilePic"] != nil {
                        cell.ivSeller.sd_imageTransition = .fade
                        cell.ivSeller.sd_setImage(with: URL(string: (seller["profilePic"] as! String).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                    }else {
                        cell.ivSeller.image = UIImage(named:"photo_placeholder")
                    }
                    cell.lblSellerName.text = "\(indexPath.row + 1). \(seller["firstName"] as! String) \(seller["lastName"] as! String)"
                    cell.lblDescription.text = item["description"] as? String
                    cell.lblPrice.text = item["currencySymbol"] as! String + String(format: "%.2f", price.floatValue)
                    let serviceCoord = CLLocation(latitude: location.geoJson.coordinates[1], longitude: location.geoJson.coordinates[0])
                    let userCoord = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
                    let distanceInMeter = userCoord.distance(from: serviceCoord)
                    let distanceInKilo = Double(round(10*(distanceInMeter / 1000)/10))
                    cell.lblDistance.text = String(format:"%.1f", distanceInKilo) + " km away"
                }
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchBar.resignFirstResponder()
        if tableView == mainTableView {
            if isService {
                var item = [String:Any]()
                if type == "online" {
                    item = self.onlineServicesList[indexPath.row]
                } else if type == "local" {
                    item = self.localServicesList[indexPath.row]
                } else {
                    item = self.popularServicesList[indexPath.row]
                }
                let serviceDetailVC = storyboard?.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
                serviceDetailVC.deleteDelegate = self
                serviceDetailVC.deleteIndex = indexPath.row
                serviceDetailVC.serviceId = item["id"] as! String
                navigationController?.pushViewController(serviceDetailVC, animated: true)
            } else {
                var item = [String:Any]()
                if type == "online" {
                    item = self.onlineJobsList[indexPath.row]
                } else if type == "local" {
                    item = self.localJobsList[indexPath.row]
                } else {
                    item = self.popularJobsList[indexPath.row]
                }
                
                self.gotoRequestView(requestId: item["id"] as! String)
            }
        } else {
            let offer = self.exploreLiveOffersList[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let customOfferDetailsVC = storyboard.instantiateViewController(withIdentifier: "OfferDetailVC") as! OfferDetailViewController
            customOfferDetailsVC.exploreVC = self
            customOfferDetailsVC.offerId = offer["offerId"] as! String
            customOfferDetailsVC.offerFlag = 0
            navigationController?.pushViewController(customOfferDetailsVC, animated:true)
        }
    }
}

// MARK: - search bar delegate

extension ExploreServiceViewController : UISearchBarDelegate {
        
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         searchBar.endEditing(true)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let storyboard = UIStoryboard(name: "Public", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "initialSearchViewController") as! InitialSearchViewController
        vc.isPublic = false
        self.navigationController?.pushViewController(vc, animated: true)
        return false
    }
}

extension ExploreServiceViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't do anything if it's the users location
        if annotation is MKUserLocation {
            return nil
        }

        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")

        if annotationView == nil {
            if annotation is CustomPointAnnotation {
                annotationView = CustomPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
                annotationView?.canShowCallout = false
            } else {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            }
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: CustomPinAnnotationView.self) {
            view.image = UIImage(named:"icon-pin-normal")
            detailContentView.isHidden = true
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.isKind(of: CustomPinAnnotationView.self) {
            self.selectedPinView = view as? CustomPinAnnotationView
            if view.annotation is CustomPointAnnotation{
                let annotation = view.annotation as! CustomPointAnnotation
                let isSinglePin = self.onSelectMapPin(pin: annotation)
                if isSinglePin {
                    view.image = UIImage(named:"icon-pin-blue")
                }
            }
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.searchBar.endEditing(true)
        if ((self.selectedRequest?.id) != nil && (savedRequests.count != 0)) {
            self.btnRedoSearch.isHidden = false
        }
    }
}

extension ExploreServiceViewController: RequestDetailVCDelegate {
    func submittedRequest(request: RequestDetail) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.selectedRequest = request
            if request.id != "" {
                self.initLiveOfferView(request: request)
            }

            self.callExploreLiveOffersAPI(inited: true, currentPage: 1)
        }
    }

    func onUpdateRequest(request: RequestDetail, index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.selectedRequest = request
            if request.id != "" {
                self.initLiveOfferView(request: request)
            }

            self.callExploreLiveOffersAPI(inited: true, currentPage: 1)
        }
    }

    func onDeleteRequest(index: Int) {
        if isService {
//            if type == "online" {
//                self.onlineServicesList.remove(at: index)
//            } else if type == "local" {
//                self.localServicesList.remove(at: index)
//            } else {
//                self.popularServicesList.remove(at: index)
//            }
//        } else {
//            if type == "online" {
//                self.onlineJobsList.remove(at: index)
//            } else if type == "local" {
//                self.localJobsList.remove(at: index)
//            } else {
//                self.popularJobsList.remove(at: index)
//            }
        }
        if self.selectedTabIndex == 0{
            
        }else if self.selectedTabIndex == 1{
            if self.exploreLiveOffersList.count > index{
                self.selectedRequest = nil
                self.btnRedoSearch.isHidden = true
                self.btnLocation.isHidden = false
                self.btnLocationNew.isHidden = true
                self.exploreLiveOffersList.removeAll()
                self.bottomTableView.reloadData()
            }
        }else{
            
        }
        self.initUI()
        self.initData()
    }
}

extension ExploreServiceViewController: AboutMeVCDelegate {
    func selectJobRequest(request: RequestDetail) {

    }
}

extension ExploreServiceViewController: SetLocationVCDelegate{
    func selectedLocation(location: Location) {
        self.liveRange = location.geoJson.coordinates
        self.callExploreLiveOffersAPI(inited: true, currentPage: 1)
        let loc = CLLocationCoordinate2DMake(location.geoJson.coordinates[1], location.geoJson.coordinates[0])
        let viewRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(loc, 10000, 10000)
        self.mapView?.setRegion(viewRegion, animated:true)
        self.btnLocationNew.setTitle(location.city, for: .normal)
        self.btnLocationNew.layoutIfNeeded()
        self.btnLocation.setTitle(location.city, for: .normal)
        self.btnLocation.layoutIfNeeded()
    }

    func backWithStreet(street: String) {

    }
}

extension ExploreServiceViewController: SendCustomOfferDelegate {
    func selectSendCustomOffer(selId: String, selPrice: [String : Any], linkedService: [String : Any], link: Bool) {
        self.callJobsAPI(filter: "")
//        self.callExploreJobsAPI(inited: true, currentPage: 1, filter: "")
    }

    func returnFromCustomOffer(reload: Bool) {
        self.callJobsAPI(filter: "")
//        self.callExploreJobsAPI(inited: true, currentPage: 1, filter: "")
    }


}

extension ExploreServiceViewController: DeleteServiceDelegate {
    func onClickDeleteService(index: Int) {
        if type == "online" {
            self.onlineServicesList.remove(at: index)
        } else if type == "local" {
            self.localServicesList.remove(at: index)
        } else {
            self.popularServicesList.remove(at: index)
        }
        self.mainTableView.reloadData()
    }
}

extension ExploreServiceViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo as NSDictionary)

        if let payload_key = userInfo[kFCMMessageIDKey.fcmPayloadKey] as? String{
            if let reqId = userInfo["requestId"] as? String {
                if payload_key == kRedirectKey.liveOfferKey && self.selectedRequest != nil && self.selectedRequest?.id == reqId {

                    self.showIncomingNotification(show: true)
                    self.newIncomingOffer = self.newIncomingOffer + 1
                    self.totalIncomingOffer = self.totalIncomingOffer + 1
                    callExploreLiveOffersAPI(inited: true, currentPage: 0)
                }
            }
        }
        completionHandler([.alert, .badge, .sound])
    }
}
