//
//  SendRequestOfferViewController.swift
//  Pointters
//
//  Created by Billiard ball on 22.06.2020.
//  Copyright © 2020 Kenji. All rights reserved.
//

import UIKit

protocol SendRequestCustomOfferDelegate {
    func selectSendCustomOffer(selId:String, selPrice:[String:Any], linkedService: [String:Any], link:Bool)
    func returnFromCustomOffer(reload: Bool)
}

class SendRequestOfferViewController: UIViewController {
    
    @IBOutlet weak var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonSend: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var bottomView: UIView!
    
    var customOfferDelegate: SendCustomOfferDelegate?
    var isJobOffer = false
    
    var requestId = ""
    var loginUserId = ""
    var deliveryStatus = 0
    var buyerId = ""
    var offerId = ""

    var serviceId = ""
    var isLinkService = false
    var linkCellCount = 1
    var linkService = Service.init()
    
    var numberFormatter = NumberFormatter()
    
    var customPrice: Float = 0.00
    var currencyCode = ""
    var currencySymbol = ""
    var radius = 0
    var offerDescription = ""
    var workduration = 1
    var workDurationUom = "hour"

    var addressDic: [String : Any] = [:]
    var measurementDic: [String : Any] = [:]
    
    var location: [String : Any] = [:]
    var media: [[String : Any]] = []
    
    var showPicker = false
    var price = Price.init()
    
    var categoryId = ""
    var numStores: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginUserId = UserCache.sharedInstance.getAccountData().id
        initUI()
        PointtersHelper.sharedInstance.sendAnalyticsToFirebase(event: kFirebaseEvents.screenCustomOfferDetail)
        if offerId != "" {
            callGetOfferDetailAPI(offerId: offerId)
            if isJobOffer {
                callGetRequestOfferDetailAPI(offerId: offerId)
            } else {
                
            }
        }
        
