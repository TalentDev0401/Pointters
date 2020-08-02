//
//  FulFillment.swift
//  Pointters
//
//  Created by Mac on 2/25/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class FulFillment: NSObject {
    
    var online:Bool = false
    var shipment:Bool = false
    var local:Bool = false
    var store:Bool = false
    var localServiceRadiusUom:String = "mile"
    var localServiceRadius:Int = 0
    var shipmentAddress = ShipAddress.init()
    var shipmentParcel = ShipParcel.init()
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["online"] as? Bool                        { online = val }
        if let val = dict["shipment"] as? Bool                      { shipment = val }
        if let val = dict["local"] as? Bool                         { local = val }
        if let val = dict["store"] as? Bool                         { store = val }
        if let val = dict["localServiceRadius"] as? Int             { localServiceRadius = val }
        if let val = dict["localServiceRadiusUom"] as? String       { localServiceRadiusUom = val }
        if let val = dict["address"] as? [String:Any]               { shipmentAddress = ShipAddress.init(dict: val)}
        if let val = dict["parcel"] as? [String:Any]                { shipmentParcel = ShipParcel.init(dict: val)}
    }
    
    func dict() -> [String:Any] {
        var dictFulfillment = [String:Any]()
        dictFulfillment["online"] = online
        dictFulfillment["shipment"] = shipment
        dictFulfillment["local"] = local
        dictFulfillment["store"] = store
        dictFulfillment["localServiceRadius"] = localServiceRadius
        dictFulfillment["localServiceRadiusUom"] = localServiceRadiusUom
        if shipment {
            dictFulfillment["address"] = shipmentAddress.dict()
            dictFulfillment["parcel"] = shipmentParcel.dict()
        }
        
        return dictFulfillment
    }
}
