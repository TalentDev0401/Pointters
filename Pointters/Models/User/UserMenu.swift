//
//  UserMenu.swift
//  Pointters
//
//  Created by Mac on 2/26/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class UserMenu: NSObject {
    
    var followers:Int = 0
    var following:Int = 0
    var points:Int = 0
    var notifications:Int = 0
    var buy = Buy.init()
    var sell = Sell.init()
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["followers"] as? Int           { followers = val }
        if let val = dict["following"] as? Int           { following = val }
        if let val = dict["notifications"] as? Int       { notifications = val }
        if let val = dict["points"] as? Int              { points = val }
        if let val = dict["buy"] as? [String:Any]        { buy = Buy.init(dict: val) }
        if let val = dict["sell"] as? [String:Any]       { sell = Sell.init(dict: val) }
    }

}

class Buy: NSObject {
    
    var offers:Int = 0
    var orders:Int = 0
    var request:Int = 0
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["offers"] as? Int          { offers = val }
        if let val = dict["orders"] as? Int          { orders = val }
        if let val = dict["request"] as? Int        { request = val }
    }
}

class Sell: NSObject {
    
    var offers:Int = 0
    var orders:Int = 0
    var jobs:Int = 0
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["offers"] as? Int          { offers = val }
        if let val = dict["orders"] as? Int          { orders = val }
        if let val = dict["jobs"] as? Int            { jobs = val }
    }
}
