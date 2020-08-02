//
//  Metrics.swift
//  Pointters
//
//  Created by Mac on 2/22/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Metrics: NSObject {

    var avgOnTime:Float = 100.0
    var avgQuality:Float = 5.0
    var avgRating:Int = 100
    var avgResponseTime:Float = 0.0
    var avgWillingToBuyAgain:Float = 100.0
    var numLikes:Int = 0
    var numOrdersCompleted:Int = 0
    var numWatching:Int = 0
    var pointValue:Int = 0

    override init() {
        super.init()
    }

    init(dict:[String:Any]) {
        if let val = dict["avgOnTime"] as? Float                { avgOnTime = val }
        if let val = dict["avgQuality"] as? Float               { avgQuality = val }
        if let val = dict["avgRating"] as? Int                  { avgRating = val }
        if let val = dict["avgResponseTime"] as? Float          { avgResponseTime = val }
        if let val = dict["avgWillingToBuyAgain"] as? Float     { avgWillingToBuyAgain = val }
        if let val = dict["numLikes"] as? Int                   { numLikes = val }
        if let val = dict["numOrdersCompleted"] as? Int         { numOrdersCompleted = val }
        if let val = dict["numWatching"] as? Int                { numWatching = val }
        if let val = dict["pointValue"] as? Int                 { pointValue = val }
    }
}
