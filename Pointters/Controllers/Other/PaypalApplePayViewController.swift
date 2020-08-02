//
//  PaypalApplePayViewController.swift
//  Pointters
//
//  Created by C on 6/30/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import PassKit
import Stripe

protocol PaypalApplePayVCDelegate {
    func refreshForUpdate()
    func deletedMethod(isPayPal: Bool)
}

class PaypalApplePayViewController: UIViewController {

    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var tableView: TPKeyboardAvoidingTableView!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var labelHeaderTitle: UILabel!
    @IBOutlet var labelMainTitle: UILabel!
    @IBOutlet var labelSubTitle: UILabel!

    var addDelegate: PaypalApplePayVCDelegate?
    
    var paymentMethod = StripePaymentMethod()
    var isPayPal = false
    var isDefault = false
    var isEditted = false
    
    var applePaySuccess = false
    
    var applePayError = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        
        btnDone.alpha = 0.3
        btnDone.isUserInteractionEnabled = false
        
        if self.isPayPal {
            labelHeaderTitle.text = "PayPal"
            labelMainTitle.text = "PayPal Detail"
            labelSubTitle.text = "Maintain your paypal information"
            btnDelete.setTitle("Delete PayPal Account", for: .normal)
        } else {
            labelHeaderTitle.text = "Apple Pay"
            labelMainTitle.text = "Apple Pay Detail"
            labelSubTitle.text = "Maintain your Apple Pay information"
            btnDelete.setTitle("Delete Apple Pay Card", for: .normal)
        }
        
        if paymentMethod.id.isEmpty {
            btnDelete.isHidden = true
        } else {
            btnDelete.isHidden = false
        }
    }
    
    func initWithPaymentMethod(paymentMethod: StripePaymentMethod, isPayPal: Bool) {
        self.isPayPal = isPayPal
        self.paymentMethod = paymentMethod
        self.isDefault = paymentMethod.defaultOption
    }
    
    func setupPayPalMethod() {
        if !self.paymentMethod.id.isEmpty {
            return
        }
//        let payPalDriver = BTPayPalDriver(apiClient: self.braintreeClient!)
//        payPalDriver.viewControllerPresentingDelegate = self
//        payPalDriver.appSwitchDelegate = self
//
//        // Start the Vault flow, or...
//        payPalDriver.authorizeAccount(withAdditionalScopes: Set(["address"])) { (tokenizedPayPalAccount, error) in
//            guard let tokenizedPayPalAccount = tokenizedPayPalAccount else {
//                if let error = error {
//                    // Handle error
//                    print(error)
//                } else {
//                    // User canceled
//                }
//                return
//            }
//
//            let paymentNonce = tokenizedPayPalAccount.nonce
//            print("Payment nonce : \(paymentNonce)")
//            self.isEditted = true
//            self.callPostNonceToServer(nonce: paymentNonce)
//
//            if let address = tokenizedPayPalAccount.billingAddress {
//                print("Billing address:\n\(address.streetAddress)\n\(address.extendedAddress ?? "")\n\(address.locality) \(address.region ?? "")\n\(address.postalCode ?? "") \(address.countryCodeAlpha2)")
//            }
//
//        }
    }
    
    func setupApplePayMethod() {
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex, PKPaymentNetwork.discover]) {
            
            let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: kApplePayMerchantId.key, country: "US", currency: "USD")
            paymentRequest.paymentSummaryItems = [
                PKPaymentSummaryItem(label: "Pointters LLC", amount: 1.00),
            ]
            if Stripe.canSubmitPaymentRequest(paymentRequest) {
                // Setup payment authorization view controller
                let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                paymentAuthorizationViewController?.delegate = self
                
                // Present payment authorization view controller
                present(paymentAuthorizationViewController!, animated: true)
            }
            else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Payment request is invalid.", buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        }else{
            PointtersHelper.sharedInstance.showAlertViewWithTitle("Apple Pay is not available on your device", message: "Please check your app setting or connect payment method on your device settings.", buttonTitles: ["OK"], viewController: self, completion: nil)
        }
    }
    
    func callPostNonceToServer(nonce: String) {
    }
    
    func showLoadingUI() {
        // ...
    }
    
    @objc func hideLoadingUI() {
        NotificationCenter
            .default
            .removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        // ...
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callUpdateStripePaymentMethod(methodToken: self.paymentMethod.id, name: "", cvv: "*", expMon: "", expYear: "", makeDefault: isDefault) { (status, statusCode, response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if status == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    let paymentMethod = StripePaymentMethod(dict: responseDict)
                    if paymentMethod.isPayPal {
//                        UserCache.sharedInstance.setPaypalEmail(email: paymentMethod.email)
                    } else if paymentMethod.isApplePay {
                        UserCache.sharedInstance.setApplePayEmail(email: paymentMethod.brand + " : ****" + paymentMethod.last4)
                    }
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully updated.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                        self.dismiss(animated: true, completion: nil)
                    })
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        }
    }
    
    @IBAction func btnDeleteTapped(_ sender: Any) {

        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callDeleteStripePaymentMethod(methodToken: paymentMethod.id) { (status, statusCode, response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if status == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    if self.addDelegate != nil {
                        self.addDelegate?.deletedMethod(isPayPal: self.isPayPal)
                    }
                    self.dismiss(animated: true, completion: nil)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// UITableViewDataSource
extension PaypalApplePayViewController: UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell") as! PaymentCell
            
            if isPayPal {
                cell.imgIcon.image = UIImage(named: "icon-paypal")
                cell.lblTitle.text = "Paypal"
                cell.lblSubTitle.text = UserCache.sharedInstance.getPaypalEmail()
                cell.constantPaymentIconRatio.constant = 1.0
            } else {
                cell.imgIcon.image = UIImage(named: "icon-applepay")
                cell.lblTitle.text = "Apple Pay"
                cell.lblSubTitle.text = UserCache.sharedInstance.getApplePayEmail()
                cell.constantPaymentIconRatio.constant = 1.0/1.56
            }
            cell.lblDefault.isHidden = !paymentMethod.defaultOption
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") as! PaymentCell
            cell.imgIcon.isHidden = !isDefault
            return cell
        }
    }
}

// UITableViewDelegate
extension PaypalApplePayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            if isPayPal {
                setupPayPalMethod()
            } else {
                if paymentMethod.id.isEmpty {
                    setupApplePayMethod()
                }
            }
        } else {
            if !paymentMethod.id.isEmpty {
                btnDone.alpha = 1.0
                btnDone.isUserInteractionEnabled = true
            }
            isDefault = !isDefault
            tableView.reloadData()
        }
    }
}

extension PaypalApplePayViewController : PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: {
            if (self.applePaySuccess) {
                self.addDelegate?.refreshForUpdate()
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        STPAPIClient.shared().createToken(with: payment) { (token: STPToken?, error: Error?) in
            guard let token = token, error == nil else {
                completion(.failure)
                self.applePaySuccess = false
                self.applePayError = (error?.localizedDescription)!
                return
            }
            ApiHandler.createStripePaymentMethod(tokenId: token.tokenId, makeDefault: self.isDefault, withCompletionHandler: { (result, statusCode, response, error) in
                if result == true {
                    let responseDict = response.value as! [String:Any]
                    print(responseDict as NSDictionary)
                    if statusCode == 200 {
                        self.paymentMethod = StripePaymentMethod.init(dict: responseDict)
                        self.applePaySuccess = true
                        completion(.success)
                    } else {
                        self.applePaySuccess = false
                        completion(.failure)
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                    }
                } else {
                    completion(.failure)
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            })
        }
    }
    
}
