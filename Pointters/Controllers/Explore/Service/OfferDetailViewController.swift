//
//  OfferDetailViewController.swift
//  Pointters
//
//  Created by super on 3/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class OfferDetailViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var btnAccept: UIButton!
    
    var offerId = ""
    var offerFlag = 1
    var offerDetailDic = [String:Any]()
    var loginUserId = ""
    
    var exploreVC: ExploreServiceViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginUserId = UserCache.sharedInstance.getAccountData().id
        initUI()
    }
    
    func initUI(){
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 80.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        if (offerFlag == 1){
            callGetOfferDetailAPI(offerId:offerId)
        } else {
            callGetRequestOfferDetailAPI(offerId:offerId)
        }
    }
    
    func disableAcceptButton() {
        self.btnAccept.setTitle("Closed", for: .normal)
        self.btnAccept.isUserInteractionEnabled = false
        if (self.exploreVC != nil) {
            self.exploreVC.selectedRequest = nil
        }
    }
    
    //    *******************************************************//
    //                  MARK: - IBAction Method                  //v
    //    *******************************************************//
    
    @IBAction func btnAcceptTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        let checkoutVC = storyboard.instantiateViewController(withIdentifier: "CheckoutVC") as! CheckoutViewController
        if let service = self.offerDetailDic["service"] as? [String:Any] {
            var services = service
            if let fulfillmentMethod = self.offerDetailDic["fulfillmentMethod"] as? [String:Any] {
                services["fulfillmentMethod"] = fulfillmentMethod
            }
            checkoutVC.isCustomOffer = true
            checkoutVC.arrAmount = [1]
            checkoutVC.serviceInfo = services
            var servicePrices: [String:Any] = [:]
            if service["price"] != nil {
                servicePrices = (service["price"] as? [String:Any])!
            } else if service["prices"] != nil {
                let prices: [[String:Any]] = service["prices"] as! [[String : Any]]
                servicePrices = prices[0]
            }
            if let offerPrice = self.offerDetailDic["price"] as? Float {
                servicePrices["customPrice"] = offerPrice
            }
            
            checkoutVC.servicePrices = [servicePrices]
            if let media = service["media"] as? [String:Any] {
                checkoutVC.serviceBgMedia = [media]
            }
            
            if let serviceId = self.offerDetailDic["serviceId"] {
                checkoutVC.serviceId = serviceId as! String
            }
            if let seller = self.offerDetailDic["seller"] {
                checkoutVC.serviceSeller = seller as! [String:Any]
            }
        } else {
            let service = self.offerDetailDic
            checkoutVC.isCustomOffer = true
            checkoutVC.arrAmount = [1]
            checkoutVC.serviceInfo = service
            var servicePrices: [String:Any] = [:]
            if service["prices"] != nil {
                let prices: [[String:Any]] = service["prices"] as! [[String : Any]]
                servicePrices = prices[0]
            }
            if let offerPrice = self.offerDetailDic["price"] as? Float {
                servicePrices["customPrice"] = offerPrice
            }
            
            checkoutVC.servicePrices = [servicePrices]
            if let media = service["media"] as? [String:Any] {
                checkoutVC.serviceBgMedia = [media]
            }
            
            if let serviceId = self.offerDetailDic["serviceId"] {
                checkoutVC.serviceId = serviceId as! String
            }
            if let seller = self.offerDetailDic["seller"] {
                checkoutVC.serviceSeller = seller as! [String:Any]
            }
        }
        if let customOfferId = self.offerDetailDic["_id"] as? String {
            checkoutVC.customOfferId = customOfferId
        }
        if let requestOfferId = self.offerDetailDic["offerId"] as? String {
            checkoutVC.requestOfferId = requestOfferId
        }
        if let offerDescription = self.offerDetailDic["description"] as? String  {
            checkoutVC.customDescription = offerDescription
        }
        if let customDuration = self.offerDetailDic["workDuration"] as? NSNumber {
            checkoutVC.customDuration = customDuration.intValue
        }
        if let customDurationUnit = self.offerDetailDic["workDurationUom"] as? String {
            checkoutVC.customDurationUnit = customDurationUnit
        }
        checkoutVC.offerDetailVC = self
        navigationController?.pushViewController(checkoutVC, animated: true)
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // move to profile page
    @objc func btnNameTapped(sender: UIButton) {
        if let strOtherId = self.offerDetailDic["sellerId"] as? String{
            if strOtherId == self.loginUserId {
                UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
            } else {
                UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
            }
            let storyboard = UIStoryboard(name: "Account", bundle: nil)
            let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
            navigationController?.pushViewController(userProfileVC, animated:true)
        }
    }
    
    @objc func btnChatTapped(sender: UIButton) {
        var userId = ""
        if let sellerId = self.offerDetailDic["sellerId"] as? String {
            userId = sellerId
        }
        if let seller = self.offerDetailDic["seller"] as? [String:Any]{
            var sellerName = ""
            if let firstName = seller["firstName"] as? String {
                sellerName = firstName
            }
            if let lastName = seller["lastName"] as? String {
                sellerName = sellerName + " " + lastName
            }
            if let id = seller["id"] as? String {
                userId = id
            }
            let userName = sellerName
            var userPic = ""
            if let profilePic = seller["profilePic"] as? String {
                userPic = profilePic
            }
            UserCache.sharedInstance.setChatCredentials(id: "", userId: userId, name: userName, pic: userPic, verified: true)
            let storyboard = UIStoryboard(name: "Chats", bundle: nil)
            let privateChatVC = storyboard.instantiateViewController(withIdentifier: "PrivateChatVC") as! PrivateChatViewController
            privateChatVC.otherUserId = userId
            privateChatVC.otherUserPic = userPic
            privateChatVC.otherUsername = userName
            navigationController?.pushViewController(privateChatVC, animated:true)
        }
        
    }
    
    @objc func btnCallTapped(sender: UIButton) {
        PointtersHelper.sharedInstance.callByPhone(phone: "123456789", ctrl: self)
    }
    
    @objc func btnGetDirection(sender: UIButton) {
        if let itemLocation = self.offerDetailDic["location"] as? [String:Any] {
            let offerLocation = Location.init(dict: itemLocation)
            let getDirectionVC = storyboard?.instantiateViewController(withIdentifier: "GetDirectionVC") as! GetDirectionViewController
            getDirectionVC.serviceLocation = offerLocation
            navigationController?.pushViewController(getDirectionVC, animated: true)
        }
    }
    
    //*******************************************************//
    //                 MARK: - Call API Method               //
    //*******************************************************//
    
    func callGetOfferDetailAPI(offerId: String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetOfferDetail(offerId: offerId, withCompletionHandler:{ (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.offerDetailDic = responseDict["offer"] as! [String : Any]
                    if let offerExpiresIn = self.offerDetailDic["expiresIn"] as? Int {
                        if offerExpiresIn <= 0 {
                            self.btnAccept.setTitle("Expired", for: .normal)
                            self.btnAccept.isUserInteractionEnabled = false
                        } else {
                            self.btnAccept.setTitle("Accept", for: .normal)
                            self.btnAccept.isUserInteractionEnabled = true
                        }
                    }
                    if let closed = self.offerDetailDic["closed"] as? Bool {
                        if closed {
                            self.btnAccept.setTitle("Closed", for: .normal)
                            self.btnAccept.isUserInteractionEnabled = false
                        } else {
                            self.btnAccept.setTitle("Accept", for: .normal)
                            self.btnAccept.isUserInteractionEnabled = true
                        }
                    }
                    if let strOtherId = self.offerDetailDic["sellerId"] as? String{
                        if strOtherId == self.loginUserId {
                            self.btnAccept.isEnabled = false
                        }
                    }
                    self.mainTableView.reloadData()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: { (type) in
                    self.navigationController?.popViewController(animated: true)
                })
            }
        })
    }
    
    func callGetRequestOfferDetailAPI(offerId: String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetRequestOfferDetail(offerId: offerId, withCompletionHandler:{ (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.offerDetailDic = responseDict
                    if let offerExpiresIn = self.offerDetailDic["expiresIn"] as? Int {
                        if offerExpiresIn <= 0 {
                            self.btnAccept.setTitle("Expired", for: .normal)
                            self.btnAccept.isUserInteractionEnabled = false
                        } else {
                            self.btnAccept.setTitle("Accept", for: .normal)
                            self.btnAccept.isUserInteractionEnabled = true
                        }
                    }
                    if let closed = self.offerDetailDic["closed"] as? Bool {
                        if closed {
                            self.btnAccept.setTitle("Closed", for: .normal)
                            self.btnAccept.isUserInteractionEnabled = false
                        } else {
                            self.btnAccept.setTitle("Accept", for: .normal)
                            self.btnAccept.isUserInteractionEnabled = true
                        }
                    }
                    self.mainTableView.reloadData()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: { (type) in
                    self.navigationController?.popViewController(animated: true)
                })
            }
        })
    }
    
}

