//
//  StripePaymentMethod.swift
//  Pointters
//
//  Created by dreams on 1/29/19.
//  Copyright © 2019 Kenji. All rights reserved.
//

import UIKit

class StripePaymentMethod: NSObject {

    //required
    var isPayPal = false
    var isPaystack = false
    var isApplePay = false
    var isCreditCard = false

    var paypal = "paypal"
    var paystack = "paystack"
    var brand = ""
    var defaultOption = false
    var email = ""
    var expirationYear = 0
    var expirationMonth = 0
    var id = ""
    var imageUrl = ""
    var last4 = ""
    var name = ""
    var tokenization_method = ""

    //optional
    //var address_country = ""
    //var customer = ""
    //var fingerprint = ""
    //var funding = ""
    //var object = ""

    override init() {
        super.init()
    }

    init(dict:[String:Any]) {
        if let cardType = dict["tokenization_method"] as? String {
            if cardType == "apple_pay" {
                isApplePay = true
            } else {
                isPayPal = true
            }
        } else {
            isCreditCard = true
        }

        //if let val = dict["address_country"] as? String             { address_country = val }
        if let val = dict["brand"] as? String                              { brand = val }
        //if let val = dict["customer"] as? String                 { customer = val }
        if let val = dict["default"] as? Int                                { defaultOption = NSNumber(value: val).boolValue }
        if let val = dict["exp_year"] as? Int                     { expirationYear = val }
        if let val = dict["exp_month"] as? Int                    { expirationMonth = val }
        //if let val = dict["funding"] as? String                     { funding = val }
        //if let val = dict["fingerprint"] as? String                     { fingerprint = val }
        if let val = dict["id"] as? String                            { id = val }
        if let val = dict["imageUrl"] as? String                           { imageUrl = val }
        if let val = dict["last4"] as? String                              { last4 = val }
        if let val = dict["name"] as? String                            { name = val }
        //if let val = dict["object"] as? String                         { object = val }
        if let val = dict["tokenization_method"] as? String       { tokenization_method = val }
    }
}
