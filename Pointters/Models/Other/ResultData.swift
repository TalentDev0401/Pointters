//
//  ResultData.swift
//  Pointters
//
//  Created by Mac on 2/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ResultData: NSObject {
    
    var order:Order = Order.init()
    var seller:Owner = Owner.init()
    var buyer:Owner = Owner.init()
    var requests:Request = Request.init()
    var requestOffers:RequestOffer = RequestOffer.init()
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["order"] as? [String:Any]              { order = Order.init(dict: val) }
        if let val = dict["seller"] as? [String:Any]             { seller = Owner.init(dict: val) }
        if let val = dict["buyer"] as? [String:Any]              { buyer = Owner.init(dict: val) }
        if let val = dict["requests"] as? [String:Any]           { requests = Request.init(dict: val) }
        if let val = dict["requestOffers"] as? [String:Any]      { requestOffers = RequestOffer.init(dict: val) }
    }
    
    
}
