//
//  PayPalTranscation.swift
//  Pointters
//
//  Created by Kirill Chistyakov on 27/05/20.
//  Copyright © 2019 Pointers. All rights reserved.
//

import Foundation

class PayPalTranscation:NSObject {
    let marchantName = "Pointters, Inc"
    let items:NSMutableArray = NSMutableArray()
    // Paypal configure
    var payPalConfig = PayPalConfiguration()
    
    var environment:String = PayPalEnvironmentSandbox {//PayPalEnvironmentProduction
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    //MARK: Paypal Setup
    func acceptCreditCards() -> Bool {
        return false//self.payPalConfig.acceptCreditCards
    }
    
    func setAcceptCreditCards(acceptCreditCards: Bool) {
        self.payPalConfig.acceptCreditCards = self.acceptCreditCards()
    }
    
    func authorizeProfileSharingInfo(controller: UIViewController) {
        self.configurePaypal(strMarchantName: marchantName)
        self.payPalConfig.acceptCreditCards = self.acceptCreditCards()
        
        let scopes = [kPayPalOAuth2ScopeOpenId, kPayPalOAuth2ScopeEmail, kPayPalOAuth2ScopeFuturePayments]
        let profileSharingViewController = PayPalProfileSharingViewController(scopeValues: NSSet(array: scopes) as Set<NSObject>, configuration: payPalConfig, delegate: (controller as! PayPalProfileSharingDelegate))
        controller.present(profileSharingViewController!, animated: true, completion: nil)
    }
    
    func authorizeFuturePaymentDetail(controller: UIViewController) {
        self.configurePaypal(strMarchantName: marchantName)
        self.payPalConfig.acceptCreditCards = self.acceptCreditCards()
        let futurePaymentViewController = PayPalFuturePaymentViewController(configuration: payPalConfig, delegate: (controller as! PayPalFuturePaymentDelegate))
        controller.present(futurePaymentViewController!, animated: true, completion: nil)
    }
    
    func configurePayPalPaymentsDetails(paymentRequest:PaymentRequest, controller: UIViewController) {
   
        self.configurePaypal(strMarchantName: paymentRequest.marchantName ?? marchantName)
        
        let item = PayPalItem.init(name: paymentRequest.itemName ?? marchantName, withQuantity: paymentRequest.quantity ?? 1, withPrice: paymentRequest.price ?? 0, withCurrency: paymentRequest.currency?.rawValue ?? PaypalPrice.USD.rawValue, withSku: nil)
        items.add(item)
        
        self.goforPayNow(shipPrice: paymentRequest.shipPrice, taxPrice: paymentRequest.taxPrice, totalAmount: paymentRequest.totalAmount, strShortDesc: paymentRequest.shortDesc, strCurrency: paymentRequest.currency?.rawValue, controller: controller)
    }
    
    //MARK: Start Payment
    func goforPayNow(shipPrice:NSDecimalNumber?, taxPrice:NSDecimalNumber?, totalAmount:NSDecimalNumber?, strShortDesc:String?, strCurrency:String?, controller: UIViewController) {

        var subtotal : NSDecimalNumber = 0
        if items.count > 0 {
            subtotal = PayPalItem.totalPrice(forItems: items as [AnyObject])
        } else {
            subtotal = totalAmount ?? 0
        }
        
          let shipping = shipPrice ?? 0
          let tax = taxPrice ?? 0
            let description = strShortDesc ?? ""
        
        
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: strCurrency!, shortDescription: description, intent: .sale)
        
        payment.items = items as [AnyObject]
        payment.paymentDetails = paymentDetails
        
        self.payPalConfig.acceptCreditCards = self.acceptCreditCards();
        
        if self.payPalConfig.acceptCreditCards == true {
            print("We are able to do the card payment")
        }
        
        if (payment.processable) {
            let topViewController = UIApplication.topViewController()
            let objVC = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: controller as! PayPalPaymentDelegate)
            guard let topVC = topViewController else { return }
            if topVC.isModal {
                topVC.present(objVC!, animated: true, completion: { () -> Void in
                    print("Paypal Presented")
                })
                return
            }
            if let tabbar = topVC.tabBarController {
                tabbar.present(objVC!, animated: true, completion: { () -> Void in
                    print("Paypal Presented")
                })
            } else {
                topVC.present(objVC!, animated: true, completion: { () -> Void in
                    print("Paypal Presented")
                })
            }
        }
        else {
            print("Payment not processalbe: \(payment)")
        }
    }
    
    //MARK: Configure paypal
    func configurePaypal(strMarchantName:String) {
        if items.count>0 {
            items.removeAllObjects()
        }
        // Set up payPalConfig
        self.payPalConfig.acceptCreditCards = self.acceptCreditCards();
        self.payPalConfig.merchantName = strMarchantName
        self.payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full") as URL?
        self.payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full") as URL?
        
        self.payPalConfig.languageOrLocale = NSLocale.preferredLanguages[0]
        
        self.payPalConfig.payPalShippingAddressOption = .payPal;
        
        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
        PayPalMobile.preconnect(withEnvironment: environment)
    }
   
}

extension UIViewController {
    var isModal: Bool {
        if presentingViewController != nil {
            return true
        }
        if navigationController?.presentingViewController?.presentedViewController === navigationController {
            return true
        }
        if let presentingVC = tabBarController?.presentingViewController, presentingVC is UITabBarController {
            return true
        }
        return false
    }
}



extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

