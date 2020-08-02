//
//  Withdraw.swift
//  Pointters
//
//  Created by dreams on 11/5/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Withdraw: NSObject {
    
    var id = ""
    var firstName = ""
    var lastName = ""
    var businessName = ""
    var birthday = ""
    var social = ""
    var address = WithdrawAddress()
    var tax = ""
    
    var holderName = ""
    var name_bank = ""
    var account_bank = ""
    var routing_bank = ""
    var status = ""

    ///////////////////////////////
    
    var isIndividualType = true
    var sections = ["Account Type"]
    
    var rowData = NSMutableDictionary()
    var rawData = [String: Any]()
    
    override init() {
        super.init()
    }

    init(dict:[String:Any]) {
        super.init()
        self.rawData = dict
        self.refreshSections()
    }
    
    func refreshSections() {
        if let type = self.rawData["type"] as? String {
            if type == "individual" {
                self.isIndividualType = true
            } else {
                self.isIndividualType = false
            }
        }
        
        if let state = self.rawData["status"] as? String {
            self.status = state
        }
        
        self.sections = ["Account Type"]
        self.rowData = NSMutableDictionary()
        self.rowData.addEntries(from: ["Account Type": []])
        
        if let data = self.rawData["verification_fields"] as? NSDictionary {
            if self.isIndividualType {
                if let bankData = data.value(forKey: "individual") as? NSDictionary {
                   self.buildSectionData(data: bankData)
                }
            } else {
                if let bankData = data.value(forKey: "company") as? NSDictionary {
                    self.buildSectionData(data: bankData)
                }
            }
        }
    }
    
    func buildSectionData(data: NSDictionary) {
        if let minimum = data.value(forKey: "minimum") as? NSDictionary {
            for sectionKey in minimum.getSortedKeysDesc() {
                if let section = minimum[sectionKey] as? NSDictionary {
                    var sectionName = ""
                    var sectionRows = [NSDictionary]()
                    for rowKey in section.getSortedKeys() {
                        if rowKey == "account_holder_type" || rowKey == "type" || rowKey == "personal_address" {
                            continue
                        }
                        if let row = section.value(forKey: rowKey) as? NSDictionary {
                            if let object = row.value(forKey: "sectionDisplayName") as? String {
                                sectionName = object
                            }
                            
                            if rowKey == "account_holder_name" {
                                self.holderName = row.value(forKey: "value") as? String ?? ""
                            } else if rowKey == "account_number" {
                                if let val = row.value(forKey: "value") as? String {
                                    self.account_bank = val
                                } else if let val = row.value(forKey: "value") as? Int {
                                    self.account_bank = String(val)
                                }
                            } else if rowKey == "bank_name" {
                                self.name_bank = row.value(forKey: "value") as? String ?? ""
                            } else if rowKey == "routing_number" {
                                if let val = row.value(forKey: "value") as? String {
                                    self.routing_bank = val
                                } else if let val = row.value(forKey: "value") as? Int {
                                    self.routing_bank = String(val)
                                }
                            } else if rowKey == "business_tax_id" {
                                self.tax = row.value(forKey: "value") as? String ?? ""
                            } else if rowKey == "business_name" {
                                self.businessName = row.value(forKey: "value") as? String ?? ""
                            } else if rowKey == "first_name" {
                                    self.firstName = row.value(forKey: "value") as? String ?? ""
                            } else if rowKey == "last_name" {
                                self.lastName = row.value(forKey: "value") as? String ?? ""
                            } else if rowKey == "ssn_last_4" {
                                if let val = row.value(forKey: "value") as? String {
                                    self.social = val
                                } else if let val = row.value(forKey: "value") as? Int {
                                    self.social = String(val)
                                }
                            } else if rowKey == "dob" {
                                let dayDic = row.value(forKey: "day") as? NSDictionary
                                let monthDic = row.value(forKey: "month") as? NSDictionary
                                let yearDic = row.value(forKey: "year") as? NSDictionary
                                if let day = dayDic?.value(forKey: "value") as? Int, let month = monthDic?.value(forKey: "value") as? Int, let year = yearDic?.value(forKey: "value") as? Int {
                                    self.birthday = "\(year)-\(month)-\(day)"
                                }
                            } else if rowKey == "address" {
                                let cityDic = row.value(forKey: "city") as? NSDictionary
                                let streetDic = row.value(forKey: "line1") as? NSDictionary
                                let postalDic = row.value(forKey: "postal_code") as? NSDictionary
                                let stateDic = row.value(forKey: "state") as? NSDictionary
                                if let _ = row.value(forKey: "state") as? NSDictionary {
                                    self.address.hasState = true
                                } else {
                                    self.address.hasState = false
                                }
                                if let city = cityDic?.value(forKey: "value") as? String, let street = streetDic?.value(forKey: "value") as? String, let postal = postalDic?.value(forKey: "value") as? String {
                                    self.address.locality = city
                                    self.address.streetAddress = street
                                    self.address.postalCode = postal
                                    if let state = stateDic?.value(forKey: "value") as? String {
                                        self.address.region = state
                                    }
                                }
                            }
                            
                            sectionRows.append(row)
                        }
                    }
                    self.rowData.addEntries(from: [sectionName: sectionRows])
                    sections.append(sectionName)
                }
            }
        }
    }
    
    func updateRawData() {
        self.rawData["type"] = self.isIndividualType ? "individual" : "company"
        guard let _ = self.rawData["verification_fields"] as? NSDictionary else {
            return
        }
        var verificationData = self.rawData["verification_fields"] as! [String: Any]
        if var typeData = verificationData[self.isIndividualType ? "individual" : "company"] as? [String: Any] {
            if var min = typeData["minimum"] as? [String: Any] {
                if var legal = min["legal_entity"] as? [String: Any] {
                    //address
                    if var address = legal["address"] as? [String: Any] {
                        if var city = address["city"] as? [String: Any] {
                            city["value"] = self.address.locality
                            address["city"] = city
                        }
                        if var line1 = address["line1"] as? [String: Any] {
                            line1["value"] = self.address.streetAddress
                            address["line1"] = line1
                        }
                        if var postal_code = address["postal_code"] as? [String: Any] {
                            postal_code["value"] = self.address.postalCode
                            address["postal_code"] = postal_code
                        }
                        if var state = address["state"] as? [String: Any] {
                            if !self.address.region.isEmpty {
                                state["value"] = self.address.region
                                address["state"] = state
                            }
                        }
                        legal["address"] = address
                    }
                    
                    //birthday
                    if var birthday = legal["dob"] as? [String: Any] {
                        if var day = birthday["day"] as? [String: Any] {
                            if !self.birthday.isEmpty{
                                day["value"] = self.birthday.split(separator: "-")[2]
                            }
                            birthday["day"] = day
                        }
                        if var month = birthday["month"] as? [String: Any] {
                            if !self.birthday.isEmpty{
                                month["value"] = self.birthday.split(separator: "-")[1]
                            }
                            birthday["month"] = month
                        }
                        if var year = birthday["month"] as? [String: Any] {
                            if !self.birthday.isEmpty{
                                year["value"] = self.birthday.split(separator: "-")[0]
                            }
                            birthday["year"] = year
                        }
                        legal["dob"] = birthday
                    }
                    
                    //First Name
                    if var firstname = legal["first_name"] as? [String: Any] {
                        firstname["value"] = self.firstName
                        legal["first_name"] = firstname
                    }
                    
                    //Last Name
                    if var lastname = legal["last_name"] as? [String: Any] {
                        lastname["value"] = self.lastName
                        legal["last_name"] = lastname
                    }
                    
                    //Last Name
                    if var ssn = legal["ssn_last_4"] as? [String: Any] {
                        ssn["value"] = self.social
                        legal["ssn_last_4"] = ssn
                    }
                    
                    //Business Name
                    if var bname = legal["business_name"] as? [String: Any] {
                        bname["value"] = self.businessName
                        legal["business_name"] = bname
                    }
                    
                    //Tax
                    if var tax = legal["business_tax_id"] as? [String: Any] {
                        tax["value"] = self.tax
                        legal["business_tax_id"] = tax
                    }
                    
                    min["legal_entity"] = legal
                }
                if var external = min["external_account"] as? [String: Any] {
                    //Holder Name
                    if var holdername = external["account_holder_name"] as? [String: Any] {
                        holdername["value"] = self.holderName
                        external["account_holder_name"] = holdername
                    }
                    
                    //Bank Name
                    if var bankname = external["bank_name"] as? [String: Any] {
                        bankname["value"] = self.name_bank
                        external["bank_name"] = bankname
                    }
                    
                    //Routing Number
                    if var routing = external["routing_number"] as? [String: Any] {
                        routing["value"] = self.routing_bank
                        external["routing_number"] = routing
                    }
                    
                    //Bank Number
                    if var banknumber = external["account_number"] as? [String: Any] {
                        banknumber["value"] = self.account_bank
                        external["account_number"] = banknumber
                    }
                    
                    min["external_account"] = external
                }
                typeData["minimum"] = min
            }
            verificationData[self.isIndividualType ? "individual" : "company"] = typeData
        }
        self.rawData["verification_fields"] = verificationData
        self.refreshSections()
    }
    
    func dict() -> [String:Any] {
        var dict = [String:Any]()
        dict["business_name"] = self.businessName
//        dict["type"] = "custom"
        dict["email"] = UserCache.sharedInstance.getAccountData().email
        
        var external = [String: Any]()
        external["object"] = "bank_account"
        external["account_holder_name"] = self.holderName
        external["account_holder_type"] = self.isIndividualType ? "individual" : "company"
        external["bank_name"] = self.name_bank
        if !self.routing_bank.isEmpty {
            external["routing_number"] = self.routing_bank.replacingOccurrences(of: "-", with: "")
        }
        external["account_number"] = self.account_bank

        dict["external_account"] = external
        
        var legal = [String: Any]()
        legal["type"] = self.isIndividualType ? "individual" : "company"
        var addressDict = [String: Any]()
        addressDict["city"] = self.address.locality
        addressDict["line1"] = self.address.streetAddress
        addressDict["postal_code"] = self.address.postalCode
        addressDict["state"] = self.address.region
        if !self.address.streetAddress.isEmpty {
            legal["address"] = addressDict
        }
        if !self.businessName.isEmpty {
            legal["business_name"] = self.businessName
        }
        if !self.tax.isEmpty {
            legal["business_tax_id"] = self.tax
        }
        legal["first_name"] = self.firstName
        legal["last_name"] = self.lastName
        if !self.social.isEmpty{
            legal["ssn_last_4"] = self.social
        }
        if !self.address.streetAddress.isEmpty {
            legal["personal_address"] = addressDict
        }
        
        if !self.birthday.isEmpty {
            var dob = [String: Any]()
            dob["year"] = self.birthday.split(separator: "-")[0]
            dob["month"] = self.birthday.split(separator: "-")[1]
            dob["day"] = self.birthday.split(separator: "-")[2]
            legal["dob"] = dob
        }
        
        dict["legal_entity"] = legal
        
        
        return dict
    }
}
