//
//  OrderItem.swift
//  Pointters
//
//  Created by super on 5/22/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class OrderItem: NSObject {
    
    var id:String = ""
    var desc:String = ""
    var price:Float = 0.0
    var priceWithoutDiscount:Float = 0.0
    var quantity:Int = 0
    var time:Int = 0
    var timeUnitOfMeasure:String = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["_id"] as? String                       { id = val }
        if let val = dict["description"] as? String               { desc = val }
        if let val = dict["price"] as? NSNumber                      { price = val.floatValue }
        if let val = dict["priceWithoutDiscount"] as? NSNumber       { priceWithoutDiscount = val.floatValue }
        if let val = dict["quantity"] as? Int                     { quantity = val }
        if let val = dict["time"] as? Int                         { time = val }
        if let val = dict["timeUnitOfMeasure"] as? String         { timeUnitOfMeasure = val }
    }
}
