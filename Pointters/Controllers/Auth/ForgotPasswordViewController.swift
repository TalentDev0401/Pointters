//
//  ForgotPasswordViewController.swift
//  Pointters
//
//  Created by Mac on 2/14/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet var consNavBarTop: NSLayoutConstraint!
    @IBOutlet var tfEmail: UITextField!
    @IBOutlet var consBtnSendBottom: NSLayoutConstraint!
    @IBOutlet var btnSend: UIButton!
    
    var txtEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//

    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarTop.constant = 85.0
            consBtnSendBottom.constant = 32.0
        } else {
            consNavBarTop.constant = 64.0
            consBtnSendBottom.constant = 16.0
        }
        
        btnSend.layer.cornerRadius = 5.0
        btnSend.layer.masksToBounds = true
    }
    
    func allowSend() {
        if txtEmail != "" && PointtersHelper.sharedInstance.isValidEmail(txtEmail) {
            btnSend.backgroundColor = UIColor.getCustomBlueColor()
            btnSend.isUserInteractionEnabled = true
        } else {
            btnSend.backgroundColor = UIColor.lightGray
            btnSend.isUserInteractionEnabled = false
        }
    }
    
    func moveToResetPassword() {
        UserCache.sharedInstance.setResetEmail(emailId: txtEmail)
        let resetVC = storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordViewController
        navigationController?.pushViewController(resetVC, animated: true)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                if PointtersHelper.sharedInstance.checkiPhonX()  {
                    self.consBtnSendBottom?.constant = 32.0
                } else {
                    self.consBtnSendBottom?.constant = 16.0
                }
            } else {
                self.consBtnSendBottom?.constant = (endFrame?.size.height)! + 16.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendTapped(_ sender: Any) {
        callUserOtpApi(authEmail: txtEmail)
    }
    
    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    func callUserOtpApi(authEmail:String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callUserOTP(emailId: authEmail, withCompletionHandler: { (result,statusCode,response,error) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if result == true {
                if statusCode == 200 {
                    self.moveToResetPassword()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Please provide a valid User Email.", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        })
    }
}

//*******************************************************//
//                 MARK: - Extensions                    //
//*******************************************************//

// UITextFieldDelegate
extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typeCasteToStringFirst = textField.text as NSString?
        let newString = typeCasteToStringFirst?.replacingCharacters(in: range, with: string)
        
        if textField == tfEmail {
            txtEmail = newString!
        }
        
        allowSend()
        
        return true
    }
}
