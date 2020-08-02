//
//  ShipParcel.swift
//  Pointters
//
//  Created by super on 5/29/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ShipParcel: NSObject {
    
    var length:Float = 0.0
    var width:Float = 0.0
    var height:Float = 0.0
    var weight:Float = 1.0
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["length"] as? Float                  { length = val }
        if let val = dict["width"] as? Float                   { width = val }
        if let val = dict["height"] as? Float                  { height = val }
        if let val = dict["weight"] as? Float                  { weight = val }
    }
    
    func dict() -> [String:Any] {
        var dictParcel = [String:Any]()
        dictParcel["length"] = length
        dictParcel["width"] = width
        dictParcel["height"] = height
        dictParcel["weight"] = weight
        return dictParcel
    }
}
