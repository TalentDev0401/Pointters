//
//  Price.swift
//  Pointters
//
//  Created by Mac on 2/23/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Price: NSObject {

    var id:String = ""
    var desc:String = ""
    var currencyCode:String = ""
    var currencySymbol:String = ""
    var price:Float = 0.0
    var time:Int = 0
    var timeUnitOfMeasure:String = ""

    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["id"] as? String                      { id = val }
        if let val = dict["_id"] as? String                      { id = val }
        if let val = dict["description"] as? String               { desc = val }
        if let val = dict["currencyCode"] as? String            { currencyCode = val }
        if let val = dict["currencySymbol"] as? String          { currencySymbol = val }
        if let val = dict["price"] as? Float                    { price = val }
        if let val = dict["time"] as? Int                       { time = val }
        if let val = dict["timeUnitOfMeasure"] as? String       { timeUnitOfMeasure = val }
    }
    
    func dict() -> [String:Any] {
        var dictPrice = [String:Any]()
        dictPrice["description"] = desc
        dictPrice["currencyCode"] = currencyCode
        dictPrice["currencySymbol"] = currencySymbol
        dictPrice["price"] = price
        dictPrice["time"] = time
        dictPrice["timeUnitOfMeasure"] = timeUnitOfMeasure
        return dictPrice
    }
}
