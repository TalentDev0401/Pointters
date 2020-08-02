//
//  ApiHandler.swift
//  Pointters
//
//  Created by Mac on 2/10/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import Alamofire

class ApiHandler: NSObject {
    
    // sell jobs
    class func callGetSellJobs(lastId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void) {
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        var params:Dictionary? = [String: String]()
        if lastId != "" {
            params![kAPIRequest.kLastId] = lastId
        } else {
            params = nil
        }
        
        Alamofire.request(baseURL + "jobs", method: .get, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    
    
    // transaction history
    class func callGetTransactionHistory(filter: String, period: String, page: Int, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        var params = [String: String]()
        params["page"] = "\(page)"
        if filter != "" {
            params[kAPIRequest.kTransactionHistoryFilter] = filter
        }
        
        if period != "" {
            params[kAPIRequest.kTransactionHistoryPeriod] = period
        }
        
        Alamofire.request(baseURL + "transaction-history", method: .get, parameters: params,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil {
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
    
    // category
    class func callGetCategories(withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        Alamofire.request(baseURL + "categories", method: .get, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // public category
    class func callGetPublicCategories(withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
     
        Alamofire.request(baseURL + "categories", method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
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
    
}
