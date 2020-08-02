//
//  BackgroundCheck.swift
//  Pointters
//
//  Created by dreams on 9/27/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class BackgroundCheck: NSObject {
    
    var id = ""
    var firstName:String = ""
    var middleName:String = ""
    var lastName:String = ""
    var email:String = ""
    var phone:String = ""
    var zipcode:String = ""
    var birthday:String = ""
    var ssn:String = ""
    var driverLicenseNumber:String = ""
    var driverLicenseState:String = ""
    
    override init() {
        super.init()
    }
    
    init(dict:[String:Any]) {
        if let val = dict["_id"] as? String                  { id = val }
        if let val = dict["firstName"] as? String              { firstName = val }
        if let val = dict["middleName"] as? String            { middleName = val }
        if let val = dict["lastName"] as? String             { lastName = val }
        if let val = dict["email"] as? String             { email = val }
        if let val = dict["phone"] as? String              { phone = val }
        if let val = dict["zipcode"] as? String           { zipcode = val }
        if let val = dict["dob"] as? String                 { birthday = val }
        if let val = dict["ssn"] as? String                { ssn = val }
        if let val = dict["driverLicenseNumber"] as? String        { driverLicenseNumber = val }
        if let val = dict["driverLicenseState"] as? String            { driverLicenseState = val }
    }
    
    func dict() -> [String:Any] {
        var dict = [String:Any]()
        dict["firstName"] = firstName
        dict["middleName"] = middleName
        dict["lastName"] = lastName
        dict["email"] = email
        dict["phone"] = phone
        dict["zipcode"] = zipcode
        dict["dob"] = birthday
        dict["ssn"] = ssn
        dict["driverLicenseNumber"] = driverLicenseNumber
        dict["driverLicenseState"] = driverLicenseState
        return dict
    }
}
