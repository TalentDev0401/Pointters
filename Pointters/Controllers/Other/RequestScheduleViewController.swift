
//
//  RequestScheduleViewController.swift
//  Pointters
//
//  Created by dreams on 9/17/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol RequestScheduleDelegate {
    func onSuccessRequestSchedule()
}

class RequestScheduleViewController: UIViewController {

    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var btnDone: UIButton!
    
    @IBOutlet weak var labelStartDate: UILabel!
    @IBOutlet weak var labelEndDate: UILabel!
    
    @IBOutlet weak var startPicker: UIDatePicker!
    @IBOutlet weak var endPicker: UIDatePicker!
    
    var delegate: RequestScheduleDelegate!
    var orderId = ""
    var duration = 0
    var requestedTime = ""
    
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
        self.startPicker.backgroundColor = UIColor.groupTableViewBackground
        self.endPicker.backgroundColor = UIColor.groupTableViewBackground
        self.endPicker.isHidden = true
        var request_date = Date()
        if self.requestedTime != ""{
            request_date = fromStringToDate(date: self.requestedTime)
        }
        self.startPicker.minimumDate = request_date
        self.endPicker.minimumDate = request_date
        self.endPicker.setDate(request_date.addingTimeInterval(TimeInterval(self.duration * 3600)), animated: false)
        self.labelStartDate.text = formatDate(date: request_date)
        self.labelEndDate.text = formatDate(date: request_date.addingTimeInterval(TimeInterval(self.duration * 3600)))
    }
    
    func formatDate(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy HH:mm:ss"
        return formatter.string(from: date)
    }
    
    func fromStringToDate(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: date)!
    }
    
    
    func validateDate() -> Bool{
        if startPicker.date.timeIntervalSince1970 > endPicker.date.timeIntervalSince1970{
            return false
        }
        return true
    }
    
    //MARK:- IBActions
    
    @IBAction func onChangeStart(_ sender: Any) {
        self.labelStartDate.text = formatDate(date: startPicker.date)
        self.endPicker.setDate(startPicker.date.addingTimeInterval( TimeInterval(self.duration * 3600)), animated: false)
        self.labelEndDate.text = formatDate(date: self.endPicker.date)
    }
    
    @IBAction func onChangeEnd(_ sender: Any) {
        self.labelEndDate.text = formatDate(date: endPicker.date)
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSubmit(_ sender: Any) {
        
        
        if !validateDate(){
            PointtersHelper.sharedInstance.showAlertViewWithTitle("Warning", message: "Start date must be before end date.", buttonTitles: ["OK"], viewController: self) { (type) in
            }
            return
        }
        self.callRequestChangeSchdule()
//        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- callAPI
    
    func callRequestChangeSchdule(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let startDate = dateFormatter.string(from: startPicker.date)
        let endDate = dateFormatter.string(from: endPicker.date)
        
        let params = ["serviceScheduleDate": startDate,
                      "serviceScheduleEndDate": endDate]
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.requestChangeSchedule(orderId: self.orderId, params: params) { (result, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("Success", message: "Successfully sent request.", buttonTitles: ["OK"], viewController: self) { (type) in
                        self.delegate.onSuccessRequestSchedule()
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                print(response.error ?? "get order fulfillment failure")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
