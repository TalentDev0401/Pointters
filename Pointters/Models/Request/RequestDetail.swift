//
//  RequestDetail.swift
//  Pointters
//
//  Created by super on 4/30/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class RequestDetail: NSObject {
    
    var id = ""
    var createdAt = ""
    var updatedAt = ""
    var media = [Media]()
    var category = Category.init()
    var location = Location.init()
    var desc = ""
    var minPrice:Float = 0.0
    var maxPrice:Float = 0.0
    var currencyCode = ""
    var currencySymbol = ""
    var scheduleDate = ""
    var userId = ""
    var onlineJob = true
    var numOffers = 0
    var numNewOffers = 0
    var shareLink = ""
    var closed = false
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["_id"] as? String {
            id = val            
        } else if let val = dict["id"] as? String {
            id = val
        }
        if let val = dict["createdAt"] as? String               { createdAt = val }
        if let val = dict["updatedAt"] as? String               { updatedAt = val }
        if let val = dict["media"] as? [[String:Any]] {
            media.removeAll()
            for obj in val {
                media.append(Media.init(dict: obj))
            }
        }
        if let val = dict["category"] as? [String:Any]          { category = Category.init(dict: val) }
        if let val = dict["location"] as? [String:Any]          { location = Location.init(dict: val) }
        if let val = dict["description"] as? String             { desc = val }
        if let val = dict["minPrice"] as? Float                 { minPrice = val }
        if let val = dict["maxPrice"] as? Float                 { maxPrice = val }
        if let val = dict["currencyCode"] as? String            { currencyCode = val }
        if let val = dict["currencySymbol"] as? String          { currencySymbol = val }
        if let val = dict["scheduleDate"] as? String            { scheduleDate = val }
        if let val = dict["userId"] as? String                  { userId = val }
        if let val = dict["onlineJob"] as? Bool                 { onlineJob = val }
        if let val = dict["numOffers"] as? Int        { numOffers = val }
        if let val = dict["numNewOffers"] as? Int        { numNewOffers = val }
        if let val = dict["shareLink"] as? String           { shareLink = val }
        if let val = dict["closed"] as? Bool                   { closed = val }
    }
}
