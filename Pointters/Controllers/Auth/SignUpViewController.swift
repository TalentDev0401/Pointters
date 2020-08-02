//
//  SignUpViewController.swift
//  Pointters
//
//  Created by Mac on 2/14/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseAnalytics

class SignUpViewController: UIViewController {
    
    @IBOutlet var consNavBarTop: NSLayoutConstraint!
    @IBOutlet var fbView: UIView!
    @IBOutlet var tfEmail: UITextField!
    @IBOutlet var tfPassword: UITextField!
    @IBOutlet var btnSignUp: UIButton!
    
    var txtEmail = ""
    var txtPassword = ""
    
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
            consNavBarTop.constant = 85.0
        } else {
            consNavBarTop.constant = 64.0
        }
        
        fbView.layer.cornerRadius = 5.0
        fbView.layer.masksToBounds = true
        
        btnSignUp.layer.cornerRadius = 5.0
        btnSignUp.layer.masksToBounds = true
    }
    
    func allowSignUp() {
        if txtEmail != "" && PointtersHelper.sharedInstance.isValidEmail(txtEmail) && txtPassword != "" {
            btnSignUp.backgroundColor = UIColor.getCustomBlueColor()
            btnSignUp.isUserInteractionEnabled = true
        } else {
            btnSignUp.backgroundColor = UIColor.lightGray
            btnSignUp.isUserInteractionEnabled = false
        }
    }
    
    func moveToRegistration() {
        PointtersHelper.sharedInstance.sendAnalyticsToFirebase(event: kFirebaseEvents.userRegister)
        let vc = storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func moveToPassCode() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PasscodeVC") as! PasscodeViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func parseData(fbAccessToken: String){
        
        ApiHandler.callUserLogInWithFb(fbToken: fbAccessToken) { (result,statusCode,response, error) in
            if result == true{
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    UserCache.sharedInstance.setUserAuthToken(token: responseDict["token"] as! String)
                    self.fetchUserProfileFromFB(fbAccessToken: fbAccessToken)
                }
                else{
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: (responseDict["message"] as? String)!, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
                print(response.error ?? "signup failure")
            }
        }
    }
    
    func fetchUserProfileFromFB(fbAccessToken : String){
        let graphRequest : GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, first_name, last_name, picture.width(480).height(480)"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if ((error) != nil)
            {
                print("Error took place: \(String(describing: error))")
            } else {
                let fbDetails = result as! NSDictionary
                var dict = [String:Any]()
                dict[kUserCredentials.kLoginType] = "F"
                dict[kUserCredentials.kAuthToken] = UserCache.sharedInstance.getUserAuthToken()
                dict[kUserCredentials.kAccessToken] = fbAccessToken
                UserCache.sharedInstance.setUserCredentials(userDict:dict)
                let user = User()
                if let firstName = fbDetails.value(forKey: "first_name") as? String
                {
                    user.firstName = firstName
                }
                if let lastName = fbDetails.value(forKey: "last_name") as? String
                {
                    user.lastName = lastName
                }
                if let profilePictureObj = fbDetails.value(forKey: "picture") as? NSDictionary
                {
                    let data = profilePictureObj.value(forKey: "data") as! NSDictionary
                    let profilePic = data.value(forKey: "url") as! String
                    user.profilePic = profilePic
                }
                UserCache.sharedInstance.setAccountData(userData: user)
                self.moveToRegistration()
            }
        })
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnFacebookTapped(_ sender: Any) {
        tfEmail.resignFirstResponder()
        tfPassword.resignFirstResponder()
        PointtersHelper.sharedInstance.loginWithFacebookFromViewController(viewController: self) { (result:String?, error :NSError?) in
            
            if (result?.count)! > 0{
                //PointtersHelper.sharedInstance.startLoader(view: self.view)
                self.parseData(fbAccessToken: result!)
            }
        }
    }
    
    @IBAction func btnGoogleTapped(_ sender: Any) {
    }
    
    @IBAction func btnTermsTapped(_ sender: Any) {
        let termsVC = storyboard?.instantiateViewController(withIdentifier: "TermsVC") as! TermsViewController
        navigationController?.pushViewController(termsVC, animated: true)
    }
    
    @IBAction func btnPolicyTapped(_ sender: Any) {
        let privacyVC = storyboard?.instantiateViewController(withIdentifier: "PrivacyVC") as! PrivacyViewController
        navigationController?.pushViewController(privacyVC, animated: true)
    }
    
    @IBAction func btnSignUpTapped(_ sender: Any) {
//        let aesPassword = try! txtPassword.aesEncrypt(key: kAESCredentials.kAesKey, iv: kAESCredentials.kAesIv)
        if !PointtersHelper.sharedInstance.isValidPassword(txtPassword){
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Password must contain at least 6 characters, including UPPER/lowercase and numbers", buttonTitles: ["OK"], viewController: self, completion: nil)
            return
        }
        callUserSignupApi(authEmail: txtEmail, authPass: txtPassword)
    }
    
    @IBAction func btnSignInTapped(_ sender: Any) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    func callUserSignupApi(authEmail:String, authPass:String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callUserSignUp(emailId:authEmail, password:authPass, withCompletionHandler: { (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    UserCache.sharedInstance.setUserAuthToken(token: responseDict["token"] as! String)
                    var dict = [String:Any]()
                    dict[kUserCredentials.kLoginType] = "E"
                    dict[kUserCredentials.kAuthToken] = UserCache.sharedInstance.getUserAuthToken()
                    dict["email"] = self.txtEmail
                    UserCache.sharedInstance.setUserCredentials(userDict:dict)
                    self.moveToPassCode()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: (responseDict["message"] as? String)!, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        })
    }    
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typeCasteToStringFirst = textField.text as NSString?
        let newString = typeCasteToStringFirst?.replacingCharacters(in: range, with: string)
        
        if textField == tfEmail {
            txtEmail = newString!
        } else if textField == tfPassword {
            txtPassword = newString!
        }
        
        allowSignUp()
        
        return true
    }
}
