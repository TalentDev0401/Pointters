//
//  RadiusSettingViewController.swift
//  Pointters
//
//  Created by super on 4/8/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol SettingRadiusDelegate {
    func updateRadius(radius:Int)
    func cancelRadius()
}

class RadiusSettingViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var tfRadius: UITextField!
    @IBOutlet weak var btnDone: UIButton!
    
    var radiusDelegate: SettingRadiusDelegate?
    var radius = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI(){
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        btnDone.isUserInteractionEnabled = false
        btnDone.alpha = 0.3
        if (radius != 0) {
            tfRadius.text = "\(radius)"
            btnDone.isUserInteractionEnabled = true
            btnDone.alpha = 1.0
        }
        addToolBar()
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackPressed(_ sender: Any) {
        tfRadius.resignFirstResponder()
        if radiusDelegate != nil {
            radiusDelegate?.cancelRadius()
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneClicked(_ sender: Any) {
        tfRadius.resignFirstResponder()
        radius = Int(tfRadius.text!)!
        if radiusDelegate != nil {
            radiusDelegate?.updateRadius(radius: radius)
        }
        navigationController?.popViewController(animated: true)
    }
    
}

extension RadiusSettingViewController : UITextFieldDelegate{
    func addToolBar() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.backgroundColor = UIColor.getCustomGrayColor()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.donePressed))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        tfRadius.inputAccessoryView = toolBar
    }
    
    @objc func donePressed() {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typeCasteToStringFirst = textField.text as NSString?
        let newString = typeCasteToStringFirst?.replacingCharacters(in: range, with: string)
        if newString != "" {
            btnDone.alpha = 1.0
            btnDone.isUserInteractionEnabled = true
        } else {
            btnDone.alpha = 0.3
            btnDone.isUserInteractionEnabled = false
        }
        return true
    }
}
