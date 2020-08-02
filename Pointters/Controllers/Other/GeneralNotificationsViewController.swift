//
//  GeneralNotificationsViewController.swift
//  Pointters
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol GeneralNotificationsDelegate {
    func selectNotifications(selected : Int)
}

class GeneralNotificationsViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var imgCheckPush: UIImageView!
    @IBOutlet var imgCheckEmail: UIImageView!
    @IBOutlet weak var lblItemPush: UILabel!
    @IBOutlet weak var lblItemEmail: UILabel!
    
    var generalDelegate: GeneralNotificationsDelegate?
    var generalType: Int?
    var generalItem: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        lblDesc.text = kNotificationDescriptions[generalType!-1]
        if generalType != 4 {
            lblItemPush.text = kNotificationItems.kNotificationPush
            lblItemEmail.text = kNotificationItems.kNotificationEmail
        } else {
            lblItemPush.text = kSummaryEmailItems.kSummaryEmailDaily
            lblItemEmail.text = kSummaryEmailItems.kSummaryEmailWeekly
        }
        setGeneralItems(item: generalItem!)
    }
    
    func setGeneralItems(item: Int) {
        if item == 0 {
            imgCheckPush.image = UIImage(named: "icon-checkbox-normal")
            imgCheckEmail.image = UIImage(named: "icon-checkbox-normal")
        } else if item == 1 {
            imgCheckPush.image = UIImage(named: "icon-checkbox-select")
            imgCheckEmail.image = UIImage(named: "icon-checkbox-normal")
        } else if item == 2 {
            imgCheckPush.image = UIImage(named: "icon-checkbox-normal")
            imgCheckEmail.image = UIImage(named: "icon-checkbox-select")
        } else {
            imgCheckPush.image = UIImage(named: "icon-checkbox-select")
            imgCheckEmail.image = UIImage(named: "icon-checkbox-select")
        }
    }

    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        if generalDelegate != nil {
            generalDelegate?.selectNotifications(selected: generalItem!)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnPushTapped(_ sender: Any) {
        if generalItem == 0 {
            generalItem = 1
        } else if generalItem == 1 {
            generalItem = 0
        } else if generalItem == 2 {
            generalItem = 3
        } else {
            generalItem = 2
        }
        setGeneralItems(item: generalItem!)
    }
    
    @IBAction func btnEmailTapped(_ sender: Any) {
        if generalItem == 0 {
            generalItem = 2
        } else if generalItem == 1 {
            generalItem = 3
        } else if generalItem == 2 {
            generalItem = 0
        } else {
            generalItem = 1
        }
        setGeneralItems(item: generalItem!)
    }
}
