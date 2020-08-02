//
//  PostUser.swift
//  Pointters
//
//  Created by super on 4/12/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class PostUser: NSObject {
    
    var id:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var companyName:String = ""
    var profilePic:String = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["id"] as? String                         { id = val }
        if let val = dict["firstName"] as? String                  { firstName = val }
        if let val = dict["lastName"] as? String                   { lastName = val }
        if let val = dict["companyName"] as? String                { companyName = val }
        if let val = dict["profilePic"] as? String                 { profilePic = val }
    }
    
}
