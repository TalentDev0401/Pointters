//
//  AddCardViewController.swift
//  Pointters
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import Stripe

protocol AddCardDelegate {
    func refreshPage()
}

class AddCardViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var tableView: TPKeyboardAvoidingTableView!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var btnDelete: UIButton!

    var isDefault = false
    var name = ""
    var number = ""
    var date = ""
    var cvv = ""
    var isProcessing = false
    
    var paymentMethod: StripePaymentMethod?
    var paymentIndex: Int = 0

    var addDelegate: AddCardDelegate?
    let datePicker = MonthYearPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
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
        
        btnDone.alpha = 0.3
        btnDone.isUserInteractionEnabled = false
        
        if paymentMethod == nil {
            btnDelete.isHidden = true
            btnDone.setTitle("Done", for: .normal)
        } else {
            btnDelete.isHidden = false
            btnDone.setTitle("Update", for: .normal)
            tableView.reloadData()
            validateForms()
        }
    }
    
    func initPaymentMethodWithIndex(method: StripePaymentMethod, index: Int) {
        paymentMethod = method
        paymentIndex = index
        isDefault = (paymentMethod?.defaultOption)!
        name = (paymentMethod?.name)!
        number = "*****" + (paymentMethod?.last4)!
        cvv = "***"
        datePicker.month = (paymentMethod?.expirationMonth)!
        datePicker.year = (paymentMethod?.expirationYear)!
        date = "\(paymentMethod?.expirationMonth ?? 0)/\(paymentMethod?.expirationYear ?? 0)"
    }
    
    func showDatePicker() {
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()

        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker))
        
        toolbar.setItems([spaceButton,doneButton], animated: false)
        
        let dateCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! BackgroundCell

        dateCell.tfDesc.inputAccessoryView = toolbar
        dateCell.tfDesc.inputView = datePicker
    }
    
    func saveFormValues() {
        for viewcell in self.tableView.visibleCells {
            let cell = viewcell as! BackgroundCell
            
            if cell.indexPath?.row == 0 {
                name = cell.tfDesc.text!
            }
            if cell.indexPath?.row == 1 {
                number = cell.tfDesc.text!
            }
            if cell.indexPath?.row == 2 {
                date = cell.tfDesc.text!
            }
            if cell.indexPath?.row == 3 {
                cvv = cell.tfDesc.text!
            }
        }
    }
    
    func validateForms() {
        
        saveFormValues()
        var invalid_card = true
        let numberState = STPCardValidator.validationState(forNumber: number, validatingCardBrand: true)
        if numberState == .invalid || numberState == .incomplete {
            invalid_card = true
        } else {
            invalid_card = false
        }
        if self.paymentMethod == nil {
            if number == "" || cvv == "" || date == "" || number.contains("*") || cvv.contains("*") || invalid_card {
                btnDone.alpha = 0.3
                btnDone.isUserInteractionEnabled = false
            } else {
                btnDone.alpha = 1.0
                btnDone.isUserInteractionEnabled = true
            }
        } else {
            if cvv == "" || date == "" {
                btnDone.alpha = 0.3
                btnDone.isUserInteractionEnabled = false
            } else {
                btnDone.alpha = 1.0
                btnDone.isUserInteractionEnabled = true
            }
        }
        
    }
    
    func setCardMethod() {
        
        if !isProcessing {
            isProcessing = true
            
            var cardnumber = ""
            var cvv = ""
            
            for viewcell in self.tableView.visibleCells {
                let cell = viewcell as! BackgroundCell
                
                if cell.indexPath?.row == 1 {
                    cardnumber = cell.tfDesc.text!
                }
                if cell.indexPath?.row == 3 {
                    cvv = cell.tfDesc.text!
                }
            }
            
            let cardParams = STPCardParams()
            cardParams.name = name
            cardParams.number = cardnumber
            cardParams.expMonth = UInt(datePicker.month)
            cardParams.expYear = UInt(datePicker.year)
            cardParams.cvc = cvv
            let cvcState = STPCardValidator.validationState(forCVC: cardParams.cvc ?? "", cardBrand: STPCardValidator.brand(forNumber: cardParams.number ?? ""))
            if cvcState == .invalid || cvcState == .incomplete {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Invalid CVV Number.", buttonTitles: ["OK"], viewController: self, completion: nil)
                self.isProcessing = false
                return
            }
            
            PointtersHelper.sharedInstance.startLoader(view: self.view)
            STPAPIClient.shared().createToken(withCard: cardParams) { (token: STPToken?, error: Error?) in
                guard let token = token, error == nil else {
                    self.isProcessing = false
                    PointtersHelper.sharedInstance.stopLoader()
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: (error?.localizedDescription)!, buttonTitles: ["OK"], viewController: self, completion: nil)
                    return
                }
                ApiHandler.createStripePaymentMethod(tokenId: token.tokenId, makeDefault: self.isDefault, withCompletionHandler: { (result, statusCode, response, error) in
                    PointtersHelper.sharedInstance.stopLoader()
                    self.isProcessing = false
                    if result == true {
                        let responseDict = response.value as! [String:Any]
                        if statusCode == 200 {
                            if let errors = responseDict["errors"] {
                                print(errors)
                                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                            } else {
                                self.addDelegate?.refreshPage()
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                        }
                    } else {
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
                    }
                })
            }

        }
    }
    
    func editPaymentMethod() {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callUpdateStripePaymentMethod(methodToken: (paymentMethod?.id)!, name: name, cvv: cvv, expMon: "\(datePicker.month)", expYear: "\(datePicker.year)", makeDefault: isDefault) { (status, statusCode, response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            
            self.isProcessing = false

            if status == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully updated.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                        self.addDelegate?.refreshPage()
                        self.dismiss(animated: true, completion: nil)
                    })
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
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
        dismiss(animated: true, completion: nil)
    }

    @IBAction func btnDoneTapped(_ sender: Any) {
        self.view.endEditing(true)
        if self.paymentMethod == nil {
            setCardMethod()
        } else {
            editPaymentMethod()
        }
        
    }
    
    @IBAction func btnDeleteTapped(_ sender: Any) {
        
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callDeleteStripePaymentMethod(methodToken: (paymentMethod?.id)!) { (status, statusCode, response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if status == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.addDelegate?.refreshPage()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        }
        
    }

    @objc func doneDatePicker() {

        let dateCell = tableView.cellForRow(at: IndexPath.init(row: 2, section: 0)) as! BackgroundCell
        dateCell.tfDesc.text = String(format: "%02d/%d", datePicker.month, datePicker.year)

        validateForms()
        self.view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {

        var cardnumber = ""
        var cvv = ""
        
        for viewcell in self.tableView.visibleCells {
            let cell = viewcell as! BackgroundCell
            if cell.indexPath?.row == 1 {
                cardnumber = cell.tfDesc.text!
                let numberState = STPCardValidator.validationState(forNumber: cardnumber, validatingCardBrand: true)
                if numberState == .invalid || numberState == .incomplete {
                    cell.labelInvalid.isHidden = false
                } else {
                    cell.labelInvalid.isHidden = true
                }
                if cardnumber.contains("*****") {
                    cell.labelInvalid.isHidden = true
                }
            }
            
            if cell.indexPath?.row == 3 {
                cvv = cell.tfDesc.text!
                
                if cvv.count > 4 || cvv.count < 3 {
                    cell.labelInvalid.isHidden = false
                } else {
                    cell.labelInvalid.isHidden = true
                }
                if cvv.contains("***") {
                    cell.labelInvalid.isHidden = true
                }
            }
        }
        validateForms()
    }
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITextFieldDelegate
extension AddCardViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 100 {
            showDatePicker()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.paymentMethod != nil, textField.tag == 200 {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Card number is not allowed to edit.", buttonTitles: ["OK"], viewController: self, completion: nil)
            textField.resignFirstResponder()
            return
        }
        if textField.tag == 200 || textField.tag == 400{
            textField.perform(#selector(selectAll(_:)), with: textField, afterDelay: 0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateForms()
    }
}

// UITableViewDataSource
extension AddCardViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kCardDetailItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") as! BackgroundCell
            cell.iconCheck.isHidden = !isDefault
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "editCell") as! BackgroundCell
            cell.lblTitle.text = kCardDetailItems[indexPath.row]
            
            cell.tfDesc.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
            switch indexPath.row {
            case 0:
                cell.tfDesc.keyboardType = .default
                cell.tfDesc.placeholder = "James Anderson"
                cell.tfDesc.text = name
                break
            case 1:
                cell.tfDesc.tag = 200
                cell.tfDesc.keyboardType = .numberPad
                cell.tfDesc.placeholder = "xxxx xxxx xxxx xxxx"
                cell.tfDesc.text = number
                break
            case 2:
                cell.tfDesc.tag = 100
                cell.tfDesc.placeholder = "01/18"
                cell.tfDesc.text = date
                break
            case 3:
                cell.tfDesc.tag = 400
                cell.tfDesc.keyboardType = .numberPad
                cell.tfDesc.placeholder = "CVV"
                cell.tfDesc.text = cvv
                break
            default:
                break
            }
            
            return cell
        }
    }
}

// UITableViewDelegate
extension AddCardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 {
            isDefault = !isDefault
            validateForms()
            tableView.reloadData()
        }
    }
}

