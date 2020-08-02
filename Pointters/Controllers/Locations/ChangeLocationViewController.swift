//
//  ChangeLocationViewController.swift
//  Pointters
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol ChangeAddressDelegate {
    func edittedAddress(addressDict : [String : Any], selectedLocation: Location)
}

class ChangeLocationViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var tableView: TPKeyboardAvoidingTableView!
    @IBOutlet var lblNavTitle: UILabel!
    
    var newDelegate: ChangeAddressDelegate?
    
    var addressDict: [String : Any] = [:]
    
    var street = ""
    var apt = ""
    var city = ""
    var state = ""
    var zip = ""
    var country = ""
    var validCountry = false
    
    var selectedLocation = Location.init()
    
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
            lblNavTitle.text = "Enter Store Location"
        }
        
        if self.selectedLocation.country == "" {
            street = UserCache.sharedInstance.getUserStreet()
            city = UserCache.sharedInstance.getUserCity()
            state = UserCache.sharedInstance.getUserState()
            zip = UserCache.sharedInstance.getUserZip()
            country = UserCache.sharedInstance.getUserCountry()
            
            selectedLocation.street = street
            selectedLocation.city = city
            selectedLocation.country = country
            selectedLocation.postalCode = zip
            selectedLocation.state = state
            selectedLocation.province = state
            
            let geo = GeoJson.init()
            geo.type = "Point"
            geo.coordinates = [UserCache.sharedInstance.getUserLongitude(), UserCache.sharedInstance.getUserLatitude()] as! [Double]
            selectedLocation.geoJson = geo
        } else {
            street = selectedLocation.street
            apt = selectedLocation.street2
            city = selectedLocation.city
            state = selectedLocation.state
            zip = selectedLocation.postalCode
            country = selectedLocation.country
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
        
        if street == "" || city == "" || state == "" || zip == "" || country == "" {
            btnDone.isUserInteractionEnabled = false
            btnDone.alpha = 0.3
        } else if street == "NA" || apt == "NA" || city == "NA" || state == "NA" || zip == "NA" || country == "NA" {
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

    }
    
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        self.selectedLocation.street2 = apt
        self.newDelegate?.edittedAddress(addressDict: selectedLocation.dict(), selectedLocation: self.selectedLocation)
        self.navigationController?.popViewController(animated: true)
    }
    
}


//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITextFieldDelegate
extension ChangeLocationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField.tag {
       case 0:
            street = textField.text!
            break
        case 1:
            apt = textField.text!
            break
        case 2:
            city = textField.text!
            break
        case 3:
            state = textField.text!
            break
        case 4:
            zip = textField.text!
            break
        case 5:
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
            street = textField.text!
            break
        case 1:
            apt = textField.text!
            break
        case 2:
            city = textField.text!
            break
        case 3:
            state = textField.text!
            break
        case 4:
            zip = textField.text!
            break
        case 5:
            country = textField.text!
            break
        default:
            break
        }
        validateForm()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 0{ //street text field click
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SetLocationVC") as! SetLocationViewController
            vc.locationDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            validateForm()
            return false
        }else{
            validateForm()
            return true
        }
    }
    
}

extension ChangeLocationViewController: SetLocationVCDelegate{
    func backWithStreet(street: String) {
        validateForm()
    }
    
    func selectedLocation(location: Location) {
        selectedLocation = location
        country = location.country
        state = location.state
        city = location.city
        street = location.street
        zip = location.postalCode
        tableView.reloadData()
        validateForm()
    }
}

// UITableViewDataSource
extension ChangeLocationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kChangeAddressItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editaddressCell") as! ShippingAddressCell
        cell.tfDesc.tag = indexPath.row
        cell.tfDesc.placeholder = kChangeAddressItems[indexPath.row]
        cell.tfDesc.delegate = self
        switch indexPath.row {
        case 0:
            cell.tfDesc.text = street
            break
        case 1:
            cell.tfDesc.text = apt
            break
        case 2:
            cell.tfDesc.text = city
            break
        case 3:
            cell.tfDesc.text = state
            break
        case 4:
            cell.tfDesc.text = zip
            break
        case 5:
            cell.tfDesc.text = country
            cell.tfDesc.tag = 5
            cell.tfDesc.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            break
        default:
            break
        }
        return cell
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == 5 {
            country = textField.text!
        }
        validateForm()
    }
}

// UITableViewDelegate
extension ChangeLocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        validateForm()
    }
}
