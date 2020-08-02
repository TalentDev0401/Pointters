//
//  Follow.swift
//  Pointters
//
//  Created by Mac on 2/23/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Follow: NSObject {

    var categories = [String]()
    var followTo = Owner.init()
    var followFrom = Owner.init()
    
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["categories"] as? [String]            { categories = val }
        if let val = dict["followTo"] as? [String:Any]          { followTo = Owner.init(dict: val) }
        if let val = dict["followFrom"] as? [String:Any]        { followFrom = Owner.init(dict: val) }        
    }
}
