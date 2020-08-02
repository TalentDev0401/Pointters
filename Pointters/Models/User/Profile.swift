//
//  Profile.swift
//  Pointters
//
//  Created by Mac on 2/22/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Profile: NSObject {

    var id:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var desc:String = ""
    var phone:String = ""
    var companyName:String = ""
    var education:String = ""
    var license:String = ""
    var insurance:String = ""
    var awards:String = ""
    var profilePic:String = ""
    var verified:Bool = false
    var userMetrics:Metrics = Metrics.init()
    var location:Location = Location.init()
    var profileBgMedia = [Media]()
    var shareLink = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["id"] as? String                      { id = val }
        if let val = dict["firstName"] as? String                 { firstName = val }
        if let val = dict["lastName"] as? String                  { lastName = val }
        if let val = dict["description"] as? String               { desc = val }
        if let val = dict["phone"] as? String                     { phone = val }
        if let val = dict["companyName"] as? String               { companyName = val }
        if let val = dict["education"] as? String                 { education = val }
        if let val = dict["license"] as? String                   { license = val }
        if let val = dict["insurance"] as? String                 { insurance = val }
        if let val = dict["awards"] as? String                    { awards = val }
        if let val = dict["verified"] as? Bool                    { verified = val }
        if let val = dict["userMetrics"] as? [String:Any]       { userMetrics = Metrics.init(dict: val) }
        if let val = dict["location"] as? [String:Any]           { location = Location.init(dict: val) }
        if let val = dict["shareLink"] as? String                   { shareLink = val }
        
        if let val = dict["profilePic"] as? String {
            profilePic = val
            if !profilePic.contains("https:") {
                profilePic = "https://s3.amazonaws.com" + profilePic
            }
        }
        if let arr = dict["profileBackgroundMedia"] as? [[String:Any]] {
            profileBgMedia.removeAll()
            for val in arr {
                profileBgMedia.append(Media.init(dict: val))
            }
        }
    }
}
