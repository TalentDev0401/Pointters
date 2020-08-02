//
//  BuyerOrderDispute.swift
//  Pointters
//
//  Created by dreams on 10/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class BuyerOrderDispute: NSObject {
    var cancellation:Int = 0
    var message:String = ""
    var reason:String = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["cancellation"] as? Int                 { cancellation = val }
        if let val = dict["message"] as? String                  { message = val }
        if let val = dict["reason"] as? String                { reason = val }
    }
    
    func dict() -> [String:Any] {
        var dispute = [String:Any]()
        dispute["cancellation"] = cancellation
        dispute["message"] = message
        dispute["reason"] = reason
        return dispute
    }
}
