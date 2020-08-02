//
//  MerchantAddressViewController.swift
//  Pointters
//
//  Created by dreams on 11/5/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol MerchantAddressDelegate {
    func onUpdateAddress(address: WithdrawAddress)
}

class MerchantAddressViewController: UIViewController {
    
    var delegate: MerchantAddressDelegate!

    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var tableView: TPKeyboardAvoidingTableView!
    @IBOutlet weak var buttonDone: UIButton!
    
    var isUSPerson = true
    
    var labelArr = ["Street", "City", "State", "Postal Code"]
    
    var address = WithdrawAddress()
    
    enum contentType : Int {
        case streetAddress, locality, region, postalCode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isUSPerson = (UserCache.sharedInstance.getUserCountry() == "United States") ? true: false
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
        validateField()
        tableView.tableFooterView = UIView()
    }
    
    func validateField(){
        if self.address.streetAddress != ""  && self.address.locality != "" && self.address.postalCode != "" {
            if !self.address.hasState{
                self.buttonDone.alpha = 1.0
                self.buttonDone.isUserInteractionEnabled = true
            } else {
                if self.address.region != "" {
                    self.buttonDone.alpha = 1.0
                    self.buttonDone.isUserInteractionEnabled = true
                } else{
                    self.buttonDone.alpha = 0.3
                    self.buttonDone.isUserInteractionEnabled = false
                }
            }
        }else{
            self.buttonDone.alpha = 0.3
            self.buttonDone.isUserInteractionEnabled = false
        }
    }
    
    func validPostalCode(postalCode:String)->Bool{
        let postalcodeRegex = "^[0-9]{5}(-[0-9]{4})?$"
        let pinPredicate = NSPredicate(format: "SELF MATCHES %@", postalcodeRegex)
        let flag = pinPredicate.evaluate(with: postalCode) as Bool
        return flag
    }

    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        if validPostalCode(postalCode: self.address.postalCode) || !isUSPerson{
            self.delegate.onUpdateAddress(address: self.address)
            navigationController?.popViewController(animated: true)
        } else {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Invalid US postal code", buttonTitles: ["OK"], viewController: self, completion: nil)
        }
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
extension MerchantAddressViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        validateField()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let text = textField.text
        switch textField.tag {
        case contentType.streetAddress.rawValue:
            self.address.streetAddress = text!
        case contentType.locality.rawValue:
            self.address.locality = text!
        case contentType.region.rawValue:
            self.address.region = text!
        case contentType.postalCode.rawValue:
            self.address.postalCode = text!
        default:
            return
        }
        validateField()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        switch textField.tag {
        case contentType.streetAddress.rawValue:
            return count <= 255
        case contentType.locality.rawValue:
            return count <= 255
        case contentType.region.rawValue:
            return count <= 255
        case contentType.postalCode.rawValue:
            return count <= 10
        default:
            return true
        }
    }
}

// UITableViewDataSource
extension MerchantAddressViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 30, width: tableView.bounds.size.width - 30, height: 25))
        headerLabel.font = UIFont(name: "Helvetica", size: 14)
        headerLabel.textColor = UIColor.getCustomGrayTextColor()
        headerLabel.text = "YOUR ADDRESS INFO"
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editCell") as! BackgroundCell
        cell.lblTitle.text = labelArr[indexPath.row]
        cell.tfDesc.addTarget(self, action: #selector(GetPaidViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        if indexPath.section == 0 {
            cell.tfDesc.keyboardType = .default
            if indexPath.row == 0 {
                cell.tfDesc.tag = contentType.streetAddress.rawValue
                cell.tfDesc.text = self.address.streetAddress
            }else if indexPath.row == 1 {
                cell.tfDesc.tag = contentType.locality.rawValue
                cell.tfDesc.text = self.address.locality
            }else if indexPath.row == 2 {
                cell.tfDesc.tag = contentType.region.rawValue
                cell.tfDesc.text = self.address.region
            }else if indexPath.row == 3 {
                cell.tfDesc.tag = contentType.postalCode.rawValue
                cell.tfDesc.keyboardType = .numbersAndPunctuation
                cell.tfDesc.text = self.address.postalCode
            }
        }
        return cell
    }
}

// UITableViewDelegate
extension MerchantAddressViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

