//
//  OrderMilestoneViewController.swift
//  Pointters
//
//  Created by super on 5/23/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class OrderMilestoneViewController: UIViewController {
    
    @IBOutlet weak var lblOrderStatus: UILabel!
    @IBOutlet weak var lblPaid: UILabel!
    @IBOutlet weak var lblScheduled: UILabel!
    @IBOutlet weak var lblStarted: UILabel!
    @IBOutlet weak var lblCompleted: UILabel!
    @IBOutlet weak var lblAcceptance: UILabel!
    @IBOutlet weak var consNavViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ivPaid: UIImageView!
    @IBOutlet weak var ivScheduled: UIImageView!
    @IBOutlet weak var ivStarted: UIImageView!
    @IBOutlet weak var ivCompleted: UIImageView!
    @IBOutlet weak var ivAcceptance: UIImageView!
    @IBOutlet weak var lblPaidDate: UILabel!
    @IBOutlet weak var lblScheduleDate: UILabel!
    @IBOutlet weak var lblStartedDate: UILabel!
    @IBOutlet weak var lblCompletedDate: UILabel!
    @IBOutlet weak var lblAcceptanceDate: UILabel!
    @IBOutlet weak var progressView1: UIView!
    @IBOutlet weak var progressView2: UIView!
    @IBOutlet weak var progressView3: UIView!
    @IBOutlet weak var progressView4: UIView!
    
    var currentAction = ""
    
    var orderStatus = OrderStatus.init()
    var orderFulfillment = OrderFulfillment.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI(){
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavViewHeight.constant = 85.0
        } else {
            consNavViewHeight.constant = 64.0
        }
        if !self.orderFulfillment.fulfillmentMethod.online {
            self.lblPaid.text = "Scheduled"
            self.lblScheduled.text = "Paid"
        }
        setView()
    }
    
    func setView() {
        self.lblOrderStatus.text = orderFulfillment.statusDescription
        if self.orderFulfillment.fulfillmentMethod.online {
            
            //        if orderStatus.paid {
            
            if self.orderFulfillment.paymentDate != ""{
                lblPaid.textColor = getBlueColor()
                lblPaidDate.isHidden = false
                lblPaidDate.text = getConvertDateFormat(fromString: orderFulfillment.paymentDate)
                ivPaid.image = UIImage(named: "icon-radio-check")
            }
            if self.currentAction == kOrderActions.kScheduled_Seller || self.orderFulfillment.sellerAcceptedScheduleTime{
                lblPaid.textColor = UIColor.black
                lblPaidDate.isHidden = false
                lblPaidDate.text = getConvertDateFormat(fromString: orderFulfillment.paymentDate)
                ivPaid.image = UIImage(named: "icon-radio-check")
                
                lblScheduled.textColor = getBlueColor()
                lblScheduleDate.isHidden = false
                lblScheduleDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceScheduleDate)
                ivScheduled.image = UIImage(named: "icon-radio-select")
                progressView1.backgroundColor = getBlueColor()
            }
            if self.currentAction == kOrderActions.kStart_Seller || self.orderFulfillment.serviceStartDate != ""{
                lblPaid.textColor = UIColor.black
                lblPaidDate.isHidden = false
                lblPaidDate.text = getConvertDateFormat(fromString: orderFulfillment.paymentDate)
                ivPaid.image = UIImage(named: "icon-radio-check")
                lblScheduled.textColor = UIColor.black
                lblScheduleDate.isHidden = false
                lblScheduleDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceScheduleDate)
                ivScheduled.image = UIImage(named: "icon-radio-check")
                lblStarted.textColor = getBlueColor()
                lblStartedDate.isHidden = false
                lblStartedDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceStartDate)
                ivStarted.image = UIImage(named: "icon-radio-select")
                progressView1.backgroundColor = getBlueColor()
                progressView2.backgroundColor = getBlueColor()
            }
            if self.currentAction == kOrderActions.kComplete_Buyer || self.orderFulfillment.serviceCompleteDate != ""{
                lblPaid.textColor = UIColor.black
                lblPaidDate.isHidden = false
                lblPaidDate.text = getConvertDateFormat(fromString: orderFulfillment.paymentDate)
                ivPaid.image = UIImage(named: "icon-radio-check")
                lblScheduled.textColor = UIColor.black
                lblScheduleDate.isHidden = false
                lblScheduleDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceScheduleDate)
                ivScheduled.image = UIImage(named: "icon-radio-check")
                lblStarted.textColor = UIColor.black
                lblStartedDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceStartDate)
                lblStartedDate.isHidden = false
                ivStarted.image = UIImage(named: "icon-radio-check")
                lblCompleted.textColor = getBlueColor()
                lblCompletedDate.isHidden = false
                lblCompletedDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceCompleteDate)
                ivCompleted.image = UIImage(named: "icon-radio-select")
                progressView1.backgroundColor = getBlueColor()
                progressView2.backgroundColor = getBlueColor()
                progressView3.backgroundColor = getBlueColor()
            }
            if self.orderFulfillment.orderAcceptanceDate != "" {
                lblPaid.textColor = UIColor.black
                lblPaidDate.isHidden = false
                lblPaidDate.text = getConvertDateFormat(fromString: orderFulfillment.paymentDate)
                ivPaid.image = UIImage(named: "icon-radio-check")
                lblScheduled.textColor = UIColor.black
                lblScheduleDate.isHidden = false
                lblScheduleDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceScheduleDate)
                ivScheduled.image = UIImage(named: "icon-radio-check")
                lblStarted.textColor = UIColor.black
                lblStartedDate.isHidden = false
                lblStartedDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceStartDate)
                ivStarted.image = UIImage(named: "icon-radio-check")
                lblCompleted.textColor = UIColor.black
                lblCompletedDate.isHidden = false
                lblCompletedDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceCompleteDate)
                ivCompleted.image = UIImage(named: "icon-radio-check")
                lblAcceptance.textColor = getBlueColor()
                lblAcceptanceDate.isHidden = false
                ivAcceptance.image = UIImage(named: "icon-radio-check")
                lblAcceptanceDate.text = getConvertDateFormat(fromString: orderFulfillment.orderAcceptanceDate)
                progressView1.backgroundColor = getBlueColor()
                progressView2.backgroundColor = getBlueColor()
                progressView3.backgroundColor = getBlueColor()
                progressView4.backgroundColor = getBlueColor()
            }
        } else {
            if self.orderFulfillment.sellerAcceptedBuyerServiceLocation && self.orderFulfillment.sellerAcceptedScheduleTime {
                lblPaid.textColor = getBlueColor()
                lblPaidDate.isHidden = false
                lblPaidDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceScheduleDate)
                ivPaid.image = UIImage(named: "icon-radio-select")
                progressView1.backgroundColor = getBlueColor()
            }
            if self.orderFulfillment.paymentDate != "" {
                lblPaid.textColor = UIColor.black
                lblPaidDate.isHidden = false
                lblPaidDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceScheduleDate)
                ivPaid.image = UIImage(named: "icon-radio-check")
                                
                lblScheduled.textColor = getBlueColor()
                lblScheduleDate.isHidden = false
                lblScheduleDate.text = getConvertDateFormat(fromString: orderFulfillment.paymentDate)
                ivScheduled.image = UIImage(named: "icon-radio-check")
                progressView1.backgroundColor = getBlueColor()
            }
            
            if self.currentAction == kOrderActions.kStart_Seller || self.orderFulfillment.serviceStartDate != "" {
                lblPaid.textColor = UIColor.black
                lblPaidDate.isHidden = false
                lblPaidDate.text = getConvertDateFormat(fromString: orderFulfillment.paymentDate)
                ivPaid.image = UIImage(named: "icon-radio-check")
                lblScheduled.textColor = UIColor.black
                lblScheduleDate.isHidden = false
                lblScheduleDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceScheduleDate)
                ivScheduled.image = UIImage(named: "icon-radio-check")
                lblStarted.textColor = getBlueColor()
                lblStartedDate.isHidden = false
                lblStartedDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceStartDate)
                ivStarted.image = UIImage(named: "icon-radio-select")
                progressView1.backgroundColor = getBlueColor()
                progressView2.backgroundColor = getBlueColor()
            }
            if self.currentAction == kOrderActions.kComplete_Buyer || self.orderFulfillment.serviceCompleteDate != "" {
                lblPaid.textColor = UIColor.black
                lblPaidDate.isHidden = false
                lblPaidDate.text = getConvertDateFormat(fromString: orderFulfillment.paymentDate)
                ivPaid.image = UIImage(named: "icon-radio-check")
                lblScheduled.textColor = UIColor.black
                lblScheduleDate.isHidden = false
                lblScheduleDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceScheduleDate)
                ivScheduled.image = UIImage(named: "icon-radio-check")
                lblStarted.textColor = UIColor.black
                lblStartedDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceStartDate)
                lblStartedDate.isHidden = false
                ivStarted.image = UIImage(named: "icon-radio-check")
                lblCompleted.textColor = getBlueColor()
                lblCompletedDate.isHidden = false
                lblCompletedDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceCompleteDate)
                ivCompleted.image = UIImage(named: "icon-radio-select")
                progressView1.backgroundColor = getBlueColor()
                progressView2.backgroundColor = getBlueColor()
                progressView3.backgroundColor = getBlueColor()
            }
            if self.orderFulfillment.orderAcceptanceDate != "" {
                lblPaid.textColor = UIColor.black
                lblPaidDate.isHidden = false
                lblPaidDate.text = getConvertDateFormat(fromString: orderFulfillment.paymentDate)
                ivPaid.image = UIImage(named: "icon-radio-check")
                lblScheduled.textColor = UIColor.black
                lblScheduleDate.isHidden = false
                lblScheduleDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceScheduleDate)
                ivScheduled.image = UIImage(named: "icon-radio-check")
                lblStarted.textColor = UIColor.black
                lblStartedDate.isHidden = false
                lblStartedDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceStartDate)
                ivStarted.image = UIImage(named: "icon-radio-check")
                lblCompleted.textColor = UIColor.black
                lblCompletedDate.isHidden = false
                lblCompletedDate.text = getConvertDateFormat(fromString: orderFulfillment.serviceCompleteDate)
                ivCompleted.image = UIImage(named: "icon-radio-check")
                lblAcceptance.textColor = getBlueColor()
                lblAcceptanceDate.isHidden = false
                ivAcceptance.image = UIImage(named: "icon-radio-check")
                lblAcceptanceDate.text = getConvertDateFormat(fromString: orderFulfillment.orderAcceptanceDate)
                progressView1.backgroundColor = getBlueColor()
                progressView2.backgroundColor = getBlueColor()
                progressView3.backgroundColor = getBlueColor()
                progressView4.backgroundColor = getBlueColor()
            }
        }
        
    }
    
    func getConvertDateFormat(fromString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var fromDate = dateFormatter.date(from:fromString)
        if fromDate == nil{
            fromDate = Date()
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: fromDate!)
    }
    
    func getBlueColor() -> UIColor {
        if #available(iOS 10.0, *) {
            return UIColor(displayP3Red: 0, green: 122/255, blue: 1, alpha: 1)
        } else {
            return UIColor(red: 0, green: 122/255, blue:1, alpha: 1)
        }
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
