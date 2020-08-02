
//
//  OrderStatus.swift
//  Pointters
//
//  Created by Mac on 2/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class OrderStatus: NSObject {
    
    var id:String = ""
    var paid:Bool = false
    var paidDate:String = ""
    var scheduled:Bool = false
    var scheduledDate:String = ""
    var started:Bool = false
    var startedDate:String = ""
    var completed:Bool = false
    var completedDate:String = ""
    var accepted:Bool = false
    var acceptedDate:String = ""
    var statusCode:String = ""
    var statusDescription:String = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["_id"] as? String                     { id = val }
        if let val = dict["paid"] as? Bool                      { paid = val }
        if let val = dict["paidDate"] as? String                { paidDate = val }
        if let val = dict["scheduled"] as? Bool                      { scheduled = val }
        if let val = dict["scheduledDate"] as? String                { scheduledDate = val }
        if let val = dict["started"] as? Bool                      { started = val }
        if let val = dict["startedDate"] as? String                { startedDate = val }
        if let val = dict["completed"] as? Bool                      { completed = val }
        if let val = dict["completedDate"] as? String                { completedDate = val }
        if let val = dict["accepted"] as? Bool                      { accepted = val }
        if let val = dict["acceptedDate"] as? String                { acceptedDate = val }
        if let val = dict["statusCode"] as? String              { statusCode = val }
        if let val = dict["statusDescription"] as? String       { statusDescription = val }
    }
}
