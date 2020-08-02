//
//  UserService.swift
//  Pointters
//
//  Created by Mac on 2/23/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class UserService: NSObject {
    
    var avgRating:Float = 0.0
    var numOrders:Int = 0
    var pointValue:Int = 0
    var ratingCount:Int = 0
    var service = Service.init()
    var user = Owner.init()

    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["avgRating"] as? Float            { avgRating = val }
        if let val = dict["numOrders"] as? Int              { numOrders = val }
        if let val = dict["pointValue"] as? Int             { pointValue = val }
        if let val = dict["ratingCount"] as? Int            { ratingCount = val }
        if let val = dict["service"] as? [String:Any]       { service = Service.init(dict: val) }
        if let val = dict["user"] as? [String:Any]          { user = Owner.init(dict: val) }
    }
}
