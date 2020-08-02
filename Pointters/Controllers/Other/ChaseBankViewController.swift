//
//  ChaseBankViewController.swift
//  Pointters
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ChaseBankViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var lblMenuTitle: UILabel!
    
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
        
    }
    
    
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func btnEditTapped(_ sender: Any) {
    }
}
