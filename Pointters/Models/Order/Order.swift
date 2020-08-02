//
//  Order.swift
//  Pointters
//
//  Created by Mac on 2/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Order: NSObject {
    
    var id:String = ""
    var currencyCode:String = ""
    var currencySymbol:String = ""
    var tagline: String = ""
    var desc:String = ""
    var media:Media = Media.init()
    var notificationCount:Int = 0
    var orderMilestoneStatuses:OrderStatus = OrderStatus.init()
    var paymentDate:String = ""
    var priceDescription:String = ""
    var serviceLocation:Location = Location.init()
    var status:String = ""
    var totalAmount:Float = 0.0
    var totalAmountBeforeDiscount:Float = 0.0
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["id"] as? String                                  { id = val }
        if let val = dict["currencyCode"] as? String                        { currencyCode = val }
        if let val = dict["currencySymbol"] as? String                      { currencySymbol = val }
        if let val = dict["description"] as? String                           { desc = val }
        if let val = dict["tagline"] as? String                                 { tagline = val }
        if let val = dict["notificationCount"] as? Int                      { notificationCount = val }
        if let val = dict["orderMilestoneStatuses"] as? [String:Any]       { orderMilestoneStatuses = OrderStatus.init(dict: val) }
        if let val = dict["paymentDate"] as? String                         { paymentDate = val }
        if let val = dict["priceDescription"] as? String                    { priceDescription = val }
        if let val = dict["serviceLocation"] as? [String:Any]               { serviceLocation = Location.init(dict: val) }
        if let val = dict["totalAmount"] as? NSNumber                          { totalAmount = val.floatValue }
        if let val = dict["totalAmountBeforeDiscount"] as? NSNumber            { totalAmountBeforeDiscount = val.floatValue }
        if let val = dict["status"] as? String                              { status = val}
        
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
