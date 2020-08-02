//
//  MerchantAccount.swift
//  Pointters
//
//  Created by dreams on 1/29/19.
//  Copyright © 2019 Kenji. All rights reserved.
//

import UIKit

class MerchantAccount: NSObject {
    
    var id = ""
    var business_name = ""
    var email = ""
    var type = ""
    var country = ""
    var default_currency = ""
    var object = ""
    var account_holder_name = ""
    var account_holder_type = ""
    var bank_name = ""
    var currency = ""
    var routing_number = ""
    var account_number = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["_id"] as? String                         { id = val }
        if let val = dict["business_name"] as? String       { business_name = val }
    }
    
    func dict() -> [String:Any] {
        var dict = [String:Any]()
        dict["business_name"] = business_name
        dict["email"] = email
        dict["default_currency"] = default_currency
        var external_account = [String: Any]()
        external_account["object"] = object
        external_account["account_holder_name"] = account_holder_name
        external_account["account_holder_type"] = account_holder_type
        external_account["bank_name"] = bank_name
        external_account["country"] = country
        external_account["currency"] = currency
        external_account["routing_number"] = routing_number
        external_account["account_number"] = account_number
        
        dict["external_account"] = external_account
        
        return dict
    }
}
