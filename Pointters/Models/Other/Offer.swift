//
//  Offer.swift
//  Pointters
//
//  Created by Mac on 2/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Offer: NSObject {
    
    var createdAt:String = ""
    var desc:String = ""
    var location:Location = Location.init()
    var media:Media = Media.init()
    var offerId:String = ""
    var price:Float = 0.0
    var currencyCode:String = ""
    var currencySymbol:String = ""
    var seller:Owner = Owner.init()
    var buyer:Owner = Owner.init()
    var sellerId:String = ""
    var serviceId:String = ""
    var workDuration:Int = 0
    var workDurationUom:String = ""
    var closed:Bool = false
    var orderId: String = ""
    var expiresIn: Int = 7
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["createdAt"] as? String               { createdAt = val }
        if let val = dict["description"] as? String               { desc = val }
        if let val = dict["location"] as? [String:Any]           { location = Location.init(dict: val) }
        if let val = dict["offerId"] as? String                 { offerId = val }
        if let val = dict["price"] as? Float                    { price = val }
        if let val = dict["currencyCode"] as? String            { currencyCode = val }
        if let val = dict["currencySymbol"] as? String          { currencySymbol = val }
        if let val = dict["seller"] as? [String:Any]            { seller = Owner.init(dict: val) }
        if let val = dict["buyer"] as? [String:Any]             { buyer = Owner.init(dict: val) }
        if let val = dict["sellerId"] as? String                { sellerId = val }
        if let val = dict["serviceId"] as? String               { serviceId = val }
        if let val = dict["workDuration"] as? Int               { workDuration = val }
        if let val = dict["workDurationUom"] as? String         { workDurationUom = val }
        if let val = dict["closed"] as? Bool                            { closed = val }
        if let val = dict["orderId"] as? String                         { orderId = val }
        if let val = dict["expiresIn"] as? NSNumber               {expiresIn = val.intValue}
        
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
