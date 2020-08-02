//
//  Offer.swift
//  Pointters
//
//  Created by Dream Software on 8/26/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import Foundation
import Alamofire

extension ApiHandler {
    // send offer
    class func sendOffer(sellerId: String, buyerId: String, serviceId: String, currencyCode: String, currencySymbol: String, description: String, fulfillmentMethod: [String : Any], price: Float, workDuration: Float, workDurationUom: String, address: [String : Any], parcel: [String : Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:DataResponse<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "offer"
        
        var parameters: [String : Any] = ["sellerId": sellerId, "buyerId": buyerId, "serviceId": serviceId, "currencyCode": currencyCode, "currencySymbol": currencySymbol, "description": description, "fulfillmentMethod": fulfillmentMethod, "price": price]
        
        if workDurationUom != "" {
            parameters["workDuration"] = workDuration
            parameters["workDurationUom"] = workDurationUom
        }
        
        if fulfillmentMethod["shipment"] as! Bool == true {
            parameters["address"] = address
            parameters["parcel"] = parcel
        }
        
        Alamofire.request(baseURL + query, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil {
                    print("success")
                    withCompletionHandler(true,(response.response?.statusCode)!,response)
                }
                break
                
            case .failure(_):
                print("failure")
                withCompletionHandler(false,0,response)
                break
            }
        }
    }
    
    // edit offer
    class func editOffer(offerId: String, sellerId: String, buyerId: String, serviceId: String, currencyCode: String, currencySymbol: String, description: String, fulfillmentMethod: [String : Any], price: Float, workDuration: Float, workDurationUom: String, address: [String : Any], parcel: [String : Any], location: [String : Any], media: [[String : Any]], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "offer/" + offerId
        
        var parameters: [String : Any] = ["sellerId": sellerId, "buyerId": buyerId, "serviceId": serviceId, "currencyCode": currencyCode, "currencySymbol": currencySymbol, "description": description, "fulfillmentMethod": fulfillmentMethod, "price": price]
        
        if workDurationUom != "" {
            parameters["workDuration"] = workDuration
            parameters["workDurationUom"] = workDurationUom
        }
        
        if fulfillmentMethod["shipment"] as! Bool == true {
            parameters["address"] = address
            parameters["parcel"] = parcel
        }
        
        if location.count > 0 {
            parameters["location"] = location
        }
        
        if media.count > 0 {
            parameters["media"] = media
        }
        
        Alamofire.request(baseURL + query, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil {
                    withCompletionHandler(true,(response.response?.statusCode)!,response.result)
                }
                break
                
            case .failure(_):
                withCompletionHandler(false,0,response.result)
                break
            }
        }
    }
    
    // delete offer
    class func deleteOffer(offerId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){

        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "offer/" + offerId
        
        Alamofire.request(baseURL + query, method: .delete, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil {
                    withCompletionHandler(true,(response.response?.statusCode)!,response.result, "")
                }
                break
                
            case .failure(_):
                if let data = response.data {
                    let error = String(data: data, encoding: String.Encoding.utf8)
                    withCompletionHandler(false,0,response.result, error!)
                } else {
                    withCompletionHandler(false, 0, response.result, "")
                }
                break
            }
        }
    }
    
    // get offer detail
    class func callGetOfferDetail(offerId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "offer/" + offerId
        
        Alamofire.request(baseURL + query, method: .get, parameters: ["device" : "mobile"], headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil {
                    print("success")
                    withCompletionHandler(true,(response.response?.statusCode)!,response.result, "")
                }
                break
            case .failure(_):
                if let data = response.data {
                    let error = String(data: data, encoding: String.Encoding.utf8)
                    withCompletionHandler(false,0,response.result, error!)
                } else {
                    withCompletionHandler(false, 0, response.result, "")
                }
            }
        }
    }
    
    // buy offers
    class func callGetOffersReceived(lastId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void) {
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        var params:Dictionary? = [String: String]()
        if lastId != "" {
            params![kAPIRequest.kLastId] = lastId
        } else {
            params = nil
        }
        
        Alamofire.request(baseURL + "offers/received", method: .get, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    print("success")
                    withCompletionHandler(true,(response.response?.statusCode)!,response.result)
                }
                break
                
            case .failure(_):
                print("failure")
                withCompletionHandler(false,0,response.result)
                break
            }
        }
    }
    
    // sell offers
    class func callGetOffersSent(lastId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void) {
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        var params:Dictionary? = [String: String]()
        if lastId != "" {
            params![kAPIRequest.kLastId] = lastId
        } else {
            params = nil
        }
        
        Alamofire.request(baseURL + "offers/sent", method: .get, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    print("success")
                    withCompletionHandler(true,(response.response?.statusCode)!,response.result)
                }
                break
                
            case .failure(_):
                print("failure")
                withCompletionHandler(false,0,response.result)
                break
            }
        }
    }
}
