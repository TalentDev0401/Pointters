//
//  EnterNewBuyerLocationViewController.swift
//  Pointters
//
//  Created by Billiard ball on 26.05.2020.
//  Copyright © 2020 Kenji. All rights reserved.
//

import UIKit

protocol NewBuyerLocationDelegate {
    func edittedBuyerLocation(addressDict : [String: Any])
    func deleteBuyerLocation()
}

class EnterNewBuyerLocationViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var tableView: TPKeyboardAvoidingTableView!
    @IBOutlet var lblNavTitle: UILabel!
    @IBOutlet var btnDefault: UIButton!
    @IBOutlet var checkDefaultImg: UIImageView!
    
    // MARK: - Variables
    
    var newLocationDelegate: NewBuyerLocationDelegate?
    var addressDict: [String : Any] = [:]
    var defaultDict: [String : Any] = [:]
    var name = ""
    var street = ""
    var apt = ""
    var city = ""
    var state = ""
    var zip = ""
    var geo = GeoJson.init()
    var country = ""
    var validCountry = false
    var isEditBuyerLocation = false
    
    // MARK: - Lifecycle
    
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
            lblNavTitle.text = "Enter New Buyer Location"
        }else {
            if isEditBuyerLocation {
                lblNavTitle.text = "Enter New Buyer Location"
                btnDelete.setTitle("Delete Buyer Location", for: .normal)
            }
            
        }

        btnDelete.layer.shadowColor = UIColor.lightGray.cgColor
        btnDelete.layer.shadowOffset = CGSize.init(width: 1.0, height: 1.0)
        btnDelete.layer.shadowRadius = 2.0
        btnDefault.layer.shadowColor = UIColor.lightGray.cgColor
        btnDefault.layer.shadowOffset = CGSize.init(width: 1.0, height: 1.0)
        btnDefault.layer.shadowRadius = 2.0
        
        if let defaultsBool = addressDict["default"] as? Bool {
            if defaultsBool {
                checkDefaultImg.isHidden = false
            } else {
                checkDefaultImg.isHidden = true
            }
        } else {
            checkDefaultImg.isHidden = true
        }
        
        if addressDict.count > 0 {
            
            if let lname = addressDict["name"] as? String {
                name = lname
            }
            if let lstreet = addressDict["street1"] as? String {
                street = lstreet
            }
            
            if let geoJson = addressDict["geoJson"] as? [String:Any] {
                geo = GeoJson.init(dict: geoJson)
            }
            
            if let lapt = addressDict["street2"] as? String  {
                apt = lapt
            }
            if let lcity = addressDict["city"] as? String {
                city = lcity
            }
            if let lstate = addressDict["state"] as? String {
                state = lstate
            }
            if let lzip = addressDict["zip"] as? String {
                zip = lzip
            }
            if let lcountry = addressDict["country"] as? String {
                country = lcountry
            }
            
            btnDelete.isHidden = false
            tableView.reloadData()
            validateForm()
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
            validateForm()
        }
        
    }
    
    /**
     Set default data
     */
    func setDefaultData(dict: [String: Any]) {
        if let lname = dict["name"] as? String {
            name = lname
        }
        if let lstreet = dict["street1"] as? String {
            street = lstreet
        }
        
        if let lapt = dict["street2"] as? String  {
            apt = lapt
        }
        if let lcity = dict["city"] as? String {
            city = lcity
        }
        if let lstate = dict["state"] as? String {
            state = lstate
        }
        if let lzip = dict["zip"] as? String {
            zip = lzip
        }
        if let lcountry = dict["country"] as? String {
            country = lcountry
        }
        tableView.reloadData()
        validateForm()
        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Location set as default successfully", buttonTitles: ["OK"], viewController: self, completion: nil)
    }
    
    /**
     Check validate form
     */
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
        
        if name == "" && street == "" && city == "" && state == "" && zip == "" && country == "" {
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
    
    /**
     Set/Update selected Buyer location
     */
    func saveBuyerLocation(newAddresses: [String:Any], defaults: Bool) {
                        
        if let addressId = addressDict["_id"] {
            // - update
            PointtersHelper.sharedInstance.startLoader(view: view)
            ApiHandler.callUpdateBuyerLocation(addressId: addressId as! String,addressDict: newAddresses) { (result, statusCode, response) in
                PointtersHelper.sharedInstance.stopLoader()
                
                if result == true {
                    let responseDict = response.value as! [String:Any]
                    if statusCode == 200 {
                        self.newLocationDelegate?.edittedBuyerLocation(addressDict: responseDict)
                        
                        if defaults {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Location set as default successfully", buttonTitles: ["OK"], viewController: self, completion: {(type) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        } else {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully updated.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        }
                    } else {
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: response.error?.localizedDescription ?? "Couldn't connect with server, please try again.", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
        } else {
            // - set new
            PointtersHelper.sharedInstance.startLoader(view: view)
            ApiHandler.callSetBuyerLocation(addressDict: newAddresses) { (result, statusCode, response) in
                PointtersHelper.sharedInstance.stopLoader()
                
                if result == true {
                    let responseDict = response.value as! [String:Any]
                    if statusCode == 200 {
                        self.newLocationDelegate?.edittedBuyerLocation(addressDict: responseDict)
                        if defaults {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Location set as default successfully", buttonTitles: ["OK"], viewController: self, completion: {(type) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        } else {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully added.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        }                        
                    } else {
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: response.error?.localizedDescription ?? "Couldn't connect with server, please try again.", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
        }
    }
    
    /**
     Delete selected location
     */
    func deleteBuyerLocation() {
        if let addressId = addressDict["_id"] {
            PointtersHelper.sharedInstance.startLoader(view: view)
            ApiHandler.callDeleteBuyerLocation(addressId: addressId as! String) { (result, statusCode, response) in
                PointtersHelper.sharedInstance.stopLoader()
                
                if result == true {
                    self.newLocationDelegate?.deleteBuyerLocation()
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully deleted.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                        self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: response.error as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
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
        
//        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Location set as default successfully", buttonTitles: ["OK"], viewController: self, completion: {(type) in
//            self.navigationController?.popViewController(animated: true)
//        })
//
        var newAddressDict = [String: Any]()
        if self.checkDefaultImg.isHidden {
            newAddressDict = ["name": name, "street1": street, "street2": apt, "city": city, "geoJson": geo.dict(), "state": state, "zip": zip, "country": country, "phone": UserCache.sharedInstance.getAccountData().phone, "default": false]
        } else {
            newAddressDict = ["name": name, "street1": street, "street2": apt, "city": city, "geoJson": geo.dict(), "state": state, "zip": zip, "country": country, "phone": UserCache.sharedInstance.getAccountData().phone, "default": true]
        }
        
        saveBuyerLocation(newAddresses: newAddressDict, defaults: !self.checkDefaultImg.isHidden)
    }
            
    @IBAction func btnDeleteTapped(_ sender: Any) {
        deleteBuyerLocation()
    }
    
    @IBAction func btnDefaultTapped(_ sender: Any) {
        self.checkDefaultImg.isHidden = !self.checkDefaultImg.isHidden
    }
}


//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITextFieldDelegate
extension EnterNewBuyerLocationViewController: UITextFieldDelegate {
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

extension EnterNewBuyerLocationViewController: SetLocationVCDelegate{
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
extension EnterNewBuyerLocationViewController: UITableViewDataSource {
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
extension EnterNewBuyerLocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
