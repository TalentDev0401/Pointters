//
//  Shipment.swift
//  Pointters
//
//  Created by Dream Software on 9/10/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Shipment: NSObject {
    var __v = "0"
    var id = ""
    var batchId = ""
    var batchMessage = ""
    var buyerAddress = [String: Any]()
    var createdAt = ""
    var externalId = ""
    var fees = [[String: Any]()]
    var forms = [[String: Any]()]
    var fromAddress = [String: Any]()
    var insurance = ""
    var isActive = false
    var isReturn = false
    var items = [[String: Any]()]
    var messages = [[String:  Any]()]
    var mode = ""
    var options = [String: Any]()
    var orderId = ""
    var parcel = [String: Any]()
    var postageLabel = ""
    var rates = [[String: Any]()]
    var reference = ""
    var refundStatus = ""
    var returnAddress = [String: Any]()
    var scanForm = ""
    var selectedRole = ""
    var status = ""
    var toAddress = [String: Any]()
    var tracker = ""
    var trackingCode = ""
    var updatedAt = ""
    var userId = ""
    var uspsZone = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String : Any]) {
        if let __v = dict["__v"] as? String                                                                 { self.__v = __v }
        if let id = dict["_id"] as? String                                                                  { self.id = id }
        if let batchId = dict["batchId"] as? String                                                     { self.batchId = batchId }
        if let batchMessage = dict["batchMessage"] as? String                                   { self.batchMessage = batchMessage }
        if let buyerAddress = dict["buyerAddress"] as? [String: Any]                           { self.buyerAddress = buyerAddress }
        if let createdAt = dict["createdAt"] as? String                                               { self.createdAt = createdAt }
        if let externalId = dict["externalId"] as? String                                               { self.externalId = externalId }
        if let fees = dict["fees"] as? [[String: Any]]                                                  { self.fees = fees }
        if let forms = dict["forms"] as? [[String: Any]]                                                  { self.forms = forms }
        if let fromAddress = dict["fromAddress"] as? [String: Any]                             { self.fromAddress = fromAddress }
        if let insurance = dict["insurance"] as? String                                               { self.insurance = insurance }
        if let isActive = dict["isActive"] as? Bool                                               { self.isActive = isActive }
        if let isReturn = dict["isReturn"] as? Bool                                               { self.isReturn = isReturn }
        if let items = dict["items"] as? [[String: Any]]                                               { self.items = items }
        if let messages = dict["messages"] as? [[String: Any]]                                  { self.messages = messages }
        if let mode = dict["mode"] as? String                                                       { self.mode = mode }
        if let options = dict["options"] as? [String: Any]                                      { self.options = options }
        if let orderId = dict["orderId"] as? String                                               { self.orderId = orderId }
        if let parcel = dict["parcel"] as? [String: Any]                                            { self.parcel = parcel }
        if let postageLabel = dict["postageLabel"] as? String                                   { self.postageLabel = postageLabel }
        if let rates = dict["rates"] as? [[String: Any]]                                  { self.rates = rates }
        if let reference = dict["reference"] as? String                                               { self.reference = reference }
        if let refundStatus = dict["refundStatus"] as? String                                               { self.refundStatus = refundStatus }
        if let returnAddress = dict["returnAddress"] as? [String: Any]                                            { self.returnAddress = returnAddress }
        if let scanForm = dict["scanForm"] as? String                                               { self.scanForm = scanForm }
        if let selectedRole = dict["selectedRole"] as? String                                               { self.selectedRole = selectedRole }
        if let status = dict["status"] as? String                                               { self.status = status }
        if let toAddress = dict["toAddress"] as? [String: Any]                                               { self.toAddress = toAddress }
        if let tracker = dict["tracker"] as? String                                                     { self.tracker = tracker }
        if let trackingCode = dict["trackingCode"] as? String                                         { self.trackingCode = trackingCode }
        if let updatedAt = dict["updatedAt"] as? String                                         { self.updatedAt = updatedAt }
        if let userId = dict["userId"] as? String                                                   { self.userId = userId }
        if let uspsZone = dict["uspsZone"] as? String                                         { self.uspsZone = uspsZone }
        
    }
    
    func dict() -> [String : Any] {
        var dic = [String : Any]()
        dic["__v"] = __v
        dic["id"] = id
        dic["batchId"] = batchId
        dic["batchMessage"] = batchMessage
        dic["buyerAddress"] = buyerAddress
        dic["createdAt"] = createdAt
        dic["externalId"] = externalId
        dic["fees"] = fees
        dic["forms"] = forms
        dic["fromAddress"] = fromAddress
        dic["insurance"] = insurance
        dic["isActive"] = isActive
        dic["isReturn"] = isReturn
        dic["items"] = items
        dic["messages"] = messages
        dic["mode"] = mode
        dic["options"] = options
        dic["orderId"] = orderId
        dic["parcel"] = parcel
        dic["postageLabel"] = postageLabel
        dic["rates"] = rates
        dic["reference"] = reference
        dic["refundStatus"] = refundStatus
        dic["returnAddress"] = returnAddress
        dic["scanForm"] = scanForm
        dic["selectedRole"] = selectedRole
        dic["status"] = status
        dic["toAddress"] = toAddress
        dic["tracker"] = tracker
        dic["trackingCode"] = trackingCode
        dic["updatedAt"] = updatedAt
        dic["userId"] = userId
        dic["uspsZone"] = uspsZone
        
        return dic
    }
}
