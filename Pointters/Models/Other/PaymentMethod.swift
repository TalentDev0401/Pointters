//
//  Paymentdict.swift
//  Pointters
//
//  Created by super on 5/22/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class PaymentMethod: NSObject {
    
    var isPayPal = false
    var isApplePay = false
    var isCreditCard = false
    
    var payerId = ""
    var customerId = ""
    var imageUrl = ""
    var token = ""
    var billingAgreementId = ""
    var email = ""
    var bin = ""
    var last4 = ""
    var expirationYear = ""
    var expirationMonth = ""
    var expired = false
    var defaultOption = false
    
    var cardType = ""
    var cardholderName = ""
    var expirationDate = ""
    var customerLocation = ""
    var maskedNumber = ""
    var uniqueNumberIdentifier = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let cardType = dict["cardType"] {
            if (cardType as! String).contains("Apple Pay") {
                isApplePay = true
            } else {
                isCreditCard = true
            }
        } else {
            isPayPal = true
        }
        
        if let val = dict["payerId"] as? String                            { payerId = val }
        if let val = dict["customerId"] as? String                         { customerId = val }
        if let val = dict["imageUrl"] as? String                           { imageUrl = val }
        if let val = dict["token"] as? String                              { token = val }
        if let val = dict["billingAgreementId"] as? String                 { billingAgreementId = val }
        if let val = dict["email"] as? String                              { email = val }
        if let val = dict["bin"] as? String                                { bin = val }
        if let val = dict["last4"] as? String                              { last4 = val }
        if let val = dict["expirationYear"] as? String                     { expirationMonth = val }
        if let val = dict["expirationMonth"] as? String                    { expirationMonth = val }
        if let val = dict["expired"] as? Int                               { expired = NSNumber(value: val).boolValue }
        if let val = dict["cardType"] as? String                           { cardType = val
            cardType = cardType.replacingOccurrences(of: "Apple Pay - ", with: "")}
        if let val = dict["cardholderName"] as? String                     { cardholderName = val }
        if let val = dict["expirationDate"] as? String                     { expirationDate = val }
        if let val = dict["customerLocation"] as? String                   { customerLocation = val }
        if let val = dict["maskedNumber"] as? String                       { maskedNumber = val }
        if let val = dict["uniqueNumberIdentifier"] as? String             { uniqueNumberIdentifier = val }
        if let val = dict["default"] as? Int                               { defaultOption = NSNumber(value: val).boolValue }
    }
}
