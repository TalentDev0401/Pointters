//
//  HowPaidViewController.swift
//  Pointters
//
//  Created by dreams on 12/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import ActiveLabel

class HowPaidViewController: UIViewController {
    
    @IBOutlet weak var labelLinkInfo: ActiveLabel!
    @IBOutlet weak var cons_labelLinkInfo: NSLayoutConstraint!
    @IBOutlet weak var textview_requirement: UITextView!
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet weak var btnGetPaid: UIButton!
    @IBOutlet weak var btnTransaction: UIButton!
    @IBOutlet weak var transactionlbl: UILabel!
    
    var user_NG: Bool = true
    var paypal_email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelLinkInfo.URLColor = UIColor.getCustomLightBlueColor()
        labelLinkInfo.lineSpacing = 5
        labelLinkInfo.handleURLTap { (url) in
            UIApplication.shared.open(url)
        }
        self.initUI()
    }
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        self.btnGetPaid.layer.cornerRadius = 5
        self.btnGetPaid.layer.masksToBounds = true
        
        if !self.user_NG {
            self.cons_labelLinkInfo.constant = 0
            self.textview_requirement.text = paypal_email
            self.textview_requirement.textAlignment = .center
            self.textview_requirement.font = UIFont.systemFont(ofSize: 25.0)
            self.transactionlbl.isHidden = true
            self.btnTransaction.isHidden = true
            self.btnGetPaid.setTitle("Setup Paypal", for: .normal)
        }
    }
    
    //MARK: IBActions
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickGetPaid(_ sender: Any) {
        if self.user_NG {
            let paymentMethodVC = self.storyboard?.instantiateViewController(withIdentifier: "GetPaidVC") as! GetPaidViewController
            paymentMethodVC.fromGuide = true
            navigationController?.pushViewController(paymentMethodVC, animated: true)
        } else {
            
        }
    }
    
    @IBAction func onClickTransaction(_ sender: Any) {
        let transactionVC = self.storyboard?.instantiateViewController(withIdentifier: "TransactionHistoryVC") as! TransactionHistoryViewController
        transactionVC.fromGuide = true
        navigationController?.pushViewController(transactionVC, animated: true)
    }
    
}