        self.numberFormatter.locale = Locale(identifier: "en_US")
        self.currencyCode = numberFormatter.locale.currencyCode!
        self.currencySymbol = numberFormatter.locale.currencySymbol!
        numberFormatter.numberStyle = .currency
        self.numberFormatter.currencyCode = numberFormatter.locale.currencyCode!
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        tableView.tableFooterView = UIView()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callSellerEligabilityAPI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.radius == 0 {
            deliveryStatus = 0
            tableView.reloadSections(IndexSet(integer: 4), with: .none)
        }
        validateMandatoryFields()
        
    }
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI(){
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        
        if offerId == "" {
            buttonDelete.isHidden = true
        } else {
            buttonDelete.isHidden = false
        }
    }
    
    func callGetRequestOfferDetailAPI(offerId: String) {

        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetRequestOfferDetail(offerId: offerId, withCompletionHandler:{ (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    let offerDetailDict = responseDict
                    
                    if let requestId = offerDetailDict["requestId"] {
                        self.requestId = requestId as! String
                    }
                    
                    if let serviceId = offerDetailDict["serviceId"] {
                        self.serviceId = serviceId as! String
                    }
                    if let serviceDict = offerDetailDict["service"] {
                        self.linkService = Service.init(dict: serviceDict as! [String:Any])
                        self.isLinkService = true
                        self.linkCellCount = 2
                    }
                    
                    if let price = offerDetailDict["price"] {
                        let priceValue = price as! NSNumber
                        self.customPrice = priceValue.floatValue
                    }
                    if let currencyCode = offerDetailDict["currencyCode"] {
                        self.currencyCode = currencyCode as! String
                        self.numberFormatter.currencyCode = self.currencyCode
                    } else {
                        self.currencyCode = self.numberFormatter.locale.currencyCode!
                    }
                    
                    if let workDuration = offerDetailDict["workDuration"] {
                        self.workduration = workDuration as! Int
                        self.price.time = self.workduration
                    }
                    
                    if let workDurationUom = offerDetailDict["workDurationUom"] {
                        self.price.timeUnitOfMeasure = workDurationUom as! String
                    }
                    
                    if let workDurationUom = offerDetailDict["workDurationUom"] {
                        self.workDurationUom = workDurationUom as! String
                    }
                    
                    if let descriptionTxt = offerDetailDict["description"] {
                        self.offerDescription = descriptionTxt as! String
                    }
                    
                    if let fullfillment = offerDetailDict["fulfillmentMethod"] {
                        let fullfillmentMethod = fullfillment as! [String:Any]
                        if let onlineStr = fullfillmentMethod["online"] {
                            if (onlineStr as! Int) == 1 {
                                self.deliveryStatus = 0
                            }
                        }
                        if let shipmentStr = fullfillmentMethod["shipment"] {
                            if (shipmentStr as! Int) == 1 {
                                self.deliveryStatus = 1
                                
                                if let parcel = offerDetailDict["parcel"] {
                                    self.measurementDic = parcel as! [String:Any]
                                }
                                if let address = offerDetailDict["address"] {
                                    self.addressDic = address as! [String:Any]
                                }
                            }
                        }
                        if let localStr = fullfillmentMethod["local"] {
                            if (localStr as! Int) == 1 {
                                self.deliveryStatus = 2
                                
                                if let localServiceRadius = fullfillmentMethod["localServiceRadius"] {
                                    self.radius = localServiceRadius as! Int
                                }
                            }
                        }
                        if let storeStr = fullfillmentMethod["store"] {
                            if (storeStr as! Int) == 1 {
                                self.deliveryStatus = 3
                            }
                        }
                    }
                    
                    if let location = offerDetailDict["location"] {
                        self.location = location as! [String:Any]
                    }
                    
                    if let media = offerDetailDict["media"] {
                        if media is Dictionary<AnyHashable,Any> {
                            self.media = [media as! [String:Any]]
                        } else if media is Array<Any> {
                            self.media = media as! [[String:Any]]
                        }
                    }
                    
                    self.tableView.reloadData()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.stopLoader()
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: { (code) in
                    self.navigationController?.popViewController(animated: true)
                })
            }
        })
    }
    
    func callGetOfferDetailAPI(offerId: String) {
                PointtersHelper.sharedInstance.startLoader(view: view)
                ApiHandler.callGetOfferDetail(offerId: offerId, withCompletionHandler:{ (result,statusCode,response, error) in
                    PointtersHelper.sharedInstance.stopLoader()
                    if result == true {
                        let responseDict = response.value as! [String:Any]
                        if statusCode == 200 {
                            let offerDetailDict = responseDict["offer"] as! [String : Any]
                            
                            if let serviceId = offerDetailDict["serviceId"] {
                                self.serviceId = serviceId as! String
                            }
                            if let serviceDict = offerDetailDict["service"] {
                                self.linkService = Service.init(dict: serviceDict as! [String:Any])
                                self.isLinkService = true
                                self.linkCellCount = 2
                            }
                            
                            if let price = offerDetailDict["price"] {
                                self.customPrice = price as! Float
                            }
                            
                            if let currencyCode = offerDetailDict["currencyCode"] {
                                self.currencyCode = currencyCode as! String
                                self.numberFormatter.currencyCode = self.currencyCode
                            } else {
                                self.currencyCode = self.numberFormatter.locale.currencyCode!
                            }
                            
                            if let currencySymbol = offerDetailDict["currencySymbol"] {
                                self.currencySymbol = currencySymbol as! String
                            }
                            
                            if let workDuration = offerDetailDict["workDuration"] {
                                self.workduration = workDuration as! Int
                                self.price.time = self.workduration
                            }
                            
                            if let workDurationUom = offerDetailDict["workDurationUom"] {
                                self.price.timeUnitOfMeasure = workDurationUom as! String
                            }
                            
                            if let descriptionTxt = offerDetailDict["description"] {
                                self.offerDescription = descriptionTxt as! String
                            }
                            
                            if let fullfillment = offerDetailDict["fulfillmentMethod"] {
                                let fullfillmentMethod = fullfillment as! [String:Any]
                                if let onlineStr = fullfillmentMethod["online"] {
                                    if (onlineStr as! Int) == 1 {
                                        self.deliveryStatus = 0
                                    }
                                }
                                if let shipmentStr = fullfillmentMethod["shipment"] {
                                    if (shipmentStr as! Int) == 1 {
                                        self.deliveryStatus = 1
                                        
                                        if let parcel = offerDetailDict["parcel"] {
                                            self.measurementDic = parcel as! [String:Any]
                                        }
                                        if let address = offerDetailDict["address"] {
                                            self.addressDic = address as! [String:Any]
                                        }
                                    }
                                }
                                if let localStr = fullfillmentMethod["local"] {
                                    if (localStr as! Int) == 1 {
                                        self.deliveryStatus = 2
                                        
                                        if let localServiceRadius = fullfillmentMethod["localServiceRadius"] {
                                            self.radius = localServiceRadius as! Int
                                        }
                                    }
                                }
                                if let storeStr = fullfillmentMethod["store"] {
                                    if (storeStr as! Int) == 1 {
                                        self.deliveryStatus = 3
                                    }
                                }
                            }
                            
                            if let location = offerDetailDict["location"] {
                                self.location = location as! [String:Any]
                            }
                            
                            if let media = offerDetailDict["media"] {
                                if media is Dictionary<AnyHashable,Any> {
                                    self.media = [media as! [String:Any]]
                                } else if media is Array<Any> {
                                    self.media = media as! [[String:Any]]
                                }
                            }
                            
                            self.tableView.reloadData()
                        } else {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                        }
                    }
                    else {
                        PointtersHelper.sharedInstance.stopLoader()
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: { (code) in
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                })
    }
    
    func callSellerEligabilityAPI() {
        ApiHandler.callSellerEligability(withCompletionHandler: { (result,statusCode,response) in           
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    print(responseDict)
                    
                    self.numStores = responseDict["numStores"] as! Int
                    self.tableView.reloadData()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        })
    }
    
    func setDeliveryMethod(index:Int) {
                
        switch index {
        case 0:
            deliveryStatus = index
            break
        case 1:
            deliveryStatus = index
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let shippingDetailVC = storyboard.instantiateViewController(withIdentifier: "ShippingDetailVC") as! ShippingDetailViewController
            shippingDetailVC.shippingDetailDelegate = self
            shippingDetailVC.initWithSavedShippingDetail(addresses: addressDic, measurements: measurementDic)
            navigationController?.pushViewController(shippingDetailVC, animated: true)
            break
        case 2:
            deliveryStatus = index
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let radiusSettingVC = storyboard.instantiateViewController(withIdentifier: "RadiusSettingVC") as! RadiusSettingViewController
            radiusSettingVC.radius = radius
            radiusSettingVC.radiusDelegate = self
            navigationController?.pushViewController(radiusSettingVC, animated: true)
            break
        case 3:
            if self.numStores != 0 {
                deliveryStatus = index
            } else {
                let storyboard = UIStoryboard(name: "Account", bundle: nil)
                let newAddressVC = storyboard.instantiateViewController(withIdentifier: "EnterNewAddressVC") as! EnterNewAddressViewController
                self.navigationController?.pushViewController(newAddressVC, animated: true)
            }
            break
        default:
            break
        }
        tableView.reloadSections(IndexSet(integer: 4), with: .none)
    }
    
    func moveToLinkServicePage() {
        let linkServiceVC = storyboard?.instantiateViewController(withIdentifier: "LinkServicesVC") as! LinkServicesViewController
        linkServiceVC.categoryId = self.categoryId
        linkServiceVC.linkDelegate = self
        navigationController?.pushViewController(linkServiceVC, animated: true)
    }
    
    func validateMandatoryFields() {
        
        var isValid = true
        
        if !isLinkService || customPrice == 0 || offerDescription == "" {
            isValid = false
        }
        
        if price.time < 1 {
            isValid = false
        }
        
        if deliveryStatus == 1 {
            if addressDic.count == 0 || measurementDic.count == 0 {
                isValid = false
            }
        }
        
        if deliveryStatus == 2 {
            if radius == 0 {
                isValid = false
            }
        }
        
        if !isValid {
            buttonSend.isUserInteractionEnabled = false
            buttonSend.alpha = 0.3
        } else {
            buttonSend.isUserInteractionEnabled = true
            buttonSend.alpha = 1.0
        }

    }
    
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnCancelTapped(_ sender: Any) {
        setView(view: bottomView, hidden: true)
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        setView(view: bottomView, hidden: true)

        self.price.time = Int(picker.selectedRow(inComponent: 0)+1)
        self.price.timeUnitOfMeasure = kDeliveryTimeItems[picker.selectedRow(inComponent: 1)].lowercased()
        
        validateMandatoryFields()
        
        let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 3)) as! SendOfferCell
        
        cell.lblTime.isHidden = false
        cell.imgArrow.isHidden = true

        let strTime = String(format:"%d", self.price.time) + " " + self.price.timeUnitOfMeasure.capitalizingFirstLetter()
        cell.lblTime.text = (self.price.time > 1) ? strTime + "s" : strTime
    }
    
    func setView(view: UIView, hidden: Bool) {
        self.view.endEditing(true)
        showPicker = !hidden
        UIView.transition(with: view, duration: 0.5, options: .showHideTransitionViews, animations: {
            view.isHidden = hidden
        })
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        if self.customOfferDelegate != nil {
            self.customOfferDelegate?.returnFromCustomOffer(reload: false)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendClicked(_ sender: Any) {
        
        let descriptionCell: SendOfferCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! SendOfferCell
        offerDescription = descriptionCell.tvOfferDesc.text
        
        let priceCell: SendOfferCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! SendOfferCell
        let priceNumber = numberFormatter.number(from: priceCell.tfOfferPrice.text!)
        customPrice = (priceNumber?.floatValue)!
        guard customPrice >= 2.0 else {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Amount must be at least $1.", buttonTitles: ["OK"], viewController: self, completion: nil)
            return
        }
        if isJobOffer {
            if offerId == "" {
                callSendJobOfferAPI()
            } else {
                callEditJobOfferAPI()
            }
        } else {
            if offerId == "" {
                callSendCustomOfferAPI()
            } else {
                callEditCustomOfferAPI()
            }
        }
    }
    
    @IBAction func btnDeleteClicked(_ sender: Any) {
        PointtersHelper.sharedInstance.showAlertViewWithTitle("Confirm", message: "Are you sure you want to delete this offer?", buttonTitles: ["OK", "Cancel"], viewController: self) { (code) in
            if code == 0 {
                if self.isJobOffer {
                    PointtersHelper.sharedInstance.startLoader(view: self.view)
                    ApiHandler.deleteJobOffer(offerId: self.offerId) { (status, statusCode, response, error) in
                        PointtersHelper.sharedInstance.stopLoader()
                        
                        if status == true {
                            let responseDict = response.value as! [String:Any]
                            if statusCode == 200 {
                                
                                if self.customOfferDelegate != nil {
                                    self.customOfferDelegate?.returnFromCustomOffer(reload: true)
                                }
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                            }
                        } else {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: { (type) in
                                if self.customOfferDelegate != nil {
                                    self.customOfferDelegate?.returnFromCustomOffer(reload: true)
                                }
                                self.navigationController?.popViewController(animated: true)
                            })
                        }
                    }
                } else {
                    PointtersHelper.sharedInstance.startLoader(view: self.view)
                    ApiHandler.deleteOffer(offerId: self.offerId) { (status, statusCode, response, error) in
                        PointtersHelper.sharedInstance.stopLoader()
                        
                        if status == true {
                            let responseDict = response.value as! [String:Any]
                            if statusCode == 200 {
                                
                                if self.customOfferDelegate != nil {
                                    self.customOfferDelegate?.returnFromCustomOffer(reload: true)
                                }
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                            }
                        } else {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: { (type) in
                                if self.customOfferDelegate != nil {
                                    self.customOfferDelegate?.returnFromCustomOffer(reload: true)
                                }
                                self.navigationController?.popViewController(animated: true)
                            })
                        }
                    }
                }
            }
        }
    }
    
    func callSendCustomOfferAPI() {
        
        var fullfillmendMethod: [String : Any] = ["local": false, "online": false, "shipment": false, "store": false]
        var address: [String : Any] = [:]
        var parcel: [String : Any] = [:]
        
        switch deliveryStatus {
        case 0:
            fullfillmendMethod["online"] = true
            break
        case 1:
            fullfillmendMethod["shipment"] = true
            address = ["street1": addressDic["street1"] as Any,
                       "street2": addressDic["street2"] as Any,
                       "city": addressDic["city"] as Any,
                       "state": addressDic["state"] as Any,
                       "zip": addressDic["zip"] as Any,
                       "country": addressDic["country"] as Any,
                       "phone": UserCache.sharedInstance.getAccountData().phone]
            
            parcel = ["length": measurementDic["length"] as Any,
                      "width": measurementDic["width"] as Any,
                      "height": measurementDic["height"] as Any,
                      "weight": measurementDic["weight"] as Any]
            break
        case 2:
            fullfillmendMethod["local"] = true
            fullfillmendMethod["localServiceRadius"] = radius
            fullfillmendMethod ["localServiceRadiusUom"] = "mile"
            break
        case 3:
            fullfillmendMethod["store"] = true
            break
        default:
            break
        }
        
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.sendOffer(sellerId: loginUserId, buyerId: buyerId, serviceId: linkService.id, currencyCode: numberFormatter.locale.currencyCode!, currencySymbol: numberFormatter.locale.currencySymbol!, description: offerDescription, fulfillmentMethod: fullfillmendMethod, price: customPrice, workDuration: Float(self.price.time), workDurationUom: self.price.timeUnitOfMeasure, address: address, parcel: parcel) { (status, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()

            if status == true {
                let responseDict = response.result.value as! [String:Any]
                if statusCode == 200 {
                    let offerDict = responseDict["offer"] as! [String:Any]
                    var price: [String:Any] = [:]
                    
                    price["price"] = offerDict["price"] as! Float
                    price["currencySymbol"] = offerDict["currencySymbol"] as! String
                    price["workDuration"] = offerDict["workDuration"] as! Int
                    price["workDurationUom"] = offerDict["workDurationUom"] as! String
                    
                    let service: [String:Any] = offerDict["service"] as! [String : Any]
                    
                    self.customOfferDelegate?.selectSendCustomOffer(selId: offerDict["_id"] as! String, selPrice: price, linkedService: service, link: self.isLinkService)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                if let data = response.data {
                    let error = String(data: data, encoding: String.Encoding.utf8)
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error!, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
        }
    }
    
    func callEditCustomOfferAPI() {
        
        var fullfillmendMethod: [String : Any] = ["local": false, "online": false, "shipment": false, "store": false]
        var address: [String : Any] = [:]
        var parcel: [String : Any] = [:]
        
        switch deliveryStatus {
        case 0:
            fullfillmendMethod["online"] = true
            break
        case 1:
            fullfillmendMethod["shipment"] = true
            address = ["street1": addressDic["street1"] as Any,
                       "street2": addressDic["street2"] as Any,
                       "city": addressDic["city"] as Any,
                       "state": addressDic["state"] as Any,
                       "zip": addressDic["zip"] as Any,
                       "country": addressDic["country"] as Any,
                       "phone": UserCache.sharedInstance.getAccountData().phone]
            
            parcel = ["length": measurementDic["length"] as Any,
                      "width": measurementDic["width"] as Any,
                      "height": measurementDic["height"] as Any,
                      "weight": measurementDic["weight"] as Any]
            break
        case 2:
            fullfillmendMethod["local"] = true
            fullfillmendMethod["localServiceRadius"] = radius
            fullfillmendMethod ["localServiceRadiusUom"] = "mile"
            break
        case 3:
            fullfillmendMethod["store"] = true
            break
        default:
            break
        }
        
        PointtersHelper.sharedInstance.startLoader(view: view)
        let serviceId = linkService.id == "" ? self.serviceId : linkService.id
        ApiHandler.editOffer(offerId: offerId, sellerId: loginUserId, buyerId: buyerId, serviceId: serviceId, currencyCode: numberFormatter.locale.currencyCode!, currencySymbol: numberFormatter.locale.currencySymbol!, description: offerDescription, fulfillmentMethod: fullfillmendMethod, price: customPrice, workDuration: Float(self.price.time), workDurationUom: self.price.timeUnitOfMeasure, address: address, parcel: parcel, location: location, media: media) { (status, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()

            if status == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    
                    self.customOfferDelegate?.returnFromCustomOffer(reload: true)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        }
    }
    
    @objc func btnDeleteTapped(sender: UIButton) {
        isLinkService = false
        linkCellCount = 1
        linkService = Service.init()
        tableView.reloadData()
        validateMandatoryFields()
    }
    
    func callSendJobOfferAPI() {
        
        var fullfillmendMethod: [String : Any] = ["local": false, "online": false, "shipment": false, "store": false]
        var address: [String : Any] = [:]
        var parcel: [String : Any] = [:]
        
        switch deliveryStatus {
        case 0:
            fullfillmendMethod["online"] = true
            break
        case 1:
            fullfillmendMethod["shipment"] = true
            address = ["street1": addressDic["street1"] as Any,
                       "street2": addressDic["street2"] as Any,
                       "city": addressDic["city"] as Any,
                       "state": addressDic["state"] as Any,
                       "zip": addressDic["zip"] as Any,
                       "country": addressDic["country"] as Any,
                       "phone": UserCache.sharedInstance.getAccountData().phone]
            
            parcel = ["length": measurementDic["length"] as Any,
                      "width": measurementDic["width"] as Any,
                      "height": measurementDic["height"] as Any,
                      "weight": measurementDic["weight"] as Any]
            break
        case 2:
            fullfillmendMethod["local"] = true
            fullfillmendMethod["localServiceRadius"] = radius
            fullfillmendMethod ["localServiceRadiusUom"] = "mile"
            break
        case 3:
            fullfillmendMethod["store"] = true
            break
        default:
            break
        }
        
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callCreateJobOffer(jobId: requestId, sellerId: loginUserId, buyerId: buyerId, serviceId: linkService.id, service: self.linkService, currencyCode: numberFormatter.locale.currencyCode!, currencySymbol: numberFormatter.locale.currencySymbol!, description: offerDescription, fulfillmentMethod: fullfillmendMethod, price: customPrice, workDuration: Float(self.price.time), workDurationUom: self.price.timeUnitOfMeasure, address: address, parcel: parcel) { (status, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if status == true {
                let responseDict = response.result.value as! [String:Any]
                if statusCode == 200 {
                    let offerDict = responseDict["offer"] as! [String:Any]
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        SocketHelper.sharedInstance.sendJoinLiveOffer(requestId: offerDict["requestId"] as! String)
                        SocketHelper.sharedInstance.getEventLiveOffers(completionHandler: { (result, error) in
                            
                        })
                        SocketHelper.sharedInstance.sendLiveOffers(offerId: offerDict["_id"] as! String)
                    }
//                    if offerDict["service"] != nil{
//                        let service: [String:Any] = offerDict["service"] as! [String : Any]
//                        self.customOfferDelegate?.selectSendCustomOffer(selId: offerDict["_id"] as! String, selPrice: price, linkedService: service, link: self.isLinkService)
//                    }else{
//                        PointtersHelper.sharedInstance.showAlertViewWithTitle("Warning", message: "No service from server.", buttonTitles: ["OK"], viewController: self, completion: nil)
//                    }
                    self.customOfferDelegate?.returnFromCustomOffer(reload: true)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                if let data = response.data {
                    let error = String(data: data, encoding: String.Encoding.utf8)
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error!, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
        }
    }
    
    func callEditJobOfferAPI() {
        
        var fullfillmendMethod: [String : Any] = ["local": false, "online": false, "shipment": false, "store": false]
        var address: [String : Any] = [:]
        var parcel: [String : Any] = [:]
        
        switch deliveryStatus {
        case 0:
            fullfillmendMethod["online"] = true
            break
        case 1:
            fullfillmendMethod["shipment"] = true
            address = ["street1": addressDic["street1"] as Any,
                       "street2": addressDic["street2"] as Any,
                       "city": addressDic["city"] as Any,
                       "state": addressDic["state"] as Any,
                       "zip": addressDic["zip"] as Any,
                       "country": addressDic["country"] as Any,
                       "phone": UserCache.sharedInstance.getAccountData().phone]
            
            parcel = ["length": measurementDic["length"] as Any,
                      "width": measurementDic["width"] as Any,
                      "height": measurementDic["height"] as Any,
                      "weight": measurementDic["weight"] as Any]
            break
        case 2:
            fullfillmendMethod["local"] = true
            fullfillmendMethod["localServiceRadius"] = radius
            fullfillmendMethod ["localServiceRadiusUom"] = "mile"
            break
        case 3:
            fullfillmendMethod["store"] = true
            break
        default:
            break
        }
        
        PointtersHelper.sharedInstance.startLoader(view: view)
        let serviceId = linkService.id == "" ? self.serviceId : linkService.id
        ApiHandler.editJobOffer(offerId: offerId, sellerId: loginUserId, buyerId: buyerId, serviceId: serviceId, service: self.linkService, currencyCode: numberFormatter.locale.currencyCode!, currencySymbol: numberFormatter.locale.currencySymbol!, description: offerDescription, fulfillmentMethod: fullfillmendMethod, price: customPrice, workDuration: Float(self.price.time), workDurationUom: self.price.timeUnitOfMeasure, address: address, parcel: parcel, location: location, media: media) { (status, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if status == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    
                    self.customOfferDelegate?.returnFromCustomOffer(reload: true)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        }
    }
    
}

// MARK: - Link ServiceDelegate

extension SendRequestOfferViewController:LinkServiceDelegate {
    func selectLinkService(selected : UserService) {
        isLinkService = true
        linkCellCount = 2
        linkService = selected.service
        validateMandatoryFields()
        tableView.reloadData()
    }
}

extension SendRequestOfferViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return linkCellCount
        case 1: return 1
        case 2: return 1
        case 3: return 1
        case 4: return 4
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return 50.0
            } else {
                return 100.0
            }
        case 1:
            return 50.0
        case 2:
            return 80.0
        case 3:
            return 50.0
        case 4:
            switch indexPath.row {
            case 0:
                return 44.0
            case 1:
                return 0.0                                                              // hide shipment option
            case 2,3: return 60.0
            default:  return 0.0
            }
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 20
        case 1: return 10
        case 2,3,4: return 46
        default:
           return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 25, width: tableView.bounds.size.width - 30, height: 20))
        headerLabel.font = UIFont(name: "Helvetica", size: 14)
        headerLabel.textColor = UIColor.getCustomGrayTextColor()
        
        switch section {
        case 2:
            headerLabel.text = "OFFER DESCRIPTION"
            break
        case 3:
            headerLabel.text = "TIME TO COMPLETE WORK"
            break
        case 4:
            headerLabel.text = "DELIVERY METHOD"
            break
        default:
            break
        }
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "linkServiceCell") as! SendOfferCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell") as! SendOfferCell
                cell.imgService.layer.cornerRadius = 3.0
                cell.imgService.layer.masksToBounds = true
                cell.imgService.sd_imageTransition = .fade
                cell.imgService.sd_setImage(with: URL(string: linkService.media.fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                cell.lblDesc.text = !self.linkService.tagline.isEmpty ? self.linkService.tagline : self.linkService.desc
                cell.lblPrice.text = self.linkService.prices.currencySymbol + String(format: "%.2f", self.linkService.prices.price)
                cell.btnSellerName.setTitle(UserCache.sharedInstance.getAccountData().firstName + " " + UserCache.sharedInstance.getAccountData().lastName, for: .normal)
                cell.btnDelete.tag = 1001
                cell.btnDelete.addTarget(self, action: #selector(btnDeleteTapped(sender:)), for: .touchUpInside)
                return cell
            }
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "priceCell") as! SendOfferCell
            cell.tfOfferPrice.placeholder = currencySymbol
            if customPrice > 0 {
                cell.tfOfferPrice.text = numberFormatter.string(from: NSNumber(value: customPrice))
            }
            cell.tfOfferPrice.tag = 200
            cell.tfOfferPrice.delegate = self
            addToolBar(textField:cell.tfOfferPrice)
            return cell
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "descCell") as! SendOfferCell
            cell.tvOfferDesc.tag = 300
            cell.tvOfferDesc.delegate = self
            cell.tvOfferDesc.text = offerDescription
            addToolBar(textView: cell.tvOfferDesc)
            return cell
        }
        else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell") as! SendOfferCell
            let strTime = String(format:"%d", self.price.time) + " " + self.price.timeUnitOfMeasure.capitalizingFirstLetter()
            cell.lblTime.text = (self.price.time > 1) ? strTime + "s" : strTime
            cell.lblTime.isHidden = (self.price.timeUnitOfMeasure != "") ? false : true
            cell.imgArrow.isHidden = (self.price.timeUnitOfMeasure != "") ? true : false
            return cell
        }
        else if indexPath.section == 4 {
            if indexPath.row < 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "onlineCell") as! SendOfferCell
                cell.lblTitle.text = kDeliveryMethodItems[indexPath.row]
                let img1 = (indexPath.row == deliveryStatus) ? "icon-checkbox-blue" : "icon-checkbox-normal"
                cell.imgCheck.image = UIImage(named: img1)
                return cell
            } else if indexPath.row == 2 || indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "localCell") as! SendOfferCell
                cell.lblTitle.text = kDeliveryMethodItems[indexPath.row]
                if indexPath.row == 2 {
                    cell.lblSubTitle.text = "anywhere in the city you service"
                    let img2 = (indexPath.row == deliveryStatus) ? "icon-checkbox-blue" : "icon-checkbox-normal"
                    cell.imgCheck.image = UIImage(named: img2)
                } else {
                    if self.numStores != 0 {
                        cell.lblSubTitle.text = ""
                        let img2 = (indexPath.row == deliveryStatus) ? "icon-checkbox-blue" : "icon-checkbox-normal"
                        cell.imgCheck.image = UIImage(named: img2)
                    } else {
                        cell.lblSubTitle.text = "Add Store Locations"
                        cell.imgCheck.setImageColor(color: UIColor.darkGray)
                    }
                }
                
                
                return cell
            } else {
                return UITableViewCell()
            }
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                moveToLinkServicePage()
            } else {
                let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
                let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
                serviceDetailVC.serviceId = linkService.id
                navigationController?.pushViewController(serviceDetailVC, animated:true)
            }
        }
        if indexPath.section == 3 {
            self.setView(view: self.bottomView, hidden: false)
        }
        if indexPath.section == 4 {
            setDeliveryMethod(index: indexPath.row)
        }
    }
}

