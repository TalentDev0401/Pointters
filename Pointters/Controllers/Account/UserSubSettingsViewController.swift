//
//  UserSubSettingsViewController.swift
//  Pointters
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol UserSubSettingsDelegate {
    func selectSettings(selected : Int)
}

class UserSubSettingsViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var lblMenuTitle: UILabel!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var imgCheckPublic: UIImageView!
    @IBOutlet var imgCheckFollowers: UIImageView!
    @IBOutlet var imgCheckPrivate: UIImageView!
    
    var subSettingsDelegate: UserSubSettingsDelegate?
    var subSettingsType: Int?
    var subSettingsItem: Int?
    
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
        
        lblMenuTitle.text = kUserSettingsTitles[subSettingsType!-1][0]
        lblDesc.text = kUserSettingsTitles[subSettingsType!-1][1]
  
        setSettingItems(item: subSettingsItem!)
    }
    
    func setSettingItems(item: Int) {
        if item == 1 {
            imgCheckPublic.image = UIImage(named: "icon-checkbox-select")
            imgCheckFollowers.image = UIImage(named: "icon-checkbox-normal")
            imgCheckPrivate.image = UIImage(named: "icon-checkbox-normal")
        } else if item == 2 {
            imgCheckPublic.image = UIImage(named: "icon-checkbox-normal")
            imgCheckFollowers.image = UIImage(named: "icon-checkbox-select")
            imgCheckPrivate.image = UIImage(named: "icon-checkbox-normal")
        } else {
            imgCheckPublic.image = UIImage(named: "icon-checkbox-normal")
            imgCheckFollowers.image = UIImage(named: "icon-checkbox-normal")
            imgCheckPrivate.image = UIImage(named: "icon-checkbox-select")
        }
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        if subSettingsDelegate != nil {
            subSettingsDelegate?.selectSettings(selected: subSettingsItem!)
            navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func btnPublicTapped(_ sender: Any) {
        subSettingsItem = 1
        setSettingItems(item: subSettingsItem!)
    }
    
    @IBAction func btnFollowersTapped(_ sender: Any) {
        subSettingsItem = 2
        setSettingItems(item: subSettingsItem!)
    }
    
    @IBAction func btnPrivateTapped(_ sender: Any) {
        subSettingsItem = 3
        setSettingItems(item: subSettingsItem!)

    }
}
