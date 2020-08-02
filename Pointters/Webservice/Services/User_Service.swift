//
//  User.swift
//  Pointters
//
//  Created by Dream Software on 8/26/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import Foundation
import Alamofire

extension ApiHandler{
    // menu
    class func callGetUserMenu(withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        Alamofire.request(URLBuilder.urlUserMenu, method: .get, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
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
    
    // get user profile
    class func callGetUserProfile(userId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        
        Alamofire.request(URLBuilder.urlUserProfile(userId: userId), method: .get, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // update user profile
    class func callUpdateUser(dict:[String:Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        Alamofire.request(URLBuilder.urlUser, method: .put, parameters: dict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil {
                    withCompletionHandler(true,(response.response?.statusCode)!,response.result, "")
                }
                break
                
            case .failure(_):
                if let data = response.data {
                    let error = String(data: data, encoding: String.Encoding.utf8)
                    withCompletionHandler(false, 0, response.result, error!)
                }
                break
            }
        }
    }
    
    // get user following status
    class func callGetUserFollowingStatus(userId:String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        
        Alamofire.request(URLBuilder.urlUserFollow(userId: userId), method: .get, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // post user following status
    class func callPostUserFollowingStatus(userId:String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        
        Alamofire.request(URLBuilder.urlUserFollow(userId: userId), method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // delete user following status
    class func callDelUserFollowingStatus(userId:String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        
        Alamofire.request(URLBuilder.urlUserFollow(userId: userId), method: .delete, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // follower
    class func callGetFollowers(lastId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        
        var params:Dictionary? = [String: String]()
        if lastId != "" {
            params![kAPIRequest.kLastId] = lastId
        } else {
            params = nil
        }
        
        Alamofire.request(URLBuilder.urlGetFollowers, method: .get, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // following
    class func callGetFollowing(lastId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        
        var params:Dictionary? = [String: String]()
        if lastId != "" {
            params![kAPIRequest.kLastId] = lastId
        } else {
            params = nil
        }
        
        Alamofire.request(URLBuilder.urlGetFollowing, method: .get, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // get user setting
    class func callGetUserSettings(withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        Alamofire.request(URLBuilder.urlUserSetting, method: .get, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // update user profile
    class func callUpdateUserSettings(dict:[String:Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        Alamofire.request(URLBuilder.urlUserSetting, method: .put, parameters: dict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // seller eligability
    class func callSellerEligability(withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        
        Alamofire.request(URLBuilder.urlSellerEligability, method: .get, parameters: nil,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    //background check
    
    class func callBackgroundCheck(withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        Alamofire.request(URLBuilder.urlBackgroundCheck, method: .get, parameters: nil,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    class func putBackgroundCheck(id: String, params: [String: Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        var url = ""
        var method: HTTPMethod!
        if id == ""{
            url = URLBuilder.urlBackgroundCheck
            method = HTTPMethod.post
        }else{
            url = URLBuilder.urlBackgroundCheck + "/\(id)"
            method = HTTPMethod.put
        }
        
        Alamofire.request(url, method: method, parameters: params,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // set paypal email
    class func callSetPaypalAuthorizationCodeAPI(params: [String: Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        Alamofire.request(URLBuilder.urlUserUpdate, method: .put, parameters: params,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    //paystack list of bank
    class func callPayStackListBankInfo(withCompletionHandler:@escaping (_ result:Bool,_ statusCode: Int, _ response: Result<Any>, _ error: String) -> Void) {
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let url = URLBuilder.urlPayStackListBanks + "?device=ios"
        
        Alamofire.request(url, method: .get, parameters: nil,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    //merchant withdraw check
    class func callMerchantAccountCheck(withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let url = URLBuilder.urlStripeWithdraw + "?device=ios"
        
        Alamofire.request(url, method: .get, parameters: nil,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    class func callMerchantAccountCreate(params: [String: Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>, _ error: String) -> Void){
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        Alamofire.request(URLBuilder.urlStripeWithdraw, method: .post, parameters: params,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    class func callMerchantAccountUpdate(params: [String: Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        Alamofire.request(URLBuilder.urlStripeWithdraw, method: .put, parameters: params,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    // post user following status
    class func callFeedback(feedback:String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        
        var params = [String: Any]()
        params["comment"]  = feedback
        
        Alamofire.request(URLBuilder.urlFeedback, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    //merchant withdraw check
    class func callDetailCategory(category: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ responseResult:Result<Any>, _ response:DataResponse<Any>?,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        let url = URLBuilder.urlFeedback + "/link-data?type=" + category
        
        Alamofire.request(url, method: .get, parameters: nil,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    print("success")                    
                    withCompletionHandler(true,(response.response?.statusCode)!,response.result, response, "")
                }
                break
            case .failure(_):
                if let data = response.data {
                    let error = String(data: data, encoding: String.Encoding.utf8)
                    withCompletionHandler(false,0,response.result, nil, error!)
                } else {
                    withCompletionHandler(false, 0, response.result, nil, "")
                }
                break
            }
        }
    }
}
