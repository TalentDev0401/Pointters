//
//  Notification.swift
//  Pointters
//
//  Created by super on 4/11/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Notification: NSObject {
    var id:String = ""
    var activity:String = ""
    var type:String = ""
    var names:String = ""
    var profilePic:String = ""
    var markedRead:Bool = false
    var time:String = ""
    var userId:String = ""
    var serviceId:String = ""
    var postId:String = ""
    var orderId:String = ""
    var requestId:String = ""
    var media = Media.init()
    
    //chat type
    var conversationId = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["id"] as? String                          { id = val }
        if let val = dict["activity"] as? String                    { activity = val }
        if let val = dict["type"] as? String                        { type = val }
        if let val = dict["names"] as? String                       { names = val }
        if let val = dict["profilePic"] as? String                  { profilePic = val }
        if let val = dict["time"] as? String                        { time = val }
        if let val = dict["markedRead"] as? Bool                    { markedRead = val }
        if let val = dict["userId"] as? String                      { userId = val }
        if let val = dict["serviceId"] as? String                   { serviceId = val }
        if let val = dict["postId"] as? String                      { postId = val }
        if let val = dict["orderId"] as? String                     {orderId = val}
        if let val = dict["conversationId"] as? String          {conversationId = val}
        if let val = dict["requestId"] as? String                   {requestId = val}
        
        if let val = dict["link"] as? [String: Any] {
            if let value = val["media"] as? [String: Any] {
                media = Media.init(dict: value)
            }
        }
        
        if let val = dict["media"] as? [String:Any]                 { media = Media.init(dict: val) }
    }
    
}
