//
//  ResetPasswordViewController.swift
//  Pointters
//
//  Created by Mac on 2/14/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet var consNavBarTop: NSLayoutConstraint!
    @IBOutlet var tfCode: UITextField!
    @IBOutlet var tfPassword: UITextField!
    @IBOutlet var tfReenter: UITextField!
    @IBOutlet var consBtnResetBottom: NSLayoutConstraint!
    @IBOutlet var btnReset: UIButton!
    
    var txtEmail = ""
    var txtCode = ""
    var txtPassword = ""
    var txtReenter = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        if txtEmail == "" {
            txtEmail = UserCache.sharedInstance.getResetEmail()!
        }
        tfCode.text = txtCode
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
            consBtnResetBottom.constant = 32.0
        } else {
            consNavBarTop.constant = 64.0
            consBtnResetBottom.constant = 16.0
        }
        
        btnReset.layer.cornerRadius = 5.0
        btnReset.layer.masksToBounds = true
    }
    
    func allowReset() {
        if txtEmail != "" && txtCode != "" && txtPassword != "" && txtPassword == txtReenter {
            btnReset.backgroundColor = UIColor.getCustomBlueColor()
            btnReset.isUserInteractionEnabled = true
        } else {
            btnReset.backgroundColor = UIColor.lightGray
            btnReset.isUserInteractionEnabled = false
        }
    }
    
    func moveToMainPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let containerVC = storyboard.instantiateViewController(withIdentifier: "ContainerTabVC") as! ContainerTabViewController
        self.navigationController?.pushViewController(containerVC, animated: true)
    }
    
    func parseAPIResponse(userDict:[String:Any]) {
        let user = User()
        
        if let val = userDict["_id"] {
            user.id = val as! String
        }
        if let val = userDict["firstName"] {
            user.firstName = val as! String
        }
        if let val = userDict["lastName"] {
            user.lastName = val as! String
        }
        if let val = userDict["birthday"] {
            user.birthday = val as! String
        }
        if let val = userDict["profilePic"] {
            user.profilePic = val as! String
        }
        if let val = userDict["profileBackgroundMedia"] {
            user.profileMedia = val as! [[String : String]]
        }
        
        if let val = userDict["email"] {
            user.email = val as! String
        }
        if let val = userDict["phone"] {
            user.phone = val as! String
        }
        if let val = userDict["verified"] {
            user.verified = val as! Bool
        }
        if let val = userDict["description"] {
            user.desc = val as! String
        }
        if let val = userDict["companyName"] {
            user.companyName = val as! String
        }
        
        if let val = userDict["education"] {
            user.education = val as! String
        }
        if let val = userDict["license"] {
            user.license = val as! String
        }
        if let val = userDict["insurance"] {
            user.insurance = val as! String
        }
        if let val = userDict["awards"] {
            user.awards = val as! String
        }
        
        if let val = userDict["isAdmin"] {
            user.isAdmin = val as! Bool
        }
        if let val = userDict["isActive"] {
            user.isActive = val as! Bool
        }
        
        UserCache.sharedInstance.setAccountData(userData: user)
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
                    self.consBtnResetBottom?.constant = 32.0
                } else {
                    self.consBtnResetBottom?.constant = 16.0
                }
            } else {
                self.consBtnResetBottom?.constant = (endFrame?.size.height)! + 16.0
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
    
    @IBAction func btnResetTapped(_ sender: Any) {
//        let aesPassword = try! txtPassword.aesEncrypt(key: kAESCredentials.kAesKey, iv: kAESCredentials.kAesIv)
        if !PointtersHelper.sharedInstance.isValidPassword(txtPassword){
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Password must contain at least 6 characters, including UPPER/lowercase and numbers", buttonTitles: ["OK"], viewController: self, completion: nil)
            return
        }
        callUserResetApi(authEmail: txtEmail, authPass: txtPassword, authOtp: txtCode)
    }
    
    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    func callUserResetApi(authEmail:String, authPass:String, authOtp:String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callUserResetPassword(emailId: authEmail, password: authPass, otp: authOtp, withCompletionHandler: { (result,statusCode,response,error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                _ = response.value as! [String:Any]
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Password has been successfully reset.", buttonTitles: ["OK"], viewController: self, completion: { (index) in
                        self.callUserLoginApi(authId: authEmail, authPass: authPass)
                    })
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Provide a valid code.", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        })
    }
    
    func callUserLoginApi(authId:String, authPass:String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callUserLogIn(emailId:authId, password:authPass, withCompletionHandler: { (result,statusCode,response, error) in
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    if responseDict["success"] as! Bool == true {
                        UserCache.sharedInstance.setUserCredentials(userDict:[:])
                        UserCache.sharedInstance.setUserAuthToken(token: responseDict["token"] as! String)
                        self.callGetUserDetailApi(loginType:"E")
                    } else {
                        PointtersHelper.sharedInstance.stopLoader()
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Wrong email or password, please try again.", buttonTitles: ["OK"], viewController: self, completion: nil)
                    }
                } else {
                    PointtersHelper.sharedInstance.stopLoader()
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Wrong email or password, please try again.", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                PointtersHelper.sharedInstance.stopLoader()
                if  error != "" {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
                }else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Wrong email or password, please try again.", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
                
                print(response.error ?? "login failure")
            }
        })
    }
    
    func callGetUserDetailApi(loginType:String) {
        ApiHandler.callGetUserDetails(withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    let userDict = responseDict["user"] as! [String:Any]
                    self.parseAPIResponse(userDict : userDict)
                    
                    var dict = [String:Any]()
                    dict[kUserCredentials.kLoginType] = loginType
                    dict[kUserCredentials.kAuthToken] = UserCache.sharedInstance.getUserAuthToken()
                    dict[kUserCredentials.kCompletedRegistration] = userDict["completedRegistration"]
                    dict["email"] = self.txtEmail
                    UserCache.sharedInstance.setUserCredentials(userDict:dict)
                    
                    if userDict["completedRegistration"] as! Bool == true {
                        self.moveToMainPage()
                    } else {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "connection failed", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "connection failed", buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        })
    }
}

//*******************************************************//
//                 MARK: - Extensions                    //
//*******************************************************//

// UITextFieldDelegate
extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typeCasteToStringFirst = textField.text as NSString?
        let newString = typeCasteToStringFirst?.replacingCharacters(in: range, with: string)
        
        if textField == tfCode {
            txtCode = newString!
        } else if textField == tfPassword {
            txtPassword = newString!
        } else if textField == tfReenter {
            txtReenter = newString!
        }
        
        allowReset()
        
        return true
    }
}
