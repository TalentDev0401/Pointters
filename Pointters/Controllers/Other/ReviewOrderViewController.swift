//
//  ReviewOrderViewController.swift
//  Pointters
//
//  Created by dreams on 9/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol ReviewOrderDelegate {
    func onSuccess()
}

class ReviewOrderViewController: UIViewController {

    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var tableView: TPKeyboardAvoidingTableView!
    
    var delegate: ReviewOrderDelegate!
    
    var serviceId = ""
    var orderId = ""
    var sellerId = ""
    
    var message = ""
    
    var quality = 5
    var rating = 100
    var willingToBuyServiceAgain = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        // Do any additional setup after loading the view.
    }
    
    func initUI(){
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        self.tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.allowsSelection = false
        validateSubmit()
    }
    
    func validateSubmit(){
        if self.message == ""{
            self.btnDone.isEnabled = false
        }else{
            self.btnDone.isEnabled = true
        }
    }
    
    //MARK:- IBActions
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSubmitClicked(_ sender: Any) {
        self.callPostReview()
    }
    
    //MARK:- API call
    
    func callPostReview(){
        var params = [String : Any]()
        params["comment"] = self.message
        params["overallRating"] = self.rating
        params["qualityOfService"] = self.quality
        params["willingToBuyServiceAgain"] = self.willingToBuyServiceAgain
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callPostReviews(orderId: self.orderId, param: params) { (result, statusCode, response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Review submitted successfully.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                        self.delegate.onSuccess()
                        self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
                print(response.error ?? "post review order failed")
            }
        }
    }
}

extension ReviewOrderViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write comments here."
            textView.textColor = UIColor.lightGray
            self.message = ""
            validateSubmit()
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        self.message = textView.text
        validateSubmit()
    }
    
    @objc func qualityChanged(_ sender: UISlider){
        let step: Float = 1
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        self.quality = Int(roundedValue)
    }
    
    @objc func ratingChanged(_ sender: UISlider){
        let step: Float = 1
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        self.rating = Int(roundedValue)
    }
    
    @objc func againChanged(_ sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0{
            self.willingToBuyServiceAgain = 1
        }else{
            self.willingToBuyServiceAgain = 0
        }
    }
}

extension ReviewOrderViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "qualityCell") as! ReviewOrderCell
            cell.qualitySlider.value = 5.0
            cell.qualitySlider.addTarget(self, action: #selector(self.qualityChanged(_:)), for: .valueChanged)
            return cell
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ratingCell") as! ReviewOrderCell
            cell.ratingSlider.value = 100.0
            cell.ratingSlider.addTarget(self, action: #selector(self.ratingChanged(_:)), for: .valueChanged)
            return cell
        }else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "againCell") as! ReviewOrderCell
            cell.againSwitch.selectedSegmentIndex = 0
            cell.againSwitch.addTarget(self, action: #selector(self.againChanged(_:)), for: .valueChanged)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! ReviewOrderCell
            cell.textViewMessage.delegate = self
            cell.textViewMessage.text = "Enter your feedback here"
            cell.textViewMessage.textColor = UIColor.lightGray
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
            headerLabel.text = "COMPLETE REVIEW ON ORDER"
        case 3:
            headerLabel.text = "COMMENT"
        default: break
        }
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 || section == 2{
            return 20
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension ReviewOrderViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