// UITextViewDelegate
extension SendRequestOfferViewController: UITextViewDelegate {
    func addToolBar(textView: UITextView) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let originText: NSString = (textView.text ?? "") as NSString
        let resultString = originText.replacingCharacters(in: range, with: text as String)
        
        validateMandatoryFields()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.tag == 300 {
            offerDescription = textView.text!
            validateMandatoryFields()
        }
    }
}

// UITextFieldDelegate
extension SendRequestOfferViewController: UITextFieldDelegate {
    
    func addToolBar(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 200 {
            if textField.text != "" {
                let priceNumber = numberFormatter.number(from: textField.text!)
                if priceNumber == nil{
                    
                }
                customPrice = (priceNumber?.floatValue)!
            }
            validateMandatoryFields()
            
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if textField.tag == 200 {
                if !(textField.text?.hasPrefix("$"))!{
                    textField.text = "$" + textField.text!
                }
                return true
            }
            validateMandatoryFields()
            return true
        }
}


// MARK: -
// MARK: - Shipping Detail Delegate

extension SendRequestOfferViewController: ShippingDetailDelegate {
    func updateDetail(addressDict: [String : Any], measurementDict: [String : Any]) {
        self.addressDic = addressDict
        self.measurementDic = measurementDict
    }
}


// MARK: -
// MARK: - Shipping Detail Delegate

extension SendRequestOfferViewController: SettingRadiusDelegate {
    func updateRadius(radius: Int) {
        self.radius = radius
        if self.radius == 0 {
            deliveryStatus = 0
            tableView.reloadSections(IndexSet(integer: 4), with: .none)
        }
    }
    func cancelRadius() {
        if self.radius == 0 {
            deliveryStatus = 0
            tableView.reloadSections(IndexSet(integer: 4), with: .none)
        }
    }
}

// UIPickerViewDataSource
extension SendRequestOfferViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 {
            return kDeliveryTimeItems.count
        } else {
            return 23
        }
    }
}

// UIPickerViewDelegate
extension SendRequestOfferViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 28.0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
            return kDeliveryTimeItems[row] + "(s)"
        } else {
            return String(format:"%d", row+1)
        }
    }
}
