//
//  ShipAddress.swift
//  Pointters
//
//  Created by super on 5/29/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ShipAddress: NSObject {
    
    var name:String = "NA"
    var street1:String = "NA"
    var street2:String = "NA"
    var apt:String = "NA"
    var city:String = "NA"
    var state:String = "NA"
    var zip:String = "NA"
    var country:String = "NA"
    var phone:String = "NA"
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["name"] as? String                      { name = val }
        if let val = dict["street1"] as? String                   { street1 = val }
        if let val = dict["street2"] as? String                   { street2 = val }
        if let val = dict["apt"] as? String                       { apt = val }
        if let val = dict["city"] as? String                      { city = val }
        if let val = dict["state"] as? String                     { state = val }
        if let val = dict["zip"] as? String                       { zip = val }
        if let val = dict["country"] as? String                   { country = val }
        if let val = dict["phone"] as? String                     { phone = val }
    }
    
    func dict() -> [String:Any] {
        var dictAddress = [String:Any]()
        dictAddress["name"] = name
        dictAddress["street1"] = street1
        dictAddress["street2"] = street2
        dictAddress["apt"] = apt
        dictAddress["city"] = city
        dictAddress["state"] = state
        dictAddress["zip"] = zip
        dictAddress["country"] = country
        dictAddress["phone"] = phone
        return dictAddress
    }
}
