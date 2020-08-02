//
//  ApiHandler+Auth.swift
//  Pointters
//
//  Created by Dream Software on 8/26/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import Foundation
import Alamofire

extension ApiHandler {
    
    // user signup
    class func callUserSignUp(emailId:String, password:String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>, _ error: String) -> Void){
        
        let strEmail: String = (emailId.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed))!
        let dict : [String:Any] = ["email":strEmail, "password":password]
        Alamofire.request(URLBuilder.urlSignup, method: .post, parameters: dict, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // user register
    class func callUpdateUser(userParam:[String:Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        Alamofire.request(URLBuilder.urlUser, method: .put, parameters: userParam, encoding: JSONEncoding.default,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
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
    
    // user login
    class func callUserLogIn(emailId:String, password:String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>, _ errorString: String) -> Void) {
        
        let strEmail:String = (emailId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        let dict:[String:Any] = ["email":strEmail, "password":password]
        
        Alamofire.request(URLBuilder.urlLogin, method: .post, parameters: dict, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
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
    
    // user logout
    class func callUserLogOut(withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let fcmToken = UserCache.sharedInstance.getFCMToken()
        let params = ["fcmToken": fcmToken ?? ""] as [String : Any]
        Alamofire.request(URLBuilder.urlLogout, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseString { (response:DataResponse<String>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil {
                    withCompletionHandler(true,(response.response?.statusCode)!)
                }
                break
                
            case .failure(_):
                withCompletionHandler(false,400)
                break
            }
        }
    }
    
    // user detail info
    class func callGetUserDetails(withCompletionHandler:@escaping (_ result:Bool,_ statusCode:Int,_ response:Result<Any>) -> Void) {
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        Alamofire.request(URLBuilder.urlUser, method: .get, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // forgot password
    class func callUserOTP(emailId:String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>, _ error: String) -> Void) {
        
        let dict : [String:Any] = ["email":emailId]
        
        Alamofire.request(URLBuilder.urlUserOTP, method: .post, parameters: dict, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil {
                    print("success")
                    
                    withCompletionHandler(true,(response.response?.statusCode)!, response.result, "")
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
    
    // reset password
    class func callUserResetPassword(emailId:String, password:String, otp:String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>, _ error: String) -> Void) {
        
        let dict : [String:Any] = ["email":emailId, "newPassword":password, "oldPassword":otp]
        
        Alamofire.request(URLBuilder.urlUserResetPass, method: .post, parameters: dict, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // login with facebook
    class func callUserLogInWithFb(fbToken: String,withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error:String) -> Void) {
        
        let dict : [String:Any] = [kFBCredentials.kFBToken:fbToken]
        
        Alamofire.request(URLBuilder.urlFBLogin, method: .post, parameters: dict, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // verify verification code
    class func callSendVerificationCode(code: String ,withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>, _ error: String) -> Void) {
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        
        var dict = [String:Any]()
        dict["verifyCode"] = code
        
        Alamofire.request(URLBuilder.urlSendVerifyCode, method: .post, parameters: dict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
                } else {
                    withCompletionHandler(false,0,response.result, "Failed to verify code, try again")
                }
                break
            }
        }
    }
    
    // verify verification code
    class func callResendVerificationCode(code: String ,withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>, _ error: String) -> Void) {
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        
        var dict = [String:Any]()
        dict["verifyCode"] = "123456"
        
        Alamofire.request(URLBuilder.urlResendVerifyCode, method: .post, parameters: dict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            print(response)
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
                } else {
                    withCompletionHandler(false,0,response.result, "Failed to send email")
                }
                break
            }
        }
    }
}
