//
//  RequestOffer.swift
//  Pointters
//
//  Created by Mac on 2/22/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class RequestOffer: NSObject {

    var createdAt:String = ""
    var expiresIn:Int = 0
    var numOffers:Int = 0
    var request:Request = Request.init()
    var requester:Owner = Owner.init()
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["createdAt"] as? String               { createdAt = val }
        if let val = dict["expiresIn"] as? Int                  { expiresIn = val }
        if let val = dict["numOffers"] as? Int                  { numOffers = val }
        if let val = dict["request"] as? [String:Any]           { request = Request.init(dict: val) }
        if let val = dict["requester"] as? [String:Any]         { requester = Owner.init(dict: val) }
    }
}
