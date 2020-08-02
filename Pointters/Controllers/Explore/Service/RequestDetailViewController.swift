//
//  RequestDetailViewController.swift
//  Pointters
//
//  Created by super on 4/30/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import CoreLocation

protocol RequestDetailVCDelegate {
    func submittedRequest(request: RequestDetail)
    func onUpdateRequest(request: RequestDetail, index: Int)
    func onDeleteRequest(index: Int)
}

class RequestDetailViewController: UIViewController {

    @IBOutlet weak var consNavViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewBottomCover: UIView!
    @IBOutlet weak var btnSendOffer: UIButton!

    var isEditOffer = false

    var loginUserId = ""

    var requestDelegate : RequestDetailVCDelegate?

    var pageFlag = 0  // 0 -> from explore job, 1-> from new request, 2-> from edit request
    var requestAgain: Bool = false
    var requestId = ""
    var requestDetailDic = [String:Any]()
    var categoryDic: [String:Any] = [:]

    var dateTimePicker = UIDatePicker()
    var hasDescription = false

    var numberFormatter = NumberFormatter()
    var minPrice: Float = 2.0
    var maxPrice: Float = 50.0
    var scheduleDateString = ""
    var offerDescription = "I need ..."
    var rowIndexForUpdate = 0

    var snapPhotos = [Media]()
    var userAddress = Location.init()
    var locationText = "Not selected"

