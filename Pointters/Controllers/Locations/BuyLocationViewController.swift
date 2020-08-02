//
//  BuyLocationViewController.swift
//  Pointters
//
//  Created by Billiard ball on 23.05.2020.
//  Copyright © 2020 Kenji. All rights reserved.
//

import UIKit

protocol SetAsLocationCheckout {
    func setAsLocationWith(location: StoreLocation)
}

class BuyLocationViewController: UIViewController {

    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblCheckout: UILabel!
    @IBOutlet var lblNavTitle: UILabel!
    @IBOutlet var buttonEdit: UIButton!
    @IBOutlet var btnSetAsLocation: UIButton!

    var isSelectionMode = false
    var addressDelegate: ShippingAddressVCDelegate?
    var rateDelegate: ShippingRateVCDelegate?
    var checkoutDelegate: SetAsLocationCheckout?
    
    var arrAddress = [[String:Any]]()
    var selectedAddress: [String: Any] = [:]
    var fromAddress: ShippingAddress!
    var parcel: ShipParcel!
    var shippingCheckIndex = 0
    
    var currentPage = 1
    var totalPages = 0
    var lastDocId = ""
    var localLocation: StoreLocation?
    var fromCheckout: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.editButtonItem.isEnabled = false
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
        lblNavTitle.text = "Buyer Locations"
        lblCheckout.isHidden = false
        
        if isSelectionMode {
            buttonEdit.isHidden = true
        } else {
            buttonEdit.isHidden = false
        }
        if fromCheckout {
            self.btnSetAsLocation.isHidden = false
        } else {
            self.btnSetAsLocation.isHidden = true
        }
    }
    
    func initData() {
        callGetBuyerLocationsAPI()
    }
   
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
        
    @IBAction func btnEditTapped(_ sender: Any) {

        let newAddressVC = storyboard?.instantiateViewController(withIdentifier: "EnterNewBuyerLocationVC") as! EnterNewBuyerLocationViewController
        newAddressVC.newLocationDelegate = self
        newAddressVC.isEditBuyerLocation = true
        if self.selectedAddress.count > 0 {
            newAddressVC.addressDict = selectedAddress
            self.navigationController?.pushViewController(newAddressVC, animated: true)
        } else {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Please select 'buyer location'", buttonTitles: ["OK"], viewController: self, completion: nil)
        }
        
    }
    
    @IBAction func setAsLocationCheckout(_ sender: Any) {
        if let location = self.localLocation {
            self.checkoutDelegate?.setAsLocationWith(location: location)
            self.navigationController?.popViewController(animated: true)
        } else {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("Missed location", message: "Please select buyer location for local service.", buttonTitles: ["OK"], viewController: self, completion: nil)
        }
    }
    
    //*******************************************************//
    //                 MARK: - Call API Method               //
    //*******************************************************//
    
    func callGetBuyerLocationsAPI(){
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetBuyerLocations(withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            self.arrAddress.removeAll()
            
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.currentPage = responseDict["page"] as! Int
                    self.totalPages = responseDict["pages"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for itemAddress in arr {
                            self.arrAddress.append(itemAddress)
                        }
                    }
                    if self.shippingCheckIndex > 0 {
                        self.selectedAddress = self.arrAddress[(self.shippingCheckIndex - 1)]
                    } else {
                        self.selectedAddress = self.arrAddress[0]
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
extension BuyLocationViewController: NewBuyerLocationDelegate {
    func edittedBuyerLocation(addressDict: [String : Any]) {
        if shippingCheckIndex == 0 {
            arrAddress.append(addressDict)
        } else {
            arrAddress[shippingCheckIndex - 1] = addressDict
        }
        tableView.reloadData()
    }
    
    func deleteBuyerLocation() {
        arrAddress.remove(at: shippingCheckIndex - 1)
        if arrAddress.count > 0 {
            selectedAddress = arrAddress[0]
        }
        tableView.reloadData()
    }
}

// UITableViewDataSource
extension BuyLocationViewController: UITableViewDataSource {
    
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
        headerLabel.text = "SELECT A BUYER LOCATION"
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == arrAddress.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newaddressCell") as! ShippingAddressCell
            cell.lblNewAddress.text = "Enter New Buyer Location"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shippingCell") as! ShippingAddressCell
            let cellItem = ShippingAddress.init(dict: arrAddress[indexPath.row])
            
            if let defaultsBool = arrAddress[indexPath.row]["default"] as? Bool {
                if defaultsBool {
                    cell.lbldefault.text = "(Default)"
                } else {
                    cell.lbldefault.text = ""
                }
            } else {
                cell.lbldefault.text = ""
            }
            
            cell.lblTitle.text = cellItem.name
            cell.lblSubTitle.text = cellItem.street1 + ", " + cellItem.city + ", " + cellItem.state
            cell.imgCheck.isHidden = (self.shippingCheckIndex - 1) != indexPath.row
            return cell
        }
    }
}

// UITableViewDelegate
extension BuyLocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == arrAddress.count {
            let newAddressVC = storyboard?.instantiateViewController(withIdentifier: "EnterNewBuyerLocationVC") as! EnterNewBuyerLocationViewController
            newAddressVC.newLocationDelegate = self
            shippingCheckIndex = 0
            selectedAddress = [:]            
            self.navigationController?.pushViewController(newAddressVC, animated: true)
        } else {
            
            let location = StoreLocation.init(dict: arrAddress[indexPath.row])
            self.localLocation = location
            
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
