//
//  ShippingAddressViewController.swift
//  Pointters
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol ShippingAddressVCDelegate {
    func selectedAddress(address : ShippingAddress)
}

class ShippingAddressViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblCheckout: UILabel!
    @IBOutlet var lblNavTitle: UILabel!
    @IBOutlet var buttonEdit: UIButton!

    var isSelectionMode = false
    var addressDelegate: ShippingAddressVCDelegate?
    var rateDelegate: ShippingRateVCDelegate?
    
    var arrAddress = [[String:Any]]()
    var selectedAddress: [String: Any] = [:]
    var fromAddress: ShippingAddress!
    var parcel: ShipParcel!
    var shippingCheckIndex = 0
    
    var currentPage = 1
    var totalPages = 0
    var lastDocId = ""
    
    var shippingFlag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
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
        if shippingFlag == 0 {
            lblNavTitle.text = "Shipping Address"
            lblCheckout.isHidden = false
        } else {
            lblNavTitle.text = "Store Locations"
            lblCheckout.isHidden = true
        }
        
        if isSelectionMode {
            buttonEdit.isHidden = true
        } else {
            buttonEdit.isHidden = false
        }
    }
    
    func initData() {
        if shippingFlag == 0 {
            callGetShippingAddressesAPI(inited: true, lastId: self.lastDocId)
        } else {
            callGetStoreLocationsAPI(inited: true, lastId: self.lastDocId)
        }
    }
    
    
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnEditTapped(_ sender: Any) {

        let newAddressVC = storyboard?.instantiateViewController(withIdentifier: "EnterNewAddressVC") as! EnterNewAddressViewController
        newAddressVC.newDelegate = self
        if self.shippingFlag == 0 {
            newAddressVC.isShippingAddress = true
        }
        if self.selectedAddress.count > 0 {
            newAddressVC.addressDict = selectedAddress
        }
        self.navigationController?.pushViewController(newAddressVC, animated: true)
    }
    
    //*******************************************************//
    //                 MARK: - Call API Method               //
    //*******************************************************//
    
    func callGetShippingAddressesAPI(inited: Bool, lastId: String){
        if inited {
            PointtersHelper.sharedInstance.startLoader(view: view)
            self.lastDocId = ""
        }
        ApiHandler.callGetShippingAddresses(lastId: self.lastDocId, withCompletionHandler: { (result,statusCode,response) in
            if inited {
                PointtersHelper.sharedInstance.stopLoader()
                self.arrAddress.removeAll()
            }
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.currentPage = responseDict["page"] as! Int + 1
                    self.totalPages = responseDict["pages"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for itemAddress in arr {
                            self.arrAddress.append(itemAddress)
                        }
                    }
                    self.tableView.reloadData()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        })
    }
    
    func callGetStoreLocationsAPI(inited: Bool, lastId: String){
        if inited {
            PointtersHelper.sharedInstance.startLoader(view: view)
            self.lastDocId = ""
        }
        ApiHandler.callGetStoreLocations(lastId: self.lastDocId, withCompletionHandler: { (result,statusCode,response) in
            if inited {
                PointtersHelper.sharedInstance.stopLoader()
                self.arrAddress.removeAll()
            }
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.currentPage = responseDict["page"] as! Int + 1
                    self.totalPages = responseDict["pages"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for itemAddress in arr {
                            self.arrAddress.append(itemAddress)
                        }
                    }
                    self.tableView.reloadData()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        })
    }
    
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// NewAddressDelegate
extension ShippingAddressViewController: NewAddressDelegate {
    func deletedAddress() {
        arrAddress.remove(at: shippingCheckIndex - 1)
        if arrAddress.count > 0 {
            selectedAddress = arrAddress[0]
        }
        tableView.reloadData()
    }
    
    func edittedAddress(addressDict: [String : Any]) {
        if shippingCheckIndex == 0 {
            arrAddress.append(addressDict)
        } else {
            arrAddress[shippingCheckIndex - 1] = addressDict
        }
        tableView.reloadData()
    }
}

// UITableViewDataSource
extension ShippingAddressViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == arrAddress.count) && (self.currentPage - 1 < self.totalPages) {
            callGetShippingAddressesAPI(inited: false, lastId: self.lastDocId)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSelectionMode {
            return arrAddress.count
        } else {
            return arrAddress.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == arrAddress.count {
            return 44.0
        } else {
            return 60.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        let headerLabel = UILabel(frame: CGRect(x: 13, y: 25, width: tableView.bounds.size.width - 30, height: 20))
        headerLabel.font = UIFont(name: "Helvetica", size: 14)
        headerLabel.textColor = UIColor.getCustomGrayTextColor()
        if self.shippingFlag == 0 {
            headerLabel.text = "SELECT A SHIPPING ADDRESS"
        }else {
            headerLabel.text = "SELECT A STORE LOCATION"
        }
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == arrAddress.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newaddressCell") as! ShippingAddressCell
            if self.shippingFlag == 0 {
                cell.lblNewAddress.text = "Enter New Address"
            }else {
                cell.lblNewAddress.text = "Enter Store Location"
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shippingCell") as! ShippingAddressCell
            let cellItem = ShippingAddress.init(dict: arrAddress[indexPath.row])
            cell.lblTitle.text = cellItem.name
            cell.lblSubTitle.text = cellItem.street1 + ", " + cellItem.city + ", " + cellItem.state
            cell.imgCheck.isHidden = (self.shippingCheckIndex - 1) != indexPath.row
            return cell
        }
    }
}

// UITableViewDelegate
extension ShippingAddressViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == arrAddress.count {
            let newAddressVC = storyboard?.instantiateViewController(withIdentifier: "EnterNewAddressVC") as! EnterNewAddressViewController
            newAddressVC.newDelegate = self
            shippingCheckIndex = 0
            selectedAddress = [:]
            if self.shippingFlag == 0 {
                newAddressVC.isShippingAddress = true
            }
            self.navigationController?.pushViewController(newAddressVC, animated: true)
        } else {
            selectedAddress = arrAddress[indexPath.row]
            self.shippingCheckIndex = indexPath.row + 1
            tableView.reloadData()
            
            if addressDelegate != nil {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShippingRateVC") as! ShippingRateViewController
                vc.fromAddress = self.fromAddress
                vc.toAddress = ShippingAddress.init(dict: selectedAddress)
                vc.parcel = self.parcel
                vc.rateDelegate = self.rateDelegate
                self.navigationController?.pushViewController(vc, animated: true)
            }

        }
    }
}

