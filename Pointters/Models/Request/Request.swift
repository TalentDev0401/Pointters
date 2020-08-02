//
//  Request.swift
//  Pointters
//
//  Created by Mac on 2/22/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Request: NSObject {
    
    var id:String = ""
    var requestId:String = ""
    var createdAt:String = ""
    var desc:String = ""
    var expiresIn:Int = 0
    var currencyCode:String = ""
    var currencySymbol:String = ""
    var high:Float = 0.0
    var low:Float = 0.0
    var media:Media = Media.init()
    var numNewOffers:Int = 0
    var numOffers:Int = 0
    var orderId:String = ""
    var cloesd: Bool = false
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["id"] as? String                      { id = val }
        if let val = dict["requestId"] as? String               { requestId = val }
        if let val = dict["createdAt"] as? String               { createdAt = val }
        if let val = dict["description"] as? String               { desc = val }
        if let val = dict["expiresIn"] as? Int                  { expiresIn = val }
        if let val = dict["currencyCode"] as? String            { currencyCode = val }
        if let val = dict["currencySymbol"] as? String          { currencySymbol = val }
        if let val = dict["high"] as? Float                     { high = val }
        if let val = dict["low"] as? Float                      { low = val }
        if let val = dict["numNewOffers"] as? Int               { numNewOffers = val }
        if let val = dict["numOffers"] as? Int                  { numOffers = val }
        if let val = dict["orderId"] as? String                 { orderId = val }
        if let val = dict["closed"] as? Bool                     { cloesd = val }
        
        if let val = dict["media"] {
            if val is Dictionary<AnyHashable,Any> {
                media = Media.init(dict: val as! [String:Any])
            } else if val is Array<Any> {
                let arrMedia = val as! [[String:Any]]
                for obj in arrMedia {
                    if let type = obj["mediaType"] as? String, let file = obj["fileName"] as? String {
                        if type != "video" && file != "" {
                            media = Media.init(dict: obj)
                            break
                        }
                    }
                }
            }
        }
    }
}
