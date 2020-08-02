//
//  ShippingRateViewController.swift
//  Pointters
//
//  Created by Dream Software on 9/9/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol ShippingRateVCDelegate {
    func selectedRate(rate : ShippingRate, address: ShippingAddress, shipment: Shipment)
}

class ShippingRateViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    var toAddress: ShippingAddress!
    var fromAddress: ShippingAddress!
    var parcel: ShipParcel!
    
    var rateDelegate: ShippingRateVCDelegate?
    
    var shipment: Shipment!
    var arrRate : [ShippingRate]!
    var selectedRate: ShippingRate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrRate = []
        self.createShipment()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //Call get shipping rates
    
    func createShipment(){
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        var shipment_dict = [String: Any]()
        shipment_dict["toAddress"] = self.toAddress.dict()
        shipment_dict["fromAddress"] = self.fromAddress.dict()
        shipment_dict["parcel"] = self.parcel.dict()
        ApiHandler.createShipment(params: shipment_dict) { (result, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                self.shipment = Shipment.init(dict: responseDict)
                if statusCode == 200 {
                    self.shipment = Shipment.init(dict: responseDict["shipmentSaved"] as! [String: Any])
                    for itemAddress in self.shipment.rates {
                        self.arrRate.append(ShippingRate.init(dict: itemAddress))
                    }
                    self.tableView.reloadData()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        }
    }
    func backToCheckout(){
        let viewControllers = self.navigationController?.viewControllers
        self.rateDelegate?.selectedRate(rate: self.selectedRate, address: self.toAddress, shipment: self.shipment)
        self.navigationController?.popToViewController(viewControllers![(viewControllers?.count)! - 3 ], animated: true)
    }
}

//MARK:- tableview datasource

extension ShippingRateViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shippingRateCell") as! ShippingRateCell
        let rateItem = self.arrRate[indexPath.row]
        cell.lblTitle.text = "\(rateItem.dict()["service"] as! String) \(rateItem.dict()["carrier"] as! String)"
        cell.lblPrice.text = "$\(rateItem.dict()["rate"] as! String)"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        let headerLabel = UILabel(frame: CGRect(x: 13, y: 25, width: tableView.bounds.size.width - 30, height: 20))
        headerLabel.font = UIFont(name: "Helvetica", size: 14)
        headerLabel.textColor = UIColor.getCustomGrayTextColor()
        headerLabel.text = "SELECT A SHIPPING RATE"
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRate.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

//MARK:- tableview delegate

extension ShippingRateViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var params = [String : Any]()
        params["selectedRate"] = arrRate[indexPath.row].dict()
        self.selectedRate = arrRate[indexPath.row]
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.selectShippingRate(shipmentId: shipment.id, params: params) { (result, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    self.shipment = Shipment.init(dict: response.value as! [String : Any])
                    self.backToCheckout()
                }
            }
        }
        

    }
}
