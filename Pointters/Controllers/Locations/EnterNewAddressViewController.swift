//
//  EnterNewAddressViewController.swift
//  Pointters
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

extension UIResponder {
    
    func next<T: UIResponder>(_ type: T.Type) -> T? {
        return next as? T ?? next?.next(type)
    }
}

extension UITableViewCell {
    
    var tableView: UITableView? {
        return next(UITableView.self)
    }
    
    var indexPath: IndexPath? {
        return tableView?.indexPath(for: self)
    }
}

protocol NewAddressDelegate {
    func edittedAddress(addressDict : [String : Any])
    func deletedAddress()
}

class EnterNewAddressViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var tableView: TPKeyboardAvoidingTableView!
    @IBOutlet var lblNavTitle: UILabel!
    
    var newDelegate: NewAddressDelegate?
    var newLocation: Bool = false
    
    var addressDict: [String : Any] = [:]
    
    var name = ""
    var street = ""
    var apt = ""
    var city = ""
    var state = ""
    var zip = ""
    var geo = GeoJson.init()
    var country = ""
    var validCountry = false
    var isShippingAddress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
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
        if addressDict.count == 0 {
            lblNavTitle.text = "Enter New Address"
        }else {
            if isShippingAddress{
                lblNavTitle.text = "Enter Shipping Address"
                btnDelete.setTitle("Delete Shipping Address", for: .normal)
            }else{
                lblNavTitle.text = "Enter Store Location"
                btnDelete.setTitle("Delete Store Location", for: .normal)
            }
            
        }

        btnDelete.layer.shadowColor = UIColor.lightGray.cgColor
        btnDelete.layer.shadowOffset = CGSize.init(width: 1.0, height: 1.0)
        btnDelete.layer.shadowRadius = 2.0
        
        if addressDict.count > 0 {
            
            if !(addressDict["name"] is NSNull)  {
                name = addressDict["name"] as! String
            }
            street = addressDict["street1"] as! String
            if !(addressDict["street2"] is NSNull)  {
                apt = addressDict["street2"] as! String
            }
            city = addressDict["city"] as! String
            state = addressDict["state"] as! String
            zip = addressDict["zip"] as! String
            country = addressDict["country"] as! String
            
            btnDelete.isHidden = false

            tableView.reloadData()
            
        } else {
            street = UserCache.sharedInstance.getUserStreet()
            city = UserCache.sharedInstance.getUserCity()
            state = UserCache.sharedInstance.getUserState()
            zip = UserCache.sharedInstance.getUserZip()
            country = UserCache.sharedInstance.getUserCountry()
            var dictGeo = [String:Any]()
            dictGeo["type"] = "Point"
            dictGeo["coordinates"] = [UserCache.sharedInstance.getUserLongitude(), UserCache.sharedInstance.getUserLatitude()]
            geo = GeoJson.init(dict: dictGeo)
            btnDelete.isHidden = true
        }
        
        validateForm()
    }
    
    func validateForm() {
        
        let countryName = country
        if countryName == "" {
            validCountry = false
        } else {
            validCountry = true
        }
        
        if let cell = tableView.cellForRow(at: IndexPath.init(row: 6, section: 0)) {
            let countryCell: ShippingAddressCell = cell as! ShippingAddressCell
            if validCountry {
                countryCell.labelInvalid.isHidden = true
            } else {
                
            }
        }
        
        if name == "" || street == "" || city == "" || state == "" || zip == "" || country == "" {
            btnDone.isUserInteractionEnabled = false
            btnDone.alpha = 0.3
        } else if name == "NA" || street == "NA" || apt == "NA" || city == "NA" || state == "NA" || zip == "NA" || country == "NA" {
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
    
    func saveAddress(newAddresses: [String:Any]) {
        
        if isShippingAddress {
            if let addressId = addressDict["_id"] {
                PointtersHelper.sharedInstance.startLoader(view: view)
                ApiHandler.callUpdateShippingAddress(addressId: addressId as! String,addressDict: newAddresses) { (result, statusCode, response) in
                    PointtersHelper.sharedInstance.stopLoader()
                    
                    if result == true {
                        let responseDict = response.value as! [String:Any]
                        if statusCode == 200 {
                            self.newDelegate?.edittedAddress(addressDict: responseDict)
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully updated.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        } else {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                        }
                    } else {
                        print(response.error ?? "")
                    }
                }
            } else {
                PointtersHelper.sharedInstance.startLoader(view: view)
                ApiHandler.callSetShippingAddress(addressDict: newAddresses) { (result, statusCode, response) in
                    PointtersHelper.sharedInstance.stopLoader()
                    
                    if result == true {
                        let responseDict = response.value as! [String:Any]
                        if statusCode == 200 {
                            self.newDelegate?.edittedAddress(addressDict: responseDict)
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully added.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        } else {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                        }
                    } else {
                        print(response.error ?? "")
                    }
                }
            }
        } else {
            if let addressId = addressDict["_id"] {
                PointtersHelper.sharedInstance.startLoader(view: view)
                ApiHandler.callUpdateStoreLocations(id: addressId as! String,addressDict: newAddresses) { (result, statusCode, response) in
                    PointtersHelper.sharedInstance.stopLoader()
                    
                    if result == true {
                        let responseDict = response.value as! [String:Any]
                        if statusCode == 200 {
                            self.newDelegate?.edittedAddress(addressDict: responseDict)
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully updated.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        } else {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                        }
                    } else {
                        print(response.error ?? "")
                    }
                }
            } else {
                PointtersHelper.sharedInstance.startLoader(view: view)
                ApiHandler.callSetStoreLocations(addressDict: newAddresses) { (result, statusCode, response, error) in
                    PointtersHelper.sharedInstance.stopLoader()
                    
                    if result == true {
                        let responseDict = response.value as! [String:Any]
                        if statusCode == 200 {
                            self.newDelegate?.edittedAddress(addressDict: responseDict)
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully added.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        } else {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                        }
                    } else {
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
                    }
                }
            }
        }
    }
    
    func deleteAddress() {
        
        if isShippingAddress {
            if let addressId = addressDict["_id"] {
                PointtersHelper.sharedInstance.startLoader(view: view)
                ApiHandler.callDeleteShippingAddress(addressId: addressId as! String) { (result, statusCode, response) in
                    PointtersHelper.sharedInstance.stopLoader()
                    
                    if result == true {
                        self.newDelegate?.deletedAddress()
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully deleted.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: response.error as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                    }
                }
            }
        } else {
            if let addressId = addressDict["_id"] {
                PointtersHelper.sharedInstance.startLoader(view: view)
                ApiHandler.callDeleteStoreLocations(addressId: addressId as! String) { (result, statusCode, response) in
                    PointtersHelper.sharedInstance.stopLoader()
                    
                    if result == true {
                        self.newDelegate?.deletedAddress()
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully deleted.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: response.error as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                    }
                }
            }
        }
    }
    
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        
        for cell: UITableViewCell in self.tableView.visibleCells {
            
            let addressCell: ShippingAddressCell = cell as! ShippingAddressCell
            
            switch cell.indexPath?.row {
            case 0:
                name = addressCell.tfDesc.text!
                break
            case 1:
                street = addressCell.tfDesc.text!
                break
            case 2:
                apt = addressCell.tfDesc.text!
                break
            case 3:
                city = addressCell.tfDesc.text!
                break
            case 4:
                state = addressCell.tfDesc.text!
                break
            case 5:
                zip = addressCell.tfDesc.text!
                break
            case 6:
                country = addressCell.tfDesc.text!
                break
            default:
                break
            }
        }
        
        let newAddressDict = ["name": name, "street1": street, "street2": apt, "city": city, "geoJson": geo.dict(), "state": state, "zip": zip, "country": country, "phone": UserCache.sharedInstance.getAccountData().phone] as [String : Any]
        saveAddress(newAddresses: newAddressDict)
    }
    
    @IBAction func btnDeleteTapped(_ sender: Any) {
        deleteAddress()
    }
}


