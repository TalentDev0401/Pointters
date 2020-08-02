//
//  PayPalManager.swift
//  Pointters
//
//  Created by Kirill Chistyakov on 27/05/20.
//  Copyright © 2019 Pointers. All rights reserved.
//

import Foundation
/// Manage PayPal payment Keys 
struct PaypalKeyManager {
    static let Production = "AV1W6TInN09brBEMi54BpccbCnEnGSLnXcxm1_8YRZVBw9reYGEYSpYveQwHC5xQjno8kjKxEUWOG6pM"
    static let Sandbox = "AcjZAh2T8Blh-gIXHlsw91qlLKdPlTNkLu6UNebR6aVHQ_roGrRRcH-VUKEvdC1UJp69m22X6nMB_5Of"
}

enum PaypalPrice: String {
    case USD = "USD"
    case AUD = "AUD"
}

struct PaymentRequest {
    var marchantName:String?
    var itemName:String?
    var price:NSDecimalNumber?
    var quantity:UInt?
    var shipPrice:NSDecimalNumber?
    var taxPrice:NSDecimalNumber?
    var totalAmount:NSDecimalNumber?
    var shortDesc:String?
    var currency:PaypalPrice?
}


