//
//  Owner.swift
//  Pointters
//
//  Created by Mac on 2/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Owner: NSObject {

    var id:String = ""
    var userId:String = ""
    var sellerId:String = ""
    var buyerId:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var companyName:String = ""
    var phone:String = ""
    var profilePic:String = ""
    var isMutualFollow:Bool = false
    var location:Location = Location.init()
    
    var verified:Bool = false
    var high:Float = 0.0
    var low:Float = 0.0
    var currencyCode:String = ""
    var currencySymbol:String = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["id"] as? String                  { id = val }
        if let val = dict["userId"] as? String              { userId = val }
        if let val = dict["sellerId"] as? String            { sellerId = val }
        if let val = dict["buyerId"] as? String             { buyerId = val }
        if let val = dict["firstName"] as? String             { firstName = val }
        if let val = dict["lastName"] as? String              { lastName = val }
        if let val = dict["companyName"] as? String           { companyName = val }
        if let val = dict["phone"] as? String                 { phone = val }
        if let val = dict["verified"] as? Bool                { verified = val }
        if let val = dict["isMutualFollow"] as? Bool        { isMutualFollow = val }
        if let val = dict["high"] as? Float                 { high = val }
        if let val = dict["low"] as? Float                  { low = val }
        if let val = dict["currencyCode"] as? String        { currencyCode = val }
        if let val = dict["currencySymbol"] as? String      { currencySymbol = val }
        if let val = dict["location"] as? [String:Any]       { location = Location.init(dict: val) }
        
        if let val = dict["profilePic"] as? String {
            profilePic = val
            if !profilePic.contains("https:") {
                profilePic = "https://s3.amazonaws.com" + profilePic
            }
        }
        
    }
}
