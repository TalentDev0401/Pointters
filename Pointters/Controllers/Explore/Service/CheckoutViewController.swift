//
//  CheckoutViewController.swift
//  Pointters
//
//  Created by super on 4/4/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import STPopup
import Paystack

class CheckoutViewController: UIViewController {

    @IBOutlet weak var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnPay: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    
    var serviceInfo = [String:Any]()
    var servicePrices = [[String:Any]]()
    var serviceBgMedia = [[String:Any]]()
    var serviceSeller = [String:Any]()
    var serviceId = ""
    var arrAmount = [Int]()
    var transactionFee = "0.00"
    var taxValue = "0.00"
    var totalFee = "0.00"
    var totalPrice: Float = 0.0
    var isQuantityAtLeastOne: Bool = false
    var isFreeService: Bool = true
    var isCashPayment: Bool = false
    
    var paymentMethod = StripePaymentMethod()
    var shippingAddress: ShippingAddress?
    var fromAddress: ShippingAddress?
    var shippingRate: ShippingRate?
    var parcel: ShipParcel!
    var shipment: Shipment!

    var isShipment: Bool = false
    var isSelectedRate: Bool = false

    var isOnlineService: Bool = false
    var sellerCompletedGetPaid: Bool = false

    var timelineUnit = "Hours"
    var timelineAmount = "0"

    var isCustomOffer = false
    var customOfferId = ""
    var requestOfferId = ""
    var customDescription = ""
    var customDuration = 0
    var customDurationUnit = ""
    var displayPaypalSection: Bool = false
    var displayPaystackSection: Bool = false
    var buyerCountry = ""
    var sellerCountry = ""
    var startDate: Date?
    var startDateString = "Start date"
    var startDateFormatterString = ""
    var endDate: Date?
    var endDateString = "End date"
    var endDateFormatterString = ""
    var requestDateFormatterString = ""
    fileprivate var singleDate: Date = Date()
   
    var card_number = ""
    var card_expiry_year: UInt!
    var card_expiry_month: UInt!
    var card_cvv = ""
    var paystackdone: Bool = false
    var paystack_access_code = ""
    var paystack_authorization_code = ""

    var offerDetailVC: OfferDetailViewController?
    
