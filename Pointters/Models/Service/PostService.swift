//
//  PostService.swift
//  Pointters
//
//  Created by super on 4/12/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class PostService: NSObject {
    
    var id:String = ""
    var desc:String = ""
    var location = Location.init()
    var media: [Media] = []
    var prices = Price.init()
    var avgRating:Float = 0.0
    var numOrders:Int = 0
    var pointValue:Int = 0
    
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["id"] as? String                          { id = val }
        if let val = dict["description"] as? String                 { desc = val }
        if let val = dict["avgRating"] as? Float                    { avgRating = val }
        if let val = dict["numOrders"] as? Int                      { numOrders = val }
        if let val = dict["pointValue"] as? Int                     { pointValue = val }
        if let val = dict["location"] {
            if val is Dictionary<AnyHashable,Any> {
                location = Location.init(dict: val as! [String:Any])
            } else if val is Array<Any> {
                let arrLocation = val as! [[String:Any]]
                if arrLocation.count > 0 {
                    location = Location.init(dict: arrLocation[0])
                }
            }
        }
        if let val = dict["prices"] {
            if val is Dictionary<AnyHashable,Any> {
                prices = Price.init(dict: val as! [String:Any])
            } else if val is Array<Any> {
                let arrPrices = val as! [[String:Any]]
                if arrPrices.count > 0 {
                    prices = Price.init(dict: arrPrices[0])
                }
            }
        }
        if let val = dict["media"] {
            if val is Dictionary<AnyHashable,Any> {
                media = [Media.init(dict: val as! [String:Any])]
            } else if val is Array<Any> {
                let arrMedia = val as! [[String:Any]]
                for obj in arrMedia {
                    if let type = obj["mediaType"] as? String, let file = obj["fileName"] as? String {
                        if type != "video" && file != "" {
                            media.append(Media.init(dict: obj))
                        }
                    }
                }
            }
        }
    }
}

