//
//  CommentUser.swift
//  Pointters
//
//  Created by super on 4/12/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class CommentUser: NSObject {
    
    var userId:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var profilePic:String = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["userId"] as? String                     { userId = val }
        if let val = dict["firstName"] as? String                  { firstName = val }
        if let val = dict["lastName"] as? String                   { lastName = val }
        if let val = dict["profilePic"] as? String                 { profilePic = val }
    }
    
}
