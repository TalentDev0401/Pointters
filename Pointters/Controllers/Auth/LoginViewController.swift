//
//  LoginViewController.swift
//  Pointters
//
//  Created by Mac on 2/13/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseAnalytics

class LoginViewController: UIViewController {

    var webservice: PushWebservice!
    
    @IBOutlet var consNavBarTop: NSLayoutConstraint!
    @IBOutlet var tfEmail: UITextField!
    @IBOutlet var tfPassword: UITextField!
    @IBOutlet var btnSignIn: UIButton!
    @IBOutlet var fbView: UIView!
    
    var txtEmail = ""
    var txtPassword = ""
    
    var targetTapIndex = 0
    
    var userId = ""
    var requestId = ""
    var serviceId = ""
    var arrAmount = [Int]()
    var totalPrice:Float = 0.0
    
    var chatUserId = ""
    var chatUserPic = ""
    var chatUserName = ""
    
    var currentTap = ""
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webservice = self
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
        
        btnSignIn.layer.cornerRadius = 5.0
        btnSignIn.layer.masksToBounds = true
        
        fbView.layer.cornerRadius = 5.0
        fbView.layer.masksToBounds = true
    }
    
    func allowSignIn() {
        if txtEmail != "" && txtPassword != "" {
            btnSignIn.backgroundColor = UIColor.getCustomBlueColor()
            btnSignIn.isUserInteractionEnabled = true
        } else {
            btnSignIn.backgroundColor = UIColor.lightGray
            btnSignIn.isUserInteractionEnabled = false
        }
    }
    
    func validationsOnFields() -> Bool {
        var noErrorFound = true
        
        if tfEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Email or User name required.", buttonTitles: ["OK"], viewController: self, completion: nil)
            noErrorFound = false
        }
        if tfPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Password required.", buttonTitles: ["OK"], viewController: self, completion: nil)
            noErrorFound = false
        }
        
        return noErrorFound
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
    
    func parseData(fbAccessToken: String){
        ApiHandler.callUserLogInWithFb(fbToken: fbAccessToken) { (result,statusCode,response, error) in
            
            if result == true{
                let responseDict = response.value as! [String:Any]
                
                if statusCode == 200 {
                    UserCache.sharedInstance.setUserAuthToken(token: responseDict["token"] as! String)
                    self.webservice.sendToken()
                    self.fetchUserProfileFromFB(fbAccessToken: fbAccessToken)
                }
                else{
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: (responseDict["message"] as? String)!, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
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
                self.callGetUserDetailApi(loginType:"F", fbAccessToken:fbAccessToken)
            }
        })
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        UserDefaults.standard.set(nil, forKey: "jobType")
        navigationController?.popViewController(animated: true)
    }
 
    @IBAction func btnForgotPasswordTapped(_ sender: Any) {        
        let forgotVC = storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordViewController
        navigationController?.pushViewController(forgotVC, animated: true)
    }
  
    @IBAction func btnTermsTapped(_ sender: Any) {
        let termsVC = storyboard?.instantiateViewController(withIdentifier: "TermsVC") as! TermsViewController
        navigationController?.pushViewController(termsVC, animated: true)
    }
    
    @IBAction func btnPolicyTapped(_ sender: Any) {
        let privacyVC = storyboard?.instantiateViewController(withIdentifier: "PrivacyVC") as! PrivacyViewController
        navigationController?.pushViewController(privacyVC, animated: true)
    }
    
    @IBAction func btnSignInTapped(_ sender: Any) {
//        let aesPassword = try! txtPassword.aesEncrypt(key: kAESCredentials.kAesKey, iv: kAESCredentials.kAesIv)
        callUserLoginApi(authId: txtEmail, authPass: txtPassword)
    }
    
    @IBAction func btnSignupTapped(_ sender: Any) {
        let signupVC = storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpViewController
        navigationController?.pushViewController(signupVC, animated: true)
    }
    
    @IBAction func btnFacebookTapped(_ sender: Any) {
        PointtersHelper.sharedInstance.loginWithFacebookFromViewController(viewController: self) { (result:String?, error :NSError?) in
            if let error = error {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error.localizedDescription, buttonTitles: ["OK"], viewController: self, completion: nil)
                return
            }
            if (result?.count)! > 0{
                // PointtersHelper.sharedInstance.startLoader(view: self.view)
                self.parseData(fbAccessToken: result!)
            }
        }
    }

    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    func callUserLoginApi(authId:String, authPass:String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callUserLogIn(emailId:authId, password:authPass, withCompletionHandler: { (result,statusCode,response, error) in
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    if responseDict["success"] as! Bool == true {
                        print("login response: \(responseDict)")
                        UserCache.sharedInstance.setUserCredentials(userDict:[:])
                        UserCache.sharedInstance.setUserAuthToken(token: responseDict["token"] as! String)
                        self.callGetUserDetailApi(loginType:"E", fbAccessToken:"")
                        self.webservice.sendToken()
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
                if error != "" {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Wrong email or password, please try again.", buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        })
    }
    
    func callGetUserDetailApi(loginType:String, fbAccessToken:String) {
        ApiHandler.callGetUserDetails(withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    let userDict = responseDict["user"] as! [String:Any]
                    print(userDict as NSDictionary)
                    if userDict["completedRegistration"] as! Bool == true {
                        self.parseAPIResponse(userDict : userDict)
                        
                        var dict = [String:Any]()
                        dict[kUserCredentials.kLoginType] = loginType
                        dict[kUserCredentials.kAuthToken] = UserCache.sharedInstance.getUserAuthToken()
                        dict[kUserCredentials.kCompletedRegistration] = userDict["completedRegistration"]
                        
                        if loginType == "E" {
                            dict["email"] = self.txtEmail
                        }
                        if loginType == "F" {
                            dict[kUserCredentials.kAccessToken] = fbAccessToken
                        }
                        
                        UserCache.sharedInstance.setUserCredentials(userDict:dict)
                        
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let containerNavVC = storyBoard.instantiateViewController(withIdentifier: "ContainerTabsNavVC") as! UINavigationController
                        let containerVC = storyBoard.instantiateViewController(withIdentifier: "ContainerTabVC") as! ContainerTabViewController
                        containerVC.selectedTab = self.currentTap
                        containerVC.selectedExplorerTabIndex = self.targetTapIndex
                        containerVC.selectedUserId = self.userId
                        containerVC.selectedRequestId = self.requestId
                        containerVC.selectedServiceId = self.serviceId
                        containerVC.arrAmount = self.arrAmount
                        containerVC.totalPrice = self.totalPrice
                        containerVC.chatUserId = self.chatUserId
                        containerVC.chatUserPic = self.chatUserPic
                        containerVC.chatUserName = self.chatUserName
                        containerNavVC.viewControllers = [containerVC]
                        let window: UIWindow = PointtersHelper.sharedInstance.mainWindow()
                        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                            window.rootViewController = containerNavVC
                        }, completion: { completed in
                            window.makeKeyAndVisible()
                        })
                        PointtersHelper.sharedInstance.sendAnalyticsToFirebase(event: kFirebaseEvents.userLogin)
                    }
                    else {
                         if loginType == "E" || loginType == "F" {
                            var dict = [String:Any]()
                            dict[kUserCredentials.kLoginType] = loginType
                            dict[kUserCredentials.kAuthToken] = UserCache.sharedInstance.getUserAuthToken()
                            dict[kUserCredentials.kCompletedRegistration] = userDict["completedRegistration"]
                            dict[kUserCredentials.kAccessToken] = fbAccessToken
                            
                            UserCache.sharedInstance.setUserCredentials(userDict:dict)
                        }
                        let emailVerified = userDict["emailVerified"] as! Bool
                        if loginType == "E" && emailVerified{
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterViewController
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            let registerVC = self.storyboard?.instantiateViewController(withIdentifier: "PasscodeVC") as! PasscodeViewController
                            self.navigationController?.pushViewController(registerVC, animated: true)
                        }
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

//MARK: - webservice

extension LoginViewController: PushWebservice{
    func webServiceGetError(receivedError: String) {
        print(receivedError)
    }
    
    func webServiceGetResponse() {
        print("success")
    }
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
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
        
        allowSignIn()
        
        return true
    }
}
