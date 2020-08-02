//
//  User.swift
//  Pointters
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding {
    
    var id:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var birthday:String = ""
    var profilePic:String = ""
    var profileMedia = [[String:String]]()
 
    var email:String = ""
    var phone:String = ""
    var verified:Bool = false
    var desc:String = ""
    var companyName:String = ""
    
    var education:String = ""
    var license:String = ""
    var insurance:String = ""
    var awards:String = ""
    
    var city:String = ""
    var province:String = ""
    var state:String = ""
    var postalCode:String = ""
    var country:String = ""
    
    var isAdmin:Bool = false
    var isActive:Bool = false
    

    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        if let val = aDecoder.decodeObject(forKey: "id") as? String                                 { id = val }
        if let val = aDecoder.decodeObject(forKey: "firstName") as? String                            { firstName = val }
        if let val = aDecoder.decodeObject(forKey: "lastName") as? String                             { lastName = val }
        if let val = aDecoder.decodeObject(forKey: "birthday") as? String                             { birthday = val }
        if let val = aDecoder.decodeObject(forKey: "profilePic") as? String                           { profilePic = val }
        if let val = aDecoder.decodeObject(forKey: "profileBackgroundMedia") as? [[String:String]]    { profileMedia = val }
        if let val = aDecoder.decodeObject(forKey: "email") as? String                               { email = val }
        if let val = aDecoder.decodeObject(forKey: "phone") as? String                                { phone = val }
        if let val = aDecoder.decodeObject(forKey: "verified") as? Bool                               { verified = val }
        if let val = aDecoder.decodeObject(forKey: "description") as? String                          { desc = val }
        if let val = aDecoder.decodeObject(forKey: "companyName") as? String                          { companyName = val }
        if let val = aDecoder.decodeObject(forKey: "education") as? String                            { education = val }
        if let val = aDecoder.decodeObject(forKey: "license") as? String                              { license = val }
        if let val = aDecoder.decodeObject(forKey: "insurance") as? String                            { insurance = val }
        if let val = aDecoder.decodeObject(forKey: "awards") as? String                               { awards = val }
        if let val = aDecoder.decodeObject(forKey: "city") as? String                                 { city = val }
        if let val = aDecoder.decodeObject(forKey: "province") as? String                             { province = val }
        if let val = aDecoder.decodeObject(forKey: "state") as? String                                { state = val }
        if let val = aDecoder.decodeObject(forKey: "postalCode") as? String                           { postalCode = val }
        if let val = aDecoder.decodeObject(forKey: "country") as? String                              { country = val }
        if let val = aDecoder.decodeObject(forKey: "isAdmin") as? Bool                                { isAdmin = val }
        if let val = aDecoder.decodeObject(forKey: "isActive") as? Bool                               { isActive = val }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        aCoder.encode(birthday, forKey: "birthday")
        aCoder.encode(profilePic, forKey: "profilePic")
        aCoder.encode(profileMedia, forKey: "profileBackgroundMedia")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(verified, forKey: "verified")
        aCoder.encode(desc, forKey: "description")
        aCoder.encode(companyName, forKey: "companyName")
        aCoder.encode(education, forKey: "education")
        aCoder.encode(license, forKey: "license")
        aCoder.encode(insurance, forKey: "insurance")
        aCoder.encode(awards, forKey: "awards")
        aCoder.encode(city, forKey: "city")
        aCoder.encode(province, forKey: "province")
        aCoder.encode(state, forKey: "state")
        aCoder.encode(postalCode, forKey: "postalCode")
        aCoder.encode(country, forKey: "country")
        aCoder.encode(isAdmin, forKey: "isAdmin")
        aCoder.encode(isActive, forKey: "isActive")
    }
}
