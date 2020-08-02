//
//  BackgroundCheckViewController.swift
//  Pointters
//
//  Created by Mac on 2/17/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class BackgroundCheckViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var tableView: TPKeyboardAvoidingTableView!
    @IBOutlet weak var buttonDone: UIButton!
    
    let datePicker = UIDatePicker()
    var txtDatePicker: UITextField?
    var user = User()
    
    var backgroundCheck = BackgroundCheck()
    
    enum contentType : Int {
        case firstname, middlename, lastname, email, phone, birthday, postalcode, ssn, dln, dls
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        self.getBackgroundCheckInfo()
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
        user = UserCache.sharedInstance.getAccountData()
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
        if self.backgroundCheck.birthday != ""{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "yyyy-M-d"
            let date = dateFormatter.date(from: self.backgroundCheck.birthday)
            datePicker.date = date!
        }
    }
    
    func validateField(){
        if self.backgroundCheck.firstName != "" && self.backgroundCheck.middleName != "" && self.backgroundCheck.lastName != "" && self.backgroundCheck.phone != "" && self.backgroundCheck.birthday != "" && self.backgroundCheck.zipcode != "" && self.backgroundCheck.ssn != "" && self.backgroundCheck.driverLicenseNumber != "" && self.backgroundCheck.driverLicenseState != "" && isValidEmail(email: backgroundCheck.email){
            self.buttonDone.alpha = 1.0
            self.buttonDone.isUserInteractionEnabled = true
        }else{
            self.buttonDone.alpha = 0.3
            self.buttonDone.isUserInteractionEnabled = false
        }
    }
    
    func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    //MARK:-API call
    
    func getBackgroundCheckInfo(){
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callBackgroundCheck { (result, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.backgroundCheck = BackgroundCheck.init(dict: responseDict)
                    self.tableView.reloadData()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "You have no background check submitted yet.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                    })
                }
            } else {
                print(response.error ?? "")
            }
            self.validateField()
        }
    }
    
    func putBackgroundCheckInfo(){
        PointtersHelper.sharedInstance.startLoader(view: self.view)
         ApiHandler.putBackgroundCheck(id: self.backgroundCheck.id, params: self.backgroundCheck.dict()) { (result, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("Succes", message: "Successfully updated.", buttonTitles: ["OK"], viewController: self, completion: nil)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        }
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        self.putBackgroundCheckInfo()
    }

    @objc func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-M-d"
        txtDatePicker?.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text?.isEmpty)!{
            self.buttonDone.alpha = 0.3
            self.buttonDone.isUserInteractionEnabled = false
        }
    }
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITextFieldDelegate
extension BackgroundCheckViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        validateField()
        if textField.tag == contentType.birthday.rawValue {
            txtDatePicker = textField
            showDatePicker()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let text = textField.text
        switch textField.tag {
        case contentType.firstname.rawValue:
            backgroundCheck.firstName = text!
        case contentType.middlename.rawValue:
            backgroundCheck.middleName = text!
        case contentType.lastname.rawValue:
            backgroundCheck.lastName = text!
        case contentType.email.rawValue:
            backgroundCheck.email = text!
        case contentType.phone.rawValue:
            backgroundCheck.phone = text!
        case contentType.birthday.rawValue:
            backgroundCheck.birthday = text!
        case contentType.postalcode.rawValue:
            backgroundCheck.zipcode = text!
        case contentType.ssn.rawValue:
            backgroundCheck.ssn = text!
        case contentType.dln.rawValue:
            backgroundCheck.driverLicenseNumber = text!
        case contentType.dls.rawValue:
            backgroundCheck.driverLicenseState = text!
        default:
            return
        }
        validateField()
    }
}

// UITableViewDataSource
extension BackgroundCheckViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return kBackgroundSectionTitles.count + 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return kBackgroundLabelNames.count
            case 1: return kBackgroundLabelInfos.count
            case 2: return kBackgroundLabelAddress.count
            case kBackgroundSectionTitles.count + 3: return 0
            default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
            case 0: return 34.0
            case 1: return 25.0
            case 2: return 20.0
            default: return 55.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        if section > 2 && section != kBackgroundSectionTitles.count+3 {
            let headerLabel = UILabel(frame: CGRect(x: 15, y: 30, width: tableView.bounds.size.width - 30, height: 25))
            headerLabel.font = UIFont(name: "Helvetica", size: 14)
            headerLabel.textColor = UIColor.getCustomGrayTextColor()
            headerLabel.text = kBackgroundSectionTitles[section-3]
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "editCell") as! BackgroundCell
            cell.lblTitle.text = kBackgroundLabelNames[indexPath.row]
            cell.tfDesc.addTarget(self, action: #selector(BackgroundCheckViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            cell.tfDesc.keyboardType = .default
            if indexPath.row == 0 {
                cell.tfDesc.tag = contentType.firstname.rawValue
                cell.tfDesc.text = self.backgroundCheck.firstName
            }else if indexPath.row == 1 {
                cell.tfDesc.tag = contentType.middlename.rawValue
                cell.tfDesc.text = self.backgroundCheck.middleName
            }else {
                cell.tfDesc.tag = contentType.lastname.rawValue
                cell.tfDesc.text = self.backgroundCheck.lastName
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "editCell") as! BackgroundCell
            cell.lblTitle.text = kBackgroundLabelInfos[indexPath.row]
            cell.tfDesc.addTarget(self, action: #selector(BackgroundCheckViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            switch indexPath.row {
                case 0:
                    cell.tfDesc.tag = contentType.email.rawValue
                    cell.tfDesc.keyboardType = .emailAddress
                    cell.tfDesc.text = self.backgroundCheck.email
                    break
                case 1:
                    cell.tfDesc.tag = contentType.phone.rawValue
                    cell.tfDesc.keyboardType = .phonePad
                    cell.tfDesc.text = self.backgroundCheck.phone
                    break
                case kBackgroundLabelInfos.count-1:
                    cell.tfDesc.tag = contentType.birthday.rawValue
                    cell.tfDesc.text = self.backgroundCheck.birthday
                    break
                default:
                    break
            }
            
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "editCell") as! BackgroundCell
            cell.tfDesc.addTarget(self, action: #selector(BackgroundCheckViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            cell.lblTitle.text = kBackgroundLabelAddress[indexPath.row]
            cell.tfDesc.tag = contentType.postalcode.rawValue
            cell.tfDesc.keyboardType = .numberPad
            cell.tfDesc.text = self.backgroundCheck.zipcode
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell") as! BackgroundCell
            cell.tfDesc.addTarget(self, action: #selector(BackgroundCheckViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            if indexPath.section == 3 {
                cell.tfDesc.tag = contentType.ssn.rawValue
                cell.tfDesc.keyboardType = .phonePad
                cell.tfDesc.text = self.backgroundCheck.ssn
            } else if indexPath.section == 4{
                cell.tfDesc.tag = contentType.dln.rawValue
                cell.tfDesc.keyboardType = .phonePad
                cell.tfDesc.text = self.backgroundCheck.driverLicenseNumber
            } else{
                cell.tfDesc.tag = contentType.dls.rawValue
                cell.tfDesc.keyboardType = .default
                cell.tfDesc.text = self.backgroundCheck.driverLicenseState
            }
            
            return cell
        }
    }
}

// UITableViewDelegate
extension BackgroundCheckViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

