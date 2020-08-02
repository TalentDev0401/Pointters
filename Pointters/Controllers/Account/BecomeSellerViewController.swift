//
//  BecomeSellerViewController.swift
//  Pointters
//
//  Created by Mac on 2/15/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class BecomeSellerViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var lblServiceStatus: UILabel!
    @IBOutlet var lblPaymentStatus: UILabel!
    @IBOutlet var lblBackgroundStatus: UILabel!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var paypalEmail: UILabel!
    @IBOutlet weak var email_status: UILabel!
    @IBOutlet weak var lblNumStores: UILabel!
    
    let paymentObj = PayPalTranscation()
    var location = Location.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        successView.isHidden = true
        email_status.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initUI()
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
        callSellerEligabilityAPI()
    }
            
    func gotoHowToPaid(email: String, user_Ng: Bool) {
        let paymentMethodVC = self.storyboard?.instantiateViewController(withIdentifier: "HowPaidVC") as! HowPaidViewController
        paymentMethodVC.user_NG = user_Ng
        paymentMethodVC.paypal_email = email
        navigationController?.pushViewController(paymentMethodVC, animated: true)
    }
    
    func showSuccess() {
      successView.isHidden = false
      successView.alpha = 1.0
      UIView.beginAnimations(nil, context: nil)
      UIView.setAnimationDuration(0.5)
      UIView.setAnimationDelay(3.0)
      successView.alpha = 0.0
      UIView.commitAnimations()
    }

    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
 
    @IBAction func btnServiceTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Public", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "categorySelectViewController") as! CategorySelectViewController
        vc.toAddService = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnGetPaidTapped(_ sender: Any) {
        if location.country == "NG" {
            gotoHowToPaid(email: "", user_Ng: true)
        } else {
//            paymentObj.authorizeFuturePaymentDetail(controller: self)
            paymentObj.authorizeProfileSharingInfo(controller: self)
        }
    }
    
    @IBAction func btnBackgroundTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let backgroundCheckVC = storyboard.instantiateViewController(withIdentifier: "BackgroundCheckVC") as! BackgroundCheckViewController
        navigationController?.pushViewController(backgroundCheckVC, animated: true)
    }
    
    @IBAction func btnStoreLocationTapped(_ sender: Any) {
        let shippingAddressVC = storyboard?.instantiateViewController(withIdentifier: "ShippingAddressVC") as! ShippingAddressViewController
        shippingAddressVC.shippingFlag = 1
        navigationController?.pushViewController(shippingAddressVC, animated: true)
    }
    
    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    func callSellerEligabilityAPI() {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callSellerEligability(withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    print(responseDict)
                    
                    if let loc = responseDict["location"] as? [String: Any] {
                        self.location = Location.init(dict: loc)
                    }
                    
                    if self.location.country != "NG" {
                        if let email = responseDict["paypalSellerEmail"] as? String {
                            self.paypalEmail.text = email
                            self.email_status.isHidden = false
                        }
                    }                    
                    self.lblNumStores.text = "\(responseDict["numStores"] as! Int)"
                    self.lblServiceStatus.text = "\(responseDict["numServices"] as! Int) Added"
                    self.lblPaymentStatus.text = responseDict["paymentSetupStatus"] as? String
                    self.lblBackgroundStatus.text = responseDict["backgroundCheckStatus"] as? String
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        })
    }
    
    func callSetPaypalAuthorizationCodeAPI(param: [String: Any]) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callSetPaypalAuthorizationCodeAPI(params: param, withCompletionHandler: { (result,statusCode,response,error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    print(responseDict)
                    self.callSellerEligabilityAPI()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        })
    }
}

// MARK: - PayPalFuturePaymentDelegate

extension BecomeSellerViewController: PayPalFuturePaymentDelegate {
    func payPalFuturePaymentDidCancel(_ futurePaymentViewController: PayPalFuturePaymentViewController) {
      print("PayPal Future Payment Authorization Canceled")
      successView.isHidden = true
      futurePaymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalFuturePaymentViewController(_ futurePaymentViewController: PayPalFuturePaymentViewController, didAuthorizeFuturePayment futurePaymentAuthorization: [AnyHashable: Any]) {
        
        // set paypal authorization code to server
        for item in futurePaymentAuthorization {
            if item.key == AnyHashable("response") {
                if let authorization_code = item.value as? [String:String] {
                    let code = authorization_code["code"]!
                    let param = ["paypalAuthorizationCode":"\(code)"]
                    self.callSetPaypalAuthorizationCodeAPI(param: param)
                }
            }
        }
        
        // send authorization to your server to get refresh token.
        futurePaymentViewController.dismiss(animated: true, completion: { () -> Void in
          self.showSuccess()
        })
    }
}

// MARK: - PayPalProfileSharingDelegate

extension BecomeSellerViewController: PayPalProfileSharingDelegate {
    
    func userDidCancel(_ profileSharingViewController: PayPalProfileSharingViewController) {
      print("PayPal Profile Sharing Authorization Canceled")
      successView.isHidden = true
      profileSharingViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalProfileSharingViewController(_ profileSharingViewController: PayPalProfileSharingViewController, userDidLogInWithAuthorization profileSharingAuthorization: [AnyHashable: Any]) {
        print("PayPal Profile Sharing Authorization Success!")
      
        // set paypal authorization code to server
        for item in profileSharingAuthorization {
            if item.key == AnyHashable("response") {
                if let authorization_code = item.value as? [String:String] {
                    let code = authorization_code["code"]!
                    let param = ["paypalAuthorizationCode":"\(code)"]
                    self.callSetPaypalAuthorizationCodeAPI(param: param)
                }
            }
        }
      
        profileSharingViewController.dismiss(animated: true, completion: { () -> Void in
          self.showSuccess()
        })

    }
}
