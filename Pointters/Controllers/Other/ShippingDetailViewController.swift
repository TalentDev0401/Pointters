//
//  ShippingDetailViewController.swift
//  Pointters
//
//  Created by super on 4/8/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol ShippingDetailDelegate {
    func updateDetail(addressDict:[String:Any], measurementDict: [String:Any])
}

class ShippingDetailViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var tableView: TPKeyboardAvoidingTableView!
    
    var tfAddressOffsetIndex = 100
    var tfMeasurementOffsetIndex = 200
    
    var shippingDetailDelegate : ShippingDetailDelegate?
    
    var addressDict: [String : Any] = [:]
    var measurementDict: [String : Any] = [:]
    
    var street = ""
    var apt = ""
    var city = ""
    var state = ""
    var zip = ""
    var country = ""
    var weight:Float = 0.0
    var height:Float = 0.0
    var width:Float = 0.0
    var length:Float = 0.0
    var validCountry = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
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
        
        if addressDict.count > 0 {
            if let streetStr = addressDict["street1"] {
                street =  streetStr as! String
            }
            if let aptStr = addressDict["street2"] as? String {
                apt =  aptStr
            }
            if let cityStr = addressDict["city"] {
                city =  cityStr as! String
            }
            if let stateStr = addressDict["state"] {
                state =  stateStr as! String
            }
            if let zipStr = addressDict["zip"] {
                zip =  zipStr as! String
            }
            if let countryStr = addressDict["country"] {
                country =  countryStr as! String
            }
        }
        
        if measurementDict.count > 0 {
            if let lengthVal = measurementDict["length"] {
                length =  lengthVal as! Float
            }
            if let widthVal = measurementDict["width"] {
                width =  widthVal as! Float
            }
            if let heightVal = measurementDict["height"] {
                height =  heightVal as! Float
            }
            if let weightVal = measurementDict["weight"] {
                weight =  weightVal as! Float
            }
        }
        
        allowSaveData()
        tableView.reloadData()
    }
    
    func initWithSavedShippingDetail(addresses: [String : Any], measurements: [String : Any]) {
        addressDict = addresses
        measurementDict = measurements
    }
    
    func allowSaveData() {
        
        let countryName = IsoCountryCodes.find(key: country).name
        
        if countryName == "" {
            validCountry = false
        } else {
            validCountry = true
        }
        
        if let cell = tableView.cellForRow(at: IndexPath.init(row: 5, section: 0)) {
            let detailCell: ShippingDetailCell = cell as! ShippingDetailCell
            if validCountry {
                detailCell.labelInvalid.isHidden = true
            } else {
                detailCell.labelInvalid.isHidden = false
            }
        }
        
        if street == "" || city == "" || state == "" || zip == "" || country == "" || weight == 0 || height == 0 || width == 0 || length == 0 {
            btnDone.isUserInteractionEnabled = false
            btnDone.alpha = 0.3
        } else if street == "NA" || city == "NA" || state == "NA" || zip == "NA" || country == "NA" {
            btnDone.isUserInteractionEnabled = false
            btnDone.alpha = 0.3
        } else if !validCountry {
            btnDone.isUserInteractionEnabled = false
            btnDone.alpha = 0.3
        } else {
            btnDone.isUserInteractionEnabled = true
            btnDone.alpha = 1.0
        }
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackPressed(_ sender: Any) {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneClicked(_ sender: Any) {
        view.endEditing(true)
        var addressDict = [String:Any]()
        var measurementDict = [String:Any]()
        addressDict["name"] = UserCache.sharedInstance.getAccountData().firstName + " " + UserCache.sharedInstance.getAccountData().lastName
        addressDict["street1"] = street
        addressDict["street2"] = apt
        addressDict["city"] = city
        addressDict["state"] = state
        addressDict["zip"] = zip
        addressDict["country"] = country
        addressDict["phone"] = UserCache.sharedInstance.getAccountData().phone
        measurementDict["length"] = length
        measurementDict["width"] = width
        measurementDict["height"] = height
        measurementDict["weight"] = weight
        if shippingDetailDelegate != nil {
            shippingDetailDelegate?.updateDetail(addressDict: addressDict, measurementDict: measurementDict)
        }
        navigationController?.popViewController(animated: true)
    }

}

// UITableViewDataSource
extension ShippingDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return kShippingAddressItems.count
        case 1:
            return 4
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 20, width: tableView.bounds.size.width - 30, height: 20))
        headerLabel.font = UIFont(name: "Helvetica", size: 14)
        headerLabel.textColor = UIColor.getCustomGrayTextColor()
        if section == 0{
            headerLabel.text = "SHIP FROM ADDRESS"
        } else {
            headerLabel.text = "UNIT MEASUREMENT"
        }
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "shipAddressCell") as! ShippingDetailCell
            cell.tfDesc.tag = tfAddressOffsetIndex + indexPath.row
            cell.tfDesc.placeholder = kShippingAddressItems[indexPath.row]
            cell.tfDesc.keyboardType = .default
            addToolBar(textField: cell.tfDesc)
            if indexPath.row == 0 {
                cell.tfDesc.text = street
                if street == "NA" {
                    cell.tfDesc.text = ""
                }
            } else if indexPath.row == 1 {
                cell.tfDesc.text = apt
                if apt == "NA" {
                    cell.tfDesc.text = ""
                }
            } else if indexPath.row == 2 {
                cell.tfDesc.text = city
                if city == "NA" {
                    cell.tfDesc.text = ""
                }
            } else if indexPath.row == 3 {
                cell.tfDesc.text = state
                if state == "NA" {
                    cell.tfDesc.text = ""
                }
            } else if indexPath.row == 4 {
                cell.tfDesc.text = zip
                if zip == "NA" {
                    cell.tfDesc.text = ""
                }
            } else if indexPath.row == 5 {
                cell.tfDesc.text = country
                if country == "NA" {
                    cell.tfDesc.text = ""
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shipMeasurementCell") as! ShippingDetailCell
            cell.tfDesc.tag = tfMeasurementOffsetIndex + indexPath.row
            cell.tfDesc.placeholder = kShippingMeasurementItems[indexPath.row]
            cell.tfDesc.keyboardType = .decimalPad
            addToolBar(textField: cell.tfDesc)
            if indexPath.row == 0 {
                if weight != 0 {
                    cell.tfDesc.text = "\(weight)"
                } else {
                    cell.tfDesc.text = ""
                }
                cell.lblUnit.text = "oz"
            } else if indexPath.row == 1 {
                if height != 0 {
                    cell.tfDesc.text = "\(height)"
                } else {
                    cell.tfDesc.text = ""
                }
                cell.lblUnit.text = "inches"
            } else if indexPath.row == 2 {
                if length != 0 {
                    cell.tfDesc.text = "\(length)"
                } else {
                    cell.tfDesc.text = ""
                }
                cell.lblUnit.text = "inches"
            } else if indexPath.row == 3 {
                if width != 0 {
                    cell.tfDesc.text = "\(width)"
                } else {
                    cell.tfDesc.text = ""
                }
                cell.lblUnit.text = "inches"
            }
            return cell
        }
        
    }
}

