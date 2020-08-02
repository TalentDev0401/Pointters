//
//  ChatPhotoCell.swift
//  Pointters
//
//  Created by Mac on 1/1/18.
//  Copyright © 2018 Simran. All rights reserved.
//

import UIKit

class ChatPhotoCell: ChatBaseCell {

    @IBOutlet weak var ivMessagePhoto: UIImageView!
    @IBOutlet weak var ivImageMask: UIImageView!
    @IBOutlet weak var leadingSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var ivPlayVideo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
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
            imageName = "bg_chat_msg_gray"
            self.ivImageMask.image = UIImage(named:imageName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(13, 13, 13, 36))
        }
        else {
            self.leadingSpacingConstraint.constant = 10.0
            self.trailingSpacingConstraint.constant = 10//25.0
            imageName = "bg_chat_msg"
            self.ivImageMask.image = UIImage(named:imageName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(13, 13, 13, 36))
        }
        
        ivMessagePhoto.layer.cornerRadius = 5.0
        ivMessagePhoto.layer.masksToBounds = true
        
        if let arrMedia = message["media"] as? [[String:Any]], arrMedia.count > 0 {
            var strType = "image"
            if let _ = arrMedia[0]["mediaType"] {
                strType = arrMedia[0]["mediaType"] as! String
            }
            
            if let _ = arrMedia[0]["fileName"] {
                var strPic = arrMedia[0]["fileName"] as! String
                if !strPic.contains("https://s3.amazonaws.com"){
                    strPic = "https://s3.amazonaws.com" + strPic
                }
                
                if strType == "video" {
                    if self.bIncoming {
                        ivMessagePhoto.image = UIImage(named: "icon-videoplayer-gray")
                    } else {
                        ivMessagePhoto.image = UIImage(named: "icon-videoplayer-white")
                    }
                    
                    if let _ = arrMedia[0]["videoThumbnail"] {
                        var strThumb = arrMedia[0]["videoThumbnail"] as! String
                        if !strThumb.contains("https://s3.amazonaws.com"){
                            strThumb = "https://s3.amazonaws.com" + strThumb
                        }
                        ivMessagePhoto.sd_imageTransition = .fade
                        ivMessagePhoto.sd_setImage(with: URL(string: strThumb), placeholderImage: UIImage(named:"photo_placeholder"))
                    }
                    ivPlayVideo.isHidden = false
                } else if strType == "image" {
                    ivMessagePhoto.sd_imageTransition = .fade
                    ivMessagePhoto.sd_setImage(with: URL(string: strPic), placeholderImage: UIImage(named:"photo_placeholder"))
                    ivPlayVideo.isHidden = true
                } else if strType == "document" {
                    ivMessagePhoto.image = UIImage(named: "doc-placeholder")
                    ivPlayVideo.isHidden = true
                }
            }
        }
        
        self.setNeedsDisplay()
    }
}
