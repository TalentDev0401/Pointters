//
//  GetPaidViewController.swift
//  Pointters
//
//  Created by dreams on 11/5/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import STPopup

class GetPaidViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var tableView: TPKeyboardAvoidingTableView!
    @IBOutlet weak var buttonDone: UIButton!
    
    let datePicker = UIDatePicker()
    var txtDatePicker: UITextField?
    
    var withdraw = Withdraw()
    var address = WithdrawAddress()
    
    var alreadyExist = false
    
    var fromGuide = false
    
    var isIndividualType = true
    
    var bankInfos = [BankInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        self.getMerchantAccountInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        self.tableView.tableFooterView = UIView()
    }
    
    func showDatePicker() {
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        txtDatePicker?.inputAccessoryView = toolbar
        txtDatePicker?.inputView = datePicker
        if self.withdraw.birthday != ""{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "yyyy-M-d"
            let date = dateFormatter.date(from: self.withdraw.birthday)
            datePicker.date = date!
        }
    }
    
    func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func isValidTax(taxId: String) -> Bool {
        let taxRegext = "[0-9]{2}-[0-9]{7}"
        let taxTest = NSPredicate(format:"SELF MATCHES %@", taxRegext)
        return taxTest.evaluate(with: taxId)
    }
    
    func isValidPhone(phone: String) -> Bool {
        if phone == "" {
            return true
        }
        let phoneRegext = "[0-9]{10,14}"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegext)
        return phoneTest.evaluate(with: phone)
    }
    
    func generateMerchantRequestParams() -> [String: Any] {
        return self.withdraw.dict()
    }
    
    func setKeyboardType (key: String, textField: UITextField) {
        textField.placeholder = ""
        if key.contains("First Name") {
            textField.keyboardType = .default
        }
        if key.contains("Last Name") {
            textField.keyboardType = .default
        }
        if key.contains("SSN") {
            textField.keyboardType = .numberPad
        }
        if key.contains("Business Name") {
            textField.keyboardType = .default
        }
        if key.contains("Account Holder Name") {
            textField.keyboardType = .default
        }
        if key.contains("Bank Name") {
            textField.keyboardType = .default
        }
        if key.contains("Routing") || key.contains("Sort") {
            textField.keyboardType = .numbersAndPunctuation
        }
        if key.contains("Account Number") {
            textField.keyboardType = .default
        }
        if key.contains("Tax") {
            textField.placeholder = "xx-xxxxxxx"
            textField.keyboardType = .phonePad
        }
    }
    
    //MARK:-API call
    
    func getPayStackListBankInfo() {
        ApiHandler.callPayStackListBankInfo { (result, statusCode, response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [[String:Any]]
                if statusCode == 200 {
                    print(responseDict)
                    for item in responseDict {
                        let bankinfo = BankInfo(dic: item)
                        self.bankInfos.append(bankinfo)
                    }
                    self.tableView.reloadData()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Some error occured", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                    })
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: { (type) in
                    self.fromGuide = true
                    self.btnBackTapped(self)
                })
            }
        }
    }
    
    func getMerchantAccountInfo(){
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callMerchantAccountCheck { (result, statusCode, response, error) in
            
            if result == true {
                let responseDict = response.value as! [String:Any]
                print(responseDict as NSDictionary)
                if statusCode == 200 {
                    self.withdraw = Withdraw.init(dict: responseDict)
                    if self.withdraw.status == "existing" {
                        self.alreadyExist = true
                    }
                    self.getPayStackListBankInfo()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: { (type) in
                    })
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: { (type) in
                    self.fromGuide = true
                    self.btnBackTapped(self)
                })
            }
        }
    }
    
    func createMerchantAccountInfo(){
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callMerchantAccountCreate(params: self.generateMerchantRequestParams()) { (result, statusCode, response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully created your merchant account.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                        self.btnBackTapped(self)
                        return
                    })
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: { (type) in
                    })
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        }
    }
    
    func updateMerchantInfo(){
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callMerchantAccountUpdate(params: self.generateMerchantRequestParams()) { (result, statusCode, response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully updated your merchant account.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                        self.btnBackTapped(self)
                    })
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: { (type) in
                    })
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        }
    }
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        if self.fromGuide{
            let viewControllers = self.navigationController?.viewControllers
            self.navigationController?.popToViewController(viewControllers![viewControllers!.count-3], animated: true)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        self.view.endEditing(true)
        for cell in self.tableView.visibleCells {
            if let inputCell = cell as? BackgroundCell {
                if let textfield = inputCell.tfDesc {
                    if (textfield.text?.isEmpty)! {
                        let key = textfield.accessibilityIdentifier
                        if (key?.contains("SSN"))! && self.alreadyExist{
                            self.withdraw.social = ""
                        }else {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "\(textfield.accessibilityIdentifier ?? "") is required field.", buttonTitles: ["OK"], viewController: self, completion: nil)
                            return
                        }
                    }
                }
            }
        }
        
        if self.alreadyExist {
            self.updateMerchantInfo()
        } else {
            self.gotoTosAcceptView()
        }
    }
    
    func gotoTosAcceptView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TosAcceptTermsVC") as! TosAcceptTermsViewController
        vc.delegate = self
        vc.contentSizeInPopup = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        let popupController = STPopupController(rootViewController: vc)
        popupController.style = .formSheet
        popupController.navigationBarHidden = true
        popupController.containerView.backgroundColor = UIColor.clear
        popupController.present(in: self)
    }
    
    @objc func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-M-d"
        txtDatePicker?.text = formatter.string(from: datePicker.date)
        self.withdraw.birthday = formatter.string(from: datePicker.date)
        self.withdraw.updateRawData()
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
    }
    
    @objc func onChangeType(sender: UISegmentedControl) {
        if self.txtDatePicker?.inputView != nil {
            self.txtDatePicker!.inputView = nil
            self.txtDatePicker!.reloadInputViews()
        }
        self.withdraw.isIndividualType = sender.selectedSegmentIndex == 0 ? true : false
        self.withdraw.updateRawData()
        self.tableView.reloadData()
    }
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITextFieldDelegate
extension GetPaidViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField.accessibilityIdentifier?.contains("Date"))! {
            txtDatePicker = textField
            showDatePicker()
        } else if (textField.accessibilityIdentifier?.contains("Address"))! {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MerchantAddressVC") as! MerchantAddressViewController
            vc.delegate = self
            vc.address = WithdrawAddress.init(dict: self.withdraw.address.dict())
            vc.address.hasState = self.withdraw.address.hasState
            self.navigationController?.pushViewController(vc, animated: true)
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text
        let key = textField.accessibilityIdentifier
        if (key?.contains("First Name"))! {
            withdraw.firstName = text!
        }
        if (key?.contains("Last Name"))! {
            withdraw.lastName = text!
        }
        if (key?.contains("Birth"))! {
            withdraw.birthday = text!
        }
        if (key?.contains("Address"))! {
            withdraw.address = self.address
        }
        if (key?.contains("SSN"))! {
            withdraw.social = text!
        }
        if (key?.contains("Business Name"))! {
            withdraw.businessName = text!
        }
        if (key?.contains("Tax"))! {
            withdraw.tax = text!
        }
        if (key?.contains("Account Holder Name"))! {
            withdraw.holderName = text!
        }
        if (key?.contains("Bank Name"))! {
            withdraw.name_bank = text!
        }
        if (key?.contains("Routing"))! || (key?.contains("Sort"))!{
            withdraw.routing_bank = text!
        }
        if (key?.contains("Account Number"))! {
            withdraw.account_bank = text!
        }
        self.withdraw.updateRawData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        guard let text = textField.text else { return true }
        let key = textField.accessibilityIdentifier
        let count = text.count + string.count - range.length
        if (key?.contains("Tax"))! {
            if text.count == 2 && !(isBackSpace == -92){
                textField.text = text + "-"
            }
            return count <= 10
        }
        return true
    }
}

