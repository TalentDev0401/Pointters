//
//  Shipment.swift
//  Pointters
//
//  Created by Dream Software on 8/26/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import Foundation
import Alamofire

extension ApiHandler {
    // get shipping addresses
    class func callGetShippingAddresses(lastId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        var params:Dictionary? = [String: String]()
        if lastId != "" {
            params![kAPIRequest.kLastId] = lastId
        } else {
            params = nil
        }
        
        Alamofire.request(baseURL + "shipment-addresses", method: .get, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil {
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
    
    // set shipping address
    class func callSetShippingAddress(addressDict: [String:Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        Alamofire.request(baseURL + "shipment-address", method: .post, parameters: addressDict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // update shipping address
    class func callUpdateShippingAddress(addressId:String, addressDict: [String:Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "shipment-address/" + addressId
        
        Alamofire.request(baseURL + query, method: .put, parameters: addressDict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    class func callDeleteShippingAddress(addressId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "shipment-address/" + addressId
        Alamofire.request(baseURL + query, method: .delete, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                withCompletionHandler(true,(response.response?.statusCode)!,response.result)
                break
            case .failure(_):
                print("failure")
                withCompletionHandler(false,0,response.result)
                break
            }
        }
    }
    
    // call get buyer location
    class func callGetBuyerLocations(withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
                        
        Alamofire.request(baseURL + "buyer-locations", method: .get, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil {
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
    
    // set buyer location
    class func callSetBuyerLocation(addressDict: [String:Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        Alamofire.request(baseURL + "buyer-location", method: .post, parameters: addressDict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    class func callUpdateDefaultValue(addressId: String, defaults: String, withCompletionHandler: @escaping (_ result: Bool, _ statusCode: Int, _ response: Result<Any>) -> Void) {
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "buyer-location/" + addressId
        let param = ["default": defaults]
        Alamofire.request(baseURL + query, method: .put, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // set default value for buyer location
    class func callSetDefaultValue(addressId: String, defaults: String, withCompletionHandler: @escaping (_ result: Bool, _ statusCode: Int, _ response: Result<Any>) -> Void) {
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "buyer-location/" + addressId
        let param = ["default": defaults]
        Alamofire.request(baseURL + query, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // update shipping address
    class func callUpdateBuyerLocation(addressId:String, addressDict: [String:Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "buyer-location/" + addressId
        
        Alamofire.request(baseURL + query, method: .put, parameters: addressDict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    // delete location address
    class func callDeleteBuyerLocation(addressId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "buyer-location/" + addressId
        Alamofire.request(baseURL + query, method: .delete, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                withCompletionHandler(true,(response.response?.statusCode)!,response.result)
                break
            case .failure(_):
                print("failure")
                withCompletionHandler(false,0,response.result)
                break
            }
        }
    }
    
    // get shippment
    class func createShipment(params: [String : Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        Alamofire.request(baseURL + "shipment", method: .post, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                if response.result.value != nil {
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
    
    // select shipping rate
    class func selectShippingRate(shipmentId: String , params: [String : Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        Alamofire.request(baseURL + "shipment/" + shipmentId, method: .put, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                if response.result.value != nil {
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
