//
//  Media.swift
//  Pointters
//
//  Created by Mac on 2/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class Media: NSObject {
    
    var id:String = ""
    var mediaType:String = ""
    var fileName:String = ""
    var thumbnail:String = ""
    var fileExtension: String = ""
    
    override init() {
        super.init()
    }
    
    init(type:String, path:String) {
        mediaType = type
        fileName = path
    }
    
    init(dict:[String:Any]) {
        if let val = dict["_id"] as? String         { id = val }
        if let val = dict["mediaType"] as? String   { mediaType = val }
        if let val = dict["fileName"] as? String {
            fileName = val
            if !fileName.contains("https:") {
                fileName = "https://s3.amazonaws.com" + fileName
            }
        }
        if let val = dict["thumbnail"] as? String {
            fileName = val
            if !fileName.contains("https:") {
                fileName = "https://s3.amazonaws.com" + fileName
            }
        }
        if let val = dict["fileExtension"] as? String { fileExtension = val }
    }
    
    func dict() -> [String:String] {
        var dictMedia = [String:String]()
        dictMedia["mediaType"] = mediaType
        dictMedia["fileName"] = fileName
        dictMedia["thumbnail"] = thumbnail
        dictMedia["fileExtension"] = fileExtension
        return dictMedia
    }
}
