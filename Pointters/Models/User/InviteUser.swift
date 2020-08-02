//
//  InviteUser.swift
//  Pointters
//
//  Created by super on 4/26/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class InviteUser: NSObject {
    
    var userId = ""
    var firstName:String = ""
    var lastName:String = ""
    var numServices = 0
    var pointValue = 0
    var numOrders = 0
    var numFollowers = 0
    var avgRating:Float = 0.0
    var hasFollowed = false
    var categories = [String]()
    var profilePic = ""
    var services = [Service]()

    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["userId"] as? String                    { userId = val }
        if let val = dict["firstName"] as? String                 { firstName = val }
        if let val = dict["lastName"] as? String                  { lastName = val }
        if let val = dict["numServices"] as? Int                  { numServices = val }
        if let val = dict["numFollowers"] as? Int                 { numFollowers = val }
        if let val = dict["pointValue"] as? Int                   { pointValue = val }
        if let val = dict["numOrders"] as? Int                    { numOrders = val }
        if let val = dict["avgRating"] as? Float                  { avgRating = val }
        if let val = dict["hasFollowed"] as? Bool                 { hasFollowed = val }
        if let val = dict["profilePic"] as? String {
            profilePic = val
            if !profilePic.contains("https:") {
                profilePic = "https://s3.amazonaws.com" + profilePic
            }
        }
        if let arr = dict["categories"] as? [String] {
            categories.removeAll()
            for val in arr {
                categories.append(val)
            }
        }
        if let arr = dict["services"] as? [[String:Any]] {
            services.removeAll()
            for val in arr {
                services.append(Service.init(dict: val))
            }
        }
    }
}
