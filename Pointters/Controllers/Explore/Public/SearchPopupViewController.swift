//
//  SearchPopupViewController.swift
//  Pointters
//
//  Created by dreams on 11/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class SearchPopupViewController: UIViewController {

    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popupHeightConst: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    
    var index = 0
    var parentView: SearchResultViewController!
    var parentOfferView: ExploreServiceViewController!
    
    var resultArr = [[String: Any]]()
    var type = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.layer.cornerRadius = 5
        self.tableView.layer.masksToBounds = true
        self.btnCancel.layer.cornerRadius = 5
        self.btnCancel.layer.masksToBounds = true
        self.tableView.tableFooterView = UIView()
        if self.resultArr.count > 1 {
            self.popupHeightConst.constant = 400
        }else{
            if self.type == "services" {
                self.popupHeightConst.constant = 135
            }else if self.type == "requests" {
                self.popupHeightConst.constant = 130
            }else if self.type == "users" {
                self.popupHeightConst.constant = 70
            }else if self.type == "liveOffer" {
                self.popupHeightConst.constant = 75
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backGroundViewTap(sender:)))
        self.backgroundView.isUserInteractionEnabled = true
        self.backgroundView.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    @IBAction func onClickCancel(_ sender: Any) {
        if self.type == "liveOffer" {
            self.parentOfferView.removeSelectedPinImage()
        }else {
            self.parentView.removeSelectedPinImage(index: self.index)
        }
        
        self.popupController?.dismiss()
    }
    
    @objc func backGroundViewTap(sender: UITapGestureRecognizer) {
        if self.type == "liveOffer" {
            self.parentOfferView.removeSelectedPinImage()
        }else {
            self.parentView.removeSelectedPinImage(index: self.index)
        }
        self.popupController?.dismiss()
    }
    
    // move to send custom offer page
    @objc func btnMakeOfferTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        let dictJob = self.resultArr[sender.tag]
        let jobId = dictJob["id"] as! String
        let jobOwner = dictJob["user"] as! [String:Any]
        let ownerId = jobOwner["id"] as! String
        
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        let sendOfferVC = storyboard.instantiateViewController(withIdentifier: "SendOfferVC") as! SendOfferViewController
        sendOfferVC.isJobOffer = true
        sendOfferVC.requestId = jobId
        sendOfferVC.buyerId = ownerId
        sendOfferVC.customOfferDelegate = parentView
        self.parentView.navigationController?.pushViewController(sendOfferVC, animated:true)
    }
    
    // move to edit offer page
    @objc func btnEditOfferTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        let item : [String:Any] = self.resultArr[sender.tag]
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        let requestDetailVC = storyboard.instantiateViewController(withIdentifier: "RequestDetailVC") as! RequestDetailViewController
        requestDetailVC.requestDelegate = parentView
        requestDetailVC.pageFlag = 2
        requestDetailVC.requestId = item["id"] as! String
        requestDetailVC.rowIndexForUpdate = sender.tag
        self.parentView.navigationController?.pushViewController(requestDetailVC, animated: true)
    }
    
    func gotoRequestView(requestId: String) {
        self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        let requestDetailVC = storyboard.instantiateViewController(withIdentifier: "RequestDetailVC") as! RequestDetailViewController
        requestDetailVC.pageFlag = 0
        requestDetailVC.requestId = requestId
        self.parentView!.navigationController?.pushViewController(requestDetailVC, animated: true)
    }
    
    // Move to profile page
    @objc func btnNameTapped(sender: UIButton) {
        let dictService = self.resultArr[sender.tag]
        let itemSeller : [String:Any] = dictService["seller"] as! [String:Any]
        print(itemSeller)
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
        
        let item : [String:Any] = self.resultArr[indexPath.row]
        if item.keys.contains("media"){
            let itemMedia = item["media"] as! [[String : Any]]
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
        
        return cell
    }
    
    func requestCell(indexPath: IndexPath, tableView: UITableView) -> ExploreJobCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exploreJobCell") as! ExploreJobCell
        let item : [String:Any] = self.resultArr[indexPath.row]
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
        
        let user = self.resultArr[indexPath.row]
        
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
    
    func offerCell(indexPath: IndexPath, tableView: UITableView) -> LiveOfferCell {
        let cell : LiveOfferCell = tableView.dequeueReusableCell(withIdentifier: "liveOfferCell", for: indexPath) as! LiveOfferCell
        var item = [String: Any]()
        if indexPath.section == 0 {
            item = self.resultArr[indexPath.row]
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
        return cell
    }
}

extension SearchPopupViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.type == "services" {
            return 130
        }else if self.type == "requests" {
            return 125
        }else if self.type == "users" {
            return 62
        } else {
            return 70
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
        return resultArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.type == "services" {
            return self.serviceCell(indexPath: indexPath, tableView: tableView)
        }else if self.type == "requests" {
            return self.requestCell(indexPath: indexPath, tableView: tableView)
        }else if self.type == "users" {
            return self.userCell(indexPath: indexPath, tableView: tableView)
        }else if self.type == "liveOffer" {
            return self.offerCell(indexPath: indexPath, tableView: tableView)
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        if self.type == "services"{
            let item : [String:Any] = self.resultArr[indexPath.row]
            let storyboard = UIStoryboard(name: "Explore", bundle: nil)
            let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
            serviceDetailVC.serviceId = item["id"] as! String
            self.parentView.navigationController!.pushViewController(serviceDetailVC, animated: true)
        } else if self.type == "requests" {
            let item : [String:Any] = self.resultArr[indexPath.row]
            self.gotoRequestView(requestId: item["id"] as! String)
        } else if self.type == "users" {
            let storyboard = UIStoryboard.init(name: "Account", bundle: nil)
            let strOtherId = self.resultArr[indexPath.row]["id"] as! String
            if strOtherId == UserCache.sharedInstance.getAccountData().id {
                UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
            } else {
                UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
            }
            let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
            self.parentView.navigationController!.pushViewController(userProfileVC, animated: true)
        } else if self.type == "liveOffer" {
            let offerId = self.resultArr[indexPath.row]["offerId"] as! String
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let customOfferDetailsVC = storyboard.instantiateViewController(withIdentifier: "OfferDetailVC") as! OfferDetailViewController
            customOfferDetailsVC.offerId = offerId
            customOfferDetailsVC.offerFlag = 0
            self.parentOfferView.navigationController?.pushViewController(customOfferDetailsVC, animated:true)
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

