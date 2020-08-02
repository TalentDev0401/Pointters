//
//  ShippingAddress.swift
//  Pointters
//
//  Created by super on 4/17/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ShippingAddress: NSObject {
    
    var isActive = false
    var id = ""
    var userId = ""
    var externalId = ""
    var validationErrors = ""
    var object = ""
    var company = ""
    var street1 = ""
    var street2 = ""
    var city = ""
    var state = ""
    var zip = ""
    var country = ""
    var phone = ""
    var email = ""
    var mode = ""
    var carrierFacility = ""
    var residential = ""
    var federalTaxId = ""
    var stateTaxId = ""
    var name = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["isActive"] as? Bool                     { isActive = val }
        if let val = dict["_id"] as? String                        { id = val }
        if let val = dict["userId"] as? String                     { userId = val }
        if let val = dict["externalId"] as? String                 { externalId = val }
        if let val = dict["validationErrors"] as? String           { validationErrors = val }
        if let val = dict["object"] as? String                     { object = val }
        if let val = dict["company"] as? String                    { company = val }
        if let val = dict["street1"] as? String                    { street1 = val }
        if let val = dict["street2"] as? String                    { street2 = val }
        if let val = dict["city"] as? String                       { city = val }
        if let val = dict["state"] as? String                      { state = val }
        if let val = dict["zip"] as? String                        { zip = val }
        if let val = dict["country"] as? String                    { country = val }
        if let val = dict["phone"] as? String                      { phone = val }
        if let val = dict["email"] as? String                      { email = val }
        if let val = dict["mode"] as? String                       { mode = val }
        if let val = dict["carrierFacility"] as? String            { carrierFacility = val }
        if let val = dict["residential"] as? String                { residential = val }
        if let val = dict["federalTaxId"] as? String               { federalTaxId = val }
        if let val = dict["stateTaxId"] as? String                 { stateTaxId = val }
        if let val = dict["name"] as? String                       { name = val }
    }
    func dict() -> [String:Any] {
        var dictAddress = [String:Any]()
        dictAddress["_id"] = id
        dictAddress["externalId"] = externalId
        dictAddress["name"] = name=="" ? "Empty" : name
        dictAddress["street1"] = street1
        dictAddress["street2"] = street2
        dictAddress["city"] = city
        dictAddress["state"] = state
        dictAddress["zip"] = zip
        dictAddress["country"] = country
        dictAddress["phone"] = phone
        return dictAddress
    }
}
