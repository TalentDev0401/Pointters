//
//  Conversations.swift
//  Pointters
//
//  Created by Dream Software on 8/26/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import Foundation
import Alamofire

extension ApiHandler {
    // conversations
    class func callConversations(lastId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        var params:Dictionary? = [String: String]()
        if lastId != "" {
            params![kAPIRequest.kLastId] = lastId
        } else {
            params = nil
        }
        
        Alamofire.request(baseURL + "conversations", method: .get, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // search conversations
    class func callConversationsSearch(query: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>, _ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        var params:Dictionary? = [String: String]()
        params!["q"] = query
        
        Alamofire.request(baseURL + "conversations/search", method: .get, parameters: params,   headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
                break
            }
        }
    }
    
    // liked services
    class func callGetMessages(lastId: String,conversationId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "conversation/" + conversationId + "/messages"
        var params:Dictionary? = [String: String]()
        if lastId != "" {
            params![kAPIRequest.kLastId] = lastId
        } else {
            params = nil
        }
        
        Alamofire.request(baseURL + query, method: .get, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    class func callGetMessagesWithUserId(lastId: String,userId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "messages?userId=" + userId
        var params:Dictionary? = [String: String]()
        if lastId != "" {
            params![kAPIRequest.kLastId] = lastId
        } else {
            params = nil
        }
        
        Alamofire.request(baseURL + query, method: .get, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    class func sendMessage(params: [String: Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "message"
        
        Alamofire.request(baseURL + query, method: .post, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
