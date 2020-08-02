//
//  PushWebservice.swift
//  Pointters
//
//  Created by Dream Software on 8/13/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import Alamofire

protocol PushWebservice: BaseService {
    func webServiceGetError(receivedError: String)
    func webServiceGetResponse()
}

extension PushWebservice{
    func sendToken(){
        let callUrl = URLBuilder.urlFCMToken
        let fcmToken = UserCache.sharedInstance.getFCMToken()
        let params = ["token": fcmToken ?? "",
                            "deviceType": "ios"] as [String : Any]
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        Alamofire.request(callUrl, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON{
            response in
            let (parsedResult, parsedError) = self.parse(response)
            if let error = parsedError {
                self.webServiceGetError(receivedError: self.getErrorMessage(error))
            } else if let _ = parsedResult {
                self.webServiceGetResponse()
            }
        }
    }
    
    func deleteToken(){
        let callUrl = URLBuilder.urlFCMToken
         let fcmToken = UserCache.sharedInstance.getFCMToken()
        let params = ["token": fcmToken ?? ""] as [String : Any]
        let token = UserCache.sharedInstance.getUserAuthToken()
        if (token != nil) {
            let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
            
            Alamofire.request(callUrl, method: .delete, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON{
                response in
                let (parsedResult, parsedError) = self.parse(response)
                if let error = parsedError {
                    self.webServiceGetError(receivedError: self.getErrorMessage(error))
                } else if let _ = parsedResult {
                }
            }
        }
    }
}
