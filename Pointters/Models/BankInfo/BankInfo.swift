//
//  BankInfo.swift
//  Pointters
//
//  Created by Billiard ball on 29.05.2020.
//  Copyright © 2020 Kenji. All rights reserved.
//

import Foundation

class BankInfo {
    
    var code: String = ""
    var name: String = ""
    
    init(dic: [String: Any]) {
        self.code = dic["code"] as! String
        self.name = dic["name"] as! String
    }
}
