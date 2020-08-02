//
//  SearchResultViewController.swift
//  Pointters
//
//  Created by dreams on 10/1/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation
import STPopup

class SearchResultViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnMap: UIButton!
    @IBOutlet weak var liveOfferView: UIView!
    
    var exploreServicesList = [[String:Any]]()
    var exploreJobList = [[String: Any]]()
    var exploreUserList = [[String: Any]]()
    
    var currentPage = 1
    var totalPages = 0
    
    var categoryId = ""
    var filter = ""
    
    var searchTitle = ""
    var query = ""
    var type = ""
    
    var isPublic = true
    
    var selectedPinView: CustomPinAnnotationView!
    
    var distanceLimit: Double = 50.0
    
    var location = Location.init()
    
    var showMapView = false
    var isFromHomePage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.liveOfferView.isHidden = (self.type == "requests") ? true : false
        self.mapView.isHidden = !self.showMapView
        self.mapView.delegate = self
        self.callElasticSearch()
        if #available(iOS 13.0, *) {
            self.searchBar.searchTextField.clearButtonMode = .never
        } else {
            self.searchBar.textField?.clearButtonMode = .never
        }
        self.searchBar.text = self.searchTitle
        self.searchBar.isUserInteractionEnabled = true
        self.tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    func callElasticSearch() {
        PointtersHelper.sharedInstance.startLoader(view: view)
        var params = [String: Any]()
        params["category"] = self.categoryId
//        params["q"] = self.query
        params["type"] = self.type
//        params["filter"] = self.filter
//        var locationParam = self.location.dict()
//        locationParam["geoJson"] = ""
//        params["location"] = locationParam
        ApiHandler.callSearchElastic(params: params, withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            self.exploreServicesList.removeAll()
            self.exploreJobList.removeAll()
            self.exploreUserList.removeAll()
            if result == true {
                if response.value is Array<Any> {
                    let responseDict = response.value as! [[String:Any]]
                    if statusCode == 200 {
                        for item in responseDict {
                            if self.type == "services"{
                                let service = item["service"] as! [String: Any]
                                self.exploreServicesList.append(service)
                            }else if self.type == "requests"{
                                let request = item["request"] as! [String: Any]
                                self.exploreJobList.append(request)
                            }else if self.type == "users" {
                                let user = item["user"] as! [String: Any]
                                self.exploreUserList.append(user)
                            }
                        }
                    } else {
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "no search result.", buttonTitles: ["OK"], viewController: self, completion: nil)
                    }
                }else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "no search result.", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
            self.tableView.reloadData()
            self.addMapPins()
        })
    }
    
    func addMapPins() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        var pins = [MKAnnotation]()
        var pointIndex = 1
        if self.type == "services" {
            for service in self.exploreServicesList {
                let locationObj = service["location"] as! [[String: Any]]
                if locationObj.count > 0 {
                    let location = Location.init(dict: locationObj[0])
                    let point: CustomPointAnnotation = CustomPointAnnotation()
                    point.coordinate = CLLocationCoordinate2DMake(location.geoJson.coordinates[1], location.geoJson.coordinates[0])
                    point.number = pointIndex
                    point.type = "services"
                    pointIndex += 1
                    pins.append(point)
                }
            }
        } else if self.type == "requests"{
            for job in self.exploreJobList {
                let locationObj = job["location"] as! [String: Any]
                let location = Location.init(dict: locationObj)
                let point: CustomPointAnnotation = CustomPointAnnotation()
                point.coordinate = CLLocationCoordinate2DMake(location.geoJson.coordinates[1], location.geoJson.coordinates[0])
                point.number = pointIndex
                point.type = "requests"
                pointIndex += 1
                pins.append(point)
            }
        }else if self.type == "users" {
            for user in self.exploreUserList {
                let locationObj = user["location"] as! [String: Any]
                let location = Location.init(dict: locationObj)
                let point: CustomPointAnnotation = CustomPointAnnotation()
                point.coordinate = CLLocationCoordinate2DMake(location.geoJson.coordinates[1], location.geoJson.coordinates[0])
                point.number = pointIndex
                point.type = "users"
                pointIndex += 1
                pins.append(point)
            }
        }
        
        self.mapView.addAnnotations(pins)
    }
    
    func removeSelectedPinImage(index: Int) {
        if (self.selectedPinView != nil) {
            self.selectedPinView.image = UIImage(named:"icon-pin-normal")
        }
        let pins = self.mapView.selectedAnnotations
        for pin in pins {
            self.mapView.deselectAnnotation(pin, animated: true)
        }
    }
    
    //MARK: IBActions
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickLiveOffer(_ sender: Any) {
        
        if let userDict = UserCache.sharedInstance.getUserCredentials() {
            if let val = userDict[kUserCredentials.kLoginType] as? String {
                if val == "E" || val == "F" {
                    if let registered = userDict[kUserCredentials.kCompletedRegistration] as? Bool, registered == true {
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let containerNavVC = storyBoard.instantiateViewController(withIdentifier: "ContainerTabsNavVC") as! UINavigationController
                        let containerVC = storyBoard.instantiateViewController(withIdentifier: "ContainerTabVC") as! ContainerTabViewController
                        containerNavVC.viewControllers = [containerVC]
                        containerVC.selectedExplorerTabIndex = 1
                        let window: UIWindow = PointtersHelper.sharedInstance.mainWindow()
                        window.rootViewController = containerNavVC
                        window.makeKeyAndVisible()
                    } else {
                        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                        loginVC.targetTapIndex = 1
                        self.navigationController?.pushViewController(loginVC, animated: false)
                    }
                }
            }
        } else {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            loginVC.targetTapIndex = 1
            self.navigationController?.pushViewController(loginVC, animated: false)
        }
    }
    
    @IBAction func onClickFilter(_ sender: Any) {
        let alert = UIAlertController(title:nil, message: "Please select a service type.", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "All", style: .default , handler:{ (UIAlertAction)in
            self.filter = ""
            self.callElasticSearch()
        }))
        
        alert.addAction(UIAlertAction(title: "Online", style: .default , handler:{ (UIAlertAction)in
            self.filter = "online"
            self.callElasticSearch()
        }))
        
        alert.addAction(UIAlertAction(title: "Local", style: .default , handler:{ (UIAlertAction)in
            self.filter = "local"
            self.callElasticSearch()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction)in

        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    @IBAction func onClickMapView(_ sender: Any) {
        self.showMapView = !self.showMapView
        self.mapView.isHidden = !self.showMapView
        self.tableView.isHidden = self.showMapView
        self.btnMap.setTitle((!self.showMapView) ? " Map View" : " List View" , for: .normal)
    }
    
    // move to send custom offer page
    @objc func btnMakeOfferTapped(sender: UIButton) {
        let dictJob = self.exploreJobList[sender.tag]
        let jobId = dictJob["id"] as! String
        let jobOwner = dictJob["user"] as! [String:Any]
        let ownerId = jobOwner["id"] as! String
        
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        let sendOfferVC = storyboard.instantiateViewController(withIdentifier: "SendOfferVC") as! SendOfferViewController
        sendOfferVC.isJobOffer = true
        sendOfferVC.requestId = jobId
        sendOfferVC.buyerId = ownerId
        sendOfferVC.customOfferDelegate = self
        navigationController?.pushViewController(sendOfferVC, animated:true)
    }
    
    // move to edit offer page
    @objc func btnEditOfferTapped(sender: UIButton) {
        let item : [String:Any] = self.exploreJobList[sender.tag]
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        let requestDetailVC = storyboard.instantiateViewController(withIdentifier: "RequestDetailVC") as! RequestDetailViewController
        requestDetailVC.requestDelegate = self
        requestDetailVC.pageFlag = 2
        requestDetailVC.requestId = item["id"] as! String
        requestDetailVC.rowIndexForUpdate = sender.tag
        navigationController?.pushViewController(requestDetailVC, animated: true)
    }
    
    func gotoRequestView(requestId: String) {
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        let requestDetailVC = storyboard.instantiateViewController(withIdentifier: "RequestDetailVC") as! RequestDetailViewController
        requestDetailVC.pageFlag = 0
        requestDetailVC.requestId = requestId
        navigationController?.pushViewController(requestDetailVC, animated: true)
    }
    
    // Move to profile page
    @objc func btnNameTapped(sender: UIButton) {
        let dictService = self.exploreServicesList[sender.tag]
        let itemSeller : [String:Any] = dictService["seller"] as! [String:Any]
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
    
    //MARK: GENERATE TABLE VIEW CELLS
    
    func serviceCell(indexPath: IndexPath, tableView: UITableView) -> ExploreServiceCell {
        let cell : ExploreServiceCell = tableView.dequeueReusableCell(withIdentifier: "exploreServiceCell", for: indexPath) as! ExploreServiceCell
        if exploreServicesList.count > 0{
            let item : [String:Any] = self.exploreServicesList[indexPath.row]
            if item.keys.contains("media"){
                let itemMedia = item["media"] as! [[String : Any]]
                if itemMedia.count > 0 {
                    let media = itemMedia[0]
                    if media["fileName"] as! String != "" && media["mediaType"] as! String == "image"{
                        let fileName : String = media["fileName"] as! String
                        cell.ivService.sd_imageTransition = .fade
                        cell.ivService.sd_setImage(with: URL(string: fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                    } else if media["fileName"] as! String != "" && media["mediaType"] as! String == "video" {
                        if let thumbnailImage = generateThumbnailForVideoAtURL(filePathLocal: media["fileName"] as! NSString) {
                            cell.ivService.image = thumbnailImage
                        }
                    } else {
                        cell.ivService.image = UIImage(named:"photo_placeholder")
                    }
                }
            }
            cell.lblDescription.text = item["tagline"] as? String
            cell.lblDescription.sizeToFit()
            
            if let itemPrices = item["prices"] as? [[String:Any]] {
                let itemP = itemPrices[0]
                if let price = itemP["price"] as? NSNumber, let time = itemP["time"] as? Int, let currentSymbol = itemP["currencySymbol"] as? String, var timeOfUnit = itemP["timeUnitOfMeasure"] as? String{
                    cell.lblPrice.text = currentSymbol + String(format: "%.2f", price.floatValue)
                    if timeOfUnit == "hour" {
                        timeOfUnit = "hr"
                    }
                    cell.lblTimeUnit.text = "Per \(time) \(timeOfUnit)"
                }
            }
            
            let itemLocations = item["location"] as! [[String:Any]]
            if itemLocations.count > 0 {
                let itemLocation : [String:Any] = itemLocations[0]
                let geoJson = itemLocation["geoJson"] as! [String:Any]
                let coordinates = geoJson["coordinates"] as! [Double]
                let serviceCoord = CLLocation(latitude: coordinates[1],  longitude:coordinates[0])
                let userCoord = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
                let distanceInMeter = userCoord.distance(from: serviceCoord)
                let distanceInKilo = Double(round(10*(distanceInMeter / 1000)/10))
                let fulfillmentMethod = item["fulfillmentMethod"] as! [String:Any]
                let online = fulfillmentMethod["online"] as! Bool
                if online  == true{
                    cell.lblLocation.text = "Online service"
                } else {
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
            if let _ = item["pointValue"] {
                cell.lblPoitValue.text = "\(item["pointValue"] as! Int)"
            }else {
                cell.lblPoitValue.text = "0"
            }
            
            if item["numOrders"] is Int {
                cell.lblNumOrders.text = "\(item["numOrders"] as! Int)"
            } else {
                cell.lblNumOrders.text = "0"
            }
            if let _ = item["avgRating"] {
                cell.lblAvgRating.text = "\(item["avgRating"] as! NSNumber)%"
            }else {
                cell.lblAvgRating.text = "0%"
            }
        }
        return cell
    }
    
    func requestCell(indexPath: IndexPath, tableView: UITableView) -> ExploreJobCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exploreJobCell") as! ExploreJobCell
        let item : [String:Any] = self.exploreJobList[indexPath.row]
        if item.keys.contains("media") {
            let itemMedias : [[String:Any]] = item["media"] as! [[String : Any]]
            if itemMedias.count > 0 {
                let itemMedia = itemMedias[0]
                if itemMedia["fileName"] as! String != "" && itemMedia["mediaType"] as! String == "image"{
                    let fileName : String = itemMedia["fileName"] as! String
                    cell.ivJob.sd_imageTransition = .fade
                    cell.ivJob.sd_setImage(with: URL(string: fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                }else{
                    cell.ivJob.image = UIImage(named:"photo_placeholder")
                }
            }
        }
        let createdTimeString = item["createdAt"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        let createdTime = dateFormatter.date(from:createdTimeString)!
        let calendar = Calendar.current
        if calendar.isDateInToday(createdTime){
            cell.lblPostDate.text = "Today \(calendar.component(.hour, from: createdTime)):\(calendar.component(.minute, from: createdTime))"
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
                cell.lblPriceRange.text = "$\(item["minPrice"] as! NSNumber) - $\(item["maxPrice"] as! NSNumber)"
            }else {
                cell.lblPriceRange.text = "$0 - $0"
            }
            
        } else {
            if item.keys.contains("maxPrice") {
                cell.lblPriceRange.text = "$0 - $\(item["maxPrice"] as! NSNumber)"
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
        cell.btnEditOffer.addTarget(self, action: #selector(btnEditOfferTapped(sender:)), for: .touchUpInside)
        cell.btnMakeOffer.addTarget(self, action: #selector(btnMakeOfferTapped(sender:)), for: .touchUpInside)
        return cell
    }
    
    func userCell(indexPath: IndexPath, tableView: UITableView) -> FollowCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followCell") as! FollowCell
        
        let user = self.exploreUserList[indexPath.row]
        
        cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height/2
        cell.imgUser.layer.masksToBounds = true
        
        let strPic = (user["profilePic"] != nil) ? user["profilePic"] as! String: ""
        
        if strPic != "" {
            cell.imgUser.sd_imageTransition = .fade
            cell.imgUser.sd_setImage(with: URL(string: strPic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"user_avatar_placeholder"))
        } else {
            cell.imgUser.image = UIImage(named:"user_avatar_placeholder")
        }
        
        let strFirst = (user["firstName"] != nil) ? user["firstName"] as! String : ""
        let strLast = (user["lastName"] != nil) ? user["lastName"] as! String : ""
        cell.lblName.text = strFirst + " " + strLast
        
        if user["location"] != nil {
            let location = Location.init(dict: user["location"] as! [String: Any])
            cell.lblDesc.text = "\(location.city), \(location.country)"
        }else {
            cell.lblDesc.text = "Unknown location"
        }
        cell.btnFollow.isHidden = true
        return cell
    }
    
    func onSelectMapPin(pin: CustomPointAnnotation) -> Bool{
        let point = CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude)
        var mergedPins = [[String: Any]]()
        if self.type == "services" {
            for service in self.exploreServicesList {
                let locationObj = service["location"] as! [[String: Any]]
                let s_location = Location.init(dict: locationObj[0])
                let otherPoint = CLLocation(latitude: s_location.geoJson.coordinates[1], longitude: s_location.geoJson.coordinates[0])
                if point.distance(from: otherPoint) < self.distanceLimit {
                    mergedPins.append(service)
                }
            }
        }else if self.type == "requests" {
            for job in self.exploreJobList {
                let locationObj = job["location"] as! [String: Any]
                let s_location = Location.init(dict: locationObj)
                let otherPoint = CLLocation(latitude: s_location.geoJson.coordinates[1], longitude: s_location.geoJson.coordinates[0])
                if point.distance(from: otherPoint) < self.distanceLimit {
                    mergedPins.append(job)
                }
            }
        }else {
            for user in self.exploreUserList {
                let locationObj = user["location"] as! [String: Any]
                let s_location = Location.init(dict: locationObj)
                let otherPoint = CLLocation(latitude: s_location.geoJson.coordinates[1], longitude: s_location.geoJson.coordinates[0])
                if point.distance(from: otherPoint) < self.distanceLimit {
                    mergedPins.append(user)
                }
            }
        }
        openDetailView(resultArray: mergedPins, index: pin.number)
        return (mergedPins.count > 1) ? false: true
    }
    
    func openDetailView(resultArray: [[String: Any]], index: Int) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "searchPopupViewController") as! SearchPopupViewController
        vc.resultArr = resultArray
        vc.type = self.type
        vc.parentView = self
        vc.index = index
        vc.contentSizeInPopup = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        let popupController = STPopupController(rootViewController: vc)
        popupController.style = .bottomSheet
        popupController.navigationBarHidden = true
        popupController.containerView.backgroundColor = UIColor.clear
        popupController.present(in: self)
       
    }

}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.type == "services" {
            return 130
        }else if self.type == "requests" {
            return 125
        }else {
            return 62
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if (indexPath.row == exploreServicesList.count - 1) && (self.currentPage - 1 < self.totalPages) {
//            callExploreServicesAPI(inited: false, currentPage: self.currentPage)
//        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.type == "services" {
            return exploreServicesList.count
        }else if self.type == "requests" {
            return exploreJobList.count
        }else {
            return exploreUserList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.type == "services" {
            return self.serviceCell(indexPath: indexPath, tableView: tableView)
        }else if self.type == "requests" {
            return self.requestCell(indexPath: indexPath, tableView: tableView)
        }else if self.type == "users" {
            return self.userCell(indexPath: indexPath, tableView: tableView)
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchBar.resignFirstResponder()
        if self.type == "services"{
            let item : [String:Any] = self.exploreServicesList[indexPath.row]
            let storyboard = UIStoryboard(name: "Explore", bundle: nil)
            let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
            serviceDetailVC.serviceId = item["id"] as! String
            navigationController?.pushViewController(serviceDetailVC, animated: true)
        } else if self.type == "requests" {
            let item : [String:Any] = self.exploreJobList[indexPath.row]
            self.gotoRequestView(requestId: item["id"] as! String)
        } else if self.type == "users" {
            let storyboard = UIStoryboard.init(name: "Account", bundle: nil)
            let strOtherId = self.exploreUserList[indexPath.row]["id"] as! String
            if strOtherId == UserCache.sharedInstance.getAccountData().id {
                UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
            } else {
                UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
            }
            let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
            self.navigationController?.pushViewController(userProfileVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchResultViewController : UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
}

//MARK:- MAP VIEW

extension SearchResultViewController: MKMapViewDelegate {
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
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: CustomPinAnnotationView.self) {
            view.image = UIImage(named:"icon-pin-normal")
        }
    }
}

extension SearchResultViewController: SendCustomOfferDelegate {
    func selectSendCustomOffer(selId: String, selPrice: [String : Any], linkedService: [String : Any], link: Bool) {
        
    }
    
    func returnFromCustomOffer(reload: Bool) {
        self.callElasticSearch()
    }
}

extension SearchResultViewController: RequestDetailVCDelegate {
    func submittedRequest(request: RequestDetail) {
        self.callElasticSearch()
    }
    
    func onUpdateRequest(request: RequestDetail, index: Int) {
        self.callElasticSearch()
    }
    
    func onDeleteRequest(index: Int) {
        self.callElasticSearch()
    }
}
