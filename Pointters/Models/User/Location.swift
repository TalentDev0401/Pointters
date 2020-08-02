//
//  Location.swift
//  Pointters
//
//  Created by Mac on 2/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Location: NSObject {

    var city:String = "NA"
    var country:String = "NA"
    var geoJson:GeoJson = GeoJson.init()
    var postalCode:String = ""
    var province:String = "NA"
    var state:String = "NA"
    var street: String = ""
    var street2: String = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["city"] as? String                  { city = val }
        if let val = dict["country"] as? String               { country = val }
        if let val = dict["geoJson"] as? [String:Any]        { geoJson = GeoJson.init(dict: val) }
        if let val = dict["postalCode"] as? String            { postalCode = val }
        if let val = dict["province"] as? String              { province = val }
        if let val = dict["state"] as? String                 { state = val }
        if let val = dict["street"] as? String                  { street = val }
        if let val = dict["street1"] as? String {
            street = val
        }
        if let val = dict["street2"] as? String                 { street2 = val }
    }
    
    func dict() -> [String:Any] {
        var dictLocation = [String:Any]()
        if city != "" {
            dictLocation["city"] = city
        }
        dictLocation["country"] = country
        dictLocation["geoJson"] = geoJson.dict()
        if postalCode != "" && postalCode != "NA" {
            dictLocation["postalCode"] = postalCode
        }
        dictLocation["province"] = province
        dictLocation["state"] = state
        if street != "" {
            dictLocation["street"] = street
            dictLocation["street1"] = street
        }
        if street2 != "" {
            dictLocation["street2"] = street2
        }
        
        return dictLocation
    }
}

class GeoJson: NSObject {
    
    var type:String = "Point"
    var coordinates = [Double]()
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["type"] as? String                 { type = val }
        if let val = dict["coordinates"] as? [Double]        { coordinates = val }
    }
    
    func dict() -> [String:Any] {
        var dictGeo = [String:Any]()
        dictGeo["type"] = type
        dictGeo["coordinates"] = coordinates
        return dictGeo
    }
    
}
