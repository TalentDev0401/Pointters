//
//  ChatMessageCell.swift
//  Pointters
//
//  Created by Mac on 1/1/18.
//  Copyright © 2018 Simran. All rights reserved.
//

import UIKit

class ChatMessageCell: ChatBaseCell {

    @IBOutlet weak var bvMessageText: ChatBubbleView!
    @IBOutlet weak var conBubbleViewLeading: NSLayoutConstraint!
    @IBOutlet weak var conBubbleViewTrailing: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTime?.font = UIFont(name: "Helvetica", size: 9.0)!
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func setData(message: [String:Any]) {
        super.setData(message: message)
        
        var msgText = ""
        if let _ = message["messageText"] {
            msgText = message["messageText"] as! String
        } else if let dictOffer = message["offer"] as? [String:Any] {
            var valPrice = 0
            if let _ = dictOffer["price"] {
                valPrice = dictOffer["price"] as! Int
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
                msgText = "Custom offer " + strSymbol + String(valPrice) + " Service for " + String(valWorkTime) + " " + strWorkUnit + "s"
            } else {
                msgText = "Custom offer " + strSymbol + String(valPrice) + " Service for " + String(valWorkTime) + " " + strWorkUnit
            }
        }
        self.bvMessageText.setText(contentText: msgText, nBubble: self.bIncoming)
        
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

        do {
            if self.conBubbleViewLeading == nil {
                self.conBubbleViewLeading = NSLayoutConstraint.init(item: self.bvMessageText, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.viewMessage, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0)
                self.addConstraint(self.conBubbleViewLeading)
            }
            if self.conBubbleViewTrailing == nil {
                self.conBubbleViewTrailing = NSLayoutConstraint.init(item: self.viewMessage, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.bvMessageText, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0)
                self.addConstraint(self.conBubbleViewTrailing)
            }
            
            if self.bIncoming {
                NSLayoutConstraint.deactivate([self.conBubbleViewTrailing])
            } else {
                NSLayoutConstraint.deactivate([self.conBubbleViewLeading])
            }
        } catch is NSException {
            print("Constraints activation error!!!")
        }
    }
}
