//
//  Request.swift
//  Pointters
//
//  Created by Dream Software on 8/26/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import Foundation
import Alamofire

extension ApiHandler {
    // get request detail
    class func callGetRequestDetail(requestId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "request/" + requestId
        
        Alamofire.request(baseURL + query, method: .get, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // get request offer detail
    class func callGetRequestOfferDetail(offerId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!, "Content-Type": "application/json"]
        let query = "request/offer/" + offerId
        
        Alamofire.request(baseURL + query, method: .get, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // create new job offer detail
    class func callCreateJobOffer(jobId: String, sellerId: String, buyerId: String, serviceId: String,  service: Service, currencyCode: String, currencySymbol: String, description: String, fulfillmentMethod: [String : Any], price: Float, workDuration: Float, workDurationUom: String, address: [String : Any], parcel: [String : Any], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:DataResponse<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "request/" + jobId + "/offer"
        
        var parameters: [String : Any] = ["sellerId": sellerId, "buyerId": buyerId, "currencyCode": currencyCode, "currencySymbol": currencySymbol, "description": description, "fulfillmentMethod": fulfillmentMethod, "price": price, "numOffers": 0]//, "serviceId": serviceId
        
        if workDurationUom != "" {
            parameters["workDuration"] = workDuration
            parameters["workDurationUom"] = workDurationUom
        }
        
        if fulfillmentMethod["shipment"] as! Bool == true {
            parameters["address"] = address
            parameters["parcel"] = parcel
        }
        
        let location = service.location.dict()
        parameters["location"] = location
        let media = service.media.dict()
        parameters["media"] = [media]
//        if let media = offerDetailDict["media"] {
//            if media is Dictionary<AnyHashable,Any> {
//                self.media = [media as! [String:Any]]
//            } else if media is Array<Any> {
//                self.media = media as! [[String:Any]]
//            }
//        }
        
        Alamofire.request(baseURL + query, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil {
                    withCompletionHandler(true,(response.response?.statusCode)!,response)
                }
                break
                
            case .failure(_):
                withCompletionHandler(false,0,response)
                break
            }
        }
    }
    
    // edit request
    class func editRequest(requestId: String, serviceId: String, sellerId: String, media: [[String:String]], isPrivate: Bool, description: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "request/" + requestId
        
        var parameters = [String:Any]()
        if media.count != 0 {
            parameters = ["serviceId": serviceId, "sellerId": sellerId, "media": media, "isPrivate": isPrivate, "description": description]
        } else {
            parameters = ["serviceId": serviceId, "sellerId": sellerId, "isPrivate": isPrivate, "description": description]
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
    
    // get request
    class func callGetRequest(requestId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "request/" + requestId
        
        Alamofire.request(baseURL + query, method: .get, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // post request
    class func postRequest(serviceId: String, sellerId: String, media: [[String:String]], isPrivate: Bool, description: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "request"
        
        var parameters = [String:Any]()
        if media.count != 0 {
            parameters = ["serviceId": serviceId, "sellerId": sellerId, "media": media, "isPrivate": isPrivate, "description": description]
        } else {
            parameters = ["serviceId": serviceId, "sellerId": sellerId, "isPrivate": isPrivate, "description": description]
        }
        
        Alamofire.request(baseURL + query, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // delete request
    class func deleteRequest(requestId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "request/" + requestId
        
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
    
    // edit job offer
    class func editJobOffer(offerId: String, sellerId: String, buyerId: String, serviceId: String, service: Service, currencyCode: String, currencySymbol: String, description: String, fulfillmentMethod: [String : Any], price: Float, workDuration: Float, workDurationUom: String, address: [String : Any], parcel: [String : Any], location: [String : Any], media: [[String : Any]], withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "request/offer/" + offerId
        
        var parameters: [String : Any] = ["sellerId": sellerId, "buyerId": buyerId, "currencyCode": currencyCode, "currencySymbol": currencySymbol, "description": description, "fulfillmentMethod": fulfillmentMethod, "price": price, "numOffers": 0]//, "serviceId": serviceId
        
        if workDurationUom != "" {
            parameters["workDuration"] = workDuration
            parameters["workDurationUom"] = workDurationUom
        }
        
        if fulfillmentMethod["shipment"] as! Bool == true {
            parameters["address"] = address
            parameters["parcel"] = parcel
        }
        
        let location = service.location.dict()
        parameters["location"] = location
//        let media = service.media.dict()
        parameters["media"] = media
        
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
    
    // delete Job offer
    class func deleteJobOffer(offerId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        let query = "request/offer/" + offerId
        
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
    
    // buy requests
    class func callGetLiveOfferRequests(lastId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void) {
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        var params:Dictionary? = [String: String]()
        if lastId != "" {
            params![kAPIRequest.kLastId] = lastId
        } else {
            params = nil
        }
        
        Alamofire.request(baseURL + "requests", method: .get, parameters: params, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // MARK: - Job Request
    
    class func callCreateJobRequest(category: [String:Any], location: Location, medias: [Media], description: String, minPrice: Float, maxPrice: Float, currencyCode: String, currencySymbol: String, scheduleDate: String, onlineJob: Bool, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        var mediaArray: [[String: Any]] = []
        for media in medias {
            mediaArray.append(media.dict())
        }
        
        var posixDateString = ""
        
        if !scheduleDate.isEmpty {
            let dateFormatter = DateFormatter()
            let tempLocale = dateFormatter.locale // save locale temporarily
            
            dateFormatter.dateFormat = "d MMM yyyy HH:mm"
            dateFormatter.locale = tempLocale // reset the locale
            let date = dateFormatter.date(from: scheduleDate)!
            
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            posixDateString = dateFormatter.string(from: date)
        }
        
        
        var dict = [String: Any]()
        if onlineJob {
            dict = [
                "category": ["name": (category["name"] as! String), "id": (category["_id"] as! String)],
                "media": mediaArray,
                "description": description,
                "minPrice": minPrice,
                "maxPrice": maxPrice,
                "currencyCode": currencyCode,
                "currencySymbol": currencySymbol,
                "onlineJob": onlineJob]
        } else {
            dict = [
                "category": ["name": (category["name"] as! String), "id": (category["_id"] as! String)],
                "location": location.dict(),
                "media": mediaArray,
                "description": description,
                "minPrice": minPrice,
                "maxPrice": maxPrice,
                "currencyCode": currencyCode,
                "currencySymbol": currencySymbol,
                "onlineJob": onlineJob
            ]
        }
        if !scheduleDate.isEmpty {
            dict["scheduleDate"] = posixDateString
        }
        
        Alamofire.request(baseURL + "request", method: .post, parameters: dict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    class func callEditJobRequest(requestId: String, category: [String:Any], location: Location, medias: [Media], description: String, minPrice: Float, maxPrice: Float, currencyCode: String, currencySymbol: String, scheduleDate: String, onlineJob: Bool,  withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>,_ error: String) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        var mediaArray: [[String: Any]] = []
        for media in medias {
            mediaArray.append(media.dict())
        }
        
        var posixDateString = ""
        
        if !scheduleDate.isEmpty {
            let dateFormatter = DateFormatter()
            let tempLocale = dateFormatter.locale // save locale temporarily
            
            dateFormatter.dateFormat = "d MMM yyyy HH:mm"
            dateFormatter.locale = tempLocale // reset the locale
            let date = dateFormatter.date(from: scheduleDate)!
            
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            posixDateString = dateFormatter.string(from: date)
        }
        
        var dict : [String:Any] = ["category": ["name": (category["name"] as! String), "id": (category["_id"] as! String)], "location": location.dict(), "media": mediaArray, "description": description, "minPrice": minPrice, "maxPrice": maxPrice, "currencyCode": currencyCode, "currencySymbol": currencySymbol, "onlineJob": onlineJob]
        if !scheduleDate.isEmpty {
            dict["scheduleDate"] = posixDateString
        }
        
        Alamofire.request(baseURL + "request/" + requestId, method: .put, parameters: dict, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
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
    
    // delete offer
    class func callDeleteJobRequest(requestId: String, withCompletionHandler:@escaping (_ result:Bool,_ statusCode : Int,_ response:Result<Any>) -> Void){
        
        let token = UserCache.sharedInstance.getUserAuthToken()
        let headers: HTTPHeaders = [kAPIRequest.kAuthorization: "Bearer " + token!]
        
        Alamofire.request(baseURL + "request/" + requestId, method: .delete, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
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
}
