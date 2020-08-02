//
//  Order.swift
//  Pointters
//
//  Created by Dream Software on 8/26/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import Foundation
import Alamofire

extension ApiHandler {
    // buy orders
    class func callGetBuyOrder(lastId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void) {
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        var params:Dictionary? = [String: String]()
        if lastId != "" {
            params![kAPIRequest.kLastId] = lastId
        } else {
            params = nil
        }
        
        Alamofire.request(baseURL + "orders/buy", method: .get, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    // sell orders
    class func callGetSellOrder(lastId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void) {
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        var params:Dictionary? = [String: String]()
        if lastId != "" {
            params![kAPIRequest.kLastId] = lastId
        } else {
            params = nil
        }
        
        Alamofire.request(baseURL + "orders/sell", method: .get, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    // get order fulfillment
    class func callGetOrderFulfillment(orderId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "order/" + orderId
        
        Alamofire.request(baseURL + query, method: .get, parameters: nil,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    // put order fulfillment for payment
    class func callPutOrderFulfillment(orderId: String, param: [String: Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "order/" + orderId
        
        Alamofire.request(baseURL + query, method: .put, parameters: param,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    //get checkout values
    
    class func callCheckoutValues(params: [String: Any] ,withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:DataResponse<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = ( token != nil ) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        let query = "checkout/fees"
        Alamofire.request(baseURL + query, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    withCompletionHandler(true,(response.response?.statusCode)!,response, "")
                }
                break
            case .failure(_):
                if let data = response.data {
                    let error = String(data: data, encoding: String.Encoding.utf8)
                    withCompletionHandler(false,0,response, error!)
                }
                
                break
            }
        }
    }
    
    //get transaction fee
    
    class func callGetTransactionFee(subTotal: String, currencyCode: String ,withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "order-transaction-fee?subtotal=" + subTotal + "&currencyCode=" + currencyCode
        
        Alamofire.request(baseURL + query, method: .get, parameters: nil,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    //get tax amount
    
    class func callGetTaxAmount(params: [String: Any] ,withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "tax/order-tax"
        
        Alamofire.request(baseURL + query, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    //get order
    
    class func callGetOrder(params: [String: Any] ,withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:DataResponse<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "order"
        Alamofire.request(baseURL + query, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    //request cancel order
    
    class func requestCancelOrder(orderId: String ,params: [String: Any] ,withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "order/" +  orderId + "/request-cancel-order"
        Alamofire.request(baseURL + query, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    //apporve cancel order
    
    class func approveCancelOrder(orderId: String ,withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "order/" +  orderId + "/accept-cancel-order"
        Alamofire.request(baseURL + query, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    withCompletionHandler(true,(response.response?.statusCode)!,response.result, "")
                }
                break
            case .failure(_):
                if let data = response.data {
                    let error = String(data: data, encoding: String.Encoding.utf8)
                    withCompletionHandler(false,0,response.result, error!)
                }
                
                break
            }
        }
    }
    
    //get order
    
    class func requestChangeLocation(orderId: String ,params: [String: Any] ,withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "order/" +  orderId + "/request-location-change"
        
        Alamofire.request(baseURL + query, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    withCompletionHandler(true,(response.response?.statusCode)!,response.result)
                }
                break
            case .failure(_):
                if let data = response.data {
                    let error = String(data: data, encoding: String.Encoding.utf8)
                    print(error)
                }
                withCompletionHandler(false,0,response.result)
                break
            }
        }
    }
    
    //request schedule change
    
    class func requestChangeSchedule(orderId: String ,params: [String: Any] ,withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "order/" +  orderId + "/request-schedule-change"
        Alamofire.request(baseURL + query, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    //accept schedule and location change
    
    class func AcceptScheduleLocationChange(orderId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "order/" +  orderId + "/accept-schedule-location"
        Alamofire.request(baseURL + query, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    class func uploadSellerDeliverMedia(orderId: String, params: [String: Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "order/" +  orderId + "/seller-delivered-media"
        Alamofire.request(baseURL + query, method: .put, parameters: params , encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    withCompletionHandler(true,(response.response?.statusCode)!,response.result, "")
                }
                break
            case .failure(_):
                if let data = response.data {
                    let error = String(data: data, encoding: String.Encoding.utf8)
                    withCompletionHandler(false,0,response.result, error!)
                }
                break
            }
        }
    }
    
    class func deleteDeliverMedia(orderId: String, mediaId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "order/" +  orderId + "/seller-delivered-media/" + mediaId
        Alamofire.request(baseURL + query, method: .delete, parameters: nil , encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    //general order service
    
    class func callGeneralOrderService(orderId: String, endpoint: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "order/" +  orderId + "/" + endpoint
        Alamofire.request(baseURL + query, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    withCompletionHandler(true,(response.response?.statusCode)!,response.result, "")
                }
                break
            case .failure(_):
                if let data = response.data {
                    let error = String(data: data, encoding: String.Encoding.utf8)
                    withCompletionHandler(false,0,response.result, error!)
                }
                break
            }
        }
    }
}
