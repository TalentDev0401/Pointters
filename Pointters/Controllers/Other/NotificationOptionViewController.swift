//
//  NotificationOptionViewController.swift
//  Pointters
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class NotificationOptionViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var lblGeneralNotes: UILabel!
    @IBOutlet var lblOrderNotes: UILabel!
    @IBOutlet var lblOfferNotes: UILabel!
    @IBOutlet var lblEmailStatus: UILabel!
    
    var notificationType = 0
    
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
        callGetUserSettingsAPI()
    }
    
    func setUserSettingsText(settingDic : [String:Any]){
        let generalNotifications : String = settingDic["generalNotifications"] as! String
        let orderNotifications : String = settingDic["orderNotifications"] as! String
        let offerNotifications : String = settingDic["offerNotifications"] as! String
        let summaryEmail : String = settingDic["summaryEmail"] as! String
        
        if generalNotifications == "pushNotification" {
            lblGeneralNotes.text = kNotificationItems.kNotificationPush
        } else if generalNotifications == "email" {
            lblGeneralNotes.text = kNotificationItems.kNotificationEmail
        } else if generalNotifications == "all" {
            lblGeneralNotes.text = kNotificationItems.kNotificationAll
        } else {
            lblGeneralNotes.text = kNotificationItems.kNotificationNone
        }
        
        if orderNotifications == "pushNotification" {
            lblOrderNotes.text = kNotificationItems.kNotificationPush
        } else if orderNotifications == "email" {
            lblOrderNotes.text = kNotificationItems.kNotificationEmail
        } else if orderNotifications == "all" {
            lblOrderNotes.text = kNotificationItems.kNotificationAll
        } else {
            lblOrderNotes.text = kNotificationItems.kNotificationNone
        }
        
        if offerNotifications == "pushNotification" {
            lblOfferNotes.text = kNotificationItems.kNotificationPush
        } else if offerNotifications == "email" {
            lblOfferNotes.text = kNotificationItems.kNotificationEmail
        } else if offerNotifications == "all" {
            lblOfferNotes.text = kNotificationItems.kNotificationAll
        } else {
            lblOfferNotes.text = kNotificationItems.kNotificationNone
        }
        
        if summaryEmail == "daily" {
            lblEmailStatus.text = kSummaryEmailItems.kSummaryEmailDaily
        } else if summaryEmail == "weekly" {
            lblEmailStatus.text = kSummaryEmailItems.kSummaryEmailWeekly
        } else if summaryEmail == "all" {
            lblEmailStatus.text = kSummaryEmailItems.kSummaryEmailAll
        } else {
            lblEmailStatus.text = kSummaryEmailItems.kSummaryEmailNone
        }
    }
    
    func moveToGeneralNotifications(type: Int, item: Int) {
        let generalVC = storyboard?.instantiateViewController(withIdentifier: "GeneralNotificationsVC") as! GeneralNotificationsViewController
        generalVC.generalDelegate = self
        generalVC.generalType = type
        generalVC.generalItem = item
        navigationController?.pushViewController(generalVC, animated: true)
    }

    
    
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnGeneralTapped(_ sender: Any) {
        notificationType = 1
        let nItem : Int
        if lblGeneralNotes.text ==  kNotificationItems.kNotificationNone{
            nItem = 0
        }else if lblGeneralNotes.text ==  kNotificationItems.kNotificationPush {
            nItem = 1
        }else if lblGeneralNotes.text ==  kNotificationItems.kNotificationEmail {
            nItem = 2
        }else{
            nItem = 3
        }
        moveToGeneralNotifications(type: notificationType, item: nItem)
    }

    @IBAction func btnOrderTapped(_ sender: Any) {
        notificationType = 2
        let nItem : Int
        if lblOrderNotes.text ==  kNotificationItems.kNotificationNone{
            nItem = 0
        }else if lblOrderNotes.text ==  kNotificationItems.kNotificationPush {
            nItem = 1
        }else if lblOrderNotes.text ==  kNotificationItems.kNotificationEmail {
            nItem = 2
        }else{
            nItem = 3
        }
        moveToGeneralNotifications(type: notificationType, item: nItem)
    }
    
    @IBAction func btnOfferTapped(_ sender: Any) {
        notificationType = 3
        let nItem : Int
        if lblOfferNotes.text ==  kNotificationItems.kNotificationNone{
            nItem = 0
        }else if lblOfferNotes.text ==  kNotificationItems.kNotificationPush {
            nItem = 1
        }else if lblOfferNotes.text ==  kNotificationItems.kNotificationEmail {
            nItem = 2
        }else{
            nItem = 3
        }
        moveToGeneralNotifications(type: notificationType, item: nItem)
    }
    
    @IBAction func btnEmailTapped(_ sender: Any) {
        notificationType = 4
        let nItem : Int
        if lblEmailStatus.text ==  kSummaryEmailItems.kSummaryEmailNone{
            nItem = 0
        }else if lblEmailStatus.text ==  kSummaryEmailItems.kSummaryEmailDaily {
            nItem = 1
        }else if lblEmailStatus.text ==  kSummaryEmailItems.kSummaryEmailWeekly {
            nItem = 2
        }else{
            nItem = 3
        }
        moveToGeneralNotifications(type: notificationType, item: nItem)
    }
    
    //*******************************************************//
    //                 MARK: - Call API Method               //
    //*******************************************************//
    
    func callGetUserSettingsAPI(){
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetUserSettings(withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.setUserSettingsText(settingDic : responseDict)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        })
    }
    
    func callSaveUserSettingsAPI(dict : [String:Any]){
        print(dict)
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callUpdateUserSettings(dict: dict, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    print("success saving settings")
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Can't save user settings!", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                print(response.error ?? "save settings failure")
            }
        })
    }
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// GeneralNotificationsDelegate
extension NotificationOptionViewController: GeneralNotificationsDelegate {
    func selectNotifications(selected: Int) {
        let strOption : String
        if(notificationType != 4){
            if selected == 0 {
                strOption = kNotificationItems.kNotificationNone
            } else if selected == 1 {
                strOption = kNotificationItems.kNotificationPush
            } else if selected == 2 {
                strOption = kNotificationItems.kNotificationEmail
            } else {
                strOption = kNotificationItems.kNotificationAll
            }
            
            switch notificationType {
            case 1:
                lblGeneralNotes.text = strOption
                break
            case 2:
                lblOrderNotes.text = strOption
                break
            case 3:
                lblOfferNotes.text = strOption
                break
            default:
                break
            }
        }else{
            if selected == 0 {
                strOption = kSummaryEmailItems.kSummaryEmailNone
            } else if selected == 1 {
                strOption = kSummaryEmailItems.kSummaryEmailDaily
            } else if selected == 2 {
                strOption = kSummaryEmailItems.kSummaryEmailWeekly
            } else {
                strOption = kSummaryEmailItems.kSummaryEmailAll
            }
            lblEmailStatus.text = strOption
        }
        var dict = [String:Any]()
        let generalNotifications : String
        let orderNotifications : String
        let offerNotifications : String
        let summaryEmail : String
        if lblGeneralNotes.text == kNotificationItems.kNotificationPush {
            generalNotifications = "pushNotification"
        } else if lblGeneralNotes.text == kNotificationItems.kNotificationEmail {
            generalNotifications = "email"
        } else if lblGeneralNotes.text == kNotificationItems.kNotificationAll {
            generalNotifications = "all"
        } else {
            generalNotifications = "none"
        }
        
        if lblOrderNotes.text == kNotificationItems.kNotificationPush {
            orderNotifications = "pushNotification"
        } else if lblOrderNotes.text == kNotificationItems.kNotificationEmail {
            orderNotifications = "email"
        } else if lblOrderNotes.text == kNotificationItems.kNotificationAll {
            orderNotifications = "all"
        } else {
            orderNotifications = "none"
        }
        
        if lblOfferNotes.text == kNotificationItems.kNotificationPush {
            offerNotifications = "pushNotification"
        } else if lblOfferNotes.text == kNotificationItems.kNotificationEmail {
            offerNotifications = "email"
        } else if lblOfferNotes.text == kNotificationItems.kNotificationAll {
            offerNotifications = "all"
        } else {
            offerNotifications = "none"
        }
        
        if lblEmailStatus.text == kSummaryEmailItems.kSummaryEmailDaily {
            summaryEmail = "daily"
        } else if lblEmailStatus.text == kSummaryEmailItems.kSummaryEmailWeekly {
            summaryEmail = "weekly"
        } else if lblEmailStatus.text == kSummaryEmailItems.kSummaryEmailAll {
            summaryEmail = "all"
        } else {
            summaryEmail = "none"
        }
        dict["generalNotifications"] = generalNotifications
        dict["orderNotifications"] = orderNotifications
        dict["offerNotifications"] = offerNotifications
        dict["summaryEmail"] = summaryEmail
        
        self.callSaveUserSettingsAPI(dict : dict)
    }
}