extension OfferDetailViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 28.0
        case 1:
            if self.offerDetailDic.keys.contains("service") {
                return 40.0
            }else{
                return 0.0
            }
        case 2:
            return 40.0
        case 5:
            return 40.0
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 5 {
            return 10.0
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 75.0
        case 1:
            if self.offerDetailDic.keys.contains("service") {
                return 100.0
            }else{
                return 0.0
            }
        case 2: return 90.0
        case 3: return 50.0
        case 4: return 50.0
        case 5: return 280.0
        default: return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        if section != 0 && section != 3 && section != 4{
            let headerLabel = UILabel(frame: CGRect(x: 15, y: 20, width: tableView.bounds.size.width - 30, height: 20))
            headerLabel.font = UIFont(name: "Helvetica", size: 14)
            headerLabel.textColor = UIColor.getCustomGrayTextColor()
            
            if section == 1 {
                headerLabel.text = "LINKED SERVICE"
            } else if section == 2 {
                headerLabel.text = "OFFER DESCRIPTION"
            } else {
                headerLabel.text = "DELIVERY METHOD"
            }
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
        } else if section == 0 {
            let headerLabel = UILabel(frame: CGRect(x: 15, y: 8, width: tableView.bounds.size.width - 30, height: 20))
            headerLabel.font = UIFont(name: "Helvetica", size: 14)
            headerLabel.textColor = UIColor.getCustomGrayTextColor()
            headerLabel.text = "SELLER"
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! ProfileCell
            if let seller = self.offerDetailDic["seller"] as? [String:Any]{
                if let profilePic = seller["profilePic"] as? String {
                    cell.imgUser.sd_imageTransition = .fade
                    cell.imgUser.sd_setImage(with: URL(string: profilePic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                    cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.width/2
                }
                var sellerName = ""
                if let firstName = seller["firstName"] as? String {
                    sellerName = firstName
                }
                if let lastName = seller["lastName"] as? String {
                    sellerName = sellerName + " " + lastName
                }
                cell.lblName.text = sellerName
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(btnNameTapped(sender:)))
                cell.lblName.addGestureRecognizer(tapGesture)
                cell.lblName.isUserInteractionEnabled = true
                let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(btnNameTapped(sender:)))
                cell.imgUser.addGestureRecognizer(tapGesture1)
                cell.imgUser.isUserInteractionEnabled = true
                cell.btnChat.addTarget(self, action: #selector(btnChatTapped(sender:)), for: .touchUpInside)
                cell.btnCall.addTarget(self, action: #selector(btnCallTapped(sender:)), for: .touchUpInside)
            }
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath) as! ProfileCell
            if let service = self.offerDetailDic["service"] as? [String:Any] {
                let offerService = Service.init(dict: service)
                cell.imgService.sd_imageTransition = .fade
                cell.imgService.sd_setImage(with: URL(string: offerService.media.fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                cell.imgService.layer.cornerRadius = 5.0
                cell.lblServiceDesc.text = offerService.tagline
                cell.lblServicePrice.text = offerService.prices.currencySymbol + String(format: "%.2f", offerService.prices.price)
                cell.lblServiceTime.text = "Per \(offerService.prices.time)" + offerService.prices.timeUnitOfMeasure
                
                // missing "seller" vaule, will not set seller name
                if let seller = self.offerDetailDic["seller"] as? [String:Any]{
                    var sellerName = ""
                    if let firstName = seller["firstName"] as? String {
                        sellerName = firstName
                    }
                    if let lastName = seller["lastName"] as? String {
                        sellerName = sellerName + " " + lastName
                    }
                    cell.btnSellerName.setTitle(sellerName, for: .normal)
                    cell.btnSellerName.addTarget(self, action: #selector(btnNameTapped(sender:)), for: .touchUpInside)
                }
            }
            return cell
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "descCell", for: indexPath) as! ProfileCell
            if let offerDesc = self.offerDetailDic["description"] as? String {
                cell.lblDesc.text = offerDesc
            }
            return cell
        }else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as! ServiceDetailCell
            if let offerPrice = self.offerDetailDic["price"] as? Float {
                cell.lblPrice.text = "$" + String(format:"%.2f", offerPrice)
            }
            return cell
        }else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath) as! ServiceDetailCell
            if let duration = self.offerDetailDic["workDuration"] as? Int, let durationUnit = self.offerDetailDic["workDurationUom"] as? String {
                let strTime = String(format:"%d", duration) + " " + durationUnit.capitalizingFirstLetter()
                cell.lblDeliveryTime.text = (duration > 1) ? strTime + "s" : strTime
            }
            
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryCell", for: indexPath) as! ServiceDetailCell
            if let itemLocation = self.offerDetailDic["location"] as? [String:Any] {
                let offerLocation = Location.init(dict: itemLocation)
                if let fulfillmentMethod = self.offerDetailDic["fulfillmentMethod"] as? [String:Any] {
                    let offerFulfillment = FulFillment.init(dict: fulfillmentMethod)
                    if offerFulfillment.local == true {
                        cell.isLocalService = true
                        cell.localRadius = offerFulfillment.localServiceRadius
                    } else {
                        cell.isLocalService = false
                        cell.localRadius = 15
                    }
                    
                    
                    // missing "geolocation" value, will crash if you uncomment this
                     
                    cell.showLocation(lat: offerLocation.geoJson.coordinates[1], lng: offerLocation.geoJson.coordinates[0])
                    
                    var fulfillmentString = ""
                    if offerFulfillment.online{
                        fulfillmentString.append("Servicing Online")
                    }
                    if offerFulfillment.local{
                        if fulfillmentString != ""{
                            fulfillmentString.append(", Servicing Locally Within \(offerFulfillment.localServiceRadius) Miles")
                        } else {
                            fulfillmentString.append("Servicing Locally Within 15 Miles")
                        }
                    }
                    if offerFulfillment.store {
                        if fulfillmentString != ""{
                            fulfillmentString.append(", Service Locally at Store Locations")
                        } else {
                            fulfillmentString.append("Service Locally at Store Locations")
                        }
                    }
                    if offerFulfillment.shipment{
                        if fulfillmentString != ""{
                            fulfillmentString.append(", Shipment")
                        } else {
                            fulfillmentString.append("Shipment")
                        }
                    }
                    cell.lblFulfillment.text = fulfillmentString
                }
                cell.btnGetDirections.addTarget(self, action: #selector(btnGetDirection(sender:)), for: .touchUpInside)
            }

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let strOtherId = self.offerDetailDic["sellerId"] as? String{
                if strOtherId == self.loginUserId {
                    UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
                } else {
                    UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
                }
                let storyboard = UIStoryboard(name: "Account", bundle: nil)
                let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
                navigationController?.pushViewController(userProfileVC, animated:true)
            }
        } else if indexPath.section == 1 {
            if let service = self.offerDetailDic["service"] as? [String:Any] {
                let offerService = Service.init(dict: service)
                let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
                let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
                if let serviceId = self.offerDetailDic["serviceId"] {
                    serviceDetailVC.serviceId = serviceId as! String
                } else {
                    serviceDetailVC.serviceId = offerService.id
                }
                navigationController?.pushViewController(serviceDetailVC, animated:true)
            }
        }
    }
    
}


