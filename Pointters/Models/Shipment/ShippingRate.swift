//
//  ShippingRate.swift
//  Pointters
//
//  Created by Dream Software on 9/9/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ShippingRate: NSObject {
    var id = ""
    var service = ""
    var carrier = ""
    var rate = "0.00"
    var currency = ""
    var retailRate = ""
    var retailCurrency = ""
    var listRate = ""
    var listCurrency = ""
    var deliveryDays = ""
    var deliveryDate = ""
    var deliveryDateGuaranteed = false
    var estDeliveryDays = ""
    var carrierAccountId = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String : Any]) {
        if let id = dict["_id"] as? String                                                                 { self.id = id }
        if let service = dict["service"] as? String                                                     { self.service = service}
        if let carrier = dict["carrier"] as? String                                                      { self.carrier = carrier }
        if let rate = dict["rate"] as? String                                                                { self.rate = rate }
        if let currency = dict["currency"] as? String                                                    { self.currency = currency }
        if let retailRate = dict["retailRate"] as? String                                               { self.retailRate = retailRate }
        if let retailCurrency = dict["retailCurrency"] as? String                                   { self.retailCurrency = retailCurrency }
        if let listRate = dict["listRate"] as? String                                                        { self.listRate = listRate }
        if let listCurrency = dict["listCurrency"] as? String                                       { self.listCurrency = listCurrency }
        if let deliveryDays = dict["deliveryDays"] as? String                                       { self.deliveryDays = deliveryDays }
        if let deliveryDate = dict["deliveryDate"] as? String                                       { self.deliveryDate = deliveryDate }
        if let deliveryDateGuaranteed = dict["deliveryDateGuaranteed"] as? Bool     { self.deliveryDateGuaranteed = deliveryDateGuaranteed }
        if let estDeliveryDays = dict["estDeliveryDays"] as? String                         { self.estDeliveryDays = estDeliveryDays }
        if let carrierAccountId = dict["carrierAccountId"] as? String                           { self.carrierAccountId = carrierAccountId }
    }
    
    func dict() -> [String : Any] {
        var dic = [String : Any]()
        dic["id"] = id
        dic["service"] = service
        dic["carrier"] = carrier
        dic["rate"] = rate
        dic["currency"] = currency
        dic["retailRate"] = retailRate
        dic["retailCurrency"] = retailCurrency
        dic["listRate"] = listRate
        dic["listCurrency"] = listCurrency
        dic["deliveryDays"] = deliveryDays
        dic["deliveryDate"] = deliveryDate
        dic["deliveryDateGuaranteed"] = deliveryDateGuaranteed
        dic["estDeliveryDays"] = estDeliveryDays
        dic["carrierAccountId"] = carrierAccountId
        
        return dic
    }
}
