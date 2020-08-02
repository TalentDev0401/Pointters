//
//  ActionButton.swift
//  Pointters
//
//  Created by dreams on 10/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ActionButton: NSObject {
    var pendingOn:String = ""
    var type:String = ""
    var text:String = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["actionPendingOn"] as? String                 { pendingOn = val }
        if let val = dict["actionType"] as? String                  { type = val }
        if let val = dict["buttonText"] as? String                { text = val }
    }
    
    func dict() -> [String:Any] {
        var act = [String:Any]()
        act["actionPendingOn"] = pendingOn
        act["actionType"] = type
        act["buttonText"] = text
        return act
    }
}