    var onlineJob = true
    var shareLink = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginUserId = UserCache.sharedInstance.getAccountData().id
        initUI()
        PointtersHelper.sharedInstance.sendAnalyticsToFirebase(event: kFirebaseEvents.screenJobDetail)
    }

    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//

    override func viewDidAppear(_ animated: Bool) {
        if locationText == "Not selected" {
            self.onlineJob = true
            saveForm()
            tableView.reloadData()
            validateForm()
        }
    }

    func initUI(){
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavViewHeight.constant = 85.0
        } else {
            consNavViewHeight.constant = 64.0
        }

        btnSubmit.alpha = 0.3
        btnSubmit.isUserInteractionEnabled = false

        btnSubmit.isHidden = pageFlag == 0
        btnShare.isHidden = pageFlag != 0

        if self.requestAgain{
            btnSubmit.alpha = 1.0
            btnSubmit.isUserInteractionEnabled = true
            btnSubmit.isHidden = false
            btnShare.isHidden = true
        }

        if pageFlag != 1 {
            callGetRequestDetailAPI(requestId: requestId)
            self.viewBottom.isHidden = false
            self.viewBottomCover.isHidden = false
        } else {
            self.viewBottom.isHidden = true
            self.viewBottomCover.isHidden = true
//            getCurrentLocation()
//            let date = Date()
//            let formatter = DateFormatter()
//            formatter.dateFormat = "d MMM yyyy HH:mm"
//            scheduleDateString = formatter.string(from:date)

            tableView.reloadData()
        }

        self.tableView.tableFooterView = UIView()
        dateTimePicker.datePickerMode = .dateAndTime
        dateTimePicker.minimumDate = Date()

        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = numberFormatter.locale.currencyCode!
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
    }

    func getCurrentLocation() {
        PointtersHelper.sharedInstance.startLoader(view: view)
        let geocoder = CLGeocoder()
        let lat:Double = UserCache.sharedInstance.getUserLatitude()!
        let lng:Double = UserCache.sharedInstance.getUserLongitude()!
        let userLocation = CLLocation(latitude: lat, longitude: lng)
        geocoder.reverseGeocodeLocation(userLocation, completionHandler: {
            placemarks, error in
            PointtersHelper.sharedInstance.stopLoader()
            if let err = error {
                self.userAddress = Location.init()
                print(err.localizedDescription)
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    print(placemark)
                    self.userAddress.city = placemark.locality ?? "NA"
                    self.userAddress.country = placemark.country ?? "NA"
                    self.userAddress.postalCode = placemark.postalCode ?? "NA"
                    self.userAddress.province = placemark.subAdministrativeArea ?? "NA"
                    self.userAddress.state = placemark.administrativeArea ?? ""
                    self.userAddress.geoJson.coordinates = [userLocation.coordinate.longitude, userLocation.coordinate.latitude]
                    self.tableView.reloadData()
                } else {
                    self.userAddress = Location.init()
                    print("Placemark was nil")
                }
            } else {
                self.userAddress = Location.init()
                print("Unknown error")
            }
        })
    }

    func showDatePicker(textField: UITextField) {
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()

        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker))

        toolbar.setItems([spaceButton,doneButton], animated: false)

        textField.inputAccessoryView = toolbar
        textField.inputView = dateTimePicker
    }

    func saveForm() {

        let requestCell1 = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! RequestDetailCell
        if !requestCell1.tvDescription.text.isEmpty {
            offerDescription = requestCell1.tvDescription.text
        }

        let requestCell2 = tableView.cellForRow(at: IndexPath(row: 0, section: 4)) as! RequestDetailCell
        if !(requestCell2.tfDate.text?.isEmpty)! {
            scheduleDateString = requestCell2.tfDate.text!
        }

        let requestCell3 = tableView.cellForRow(at: IndexPath(row: 0, section: 5)) as! RequestDetailCell
        snapPhotos = requestCell3.arrSnapPhotos

        let requestCell4 = tableView.cellForRow(at: IndexPath(row: 0, section: 6)) as! RequestDetailCell
        let minNumber = numberFormatter.number(from: requestCell4.tfMinPrice.text!)
        if minNumber != nil {
            minPrice = (minNumber?.floatValue)!
        }

        let maxNumber = numberFormatter.number(from: requestCell4.tfMaxPrice.text!)
        if maxNumber != nil {
            maxPrice = (maxNumber?.floatValue)!
        }
    }

    func validateForm() {

        saveForm()

        var isValidate = true


        if scheduleDateString == "" {
            if self.onlineJob {
                isValidate = true
            } else {
                isValidate = false
            }
        }

        if (categoryDic["name"] == nil) {
            isValidate = false
        }

//        if snapPhotos.count == 0 {
//            isValidate = false
//        }

        if offerDescription.isEmpty || offerDescription == "I need ..." {
            isValidate = false
        }

        if maxPrice == 0 {
            isValidate = false
        }

        if minPrice > maxPrice {
            isValidate = false
        }

        if !self.onlineJob && userAddress.geoJson.coordinates.count < 2 {
            isValidate = false
        }

        if isValidate {
            btnSubmit.alpha = 1.0
            btnSubmit.isUserInteractionEnabled = true
        } else {
            btnSubmit.alpha = 0.3
            btnSubmit.isUserInteractionEnabled = false
        }
    }

    func callCreateRequestAPI() {
        guard minPrice >= 2.0 else {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Min price must be at least $1.", buttonTitles: ["OK"], viewController: self, completion: nil)
            return
        }
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callCreateJobRequest(category: categoryDic, location: userAddress, medias: snapPhotos, description: offerDescription, minPrice: minPrice, maxPrice: maxPrice, currencyCode: "$", currencySymbol: "USD", scheduleDate: scheduleDateString, onlineJob: onlineJob, withCompletionHandler: { (result,statusCode,response,error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {

                    let requestDetail = RequestDetail.init(dict: responseDict)
                    if self.requestDelegate != nil {
                        self.requestDelegate?.submittedRequest(request: requestDetail)
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                PointtersHelper.sharedInstance.stopLoader()
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error , buttonTitles: ["OK"], viewController: self, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }

    func callEditRequestAPI() {
        guard minPrice >= 2.0 else {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Min price must be at least $1.", buttonTitles: ["OK"], viewController: self, completion: nil)
            return
        }
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callEditJobRequest(requestId: requestId, category: categoryDic, location: userAddress, medias: snapPhotos, description: offerDescription, minPrice: minPrice, maxPrice: maxPrice, currencyCode: "$", currencySymbol: "USD", scheduleDate: scheduleDateString, onlineJob: onlineJob, withCompletionHandler: { (result,statusCode,response,error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {

                    let requestDetail = RequestDetail.init(dict: responseDict)
                    if self.requestDelegate != nil {
                        self.requestDelegate?.onUpdateRequest(request: requestDetail, index: self.rowIndexForUpdate)
                    }

                    self.navigationController?.popViewController(animated: true)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        })
    }

    func callDeleteRequestAPI() {

        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callDeleteJobRequest(requestId: requestId, withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    if self.requestDelegate != nil {
                        self.requestDelegate?.onDeleteRequest(index: self.rowIndexForUpdate)
                    }

                    self.navigationController?.popViewController(animated: true)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.stopLoader()
                print(response.error ?? "get request detail failure")
            }
        })
    }

    @objc func doneDatePicker() {

        let dateCell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 4)) as! RequestDetailCell
        let scheduleDate = dateTimePicker.date

        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy HH:mm"
        scheduleDateString = formatter.string(from:scheduleDate)

        dateCell.tfDate.text = scheduleDateString

        self.view.endEditing(true)
    }

    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//

    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func btnSubmitTapped(_ sender: Any) {

        if pageFlag == 1 || requestAgain{
            callCreateRequestAPI()
        } else if pageFlag == 2 {
            callEditRequestAPI()
        }
    }

    @IBAction func onClickChat(_ sender: Any) {
        if let user = self.requestDetailDic["user"] as? NSDictionary {
            let userId = user["userId"] as? String
            var sellerName = user["firstName"] as? String
            sellerName = sellerName! + " " + ((user["lastName"] as? String)!)
            let userName = sellerName
            let userPic = user["profilePic"] as? String
            if userId != self.loginUserId {
                UserCache.sharedInstance.setChatCredentials(id: "", userId: userId!, name: userName!, pic: userPic!, verified: true)
                let storyboard = UIStoryboard(name: "Chats", bundle: nil)
                let privateChatVC = storyboard.instantiateViewController(withIdentifier: "PrivateChatVC") as! PrivateChatViewController
                privateChatVC.otherUserId = userId!
                privateChatVC.otherUserPic = userPic!
                privateChatVC.otherUsername = userName!
                navigationController?.pushViewController(privateChatVC, animated:true)
            }
        }
    }


    @IBAction func onClickSendOffer(_ sender: Any) {

        if self.isEditOffer {
            let offerId = self.requestDetailDic["offerSentId"] as? String
            let user = self.requestDetailDic["user"] as! [String: Any]
            let buyerId = user["userId"] as! String
            let sendCustomOfferVC = storyboard?.instantiateViewController(withIdentifier: "SendOfferVC") as! SendOfferViewController
            sendCustomOfferVC.customOfferDelegate = self
            sendCustomOfferVC.offerId = offerId!
            sendCustomOfferVC.buyerId = buyerId
            sendCustomOfferVC.isJobOffer = true
            navigationController?.pushViewController(sendCustomOfferVC, animated:true)
        } else {
            let jobId = self.requestDetailDic["_id"] as! String
            let jobOwner = requestDetailDic["user"] as! [String:Any]
            let ownerId = jobOwner["userId"] as! String
            var categoryId = ""
            if let category = requestDetailDic["category"] as? [String: Any] {
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
    }


    @IBAction func onClickShare(_ sender: Any) {
        var description = self.requestDetailDic["description"] as! String
        let jobId = self.requestDetailDic["_id"] as! String
        if description.count > 50 {
            description = String(description.prefix(50))
            description = description + "..."
        }
        let shareService = "Checkout this awesome job on Pointters app: " + description + "\n" + self.shareLink
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
    //*******************************************************//
    //                 MARK: - Call API Method               //
    //*******************************************************//

    func callGetRequestDetailAPI(requestId : String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetRequestDetail(requestId: requestId, withCompletionHandler:{ (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {

                var responseDict: [String:Any] = [:]
                if response.value is Dictionary<AnyHashable,Any> {
                    responseDict = response.value as! [String:Any]
                } else if response.value is Array<Any> {
                    responseDict = (response.value as! [[String:Any]])[0]
                }

                if statusCode == 200 {
                    self.requestDetailDic = responseDict
                    print(responseDict as NSDictionary)
                    let requestDetail = RequestDetail.init(dict: responseDict)
                    if responseDict["offerSentAt"]  != nil {
                        self.isEditOffer = true
                        self.btnSendOffer.setTitle("EDIT OFFER", for: .normal)
                    } else {
                        self.isEditOffer = false
                        self.btnSendOffer.setTitle("SEND OFFER", for: .normal)
                    }
                    if requestDetail.userId == self.loginUserId {
                        self.viewBottom.isHidden = true
                        self.viewBottomCover.isHidden = true
                    } else {
                        self.viewBottom.isHidden = false
                        self.viewBottomCover.isHidden = false
                    }

                    if requestDetail.closed {
                        self.btnSendOffer.alpha = 0.3
                    } else {
                        self.btnSendOffer.alpha = 1.0
                    }
                    self.btnSendOffer.isEnabled = !requestDetail.closed

                    self.categoryDic = ["name": requestDetail.category.name, "_id": requestDetail.category.id]
                    self.minPrice = requestDetail.minPrice
                    self.maxPrice = requestDetail.maxPrice
                    self.offerDescription = requestDetail.desc
                    self.userAddress = requestDetail.location
                    self.snapPhotos = requestDetail.media
                    self.onlineJob = requestDetail.onlineJob
                    if !self.onlineJob {
                        self.locationText = self.userAddress.street + " " + self.userAddress.postalCode + " " + self.userAddress.city + ", " + self.userAddress.state
                    }
                    self.shareLink = requestDetail.shareLink

                    if !requestDetail.scheduleDate.isEmpty && !self.requestAgain{
                        let dateFormatter = DateFormatter()
                        let tempLocale = dateFormatter.locale // save locale temporarily
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        let date = dateFormatter.date(from: requestDetail.scheduleDate)!
                        dateFormatter.dateFormat = "d MMM yyyy HH:mm"
                        dateFormatter.locale = tempLocale // reset the locale
                        self.scheduleDateString = dateFormatter.string(from: date)
                    }

                    self.tableView.reloadData()
                    self.validateForm()

                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: { (type) in
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
            else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
                print(response.error ?? "get request detail failure")
            }
        })
    }

}


extension RequestDetailViewController : UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if self.pageFlag == 2 {
            return 8
        } else {
            return 7
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 60.0
        case 1: return 75.0
        case 2,3,7: return 50.0
        case 4: return self.onlineJob ? 0 : 50
        case 6:
            return 60
        case 5: return 130.0
        default: return 0.0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        if section == 1 {
            let headerLabel = UILabel(frame: CGRect(x: 15, y: 20, width: tableView.bounds.size.width - 30, height: 20))
            headerLabel.font = UIFont(name: "Helvetica", size: 14)
            headerLabel.textColor = UIColor.black
            headerLabel.text = "What are you looking for?"
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! RequestDetailCell
            if let categoryName = categoryDic["name"] {
                cell.lblCategory.text = categoryName as? String
            } else {
                cell.lblCategory.text = ""
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "descCell", for: indexPath) as! RequestDetailCell
            cell.tvDescription.delegate = self
            if self.offerDescription == "" || self.offerDescription == "I need ..."{
                cell.tvDescription.text = "I need ..."
                cell.tvDescription.textColor = UIColor.lightGray
                cell.btnClose.isHidden = true
                cell.imgClose.isHidden = true
            }else {
                cell.tvDescription.text = self.offerDescription
                cell.tvDescription.textColor = UIColor.black
                cell.btnClose.isHidden = false
                cell.imgClose.isHidden = false
            }
            if pageFlag == 0 && !requestAgain{
                cell.tvDescription.isUserInteractionEnabled = false
                cell.btnClose.isHidden = true
                cell.imgClose.isHidden = true
            }else {
                cell.tvDescription.isUserInteractionEnabled = true
            }
            return cell
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! RequestDetailCell
            if pageFlag == 0  && !requestAgain{
                cell.tfDate.isUserInteractionEnabled = false
            } else {
                cell.tfDate.isUserInteractionEnabled = true
            }

            cell.tfDate.text = scheduleDateString

            cell.tfDate.tag = 200
            cell.tfDate.delegate = self
            return cell
        } else if indexPath.section == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "snapCell", for: indexPath) as! RequestDetailCell
            let tempflag = (self.requestAgain) ? 1 : self.pageFlag
            cell.setCollectionView(snapPhotos: snapPhotos, pageFlag: tempflag, rootViewController: self)
            cell.photoEditDelegate = self
            return cell
        } else if indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as! RequestDetailCell
            cell.tfMinPrice.text = "$\(minPrice)"
            cell.tfMaxPrice.text = "$\(maxPrice)"

            cell.tfMinPrice.tag = 400
            cell.tfMaxPrice.tag = 4000
            cell.tfMinPrice.delegate = self
            cell.tfMaxPrice.delegate = self

            if pageFlag == 0{
                cell.tfMinPrice.isUserInteractionEnabled = false
                cell.tfMaxPrice.isUserInteractionEnabled = false
            } else {
                cell.tfMinPrice.isUserInteractionEnabled = true
                cell.tfMaxPrice.isUserInteractionEnabled = true
            }

            if requestAgain{
                cell.tfMinPrice.isUserInteractionEnabled = true
                cell.tfMaxPrice.isUserInteractionEnabled = true
            }

            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "onlineCell", for: indexPath) as! RequestDetailCell
            if self.onlineJob {
                cell.imgCheck.image = UIImage(named: "icon-checkbox-blue")
            } else {
                cell.imgCheck.image = UIImage(named: "icon-checkbox-normal")
            }

            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! RequestDetailCell
            cell.lblLocation.text = self.locationText

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deleteCell", for: indexPath) as! RequestDetailCell
            return cell
        }
    }

}

extension RequestDetailViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 40.0
        case 2,3,4,5,7:
            return 15.0
        default:
            return 0.0
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if pageFlag == 2 {
            if section == 7 {
                return 0.0
            } else {
                return 0.0
            }
        } else {
            if section == 6 {
                return 0.0
            } else {
                return 0.0
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if pageFlag != 0 || requestAgain{
            if indexPath.section == 0 {
                saveForm()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let categoriesVC = storyboard.instantiateViewController(withIdentifier: "CategoriesVC") as! CategoriesViewController
                categoriesVC.selSubCategory = categoryDic
                categoriesVC.categoryDelegate = self
                navigationController?.pushViewController(categoriesVC, animated:true)
            }

            if indexPath.section == 2 {
                self.onlineJob = true
                self.locationText = "Not selected"
                saveForm()
                tableView.reloadData()
                validateForm()
            }

            if indexPath.section == 3 {
                self.onlineJob = false
                saveForm()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let locationVC = storyboard.instantiateViewController(withIdentifier: "SetLocationVC") as! SetLocationViewController
                locationVC.locationDelegate = self
                navigationController?.pushViewController(locationVC, animated:true)
            }

            if indexPath.section == 7 {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("Confirm", message: "Are you sure you want to delete this offer?", buttonTitles: ["OK", "Cancel"], viewController: self) { (code) in
                    if code == 0 {
                        self.callDeleteRequestAPI()
                    }
                }
            }
        }
    }
}

extension RequestDetailViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 200 {
            textField.placeholder = ""
            showDatePicker(textField: textField)
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 400 || textField.tag == 4000 {
            if textField.text == "$0.0" {
                textField.text = ""
            }
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 400 || textField.tag == 4000 {
            if !(textField.text?.hasPrefix("$"))!{
                textField.text = "$" + textField.text!
            }
            return true
        }

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let priceNumber = numberFormatter.number(from: textField.text!){
            if textField.tag == 400 {
                minPrice = (priceNumber.floatValue)
            }
            if textField.tag == 4000 {
                maxPrice = (priceNumber.floatValue)
            }
        }else {
            if textField.tag == 400 {
                textField.text = "$0.0"
                minPrice = 0
            }
            if textField.tag == 4000 {
                textField.text = "$0.0"
                maxPrice = 0
            }
        }
        validateForm()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension RequestDetailViewController : UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        validateForm()
        if textView.text.isEmpty {
            textView.text = "I need ..."
            textView.textColor = UIColor.lightGray
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        self.offerDescription = textView.text
        let cell = tableView.cellForRow(at: IndexPath.init(item: 0, section: 1)) as! RequestDetailCell
        cell.btnClose.isHidden = (self.offerDescription == "") ? true: false
        cell.imgClose.isHidden = (self.offerDescription == "") ? true: false
        validateForm()
    }
}

extension RequestDetailViewController: CategoriesVCDelegate {
    func selectedCategory(category: [String : Any]) {
        categoryDic = category
        tableView.reloadData()
        validateForm()
    }
}

extension RequestDetailViewController: SetLocationVCDelegate {
    func backWithStreet(street: String) {
        if street == "" {
            self.onlineJob = true
            if self.onlineJob {
                self.locationText = "Not selected"
            }
            saveForm()
            tableView.reloadData()
            validateForm()
        }
    }

    func selectedLocation(location: Location) {
        userAddress = location
        self.locationText = userAddress.street + " " + userAddress.postalCode + " " + userAddress.city + ", " + userAddress.state
        tableView.reloadData()
        validateForm()
    }
}

extension RequestDetailViewController: RequestDetailCellDelegate {
    func edittedPhotos(snapShots: [Media]) {
        validateForm()
    }
}

extension RequestDetailViewController: SendCustomOfferDelegate {
    func selectSendCustomOffer(selId: String, selPrice: [String : Any], linkedService: [String : Any], link: Bool) {
        self.callGetRequestDetailAPI(requestId: self.requestId)
    }

    func returnFromCustomOffer(reload: Bool) {
        self.callGetRequestDetailAPI(requestId: self.requestId)
    }


}
