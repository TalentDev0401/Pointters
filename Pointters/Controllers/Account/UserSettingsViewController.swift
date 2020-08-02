//
//  UserSettingsViewController.swift
//  Pointters
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class UserSettingsViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblPhone: UILabel!
    
    var settingType = 0
    
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
    
    func moveToSubSettings(type: Int, item: Int) {
        let subSettingsVC = storyboard?.instantiateViewController(withIdentifier: "UserSubSettingsVC") as! UserSubSettingsViewController
        subSettingsVC.subSettingsDelegate = self
        subSettingsVC.subSettingsType = type
        subSettingsVC.subSettingsItem = item
        navigationController?.pushViewController(subSettingsVC, animated: true)
    }

    func getItemFromTitle(type: Int) -> Int {
        var nItem = 0
        let str = (type == 1) ? lblLocation.text : lblPhone.text
        
        switch str! {
            case kUserSettingsItems.kUserPublic:
                nItem = 1
                break
            case kUserSettingsItems.kUserFollowers:
                nItem = 2
                break
            case kUserSettingsItems.kUserOnlyMe:
                nItem = 3
                break
            default:
                break
        }

        return nItem
    }
    
    func setUserSettingsText(settingDic : [String:Any]){
        let locationViewPermission : String = settingDic["locationViewPermission"] as! String
        let phoneViewPermission : String = settingDic["phoneViewPermission"] as! String
        
        if locationViewPermission == "public" {
            lblLocation.text = kUserSettingsItems.kUserPublic
        } else if locationViewPermission == "followers" {
            lblLocation.text = kUserSettingsItems.kUserFollowers
        } else {
            lblLocation.text = kUserSettingsItems.kUserOnlyMe
        }
        
        if phoneViewPermission == "public" {
            lblPhone.text = kUserSettingsItems.kUserPublic
        } else if phoneViewPermission == "followers" {
            lblPhone.text = kUserSettingsItems.kUserFollowers
        } else {
            lblPhone.text = kUserSettingsItems.kUserOnlyMe
        }
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLocationTapped(_ sender: Any) {
        settingType = 1
        moveToSubSettings(type: settingType, item: getItemFromTitle(type: settingType))
    }
    
    @IBAction func btnPhoneTapped(_ sender: Any) {
        settingType = 2
        moveToSubSettings(type: settingType, item: getItemFromTitle(type: settingType))
    }
    
    //*******************************************************//
    //              MARK: - Call API Methods                 //
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
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callUpdateUserSettings(dict: dict, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    print("success")
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

// UserSubSettingsDelegate
extension UserSettingsViewController: UserSubSettingsDelegate {
    func selectSettings(selected: Int) {
        var strOption = ""
        if selected == 1 {
            strOption = kUserSettingsItems.kUserPublic
        } else if selected == 2 {
            strOption = kUserSettingsItems.kUserFollowers
        } else {
            strOption = kUserSettingsItems.kUserOnlyMe
        }
        
        switch settingType {
            case 1:
                lblLocation.text = strOption
                break
            case 2:
                lblPhone.text = strOption
                break
            default:
                break
        }
        
        var dict = [String:Any]()
        let locationViewPermission : String
        let phoneViewPermission : String
        
        if lblLocation.text == kUserSettingsItems.kUserPublic {
            locationViewPermission = "public"
        } else if lblLocation.text == kUserSettingsItems.kUserFollowers {
            locationViewPermission = "followers"
        } else {
            locationViewPermission = "onlyme"
        }
        
        if lblPhone.text == kUserSettingsItems.kUserPublic {
            phoneViewPermission = "public"
        } else if lblPhone.text == kUserSettingsItems.kUserFollowers {
            phoneViewPermission = "followers"
        } else {
            phoneViewPermission = "onlyme"
        }
        
        dict["locationViewPermission"] = locationViewPermission
        dict["phoneViewPermission"] = phoneViewPermission
        self.callSaveUserSettingsAPI(dict : dict)
    }
}
