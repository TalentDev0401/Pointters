//
//  Explore.swift
//  Pointters
//
//  Created by Dream Software on 8/26/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import Foundation
import Alamofire

extension ApiHandler {
    // public explore
    class func callPublicExplore(withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        let query = "homepage/public/mobile"
        Alamofire.request(baseURL + query, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in

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

    //initial search page result

    class func callInitialExploreSearch(recentAll: Bool, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        let query = (recentAll) ? "search-history/initial-page?seeAllRecentSearches=true" : "search-history/initial-page"
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        Alamofire.request(baseURL + query, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in

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

    //auto complete result

    class func callGetAutoCompleteResult(query: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        let query = "search/autocomplete?q=" + query.replacingOccurrences(of: " ", with: "%20")
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        Alamofire.request(baseURL + query, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in

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

    // explore services
    class func callServices(filter: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void) {

        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        var query = ""
        if filter != "" {
            query = "?filter=" + filter
        }else{
            query = ""
        }
        
        Alamofire.request(baseURL + "services/explore" + query, method: .get, parameters: nil,  headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // public explore services
    class func callPublicExploreServices(currentPage: Int, query: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){

        var params:Dictionary? = [String: Any]()
        params!["page"] = currentPage
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        Alamofire.request(baseURL + "services/explore?" + query, method: .get, parameters: params,  headers: headers).responseJSON { (response:DataResponse<Any>) in

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

    // public explore services
    class func callSearchElastic(params: [String: Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        //search-elastic
        Alamofire.request(baseURL + "search-elastic", method: .post, parameters: params,  headers: headers).responseJSON { (response:DataResponse<Any>) in

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

    // explore jobs
    class func callJobs(filter: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers = (token != nil) ? [kAPIRequest.kAuthorization: "Bearer " + token!] : nil
        var query = ""
        if filter != "" {
            query = "?filter=" + filter
        }else{
            query = ""
        }
        print("callExploreJobs filter query = " + baseURL + "explore/jobs" + query)

        Alamofire.request(baseURL + "explore/jobs" + query, method: .get, parameters: nil,  headers: headers).responseJSON { (response:DataResponse<Any>) in

            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    print("success")
                    if let json = response.result.value {
                        print("JSON: \(json)") // serialized json response
                    }
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

    // explore suggested services
    class func callExploreSuggestedServices(currentPage: Int, categoryId: String, geoWithin: Array<Any>, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){

        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        var params:Dictionary? = [String: Any]()
        params!["page"] = currentPage

        if !categoryId.isEmpty {
            params!["categoryId"] = categoryId
        }

        if geoWithin.count == 2 {
            params!["geoWithin"] = geoWithin
        }
        Alamofire.request(baseURL + "services/live-offer-suggested", method: .get, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in

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

    // explore offers for request
    class func callExploreOffersForRequest(requestId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){

        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]

        Alamofire.request(baseURL + "/request/" + requestId + "/offers", method: .get, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in

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
}
