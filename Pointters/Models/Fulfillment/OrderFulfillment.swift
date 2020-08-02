//
//  OrderFulfillment.swift
//  Pointters
//
//  Created by super on 5/22/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class OrderFulfillment: NSObject {
    
    var id:String = ""
    var createdAt:String = ""
    var updatedAt:String = ""
    var buyerId:String = ""
    var action:ActionButton = ActionButton.init()
    var category:Category = Category.init()
    var currencyCode:String = ""
    var currencySymbol:String = ""
    var desc:String = ""
    var tagLine: String = ""
    var fulfillmentMethod:FulFillment = FulFillment.init()
    var orderMilestoneStatuses:OrderStatus = OrderStatus.init()
    var paymentDate:String = ""
    var paymentMethod:PaymentMethod = PaymentMethod.init()
    var sellerId:String = ""
    var serviceId:String = ""
    var totalAmount:Float = 0.0
    var totalAmountBeforeDiscount:Float = 0.0
    var sellerAcceptedScheduleTime:Bool = false
    var sellerAcceptedBuyerServiceLocation:Bool = false
    var servicesPrices = [Price]()
    var sellerServiceLocation = [Location]()
    var sellerDeliveredMedia = [Media]()
    var orderItems = [OrderItem]()
    var buyerServiceLocation = Location.init()
    var taxAmount: Float = 0.0
    var transactionFee: Float = 0.0
    var shippingFee: Float = 0.0
    var contact: Owner = Owner.init()
    
    var serviceStartDate = ""
    var serviceScheduleDate = ""
    var serviceCompleteDate = ""
    var serviceScheduleEndDate = ""
    
    var orderAcceptanceDate = ""
    var cancellationDate = ""
    
    var buyerDisputeDate = ""
    
    var totalWorkDurationHours = 0
    
    var statusDescription = ""
    
    var buyerOrderDispute = BuyerOrderDispute.init()
//    var media:Media = Media.init()
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["_id"] as? String                                 { id = val }
        if let val = dict["createdAt"] as? String                           { createdAt = val }
        if let val = dict["updatedAt"] as? String                           { updatedAt = val }
        if let val = dict["buyerId"] as? String                             { buyerId = val }
        if let val = dict["actionButton"] as? [String: Any]                 {action = ActionButton.init(dict: val)}
        if let val = dict["category"] as? [String:Any]                      { category = Category.init(dict: val) }
        if let val = dict["currencyCode"] as? String                        { currencyCode = val }
        if let val = dict["currencySymbol"] as? String                      { currencySymbol = val }
        if let val = dict["description"] as? String                         { desc = val }
        if let val = dict["tagline"] as? String                                     { tagLine = val}
        if let val = dict["fulfillmentMethod"] as? [String:Any]             { fulfillmentMethod = FulFillment.init(dict: val) }
        if let val = dict["orderMilestoneStatuses"] as? [String:Any]        { orderMilestoneStatuses = OrderStatus.init(dict: val) }
        if let val = dict["paymentDate"] as? String                         { paymentDate = val }
        if let val = dict["paymentMethod"] as? [String:Any]                 { paymentMethod = PaymentMethod.init(dict: val) }
        if let val = dict["sellerId"] as? String                            { sellerId = val }
        if let val = dict["serviceId"] as? String                           { serviceId = val }
        if let val = dict["totalAmount"] as? NSNumber                          {
            totalAmount = val.floatValue
        }
        if let val = dict["totalAmountBeforeDiscount"] as? Float            { totalAmountBeforeDiscount = val }
        if let val = dict["sellerAcceptedScheduleTime"] as? Bool            { sellerAcceptedScheduleTime = val }
        if let val = dict["sellerAcceptedBuyerServiceLocation"] as? Bool    { sellerAcceptedBuyerServiceLocation = val }
        if let val = dict["shippingFee"] as? NSNumber                                     { shippingFee = val.floatValue}
        if let val = dict["transactionFee"] as? NSNumber                                  { transactionFee = val.floatValue}
        if let val = dict["taxAmount"] as? NSNumber                                       { taxAmount = val.floatValue}
        if let val = dict["contact"] as? [String: Any]                                   {contact = Owner.init(dict: val)}
        
        if let val = dict["servicesPrices"] as? [[String:Any]]              {
            servicesPrices.removeAll()
            for obj in val {
                let itemPrice = Price.init(dict: obj)
                servicesPrices.append(itemPrice)
            }
        }
        if let val = dict["sellerServiceLocation"] as? [[String: Any]]       {
            
            if val.count > 0 {
                for obj in val {
                    let item = Location.init(dict: obj)
                    sellerServiceLocation.append(item)
                }
            }
        }
        if let val = dict["sellerDeliveredMedia"] as? [[String:Any]]        {
            sellerDeliveredMedia.removeAll()
            for obj in val {
                let itemMedia = Media.init(dict: obj)
                sellerDeliveredMedia.append(itemMedia)
            }
        }
        if let val = dict["orderItems"] as? [[String:Any]]                  {
            orderItems.removeAll()
            for obj in val {
                let orderItem = OrderItem.init(dict: obj)
                orderItems.append(orderItem)
            }
        }
        if let val = dict["buyerServiceLocation"] as? [String:Any]               { buyerServiceLocation = Location.init(dict: val) }
        
        if let val = dict["serviceStartDate"] as? String                                {serviceStartDate = val}
        if let val = dict["serviceScheduleDate"] as? String                         { serviceScheduleDate = val }
        if let val = dict["serviceCompleteDate"] as? String                         {serviceCompleteDate = val}
        if let val = dict["serviceScheduleEndDate"] as? String                         {serviceScheduleEndDate = val}
        
        if let val = dict["orderAcceptanceDate"] as? String                             {orderAcceptanceDate = val}
        if let val = dict["cancellationDate"] as? String                                    {cancellationDate = val}
        if let val = dict["buyerDisputeDate"] as? String                                   {buyerDisputeDate = val}
        
        if let val = dict["totalWorkDurationHours"] as? NSInteger                   {totalWorkDurationHours = val}
        
        if let val = dict["statusDescription"] as? String                                   {statusDescription = val}
        
        if let val = dict["buyerOrderDispute"] as? [String: Any]                        {buyerOrderDispute = BuyerOrderDispute.init(dict: val)}
//        if let val = dict["media"] {
//            if val is Dictionary<AnyHashable,Any> {
//                media = Media.init(dict: val as! [String:Any])
//            } else if val is Array<Any> {
//                let arrMedia = val as! [[String:Any]]
//                for obj in arrMedia {
//                    if let type = obj["mediaType"] as? String, let file = obj["fileName"] as? String {
//                        if type != "video" && file != "" {
//                            media = Media.init(dict: obj)
//                            break
//                        }
//                    }
//                }
//            }
//        }
    }
}
