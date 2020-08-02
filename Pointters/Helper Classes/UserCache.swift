//
//  UserCache.swift
//  Pointters
//
//  Created by Mac on 2/10/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class UserCache: NSObject {
    
    let userDefault = UserDefaults.standard
    
    class var sharedInstance : UserCache {
        struct Static {
            static let instance = UserCache()
        }
        return Static.instance
    }
    
    // fcm token
    
    func setFCMToken(token: String){
        userDefault.setValue(token, forKey: "fcm_token")
        userDefault.synchronize()
    }
    
    func getFCMToken() -> String?{
        if userDefault.object(forKey: "fcm_token") != nil {
            return userDefault.object(forKey: "fcm_token") as? String
        } else {
            return nil
        }
    }
    
    // user token
    func setUserAuthToken(token: String) {
        userDefault.setValue(token, forKey: "token")
        userDefault.synchronize()
    }
    
    func getUserAuthToken() -> String? {
        if userDefault.object(forKey: "token") != nil {
            return userDefault.object(forKey: "token") as? String
        } else {
            return nil
        }
    }

    // user detail info
    func setAccountData(userData: User) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: userData)
        userDefault.setValue(encodedData, forKey:kCacheParam.kUserDetails)
        userDefault.synchronize()
    }
    
    func getAccountData() -> User {
        if userDefault.object(forKey: kCacheParam.kUserDetails) != nil {
            let decodedCredentials  = userDefault.object(forKey: kCacheParam.kUserDetails) as! Data
            let userData = NSKeyedUnarchiver.unarchiveObject(with: decodedCredentials) as! User
            return userData
        } else {
            return User()
        }
    }
    
    func setUserCredentials(userDict:[String:Any]) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: userDict)
        userDefault.setValue(encodedData, forKey:kCacheParam.kUserLoggedInAccess)
        userDefault.synchronize()
    }

    func getUserCredentials() -> [String:Any]? {
        if userDefault.object(forKey: kCacheParam.kUserLoggedInAccess) != nil {
            let decodedCredentials  = userDefault.object(forKey: kCacheParam.kUserLoggedInAccess) as! Data
            let dict = NSKeyedUnarchiver.unarchiveObject(with: decodedCredentials) as! [String:Any]
            return dict
        } else {
            return nil
        }
    }
    
    // user location
    func setUserLocation(latitude:Double, longitude:Double) {
        userDefault.setValue(latitude, forKey:kCacheParam.kUserLatitude)
        userDefault.setValue(longitude, forKey:kCacheParam.kUserLongitude)
        userDefault.synchronize()
    }
    
    func getUserLatitude() -> Double? {
        if userDefault.object(forKey: kCacheParam.kUserLatitude) != nil {
            return userDefault.object(forKey: kCacheParam.kUserLatitude) as? Double
        } else {
            return 0.0
        }
    }
    func getUserLongitude() -> Double? {
        if userDefault.object(forKey: kCacheParam.kUserLongitude) != nil {
            return userDefault.object(forKey: kCacheParam.kUserLongitude) as? Double
        } else {
            return 0.0
        }
    }

    // reset password
    func setResetEmail(emailId:String) {
        userDefault.setValue(emailId, forKey:kCacheParam.kResetPasswordEmail)
        userDefault.synchronize()
    }
    
    func getResetEmail() -> String? {
        if userDefault.object(forKey: kCacheParam.kResetPasswordEmail) != nil {
            return userDefault.object(forKey: kCacheParam.kResetPasswordEmail) as? String
        } else {
            return ""
        }
    }
    
    // user profile
    func setProfileUser(loginUser:Bool, userId:String) {
        userDefault.set(loginUser, forKey:kCacheParam.kProfileLoginUser)
        userDefault.set(userId, forKey:kCacheParam.kProfileUserId)
        userDefault.synchronize()
    }
    
    func getProfileLoginUser() -> Bool? {
        if userDefault.object(forKey: kCacheParam.kProfileLoginUser) != nil {
            return userDefault.object(forKey: kCacheParam.kProfileLoginUser) as? Bool
        } else {
            return false
        }
    }
    func getProfileUserId() -> String? {
        if userDefault.object(forKey: kCacheParam.kProfileUserId) != nil {
            return userDefault.object(forKey: kCacheParam.kProfileUserId) as? String
        } else {
            return ""
        }
    }
    
    // chat
    func setChatCredentials(id:String, userId:String, name:String, pic:String, verified:Bool) {
        userDefault.set(id, forKey:kCacheParam.kChatId)
        userDefault.set(userId, forKey:kCacheParam.kChatUserId)
        userDefault.set(name, forKey:kCacheParam.kChatUserName)
        userDefault.set(pic, forKey:kCacheParam.kChatUserPic)
        userDefault.set(verified, forKey:kCacheParam.kChatVerified)
        userDefault.synchronize()
    }
    
    func getChatVerified() -> Bool? {
        if userDefault.object(forKey: kCacheParam.kChatVerified) != nil {
            return userDefault.object(forKey: kCacheParam.kChatVerified) as? Bool
        } else {
            return false
        }
    }
    func getChatId() -> String? {
        if userDefault.object(forKey: kCacheParam.kChatId) != nil {
            return userDefault.object(forKey: kCacheParam.kChatId) as? String
        } else {
            return ""
        }
    }
    func getChatUserId() -> String? {
        if userDefault.object(forKey: kCacheParam.kChatUserId) != nil {
            return userDefault.object(forKey: kCacheParam.kChatUserId) as? String
        } else {
            return ""
        }
    }
    func getChatUserName() -> String? {
        if userDefault.object(forKey: kCacheParam.kChatUserName) != nil {
            return userDefault.object(forKey: kCacheParam.kChatUserName) as? String
        } else {
            return ""
        }
    }
    func getChatUserPic() -> String? {
        if userDefault.object(forKey: kCacheParam.kChatUserPic) != nil {
            return userDefault.object(forKey: kCacheParam.kChatUserPic) as? String
        } else {
            return ""
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // paypal email
    func getPaypalEmail() -> String {
        if userDefault.string(forKey: "savedPaypalEmail") != nil {
            let email  = userDefault.object(forKey: "savedPaypalEmail") as! String
            return email
        } else {
            return ""
        }
    }

    func setPaypalEmail(email: String) {
        userDefault.setValue(email, forKey: "savedPaypalEmail")
        userDefault.synchronize()
    }
    
    func deletePaypalEmail() {
        userDefault.removeObject(forKey: "savedPaypalEmail")
        userDefault.synchronize()
    }
 
    // apple pay email
    func getApplePayEmail() -> String {
        if userDefault.string(forKey: "savedApplePayEmail") != nil {
            let email  = userDefault.object(forKey: "savedApplePayEmail") as! String
            return email
        } else {
            return ""
        }
    }
    
    func setApplePayEmail(email: String) {
        userDefault.setValue(email, forKey: "savedApplePayEmail")
        userDefault.synchronize()
    }
    
    func deleteApplePayEmail() {
        userDefault.removeObject(forKey: "savedApplePayEmail")
        userDefault.synchronize()
    }
    
    // chase bank number
    func getChaseBankNo() -> String {
        if userDefault.string(forKey: "savedChaseBankNumber") != nil {
            let number  = userDefault.object(forKey: "savedChaseBankNumber") as! String
            return number
        } else {
            return "NA"
        }
    }
    
    func setChaseBankNo(number: String) {
        userDefault.setValue(number, forKey: "savedChaseBankNumber")
        userDefault.synchronize()
    }
    
    func setUserCountry(country: String) {
        userDefault.setValue(country, forKey: "saved_user_country")
        userDefault.synchronize()
    }
    
    func getUserCountry() -> String {
        if let country = userDefault.string(forKey: "saved_user_country") {
            return country
        }else{
            return ""
        }
    }
    
    func setUserState(state: String) {
        userDefault.setValue(state, forKey: "saved_user_state")
        userDefault.synchronize()
    }
    
    func getUserState() -> String {
        if let state = userDefault.string(forKey: "saved_user_state") {
            return state
        }else{
            return ""
        }
    }
    
    func setUserCity(city: String) {
        userDefault.setValue(city, forKey: "saved_user_city")
        userDefault.synchronize()
    }
    
    func getUserCity() -> String {
        if let city = userDefault.string(forKey: "saved_user_city") {
            return city
        }else{
            return ""
        }
    }
    
    func setUserStreet(street: String) {
        userDefault.setValue(street, forKey: "saved_user_street")
        userDefault.synchronize()
    }
    
    func getUserStreet() -> String {
        if let street = userDefault.string(forKey: "saved_user_street") {
            return street
        }else{
            return ""
        }
    }

    func setUserZip(zip: String) {
        userDefault.setValue(zip, forKey: "saved_user_zip")
        userDefault.synchronize()
    }
    
    func getUserZip() -> String {
        if let zip = userDefault.string(forKey: "saved_user_zip") {
            return zip
        }else{
            return ""
        }
    }
}