//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITextFieldDelegate
extension EnterNewAddressViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField.tag {
        case 0:
            name = textField.text!
            break
        case 1:
            street = textField.text!
            break
        case 2:
            apt = textField.text!
            break
        case 3:
            city = textField.text!
            break
        case 4:
            state = textField.text!
            break
        case 5:
            zip = textField.text!
            break
        case 6:
            country = textField.text!
            break
        default:
            break
        }
        validateForm()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            name = textField.text!
            break
        case 1:
            street = textField.text!
            break
        case 2:
            apt = textField.text!
            break
        case 3:
            city = textField.text!
            break
        case 4:
            state = textField.text!
            break
        case 5:
            zip = textField.text!
            break
        case 6:
            country = textField.text!
            break
        default:
            break
        }
        validateForm()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 1{ //street text field click
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SetLocationVC") as! SetLocationViewController
            vc.locationDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            return false
        }else{
            return true
        }
    }
    
}

extension EnterNewAddressViewController: SetLocationVCDelegate{
    func backWithStreet(street: String) {
        if street != ""{
            self.street = street
            tableView.reloadData()
        }
        validateForm()
    }
    
    func selectedLocation(location: Location) {
        country = location.country
        state = location.state
        city = location.city
        street = location.street
        zip = location.postalCode
        geo = location.geoJson
        tableView.reloadData()
        validateForm()
    }
}

// UITableViewDataSource
extension EnterNewAddressViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kNewAddressItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editaddressCell") as! ShippingAddressCell
        cell.tfDesc.tag = indexPath.row
        cell.tfDesc.placeholder = kNewAddressItems[indexPath.row]
        cell.tfDesc.delegate = self
        switch indexPath.row {
        case 0:
            cell.tfDesc.text = name
            break
        case 1:
            cell.tfDesc.text = street
            break
        case 2:
            cell.tfDesc.text = apt
            break
        case 3:
            cell.tfDesc.text = city
            break
        case 4:
            cell.tfDesc.text = state
            break
        case 5:
            cell.tfDesc.text = zip
            break
        case 6:
            cell.tfDesc.text = country
            cell.tfDesc.tag = 6
            cell.tfDesc.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            break
        default:
            break
        }
        return cell
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == 6 {
            country = textField.text!
            validateForm()
        }
    }
}

// UITableViewDelegate
extension EnterNewAddressViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
