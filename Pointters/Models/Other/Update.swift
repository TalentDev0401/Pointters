//
//  Update.swift
//  Pointters
//
//  Created by super on 4/11/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Update: NSObject {
    
    var user = PostUser.init()
    var liked = false
    var post = Post.init()
    var comments = [Comment]()
    var service = PostService.init()
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["user"] as? [String:Any]                  { user = PostUser.init(dict: val) }
        if let val = dict["liked"] as? Bool                         { liked = val }
        if let val = dict["post"] as? [String:Any]                  { post = Post.init(dict: val) }
        if let val = dict["comments"] as? [[String:Any]]{
            comments.removeAll()
            for item in val  {
                comments.append(Comment.init(dict: item))
            }
        }
        if let val = dict["service"] as? [String:Any]               { service = PostService.init(dict: val)}
    }
    
}

