//
//  LikeUser.swift
//  Pointters
//
//  Created by super on 4/13/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class LikeUser: NSObject {
    
    var id = ""
    var firstName = ""
    var lastName = ""
    var companyName = ""
    var profilePic = ""
    var location = Location.init()
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["id"] as? String                         { id = val }
        if let val = dict["firstName"] as? String                  { firstName = val }
        if let val = dict["lastName"] as? String                   { lastName = val }
        if let val = dict["companyName"] as? String                { companyName = val }
        if let val = dict["profilePic"] as? String                 { profilePic = val }
        if let val = dict["location"] as? [String:Any]             { location = Location.init(dict: val)}
    }
    
}
