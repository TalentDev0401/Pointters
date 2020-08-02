//
//  Category.swift
//  Pointters
//
//  Created by Mac on 2/23/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Category: NSObject {

    var id:String = ""
    var name:String = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["_id"] as? String                 { id = val }
        if let val = dict["id"] as? String                  { id = val }
        if let val = dict["name"] as? String                { name = val }
    }
    
    func dict() -> [String:Any] {
        var dictCategory = [String:Any]()
        dictCategory["id"] = id
        dictCategory["name"] = name
        return dictCategory
    }
}
