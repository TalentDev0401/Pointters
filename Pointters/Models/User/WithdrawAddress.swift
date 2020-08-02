//
//  WithdrawAddress.swift
//  Pointters
//
//  Created by dreams on 11/5/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class WithdrawAddress: NSObject {
    
    var streetAddress = ""
    var locality = ""
    var region = ""
    var postalCode = ""
    var hasState = true
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["streetAddress"] as? String                  { streetAddress = val }
        if let val = dict["locality"] as? String              { locality = val }
        if let val = dict["region"] as? String  {
            region = val
            hasState = true
        } else {
            hasState = false
        }
        if let val = dict["postalCode"] as? String             { postalCode = val }
    }
    
    func dict() -> [String:Any] {
        var dict = [String:Any]()
        dict["streetAddress"] = streetAddress
        dict["locality"] = locality
        dict["region"] = region
        dict["postalCode"] = postalCode
        
        return dict
    }
}
