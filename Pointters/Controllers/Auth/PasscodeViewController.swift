//
//  PasscodeViewController.swift
//  Pointters
//
//  Created by dreams on 12/27/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class PasscodeViewController: UIViewController {
    
    @IBOutlet var consNavBarTop: NSLayoutConstraint!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var tfPasscode: UITextField!
    
    var textPasscode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfPasscode.text = textPasscode
        self.initUI()
        self.allowSignIn()
        // Do any additional setup after loading the view.
    }

    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarTop.constant = 85.0
        } else {
            consNavBarTop.constant = 64.0
        }
        
        btnConfirm.layer.cornerRadius = 5.0
        btnConfirm.layer.masksToBounds = true
    }
    
    func allowSignIn() {
        if textPasscode != "" {
            btnConfirm.backgroundColor = UIColor.getCustomBlueColor()
            btnConfirm.isUserInteractionEnabled = true
        } else {
            btnConfirm.backgroundColor = UIColor.lightGray
            btnConfirm.isUserInteractionEnabled = false
        }
    }
    
    //MARK: -- IBAction
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callSendVerificationCode(code: textPasscode) { (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true{
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else{
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: (responseDict["message"] as? String)!, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        }
    }
    @IBAction func onClickResend(_ sender: Any) {
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callResendVerificationCode(code: textPasscode) { (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true{
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully sent a verification code to your email.", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
                else{
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: (responseDict["message"] as? String)!, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        }
    }
    
}

// UITextFieldDelegate
extension PasscodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typeCasteToStringFirst = textField.text as NSString?
        let newString = typeCasteToStringFirst?.replacingCharacters(in: range, with: string)
        
        textPasscode = newString!

        allowSignIn()
        
        return true
    }
}