// UITableViewDataSource
extension GetPaidViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.withdraw.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1,2:
            if let rows = self.withdraw.rowData.value(forKey: self.withdraw.sections[section]) as? [NSDictionary] {
                return rows.count
            }else {
                return 0
            }
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 30, width: tableView.bounds.size.width - 10, height: 25))
        headerLabel.font = UIFont(name: "Helvetica", size: 14)
        headerLabel.textColor = UIColor.getCustomGrayTextColor()
        headerLabel.text = self.withdraw.sections[section]
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "typeCell") as! BackgroundCell
            cell.lblTitle.text = "Bank Type"
            cell.segmentType.selectedSegmentIndex = self.withdraw.isIndividualType ? 0 : 1
            cell.segmentType.addTarget(self, action: #selector(onChangeType(sender:)), for: .valueChanged)
            cell.segmentType.isEnabled = !self.alreadyExist
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "editCell") as! BackgroundCell
            if let row = self.withdraw.rowData.value(forKey: self.withdraw.sections[indexPath.section]) as? [NSDictionary] {
                let rowData = row[indexPath.row]
                cell.tfDesc.addTarget(self, action: #selector(GetPaidViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
                cell.lblTitle.text = rowData.value(forKey: "displayName") as? String
                if cell.lblTitle.text == "Bank Name" {
                    cell.tfDesc.isHidden = true
                    cell.bankname.isHidden = false
                    cell.bankname.isUserInteractionEnabled = true
                    cell.bankname.text = rowData.value(forKey: "value") as? String
                    var banknameArray: [String] = []
                    for item in self.bankInfos {
                        banknameArray.append(item.name)
                    }
                    cell.bankname.optionArray = banknameArray
                    cell.bankname.didSelect{(selectedText , index ,id) in
                        cell.bankname.text = "\(selectedText)"
                        cell.tfDesc.text = "\(selectedText)"
                        self.withdraw.name_bank = "\(selectedText)"
                    }
                } else {
                    cell.tfDesc.isHidden = false
                    cell.bankname.isHidden = true
                }
                cell.tfDesc.accessibilityIdentifier = rowData.value(forKey: "displayName") as? String
                if rowData.value(forKey: "displayName") as? String == "Address" {
                    let streetDict = rowData.value(forKey: "line1") as? NSDictionary
                    let street = streetDict?.value(forKey: "value") as? String
                    let cityDict = rowData.value(forKey: "city") as? NSDictionary
                    let city = cityDict?.value(forKey: "value") as? String
                    let stateDict = rowData.value(forKey: "state") as? NSDictionary
                    let state = stateDict?.value(forKey: "value") as? String
                    let postalDict = rowData.value(forKey: "postal_code") as? NSDictionary
                    let postal = postalDict?.value(forKey: "value") as? String
                    if street == nil || street == ""{
                        cell.tfDesc.text = ""
                    } else {
                        cell.tfDesc.text = "\(street ?? ""), \(city ?? ""), \(postal ?? ""), \(state ?? "")"
                    }
                    
                } else if rowData.value(forKey: "displayName") as? String == "Date of Birth" {
                    let day = rowData.value(forKey: "day") as? NSDictionary
                    let month = rowData.value(forKey: "month") as? NSDictionary
                    let year = rowData.value(forKey: "year") as? NSDictionary
                    if let yearStr = year?.value(forKey: "value") as? Int{
                        if yearStr != 0 {
                            cell.tfDesc.text = "\(year?.value(forKey: "value") as! Int)-\(month?.value(forKey: "value") as! Int)-\(day?.value(forKey: "value") as! Int)"
                        } else {
                            cell.tfDesc.text = ""
                        }
                    } else {
                        cell.tfDesc.text = ""
                    }
                    if let yearStr = year?.value(forKey: "value") as? String{
                        if yearStr != "" {
                            cell.tfDesc.text = "\(year?.value(forKey: "value") as! String)-\(month?.value(forKey: "value") as! String)-\(day?.value(forKey: "value") as! String)"
                        } else {
                            cell.tfDesc.text = ""
                        }
                    }
                    
                } else {
                    cell.tfDesc.text = rowData.value(forKey: "value") as? String
                    let key = cell.tfDesc.accessibilityIdentifier
                    if key != nil {
                        self.setKeyboardType(key: key!, textField: cell.tfDesc)
                    }
                }
                
            }
            
            return cell
        }
    }
}

// UITableViewDelegate
extension GetPaidViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension GetPaidViewController: MerchantAddressDelegate {
    func onUpdateAddress(address: WithdrawAddress) {
        self.withdraw.address = address
        self.withdraw.updateRawData()
        self.tableView.reloadData()
    }
}

extension GetPaidViewController: TosAcceptDelegate {
    func onClickAgree() {
        self.createMerchantAccountInfo()
    }
}
