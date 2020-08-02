//
//  ChatSendRequestOfferCell.swift
//  Pointters
//
//  Created by Billiard ball on 25.06.2020.
//  Copyright © 2020 Kenji. All rights reserved.
//

import UIKit

class ChatSendRequestOfferCell: ChatBaseCell {

    @IBOutlet weak var ivImageMask: UIImageView!
    @IBOutlet weak var leadingSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingSpacingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ivServicePic: UIImageView!
    @IBOutlet weak var lblServiceDesc: UILabel!
    @IBOutlet weak var lblServiceWork: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnRequest: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnRequest.layer.cornerRadius = self.btnRequest.frame.height/2
        self.btnRequest.layer.masksToBounds = true
        self.btnRequest.isUserInteractionEnabled = false
        setUpFonts()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setUpFonts() {
        lblServiceDesc?.font = UIFont(name: "Helvetica", size: 15.0)!
        lblServiceWork?.font = UIFont(name: "Helvetica", size: 11.0)!
        lblName?.font = UIFont(name: "Helvetica", size: 10.0)!
    }
        
    override func setData(message: [String:Any]) {
        super.setData(message: message)
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let dt = dateFormatter.date(from:(message["createdAt"] as? String)!)
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd-MM-yyyy hh:mm a"
        let str = dateFormatter1.string(from:dt!)
        self.lblTime.text = str
        
        var imageName = ""
        if self.bIncoming {
            self.leadingSpacingConstraint.constant = 10//20.0
            self.trailingSpacingConstraint.constant = 10.0
            imageName = "bg_chat_msg_shadow_left"
            self.ivImageMask.image = UIImage(named:imageName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(13, 13, 13, 36))
            
            self.lblServiceDesc.textColor = UIColor.black
            self.lblServiceWork.textColor = UIColor.darkGray
//            self.lblName.textColor = UIColor.darkGray
            //self.ivImageLine.backgroundColor = UIColor.lightGray
        }
        else {
            self.leadingSpacingConstraint.constant = 10.0
            self.trailingSpacingConstraint.constant = 25.0
            imageName = "bg_chat_msg_shadow_right"
            self.ivImageMask.image = UIImage(named:imageName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(13, 13, 13, 36))
            
            self.lblServiceDesc.textColor = UIColor.black
            self.lblServiceWork.textColor = UIColor.darkGray
//            self.lblName.textColor = UIColor.darkGray
        }
        
        if let dictOffer = message["offer"] as? [String:Any] {
            var valPrice: Float = 0.00
            if let _ = dictOffer["price"] {
                let valNumber = dictOffer["price"] as! NSNumber
                valPrice = valNumber.floatValue
            }
            var strSymbol = "$"
            if let _ = dictOffer["currencySymbol"] {
                strSymbol = dictOffer["currencySymbol"] as! String
            }
            var valWorkTime = 1
            if let _ = dictOffer["workDuration"] {
                valWorkTime = dictOffer["workDuration"] as! Int
            }
            var strWorkUnit = "hour"
            if let _ = dictOffer["workDurationUom"] {
                strWorkUnit = dictOffer["workDurationUom"] as! String
            }
            
            if valWorkTime > 1 {
                let title = "\(strSymbol)\(valPrice)/\(valWorkTime) \(strWorkUnit)s - BUY NOW"
                self.btnRequest.setTitle(title, for: .normal)
            } else {
                let title = "\(strSymbol) \(valPrice)/\(valWorkTime) \(strWorkUnit) - BUY NOW"
                self.btnRequest.setTitle(title, for: .normal)
            }
        
            if let dictMedia = dictOffer["media"] as? [String:Any] {
                if var strPic = dictMedia["fileName"] as? String, strPic != "" {
                    if !strPic.contains("https://s3.amazonaws.com"){
                        strPic = "https://s3.amazonaws.com" + strPic
                    }
                    self.ivServicePic.sd_imageTransition = .fade
                    self.ivServicePic.sd_setImage(with: URL(string: strPic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                    self.ivServicePic.layer.cornerRadius = 5.0
                } else {
                    self.ivServicePic.image = UIImage(named: "photo_placeholder")
                    self.ivServicePic.layer.cornerRadius = 5.0
                }
            }
            
            if let strDesc = dictOffer["description"] as? String, strDesc != "" {
                self.lblServiceDesc.text = strDesc
            }
            
//            var dictPrice: [String:Any] = [:]
//            if dictOffer["price"] != nil {
//                dictPrice = (dictOffer["price"] as? [String:Any])!
//            } else if dictOffer["prices"] != nil {
//                let prices: [[String:Any]] = dictOffer["prices"] as! [[String : Any]]
//                dictPrice = prices[0]
//            }
            
            if let dictServiceLocation = dictOffer["location"] as? [String:Any] {
                var city = ""
                var country = ""
                if let city_temp = dictServiceLocation["city"] as? String {
                    city = city_temp
                }
                if let country_temp = dictServiceLocation["country"] as? String {
                    country = country_temp
                }
                self.lblServiceWork.text = "\(city), \(country)"
            }
            
//            if dictPrice.count > 0 {
//                var valServicePrice = 0
//                if let _ = dictPrice["price"] {
//                    let p: NSNumber = dictPrice["price"] as! NSNumber
//                    valServicePrice = p.intValue
//                }
//                var strServiceSymbol = "$"
//                if let _ = dictPrice["currencySymbol"] {
//                    strServiceSymbol = dictPrice["currencySymbol"] as! String
//                }
//                var valServiceTime = 1
//                if let _ = dictPrice["time"] {
//                    valServiceTime = dictPrice["time"] as! Int
//                }
//                var strServiceUnit = "hour"
//                if let _ = dictPrice["timeUnitOfMeasure"] {
//                    strServiceUnit = dictPrice["timeUnitOfMeasure"] as! String
//                }
                
//                    if valServiceTime > 1 {
//                        self.lblServiceWork.text = "Starts at " + strServiceSymbol + String(valServicePrice) + " for " + String(valServiceTime) + " " + strServiceUnit + "s"
//                    } else {
//                        self.lblServiceWork.text = "Starts at " + strServiceSymbol + String(valServicePrice) + " for " + String(valServiceTime) + " " + strServiceUnit
//                    }
//            }
            
            if let dictSeller = dictOffer["seller"] as? [String:Any] {
                var strFirst = ""
                if let _ = dictSeller["firstName"] {
                    strFirst = dictSeller["firstName"] as! String
                }
                var strLast = ""
                if let _ = dictSeller["lastName"] {
                    strLast = dictSeller["lastName"] as! String
                }
                
                self.lblName.text = strFirst + " " + strLast
            }
        }
        
        self.setNeedsDisplay()
    }
}