// UITableViewDelegate
extension ShippingDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// UITextFieldDelegate
extension ShippingDetailViewController: UITextFieldDelegate {
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
    
    @objc func donePressed() {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typeCasteToStringFirst = textField.text as NSString?
        let newString = typeCasteToStringFirst?.replacingCharacters(in: range, with: string)
        
        if textField.tag == tfAddressOffsetIndex {
            street = newString!
//            tableView.reloadRows(at: [IndexPath(row:0, section:0)], with: .none)
        } else if textField.tag == tfAddressOffsetIndex + 1 {
            apt = newString!
        } else if textField.tag == tfAddressOffsetIndex + 2 {
            city = newString!
        } else if textField.tag == tfAddressOffsetIndex + 3 {
            state = newString!
        } else if textField.tag == tfAddressOffsetIndex + 4 {
            zip = newString!
        } else if textField.tag == tfAddressOffsetIndex + 5 {
            country = newString!
        } else if textField.tag == tfMeasurementOffsetIndex {
            weight = (newString! as NSString).floatValue
        } else if textField.tag == tfMeasurementOffsetIndex + 1 {
            height = (newString! as NSString).floatValue
        } else if textField.tag == tfMeasurementOffsetIndex + 2 {
            length = (newString! as NSString).floatValue
        } else if textField.tag == tfMeasurementOffsetIndex + 3 {
            width = (newString! as NSString).floatValue
        }
        allowSaveData()
        return true
    }
}
