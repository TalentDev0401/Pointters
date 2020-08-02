//
//  CancelOrderViewController.swift
//  Pointters
//
//  Created by Dream Software on 9/14/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol CancelOrderDelegate {
    func onSuccessCancelOrder(description: String)
    func onSuccessApproveCancel(description: String, newAction: ActionButton)
}

class CancelOrderViewController: UIViewController {

    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var tableView: TPKeyboardAvoidingTableView!
    
    var orderId = "'"
    var message = ""
    var selectedReasonIndex = [false, false, false]
    var isSeller = false
    
    var isForApprove = false
    var cancelReason = BuyerOrderDispute.init()
    
    var delegate: CancelOrderDelegate!
    
    let reasonArray = [
        "Did not completed on time",
        "Poor quality of service",
        "Other"
    ]
    
    let reasonValue = [
        "not_on_time",
        "poor_quality_of_service",
        "other"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isForApprove{
            let reasonIndex = reasonValue.index(of: cancelReason.reason)
            self.selectedReasonIndex[reasonIndex!] = true
            self.message = cancelReason.message
            self.tableView.reloadData()
            validateSubmit()
        }
    }
    
    func initUI(){
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        if isForApprove{
            pageTitle.text = "Approve Cancel"
            btnDone.setTitle("Approve", for: .normal)
            self.tableView.isUserInteractionEnabled = false
        }
        self.tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        validateSubmit()
    }
    
    func validateSubmit(){
        if (self.selectedReasonIndex[0] || self.selectedReasonIndex[1] || self.selectedReasonIndex[2]){
            if self.message == ""{
                self.btnDone.isEnabled = false
            }else{
                self.btnDone.isEnabled = true
            }
        }else{
            self.btnDone.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- IBActions
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSubmitClicked(_ sender: Any) {
        if self.isForApprove{
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Are you sure to approve this cancel request?", buttonTitles: ["Yes", "No"], viewController: self) { (type) in
                if type == 0 {
                    self.callApproveCancelOrder()
                } else {
                    return
                }
            }
            
        }else{
            self.callRequestCancelOrder()
        }
    }
    
    //MARK:- API call
    
    func callRequestCancelOrder(){
        var reason = ""
        for index in 0...self.selectedReasonIndex.count-1{
            if self.selectedReasonIndex[index]{
                reason = self.reasonValue[index]
            }
        }
        var params = [String: Any]()
        params["buyerOrderDispute"] = [
            "reason": reason,
            "message": self.message
        ]
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.requestCancelOrder(orderId: self.orderId, params: params) { (result, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! NSDictionary
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("Success", message:"Successfully sent order cancel request.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                        var description = ""
                        if let _ = responseDict.value(forKey: "statusDescription"){
                            description = responseDict.value(forKey: "statusDescription") as! String
                        }
                        if self.delegate != nil{
                            self.delegate.onSuccessCancelOrder(description: description)
                        }
                        self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                print(response.error ?? "get order fulfillment failure")
            }
        }
    }
    
    func callApproveCancelOrder(){
        
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.approveCancelOrder(orderId: self.orderId) { (result, statusCode, response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! NSDictionary
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("Success", message:"Successfully approved order cancel request.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                        var description = ""
                        var newAction = ActionButton.init()
                        if let _ = responseDict.value(forKey: "statusDescription"){
                            description = responseDict.value(forKey: "statusDescription") as! String
                        }
                        if let _ = responseDict.value(forKey: "actionButton"){
                            newAction = ActionButton.init(dict: responseDict.value(forKey: "actionButton") as! [String: Any])
                        }
                        if self.delegate != nil{
                            self.delegate.onSuccessApproveCancel(description: description, newAction: newAction)
                        }
                        self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        }
    }
}

extension CancelOrderViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Reason for cancel order"
            textView.textColor = UIColor.lightGray
            self.message = ""
            validateSubmit()
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        self.message = textView.text
        validateSubmit()
    }
}

extension CancelOrderViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 0
        }else if section == 1{
            return self.reasonArray.count
        }else{
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "reasonCell") as! CancelOrderCell
            cell.labelReason.text = self.reasonArray[indexPath.row]
            if self.selectedReasonIndex[indexPath.row]{
                cell.imageCheck.image = UIImage(named: "icon-checkbox-select")
            }else{
                cell.imageCheck.image = UIImage(named: "icon-checkbox-normal")
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "reasonMessageCell") as! CancelOrderCell
            cell.textViewMessage.delegate = self
            if isForApprove{
                cell.textViewMessage.text = self.cancelReason.message
            }else{
                cell.textViewMessage.textColor = UIColor.lightGray
                cell.textViewMessage.text = "Reason for cancel order"
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 20, width: tableView.bounds.size.width / 2, height: 20))
        headerLabel.font = UIFont(name: "Helvetica", size: 14)
        headerLabel.textColor = UIColor.getCustomGrayTextColor()
        switch section {
        case 0:
            headerLabel.text = self.isSeller ? "Request Buyer to Cancel Order" : "Request Seller to Cancel Order"
        case 1:
            headerLabel.text = "REASON TO CANCEL ORDER"
        case 2:
            let fromUser = self.isForApprove ? "FROM" : "TO"
            headerLabel.text = self.isSeller ? "MESSAGE \(fromUser) BUYER" : "MESSAGE \(fromUser) SELLER"
        default: break
        }
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.isForApprove{
            return 0
        }else{
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 0
        }else if indexPath.section == 1{
            if isSeller{
                if indexPath.row == 0 || indexPath.row == 1{
                    return 0
                }
            }
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 0
        }else {
            return UITableViewAutomaticDimension
        }
    }
}

extension CancelOrderViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            
            let currentCell = tableView.cellForRow(at: indexPath) as! CancelOrderCell
            self.selectedReasonIndex = [false, false, false]
            currentCell.imageCheck.image = UIImage(named: "icon-checkbox-select")
            self.selectedReasonIndex[indexPath.row] = true
            currentCell.setSelected(false, animated: true)
        }
        self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        
        UIView.transition(with: self.view,
                          duration:1.0,
                          options: .transitionCrossDissolve,
                          animations: { self.validateSubmit() },
                          completion: nil)
        
    }
}
