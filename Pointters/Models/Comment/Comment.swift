//
//  Comment.swift
//  Pointters
//
//  Created by super on 4/12/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Comment: NSObject {
    
    var comment = ""
    var updatedAt = ""
    var user = CommentUser.init()
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["comment"] as? String                    { comment = val }
        if let val = dict["updatedAt"] as? String                  { updatedAt = val }
        if let val = dict["user"] as? [String:Any]                 { user = CommentUser.init(dict: val) }
    }
    
}
