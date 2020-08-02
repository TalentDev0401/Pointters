//
//  TransactionHistory.swift
//  Pointters
//
//  Created by super on 4/13/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class TransactionHistory: NSObject {
    
    var orderId = ""
    var desc = ""
    var currencyCode = ""
    var currencySymbol = ""
    var date = ""
    var amount:Float = 0.0
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["orderId"] as? String                    { orderId = val }
        if let val = dict["description"] as? String                { desc = val }
        if let val = dict["currencyCode"] as? String               { currencyCode = val }
        if let val = dict["currencySymbol"] as? String             { currencySymbol = val }
        if let val = dict["date"] as? String                       { date = val }
        if let val = dict["amount"] as? NSNumber                      { amount = val.floatValue }
    }
    
}
