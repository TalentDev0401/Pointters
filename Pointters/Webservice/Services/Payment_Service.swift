//
//  Payment.swift
//  Pointters
//
//  Created by Dream Software on 8/26/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import Foundation
import Alamofire

extension ApiHandler {
    // create payment method
    class func createPaymentMethod(nonce: String, makeDefault: Bool, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]

        let dict : [String :Any] = ["paymentMethodNonce" : nonce, "options" : ["makeDefault" : makeDefault]]

        Alamofire.request(baseURL + "braintree/payment-method", method: .post, parameters: dict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in

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
                }
                break
            }
        }
    }

    // create payment method
    class func createStripePaymentMethod(tokenId: String, makeDefault: Bool, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]

        var dict = [String :Any]()
        dict["source"] = tokenId
        if makeDefault {
            dict["default"] = makeDefault
        }
        Alamofire.request(baseURL + "payment/payment-method", method: .post, parameters: dict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
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
                }
                break
            }
        }
    }

    // update payment method
    class func callUpdatePaymentMethod(methodToken: String, nonce: String, makeDefault: Bool, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){

        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]

        var dict : [String :Any] = ["paymentMethodNonce" : nonce, "options" : ["makeDefault" : makeDefault]]
        if nonce == "" {
            dict.removeValue(forKey: "paymentMethodNonce")
        }

        Alamofire.request(baseURL + "braintree/payment-method/" + methodToken, method: .put, parameters: dict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in

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
                }
                break
            }
        }
    }

    // update Stripe payment method
    class func callUpdateStripePaymentMethod(methodToken: String, name: String, cvv: String, expMon: String, expYear: String, makeDefault: Bool, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){

        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]

        var dict = [String: Any]()
        if !name.isEmpty {
            dict["name"] = name
        }
        if !expMon.isEmpty {
            dict["exp_month"] = expMon
        }
        if !expYear.isEmpty {
            dict["exp_year"] = expYear
        }
        if makeDefault {
            dict["default"] = makeDefault
        }

        Alamofire.request(baseURL + "payment/payment-method/" + methodToken, method: .put, parameters: dict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in

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
                }
                break
            }
        }
    }

    // delete payment method
    class func callDeletePaymentMethod(methodToken: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){

        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "braintree/payment-method/" + methodToken

        Alamofire.request(baseURL + query, method: .delete, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in

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

    // delete Stripe payment method
    class func callDeleteStripePaymentMethod(methodToken: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){

        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "payment/payment-method/" + methodToken

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
                }
                break
            }
        }
    }

    // get payment methods
    class func callGetPaymentMethods(withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){

        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = ( token != nil ) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        let query = "braintree/payment-methods"

        Alamofire.request(baseURL + query, method: .get, parameters: nil,  headers: headers).responseJSON { (response:DataResponse<Any>) in

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

    // get payment methods
    class func callGetStripePaymentMethods(withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){

        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = ( token != nil ) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        let query = "payment/payment-methods"

        Alamofire.request(baseURL + query, method: .get, parameters: nil,  headers: headers).responseJSON { (response:DataResponse<Any>) in

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
                }
                break
            }
        }
    }
    
    // set paystack amount
    class func callSetPaystackAmountMethods(amount: Float, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){

        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = ( token != nil ) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        let query = "paystack/access-code"//verify
        let param = ["amount": "\(amount)"]

        Alamofire.request(baseURL + query, method: .get, parameters: param,  headers: headers).responseJSON { (response:DataResponse<Any>) in

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
                }
                break
            }
        }
    }
    
    // Verify paystack transaction
    class func verifyPaystackTransaction(access_url: String, reference: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){

        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = ( token != nil ) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        let query = "http://pointters-api-test.us-east-1.elasticbeanstalk.com:9000/verify"//"\(access_url)/verify"//
        let param = ["reference": reference]
        Alamofire.request(query, method: .post, parameters: param,  headers: headers).responseJSON { (response:DataResponse<Any>) in

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
                }
                break
            }
        }
    }
}
