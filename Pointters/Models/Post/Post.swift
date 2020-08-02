//
//  Post.swift
//  Pointters
//
//  Created by super on 4/12/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Post: NSObject {
    
    var id:String = ""
    var message:String = ""
    var type:String = ""
    var createdAt:String = ""
    var updatedAt:String = ""
    var countLikes = 0
    var countComments = 0
    var countShares = 0
    var tag = PostTag.init()
    var media: [Media] = []
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["id"] as? String                         { id = val }
        if let val = dict["message"] as? String                    { message = val }
        if let val = dict["type"] as? String                       { type = val }
        if let val = dict["createdAt"] as? String                  { createdAt = val }
        if let val = dict["updatedAt"] as? String                  { updatedAt = val }
        if let val = dict["countLikes"] as? Int                    { countLikes = val }
        if let val = dict["countComments"] as? Int                 { countComments = val }
        if let val = dict["countShares"] as? Int                   { countShares = val }
        if let val = dict["tags"] as? [[String:Any]]               { tag = PostTag.init(dict: val[0]) }
        if let val = dict["media"]                                 {
            
            if val is Dictionary<AnyHashable,Any> {
                media = [Media.init(dict: val as! [String:Any])]
            } else if val is Array<Any> {
                let arrMedia = val as! [[String:Any]]
                for obj in arrMedia {
                    if let file = obj["fileName"] as? String {
                        if file != "" {
                            media.append(Media.init(dict: obj))
                        }
                    }
                }
            }
        }
    }
    
}
