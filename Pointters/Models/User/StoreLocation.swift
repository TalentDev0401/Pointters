//
//  StoreLocation.swift
//  Pointters
//
//  Created by Billiard ball on 09.06.2020.
//  Copyright © 2020 Kenji. All rights reserved.
//

import Foundation
import UIKit

class StoreLocation: NSObject {

    var city:String = "NA"
    var country:String = "NA"
    var geoJson:GeoJson = GeoJson.init()
    var postalCode:String = ""
    var state:String = "NA"
    var street1: String = ""
    var __v: Int = 0
    var _id: String = ""
    var isActive: Bool = false
    var userId: String = ""
    var defaults: Bool?
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["city"] as? String                  { city = val }
        if let val = dict["country"] as? String               { country = val }
        if let val = dict["geoJson"] as? [String:Any]        { geoJson = GeoJson.init(dict: val) }
        if let val = dict["postalCode"] as? String            { postalCode = val }
        if let val = dict["state"] as? String                 { state = val }
        if let val = dict["street1"] as? String {
            street1 = val
        }
        if let val = dict["__v"] as? Int                      { __v = val }
        if let val = dict["_id"] as? String                   { _id = val }
        if let val = dict["isActive"] as? Bool                { isActive = val }
        if let val = dict["userId"] as? String                { userId = val }
        if let val = dict["default"] as? Bool                 { defaults = val }
    }
    
    func dict_Location() -> [String:Any] {
        var dictLocation = [String:Any]()
        if city != "" {
            dictLocation["city"] = city
        }
        dictLocation["country"] = country
        dictLocation["geoJson"] = geoJson.dict()
        if postalCode != "" && postalCode != "NA" {
            dictLocation["postalCode"] = postalCode
        }
        dictLocation["__v"] = __v
        dictLocation["state"] = state
        if street1 != "" {
            dictLocation["street1"] = street1
        }
        if userId != "" {
            dictLocation["userId"] = userId
        }
        if _id != "" {
            dictLocation["_id"] = _id
        }
        if let val = defaults {
            dictLocation["default"] = val
        }
        
        return dictLocation
    }
}