    var chooseIndex: Int?
    var selectLocation: StoreLocation?
    var storeLocations = [StoreLocation]()
    var localLocations = [StoreLocation]()
    var clickStart: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        calculateTotalPrice()
        callCheckoutValues()
        getDefaultPaymentMethod()
    }

    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//

    func initUI() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        btnPay.layer.cornerRadius = 5.0
        btnPay.layer.masksToBounds = false
        validatePayButton()
    }

    func validatePayButton(){
        if self.isOnlineService != true {
            btnPay.alpha = 1.0
            btnPay.isUserInteractionEnabled = true
            btnPay.setTitle("Place Order", for: .normal)
        } else {
            if isFreeService == true {
                btnPay.alpha = 1.0
                btnPay.isUserInteractionEnabled = true
                btnPay.setTitle("Place Order", for: .normal)
            } else {
                btnPay.setTitle("Pay", for: .normal)
                btnPay.alpha = 1.0
                btnPay.isUserInteractionEnabled = true
                if !self.displayPaystackSection && !self.displayPaypalSection {
                    btnPay.alpha = 0.3
                    btnPay.isUserInteractionEnabled = false
                }
            }
        }
    }

    func calculateTotalPrice() {
        self.totalPrice = 0.0
        self.isFreeService = true
        self.isQuantityAtLeastOne = false
        var index = 0
        var totalQuantityOfAllItems = 0
        for amount in arrAmount {
            let item = servicePrices[index]

            var price_ns : NSNumber = 0
            if isCustomOffer{
                price_ns = item["customPrice"] as! NSNumber
            } else {
                price_ns = item["price"] as! NSNumber
            }
            let itemPrice = price_ns.floatValue
            self.totalPrice += (itemPrice * Float(amount))
            index = index + 1
            totalQuantityOfAllItems += amount
            
            if itemPrice > 0 {
                self.isFreeService = false
            }
        }
        if totalQuantityOfAllItems > 0 {
            self.isQuantityAtLeastOne = true
        }
        calculateTimeline()
    }

    func calculateTimeline(){
        var total_unit = 0
        var index = 0
        for item in self.servicePrices as [NSDictionary]{
            if arrAmount[index] == 0{
                index = index + 1
                continue
            }
            let time = (item["time"] != nil) ? item["time"] as! NSInteger : self.customDuration
            let unit = (item["timeUnitOfMeasure"] != nil) ? item["timeUnitOfMeasure"] as! String : self.customDurationUnit
            if unit == "hour"{
                total_unit = total_unit + time * arrAmount[index]
            }else if unit == "day"{
                total_unit = total_unit + time * 24  * arrAmount[index]
            }else if unit == "week"{
                total_unit = total_unit + time * 24 * 7 * arrAmount[index]
            }else if unit == "month"{
                total_unit = total_unit + time * 24 * 7 * 31 * arrAmount[index]
            }else if unit == "year"{
                total_unit = total_unit + time * 24 * 365 * arrAmount[index]
            }
            index = index + 1
        }
        if total_unit <= 24{
            if total_unit < 2{
                self.timelineUnit = "Hour"
            }else{
                self.timelineUnit = "Hours"
            }
            self.timelineAmount = "\(total_unit)"
        }else{
            self.timelineAmount = "\(total_unit/24)"
            if total_unit/24 < 2{
                self.timelineUnit = "Days"
            }else{
                self.timelineUnit = "Day"
            }
        }
    }
    
    func popupPayment(controller: UIViewController) {
        let dialogController = AZDialogViewController(title: "Payment method!",
                                                      message: "Let us know your payment method?",
                                                      widthRatio: 0.8)
        dialogController.dismissDirection = .none
        dialogController.dismissWithOutsideTouch = false
        
        dialogController.addAction(AZDialogAction(title: "PayPal", handler: { (dialog) -> (Void) in
            dialog.dismiss(animated: true) {
                self.paymentMethod.isPayPal = true
                self.paymentMethod.isPaystack = false
                self.payWithPayPal()
            }
        }))
        
        dialogController.addAction(AZDialogAction(title: "Paystack", handler: { (dialog) -> (Void) in
            dialog.dismiss(animated: true) {
                self.paymentMethod.isPaystack = true
                self.paymentMethod.isPayPal = false
                self.setPaystackAmount()
            }
        }))
        
        dialogController.addAction(AZDialogAction(title: "Cancel", handler: { (dialog) -> (Void) in
            dialog.dismiss()
        }))
                
        dialogController.buttonStyle = { (button,height,position) in
            if position == 0 {
                button.setBackgroundImage(UIImage.imageWithColor(UIColor.white), for: .highlighted)
                button.setBackgroundImage(UIImage.imageWithColor(UIColor(hexString: "#00b4f1")), for: .normal)
                button.layer.masksToBounds = true
                button.layer.borderColor = UIColor(hexString: "#00b4f1").cgColor
            } else if position == 1 {
                button.setBackgroundImage(UIImage.imageWithColor(UIColor.white), for: .highlighted)
                button.setBackgroundImage(UIImage.imageWithColor(UIColor(hexString: "#3bb75e")), for: .normal)
                button.layer.masksToBounds = true
                button.layer.borderColor = UIColor(hexString: "#3bb75e").cgColor
            } else {
                button.setBackgroundImage(UIImage.imageWithColor(UIColor.white), for: .highlighted)
                button.setBackgroundImage(UIImage.imageWithColor(UIColor(hexString: "#00b4f1")), for: .normal)
                button.layer.masksToBounds = true
                button.layer.borderColor = UIColor(hexString: "#00b4f1").cgColor
            }
            button.setTitleColor(UIColor.black, for: .highlighted)
            button.setTitleColor(UIColor.white, for: .normal)
        }

        dialogController.show(in: controller)
    }
    
    func payWithPayPal() {
        var desc = ""
        if let serviceDesc = self.serviceInfo["tagline"] as? String {
            desc = serviceDesc
        } else {
            desc = (self.serviceInfo["description"] as? String)!
        }
        
        let paymentObj = PayPalTranscation()
        let paymentrequest = PaymentRequest.init(marchantName: nil, itemName: "Pointters", price: NSDecimalNumber(value: self.totalPrice), quantity: 1, shipPrice: 0, taxPrice: 0, totalAmount: NSDecimalNumber(value: self.totalPrice), shortDesc: desc, currency: PaypalPrice.USD)
        paymentObj.configurePayPalPaymentsDetails(paymentRequest: paymentrequest, controller: self)
    }
    
    func payWithPaystack() {
        // Card view configuration
        let ngn_price = Float(self.totalPrice/0.0026)
        let popupView = MFCardView(withViewController: self, email: "test@example.com", price: "\(ngn_price)")
        popupView.delegate = self
        let popupConfig = STZPopupViewConfig()
        popupConfig.dismissAnimation = .custom
        popupConfig.dismissCustomAnimation = { containerView, popupView, completion in
            UIView.animate(withDuration: 0.3, animations: {
            }, completion: { finished in
                if self.paystackdone {
                    self.paystacktransaction()
                }
                completion()
            })
        }
        presentPopupView(popupView, config: popupConfig)
    }
    
    func paystacktransaction() {
        // building paystack card params
        let cardParams = PSTCKCardParams.init()
        cardParams.number = self.card_number
        cardParams.cvc = self.card_cvv
        cardParams.expYear = self.card_expiry_year
        cardParams.expMonth = self.card_expiry_month
                
        var desc = ""
        if let serviceDesc = self.serviceInfo["tagline"] as? String {
            desc = serviceDesc
        } else {
            desc = (self.serviceInfo["description"] as? String)!
        }
                        
        // building new Paystack Transaction
        let transactionParams = PSTCKTransactionParams.init()
        transactionParams.amount = UInt(self.totalPrice)
        let custom_filters: NSMutableDictionary = [
            "recurring": true
        ];
        let items: NSMutableArray = [desc]
        do {
            try transactionParams.setCustomFieldValue("iOS SDK", displayedAs: "Paid Via");
            try transactionParams.setCustomFieldValue("Pointters", displayedAs: "To Buy");
            try transactionParams.setMetadataValue("iOS SDK", forKey: "paid_via");
            try transactionParams.setMetadataValueDict(custom_filters, forKey: "custom_filters");
            try transactionParams.setMetadataValueArray(items, forKey: "items");
        } catch {
            print(error)
        }
        transactionParams.email = "test@gmail.com";
        
        let client = PSTCKAPIClient.init()
                        
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        client.chargeCard(cardParams, forTransaction: transactionParams, on: self,
               didEndWithError: { (error, reference) -> Void in
                PointtersHelper.sharedInstance.stopLoader()
                let userInfo = error.userInfo
                let theResult = userInfo["com.paystack.lib:ErrorMessageKey"] as! String
                PointtersHelper.sharedInstance.showAlertViewWithTitle("Error occured", message: theResult, buttonTitles: ["OK"], viewController: self, completion: nil)
            }, didRequestValidation: { (reference) -> Void in
                print("an OTP was requested, transaction has not yet succeeded: \(reference)")
            }, didTransactionSuccess: { (reference) -> Void in
                PointtersHelper.sharedInstance.stopLoader()
                // transaction may have succeeded, please verify on backend
                print("transaction success :\(reference)")
//                self.verifyPaystackTransaction(reference: reference)
                self.callOrder()
        })
    }

    @objc func btnAddTapped(sender: UIButton) {
        self.arrAmount[sender.tag] += 1
        calculateTotalPrice()
        callCheckoutValues()
        validatePayButton()
    }

    @objc func btnDownTapped(sender: UIButton) {
        if self.arrAmount[sender.tag] > 0{
            self.arrAmount[sender.tag] -= 1
            calculateTotalPrice()
            callCheckoutValues()
            validatePayButton()
        }
    }
    
    func displayStoreLocations() {
        let theme = YBTextPickerAppearanceManager.init(
            pickerTitle         : "Choose location",
            titleFont           : UIFont.boldSystemFont(ofSize: 16),
            titleTextColor      : .white,
            titleBackground     : nil,
            chooseButtonTitle     : "Choose another location",
            chooseButtonColor     : nil,
            chooseButtonFont      : UIFont.boldSystemFont(ofSize: 16),
            checkMarkPosition   : .Right,
            itemCheckedImage    : nil,
            itemUncheckedImage  : nil,
            itemColor           : .black,
            itemFont            : UIFont.systemFont(ofSize: 16),
            chooseIndex: self.chooseIndex
        )
        
        let fulfillmentMethodDict = self.serviceInfo["fulfillmentMethod"] as! [String:Any]
        let fulfillmentMethod = FulFillment.init(dict: fulfillmentMethodDict)
        var arrLocations = [String]()
        var store = false
        if fulfillmentMethod.store {
            store = true
            for item in self.storeLocations {
                let item_address = "\(item.street1), \(item.state), \(item.country)"
                arrLocations.append(item_address)
            }
        } else {
            for item in self.localLocations {
                let item_address = "\(item.street1), \(item.state), \(item.country)"
                arrLocations.append(item_address)
            }
        }
        let picker = YBTextPicker.init(with: arrLocations, appearance: theme, store: store, onCompletion: { (selectedIndexes, selectedValues) in
            
            self.chooseIndex = selectedIndexes[0]
            if fulfillmentMethod.store {
                self.selectLocation = self.storeLocations[self.chooseIndex!]
            }
            if fulfillmentMethod.local {
                self.selectLocation = self.localLocations[self.chooseIndex!]
            }
            self.tableView.reloadData()
        }, onCancel: {
            let storyboard = UIStoryboard(name: "Account", bundle: nil)
            let buyerlocations = storyboard.instantiateViewController(withIdentifier: "LocationVC") as! BuyLocationViewController
            buyerlocations.fromCheckout = true
            buyerlocations.checkoutDelegate = self
            self.navigationController?.pushViewController(buyerlocations, animated: true)
        })
        
        picker.show(withAnimation: .FromBottom)
    }

    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//

    @IBAction func btnBackClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPayClicked(_ sender: Any) {
        if self.isFreeService || !self.isOnlineService {
            if self.startDate == nil || self.endDate == nil {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("Warning", message: "Please select schedule date.", buttonTitles: ["OK"], viewController: self, completion: nil)
            } else {
                if !validateDate(){
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("Warning", message: "Start date must be before end date.", buttonTitles: ["OK"], viewController: self) { (type) in
                    }
                    return
                }
                self.callOrder()
            }
        } else {
            if self.buyerCountry == "NG" {
                if self.sellerCountry == "NG" {
                    if self.displayPaypalSection && self.displayPaystackSection {
                        self.popupPayment(controller: self)
                    } else {
                        if self.displayPaypalSection {
                            self.paymentMethod.isPayPal = true
                            self.paymentMethod.isPaystack = false
                            self.payWithPayPal()
                        }
                        if self.displayPaystackSection {
                            self.paymentMethod.isPaystack = true
                            self.paymentMethod.isPayPal = false
                            self.setPaystackAmount()
                        }
                    }
                } else {
                    self.paymentMethod.isPayPal = true
                    self.paymentMethod.isPaystack = false
                    self.payWithPayPal()
                }
            } else {
                if self.displayPaypalSection && self.displayPaystackSection {
                    self.popupPayment(controller: self)
                } else {
                    if self.displayPaypalSection {
                        self.paymentMethod.isPayPal = true
                        self.paymentMethod.isPaystack = false
                        self.payWithPayPal()
                    }
                    if self.displayPaystackSection {
                        self.paymentMethod.isPaystack = true
                        self.paymentMethod.isPayPal = false
                        self.setPaystackAmount()
                    }
                }
            }
        }
//        self.popupPayment(controller: self)
    }
   
    @IBAction func btnStartDateClicked(_ sender: Any) {
        openStartDatePicker()
    }
    
    func openStartDatePicker() {
        let selector = UIStoryboard(name: "WWCalendarTimeSelector", bundle: nil).instantiateInitialViewController() as! WWCalendarTimeSelector
        self.clickStart = true
        selector.delegate = self
        selector.optionMainPanelBackgroundColor = UIColor.white
        selector.optionButtonShowCancel = true
        selector.optionCurrentDate = singleDate
        selector.optionButtonTitleCancel = "Cancel"
        selector.optionButtonTitleDone = "Set"
        selector.optionCalendarFontColorPastDates = UIColor.darkGray
        selector.optionCalendarFontColorFutureDates = UIColor.black
        selector.optionCalendarFontColorFutureDatesHighlight = UIColor.white
        selector.optionCalendarFontColorToday = UIColor.blue
        present(selector, animated: true, completion: nil)
    }
    
    @IBAction func btnEndDateClicked(_ sender: Any) {
        openEndDatePicker()
//        openStartDatePicker()
    }
    
    func openEndDatePicker() {
        let selector = UIStoryboard(name: "WWCalendarTimeSelector", bundle: nil).instantiateInitialViewController() as! WWCalendarTimeSelector
        self.clickStart = false
        selector.delegate = self
        selector.optionButtonShowCancel = true
        selector.optionCurrentDate = singleDate
        selector.optionButtonTitleCancel = "Cancel"
        selector.optionButtonTitleDone = "Set"
        present(selector, animated: true, completion: nil)
    }

    func gotoShippingAddress(){
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let shippingAddressVC = storyboard.instantiateViewController(withIdentifier: "ShippingAddressVC") as! ShippingAddressViewController
        shippingAddressVC.shippingFlag = 0
        shippingAddressVC.isSelectionMode = true
        shippingAddressVC.addressDelegate = self
        shippingAddressVC.rateDelegate = self
        shippingAddressVC.fromAddress = self.fromAddress
        shippingAddressVC.parcel = self.parcel
        navigationController?.pushViewController(shippingAddressVC, animated: true)
    }

    func gotoShippingRate() {
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let shippingRateVC = storyboard.instantiateViewController(withIdentifier: "ShippingRateVC") as! ShippingRateViewController
        shippingRateVC.rateDelegate = self
        navigationController?.pushViewController(shippingRateVC, animated: true)
    }

    func gotoFulfillment(orderId: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FulfillmentVC") as! FulfillmentViewController
        vc.orderId = orderId
        vc.fromCheckout = true
        let fulfillmentMethodDict = self.serviceInfo["fulfillmentMethod"] as! [String:Any]
        let fulfillmentMethod = FulFillment.init(dict: fulfillmentMethodDict)
        if !fulfillmentMethod.online {
            vc.isNotOnline = true
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }

    //MARK:- API call
    func callOrder() {
        var params = [String: Any]()
        if serviceInfo["prices"] == nil {
            let item = [String: Any]()
            serviceInfo["prices"] = [item]
        }
        let price_item = serviceInfo["prices"] as! [[String: Any]]
        var orderItem: [[String: Any]] = []
        var index = 0
        var totalDuration = 0
        let price = Price.init(dict: price_item[0])
        for item in price_item{
            var item_temp = item
            item_temp["quantity"] = self.arrAmount[index]
            item_temp["currencyCode"] = (item["currencyCode"] != nil) ? item["currencyCode"] as! String : price.currencyCode
            item_temp["currencySymbol"] = (item["currencySymbol"] != nil) ? item["currencySymbol"] as! String : price.currencySymbol
            item_temp["price"] = item["price"] as! Float
            item_temp["description"] = (item["description"] != nil) ? item["description"] as! String : self.customDescription
            let time = (item["time"] != nil) ? item["time"] as! Int : self.customDuration
            item_temp["time"] = time*self.arrAmount[index]
            item_temp["timeUnitOfMeasure"] = (item["timeUnitOfMeasure"] != nil) ? item["timeUnitOfMeasure"] as! String : self.customDurationUnit
            totalDuration = totalDuration + self.arrAmount[index]*(item["time"] as! Int)
            index = index + 1
            orderItem.append(item_temp)
        }
        
        if serviceInfo["id"] == nil{
            serviceInfo["id"] = self.serviceId
        }
        params["serviceId"] = serviceInfo["id"] as! String
        params["orderItems"] = orderItem
        params["currencyCode"] = (price.currencyCode == "") ? "USD" : price.currencyCode
        params["currencySymbol"] = (price.currencySymbol == "") ? "$" : price.currencySymbol
        
        params["shippingFee"] = 0
        if self.isShipment{
            params["shippingFee"] = self.shippingRate?.rate
        }
        params["subtotalAmount"] = String(format: "%.2f", self.totalPrice)
        params["taxAmount"] = self.taxValue
        params["transactionFee"] = self.transactionFee
        params["totalAmount"] = self.totalFee
        params["totalWorkDurationHours"] = totalDuration
        
        let fulfillmentMethodDict = self.serviceInfo["fulfillmentMethod"] as! [String:Any]
        let fulfillmentMethod = FulFillment.init(dict: fulfillmentMethodDict)
        if fulfillmentMethod.online {
            var payment = [String: Any]()
            if self.paymentMethod.isPayPal {
                payment["method"] = self.paymentMethod.paypal
                params["paymentMethodToken"] = self.paymentMethod.id
            } else if self.paymentMethod.isPaystack {
                payment["method"] = self.paymentMethod.paystack
                params["paymentMethodToken"] = self.paystack_authorization_code
            }
            params["paymentMethod"] = payment
            params["sellerAcceptedScheduleTime"] = false
            params["sellerAcceptedBuyerServiceLocation"] = false
        } else {
            if fulfillmentMethod.store {
                params["buyerServiceLocation"] = self.selectLocation?.dict_Location()
            }
            if fulfillmentMethod.local {
                params["buyerServiceLocation"] = self.selectLocation?.dict_Location()
            }
            params["serviceScheduleDate"] = self.startDateFormatterString
            params["serviceScheduleEndDate"] = self.endDateFormatterString
            params["buyerRequestedServiceScheduleDate"] = self.requestDateFormatterString
        }

        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callGetOrder(params: params) { (result, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    let resDic = response.result.value as! NSDictionary
                    let dict = resDic.value(forKey: "order") as! [String: Any]
                    let orderId = dict["_id"] as! String
                    if (self.offerDetailVC != nil) {
                        self.offerDetailVC?.disableAcceptButton()
                    }
                    self.gotoFulfillment(orderId: orderId)
                }else {
                    let responseDict = response.result.value as! [String:Any]
                    let message = responseDict["message"] as! String
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: message, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                if let data = response.data {
                    let error = String(data: data, encoding: String.Encoding.utf8)
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error!, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
        }
    }

    func getDefaultPaymentMethod(){
        ApiHandler.callGetStripePaymentMethods { (result,statusCode,response, error) in
            if result == true {
                let responseDict = response.value as! [[String:Any]]
                if statusCode == 200 {
                    for paymentDic in responseDict {
                        let payment = StripePaymentMethod.init(dict: paymentDic)
                        if payment.defaultOption {
                            self.paymentMethod = payment
                            self.tableView.reloadData()
                        }
                    }
                    self.validatePayButton()
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }

        }
    }
    
    func setPaystackAmount() {
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        let ngn_price = Float(self.totalPrice/0.0026)
        ApiHandler.callSetPaystackAmountMethods(amount: ngn_price) { (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.paystack_access_code = responseDict["access_code"] as! String
                    self.paystack_authorization_code = responseDict["authorization_url"] as! String
                    self.payWithPaystack()
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        }
    }
    
    func verifyPaystackTransaction(reference: String) {
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.verifyPaystackTransaction(access_url: self.paystack_authorization_code, reference: reference) { (result, statusCode,response,error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String: Any]
                if statusCode == 200 {
                    print("response \(responseDict)")
                    self.callOrder()
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Transaction reference was not found.", buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        }
    }
    
    func callAlertSellerNotSetupGetPaid(){
        var alertMsgForSellerNotSetupGetPaid = ""
        if self.isOnlineService {
            alertMsgForSellerNotSetupGetPaid = "Oops, seller is in process of setting up get paid option required for online service. Chat with seller to proceed further."
        } else {
            alertMsgForSellerNotSetupGetPaid = "Oops, seller is in process of setting up get paid option for local service. Only CASH payment is acceptable now."
        }
        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: alertMsgForSellerNotSetupGetPaid, buttonTitles: ["Chat with seller", "Cancel"], viewController: self, completion: { (index) in
            if index == 0 {
                let storyboard = UIStoryboard(name: "Chats", bundle: nil)
                let privateChatVC = storyboard.instantiateViewController(withIdentifier: "PrivateChatVC") as! PrivateChatViewController
                privateChatVC.otherUserId = self.serviceSeller["userId"] as! String
                privateChatVC.otherUserPic = self.serviceSeller["profilePic"] as! String
                let sellerFirstName = self.serviceSeller["firstName"] as! String
                let sellerLastName = self.serviceSeller["lastName"] as! String
                privateChatVC.otherUsername = sellerFirstName + " " + sellerLastName
                self.navigationController?.pushViewController(privateChatVC, animated: true)
            }
        })
    }

    func callCheckoutValues() {

        if let _ = serviceInfo["fulfillmentMethod"]{
            let fulfillment  = serviceInfo["fulfillmentMethod"] as! NSDictionary
            self.isShipment = fulfillment.value(forKey: "shipment") as! Bool
            self.isOnlineService = fulfillment.value(forKey: "online") as! Bool
            if let _ = fulfillment.value(forKey: "address"){
                self.fromAddress = ShippingAddress.init(dict: fulfillment.value(forKey: "address") as! [String: Any])
                self.parcel = ShipParcel.init(dict: fulfillment.value(forKey: "parcel") as! [String: Any])
            }
        }

        if self.isShipment && !self.isSelectedRate {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("Warning", message: "You need to select Shipping Address.", buttonTitles: ["Select", "Cancel"], viewController: self) { (type) in
                if type == 0{
                    self.gotoShippingAddress()
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
            }
            return
        }

        var param = [String:Any]()
        param["currencyCode"] = "USD"
        param["subtotal"] = String(format: "%.2f", self.totalPrice)
        param["serviceId"] = self.serviceId
        if isShipment {
            param["shipmentId"] = self.shipment.id
        }
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callCheckoutValues(params: param) { (result, statusCode, response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    let resDic = response.result.value as! NSDictionary
                    self.displayPaypalSection = resDic.value(forKey: "displayPaypalSection") as! Bool
                    self.displayPaystackSection = resDic.value(forKey: "displayPaystackSection") as! Bool
                    if let _ = resDic["transactionFee"]{
                        let fee = resDic.value(forKey: "transactionFee") as! NSNumber
                        self.transactionFee = String(format: "%.2f", fee.floatValue)
                    }
                    if let _ = resDic["tax"]{
                        let res = resDic["tax"] as! NSDictionary
                        let tax_ns = res.value(forKey: "amount_to_collect") as! NSNumber
                        let total_ns = res.value(forKey: "order_total_amount") as! NSNumber
                        self.totalFee = "\(total_ns.floatValue + tax_ns.floatValue)"
                        self.taxValue = "\(tax_ns.floatValue)"
                        self.tableView.reloadData()
                    }
                    self.sellerCompletedGetPaid = resDic.value(forKey: "sellerCompletedGetPaid") as! Bool
                    if self.sellerCompletedGetPaid == false && self.isOnlineService == true {
                        self.callAlertSellerNotSetupGetPaid()
                    }
                    self.buyerCountry = resDic.value(forKey: "buyerCountry") as! String
                    self.sellerCountry = resDic.value(forKey: "sellerCountry") as! String
                    
                    let fulfillmentMethodDict = self.serviceInfo["fulfillmentMethod"] as! [String:Any]
                    let fulfillmentMethod = FulFillment.init(dict: fulfillmentMethodDict)
                    if fulfillmentMethod.store {
                        self.callGetStoreLocationsAPI()
                    }
                    if fulfillmentMethod.local {
                        self.callGetLocalLocationsAPI()
                    }
                }else {
                    let responseDict = response.result.value as! [String:Any]

                    let message = responseDict["message"] as! String
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: message, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                if self.isOnlineService {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
                }                
            }
        }
    }
    
    // get store locations data
    func callGetStoreLocationsAPI() {
        PointtersHelper.sharedInstance.startLoader(view: view)
        let id = self.serviceSeller["userId"] as! String
        ApiHandler.callGetStoreLocations(lastId: id) { (result, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    let resDic = response.value as! NSDictionary
                    if let locations = resDic["docs"] as? [[String: Any]] {
                        if locations.count > 1 {
                            for i in 0 ..< locations.count {
                                let storeLocation = StoreLocation.init(dict: locations[i])
                                self.storeLocations.append(storeLocation)
                                if locations[i]["isActive"] as! Bool == true {
                                    self.selectLocation = StoreLocation.init(dict: locations[i])
                                    self.chooseIndex = i
                                }
                            }
                        } else {
                            let storeLocation = StoreLocation.init(dict: locations[0])
                            self.storeLocations.append(storeLocation)
                            if locations[0]["isActive"] as! Bool == true {
                                self.selectLocation = StoreLocation.init(dict: locations[0])
                                self.chooseIndex = 0
                            }
                        }
                    }
                    self.tableView.reloadData()
                }else {
                    let responseDict = response.value as! [String:Any]

                    let message = responseDict["message"] as! String
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: message, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Server error", buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        }
    }
    
    func callGetLocalLocationsAPI(){
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetBuyerLocations(withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let resDic = response.value as! NSDictionary
                if statusCode == 200 {
                    if let locations = resDic["docs"] as? [[String: Any]] {
                        if locations.count > 1 {
                            for i in 0 ..< locations.count {
                                let storeLocation = StoreLocation.init(dict: locations[i])
                                self.localLocations.append(storeLocation)
                                if locations[i]["default"] as! Bool == true {
                                    self.selectLocation = StoreLocation.init(dict: locations[i])
                                    self.chooseIndex = i
                                }
                            }
                        } else {
                            let storeLocation = StoreLocation.init(dict: locations[0])
                            self.localLocations.append(storeLocation)
                            if locations[0]["default"] as! Bool == true {
                                self.selectLocation = StoreLocation.init(dict: locations[0])
                                self.chooseIndex = 0
                            }
                        }
                    }
                    self.tableView.reloadData()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: resDic["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        })
    }
}

extension CheckoutViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let fulfillmentMethodDict = self.serviceInfo["fulfillmentMethod"] as? [String:Any] else {
            return 5
        }
        let fulfillmentMethod = FulFillment.init(dict: fulfillmentMethodDict)
        if fulfillmentMethod.online {
            return 4
        } else {
            return 5
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return self.servicePrices.count
        case 2: return 1
        case 3:
            let fulfillmentMethodDict = self.serviceInfo["fulfillmentMethod"] as! [String:Any]
            let fulfillmentMethod = FulFillment.init(dict: fulfillmentMethodDict)
            if fulfillmentMethod.online {
                if self.displayPaystackSection && self.displayPaypalSection {
                    return 2
                } else {
                    if self.displayPaystackSection || self.displayPaypalSection {
                        return 1
                    } else {
                        return 0
                    }
                }
            } else {
                return 1
            }
        case 4:
            return 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 100.0
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            if Double(self.taxValue) == 0.0 {
                return 150.0
            }
            return 204.0
        case 3:
            let fulfillmentMethodDict = self.serviceInfo["fulfillmentMethod"] as! [String:Any]
            let fulfillmentMethod = FulFillment.init(dict: fulfillmentMethodDict)
            if fulfillmentMethod.online {
                return 60.0
            } else {
                return 87
            }
        case 4:
            return 55
        default:
            return 0.0
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 3: return 46
        case 4: return 46
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

        let fulfillmentMethodDict = self.serviceInfo["fulfillmentMethod"] as! [String:Any]
        let fulfillmentMethod = FulFillment.init(dict: fulfillmentMethodDict)
        
        switch section {
        case 3:
            if fulfillmentMethod.online {
                if self.displayPaypalSection || self.displayPaystackSection {
                    headerLabel.text = "PAYMENT METHOD"
                }
            } else {
                headerLabel.text = "SCHEDULE"
            }
            break
        case 4:
            if !fulfillmentMethod.online {
                headerLabel.text = "LOCATION"
            }
        default:
            break
        }
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        validatePayButton()
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell") as! CheckoutCell
            if self.serviceBgMedia.count > 0 {
                let itemMedia = self.serviceBgMedia[0]
                let mediaType = itemMedia["mediaType"] as! String
                if mediaType == "image" {
                    if let fileName = itemMedia["fileName"] as? String{
                        cell.imgService.sd_imageTransition = .fade
                        cell.imgService.sd_setImage(with: URL(string: fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                    }
                } else {
                    let fileName = itemMedia["fileName"] as! String
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
                                cell.imgService.image = frameImg
                            })
                        }
                    }
                }

            }

            cell.imgService.layer.cornerRadius = 3.0
            if let serviceDesc = self.serviceInfo["tagline"] as? String {
                cell.lblDesc.text = serviceDesc
            } else {
                cell.lblDesc.text = self.serviceInfo["description"] as? String
            }
            var sellerName = ""
            if let firstName = self.serviceSeller["firstName"] as? String {
                sellerName = firstName
            }
            if let lastName = self.serviceSeller["lastName"] as? String {
                sellerName = sellerName + " " + lastName
            }
            let itemPrice = (self.servicePrices.count > 0) ? self.servicePrices[0]: nil
            if itemPrice!["time"] != nil, itemPrice!["timeUnitOfMeasure"] != nil {
                cell.lblTime.text = "Per \(itemPrice!["time"] as! Int) \(itemPrice!["timeUnitOfMeasure"] as! String)"
            } else {
                cell.lblTime.text = "Per \(customDuration) \(customDurationUnit)"
            }
            var customPr: NSNumber = 0
            if let _ = itemPrice!["customPrice"] {
                customPr = (itemPrice!["customPrice"] as? NSNumber)!
            } else {
                customPr = (itemPrice!["price"] as? NSNumber)!
            }
            cell.lblPrice.text = "$" + String(format: "%.2f", customPr.floatValue)
            cell.btnSellerName.setTitle(sellerName, for: .normal)
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pricesCell") as! CheckoutCell
            let itemPrice = self.servicePrices[indexPath.row]
            if self.isCustomOffer {
                let price = itemPrice["customPrice"] as? NSNumber
                cell.lblServicePrice.text = "$" + String(format: "%.2f", (price?.floatValue)!) +  " For \(self.customDescription)"
                cell.lblAmount.text = "\(self.arrAmount[indexPath.row])"
            }else {
                let price = itemPrice["price"] as? NSNumber
                cell.lblServicePrice.text = "$" + String(format: "%.2f", (price?.floatValue)!) +  " For \(itemPrice["description"] as! String)"
                cell.lblAmount.text = "\(self.arrAmount[indexPath.row])"
            }

            cell.btnAddAmount.tag = indexPath.row
            cell.btnDownAmount.tag = indexPath.row

            cell.btnAddAmount.addTarget(self, action: #selector(btnAddTapped(sender:)), for: .touchUpInside)
            cell.btnDownAmount.addTarget(self, action: #selector(btnDownTapped(sender:)), for: .touchUpInside)

            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "serviceFeeCell") as! CheckoutCell
            cell.lblTax.text = "$\(String(format: "%.2f", Float(self.taxValue)!))"
            if Double(self.taxValue) == 0.0 {
                cell.constantTaxHeight.constant = 0.0
                cell.viewTax.isHidden = true
            } else {
                cell.constantTaxHeight.constant = 50.0
                cell.viewTax.isHidden = false
            }
            cell.lblFee.text = "$\(String(format: "%.2f", Float(self.transactionFee)!))"
            cell.lblTotalFee.text = "$\(String(format: "%.2f", Float(self.totalFee)!))"
            cell.lblCompleteTime.text = "\(self.timelineAmount) \(self.timelineUnit)"
            return cell
        } else if indexPath.section == 3 {
            let fulfillmentMethodDict = self.serviceInfo["fulfillmentMethod"] as! [String:Any]
            let fulfillmentMethod = FulFillment.init(dict: fulfillmentMethodDict)
            if fulfillmentMethod.online {
                if indexPath.row == 0 {
                    if self.displayPaypalSection {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "paypal") as! CheckoutCell
                        cell.imgPaymentMethod.image = UIImage(named: "icon-paypal")
                        cell.lblPaymentMethod.text = "PayPal"
                        cell.constantPaymentIconRatio.constant = 1.0
                        return cell
                    } else {
                        if self.displayPaystackSection {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "paystack") as! CheckoutCell
                            cell.imgPaymentMethod.image = UIImage(named: "icon-paystack")
                            return cell
                        } else {
                            return UITableViewCell()
                        }
                    }
                } else if indexPath.row == 1 {
                    if self.displayPaystackSection {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "paystack") as! CheckoutCell
                        cell.imgPaymentMethod.image = UIImage(named: "icon-paystack")
                        return cell
                    } else {
                        return UITableViewCell()
                    }
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "schedule") as! CheckoutCell
                cell.lblstartDate.text = self.startDateString
                cell.lblendDate.text = self.endDateString
                return cell
            }
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "location") as! CheckoutCell
            if let loc = self.selectLocation {
                cell.lblbuyerlocation.text = "\(loc.street1), \(loc.state), \(loc.country)"
            } else {
                cell.lblbuyerlocation.text = ""
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            let fulfillmentMethodDict = self.serviceInfo["fulfillmentMethod"] as! [String:Any]
            let fulfillmentMethod = FulFillment.init(dict: fulfillmentMethodDict)
            if fulfillmentMethod.online {
                if indexPath.row == 0 {
                    if self.displayPaypalSection {
                        self.paymentMethod.isPayPal = true
                        self.paymentMethod.isPaystack = false
                        self.payWithPayPal()
                    } else {
                        if self.displayPaystackSection {
                            self.paymentMethod.isPaystack = true
                            self.paymentMethod.isPayPal = false
                            self.payWithPaystack()
                        }
                    }
                }else if indexPath.row == 1 {
                    self.paymentMethod.isPaystack = true
                    self.paymentMethod.isPayPal = false
                    self.payWithPaystack()
                }
            }
        } else if indexPath.section == 4 {
            self.tableView.deselectRow(at: indexPath, animated: true)
            displayStoreLocations()
        }
    }
}

extension CheckoutViewController : PaymentMethodVCDelegate {
    func selectedMethod(method: StripePaymentMethod) {
        paymentMethod = method
        self.isCashPayment = false
        tableView.reloadData()
    }
    
    func selectCash(isCashPayment: Bool) {
        self.isCashPayment = isCashPayment
        tableView.reloadData()
    }
}

extension CheckoutViewController : ShippingAddressVCDelegate {
    func selectedAddress(address: ShippingAddress) {
        shippingAddress = address
        tableView.reloadData()

        PointtersHelper.sharedInstance.showAlertViewWithTitle("Action needed.", message: "You need to select shippment rate after selecting shipping address.", buttonTitles: ["Ok"], viewController: self) { (type) in
            return
        }
    }
}

extension CheckoutViewController: ShippingRateVCDelegate{
    func selectedRate(rate: ShippingRate, address: ShippingAddress, shipment: Shipment) {
        self.shippingRate = rate
        self.shippingAddress = address
        self.shipment = shipment
        self.isSelectedRate = true
        self.tableView.reloadData()
        self.callCheckoutValues()
    }
}

extension CheckoutViewController: PayPalPaymentDelegate {
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        paymentViewController.dismiss(animated: true) { () -> Void in
            print("and Dismissed")
        }
        print("Payment cancel")
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print(completedPayment.confirmation)
        // set paypal authorization code to server
        for item in completedPayment.confirmation {
            if item.key == AnyHashable("response") {
                if let authorization_code = item.value as? [String:String] {
                    let code = authorization_code["id"]!
                    self.paymentMethod.id = code
                }
            }
        }
        paymentViewController.dismiss(animated: true) { () -> Void in
            self.callOrder()
        }
        print("Payment is going on")
    }
}

extension CheckoutViewController: MFCardDelegate {
    func didEdit(number: String) {
        print("card number : \(number)")
        self.card_number = number.formattedCardNumber()
    }
    
    func didEdit(expiryDate: String) {
        print("expiryDate: \(expiryDate)")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        guard let date = formatter.date(from: expiryDate) else {
            return
        }
        formatter.dateFormat = "MM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        self.card_expiry_month = UInt(month)
        self.card_expiry_year = UInt(year)
    }
    
    func didEdit(cvc: String) {
        print("cvc: \(cvc)")
        self.card_cvv = cvc
    }
    
    func cardPayButtonClicked() {
        self.paystackdone = true
        dismissPopupView()
        
    }
    
    func cardDidClose() {
        self.paystackdone = false
        dismissPopupView()
    }
}

extension CheckoutViewController: WWCalendarTimeSelectorProtocol {
    func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date) {
        singleDate = date
        let formatter = DateFormatter()
        if self.clickStart {
            formatter.dateFormat = "MMM dd, yyyy, HH:mm a"
            self.startDate = date
            self.startDateString = formatter.string(from: date)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            self.startDateFormatterString = formatter.string(from: date)
            
            if let endDate = increaseDate(date: date) {
                self.endDate = endDate
                formatter.dateFormat = "MMM dd, yyyy, HH:mm a"
                self.endDateString = formatter.string(from: endDate)
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                self.endDateFormatterString = formatter.string(from: endDate)
            }
        } else {
            self.endDate = date
            formatter.dateFormat = "MMM dd, yyyy, HH:mm a"
            self.endDateString = formatter.string(from: date)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            self.endDateFormatterString = formatter.string(from: date)
            
            if let startDate = decreaseDate(date: date) {
                self.startDate = startDate
                formatter.dateFormat = "MMM dd, yyyy, HH:mm a"
                self.startDateString = formatter.string(from: startDate)
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                self.startDateFormatterString = formatter.string(from: startDate)
            }
        }
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        self.requestDateFormatterString = formatter.string(from: Date())
        
        self.tableView.reloadData()
    }
    
    func validateDate() -> Bool{
        if self.startDate!.timeIntervalSince1970 > self.endDate!.timeIntervalSince1970{
            return false
        }
        return true
    }
    
    func increaseDate(date: Date) -> Date? {
        var endDate: Date!
        let unit = self.timelineUnit
        if unit == "Hour" || unit == "Hours" {
            endDate = date.addingTimeInterval( TimeInterval(Int(self.timelineAmount)! * 3600))
        }else if unit == "Day" || unit == "Days" {
            endDate = date.addingTimeInterval( TimeInterval(Int(self.timelineAmount)! * 24 * 3600))
        } else {
            return nil
        }
        return endDate
    }
    
    func decreaseDate(date: Date) -> Date? {
        var startDate: Date!
        let unit = self.timelineUnit
        if unit == "Hour" || unit == "Hours" {
            startDate = date.addingTimeInterval( TimeInterval(-Int(self.timelineAmount)! * 3600))
        }else if unit == "Day" || unit == "Days" {
            startDate = date.addingTimeInterval( TimeInterval(-Int(self.timelineAmount)! * 24 * 3600))
        } else {
            return nil
        }
        return startDate
    }
}

extension CheckoutViewController: SetAsLocationCheckout {
    func setAsLocationWith(location: StoreLocation) {
        self.selectLocation = location
        for i in 0 ..< self.localLocations.count {
            if self.localLocations[i]._id == location._id {
                self.chooseIndex = i
            }
        }
        self.tableView.reloadData()
    }
}
