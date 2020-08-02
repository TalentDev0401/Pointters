//
//  PostTag.swift
//  Pointters
//
//  Created by super on 4/12/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class PostTag: NSObject {
    
    var type = ""
    var userId = ""
    var firstName = ""
    var lastName = ""
    var profilePic = ""
    var location = Location.init()
    var serviceId = ""
    var serviceDesc = ""
    var media = Media.init()
    var price = Price.init()
    var pointValue = 0
    var numOrders = 0
    var avgRating:Float = 0.0
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["type"] as? String                       { type = val }
        if type == "user"{
            if let val = dict["userId"] as? String                 { userId = val }
            if let val = dict["firstName"] as? String              { firstName = val }
            if let val = dict["lastName"] as? String               { lastName = val }
            if let val = dict["profilePic"] as? String             { profilePic = val }
            if let val = dict["location"] as? [String:Any]         { location = Location.init(dict: val) }
        } else if type == "service" {
            if let val = dict["serviceId"] as? String              { serviceId = val }
            if let val = dict["description"] {
                serviceDesc = val as! String
            }
            if let val = dict["media"] as? [String:Any]            { media = Media.init(dict: val) }
            if let val = dict["prices"] as? [[String:Any]]         { price = Price.init(dict: val[0]) }
            if let val = dict["location"] as? [[String:Any]]       {
                if val.count > 0 {
                    location = Location.init(dict: val[0])
                }
            }
            if let val = dict["pointValue"] as? Int                { pointValue = val }
            if let val = dict["numOrders"] as? Int                 { numOrders = val }
            if let val = dict["avgRating"] as? Float               { avgRating = val }
        } else if type == "post" {
            if let val = dict["serviceId"] as? String              { serviceId = val }
            if let val = dict["description"] as? String            { serviceDesc = val }
            if let val = dict["media"] as? [String:Any]            { media = Media.init(dict: val) }
            if let val = dict["prices"] as? [[String:Any]]         { price = Price.init(dict: val[0]) }
            if let val = dict["location"] as? [[String:Any]]       {
                if val.count > 0 {
                    location = Location.init(dict: val[0])
                }
            }
            if let val = dict["pointValue"] as? Int                { pointValue = val }
            if let val = dict["numOrders"] as? Int                 { numOrders = val }
            if let val = dict["avgRating"] as? Float               { avgRating = val }
        }
    }
    
}
