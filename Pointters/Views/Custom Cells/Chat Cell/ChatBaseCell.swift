//
//  ChatBaseCell.swift
//  Pointters
//
//  Created by Mac on 1/2/18.
//  Copyright © 2018 Simran. All rights reserved.
//

import UIKit

class ChatBaseCell: UITableViewCell {
    
    @IBOutlet weak var viewUser: UIView!
    @IBOutlet weak var ivUserPhoto: UIImageView!
    
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var conUserViewLeading: NSLayoutConstraint!
    @IBOutlet weak var conMessageViewLeading: NSLayoutConstraint!
    @IBOutlet weak var conMessageViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var conCheckIconLeading: NSLayoutConstraint!
    
    var bIncoming: Bool = false
    var strPhoto: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setUserData(userData:[String:Any]) {
        self.bIncoming = userData["income"] as! Bool

        if self.bIncoming {
            self.strPhoto = userData["sender_photo"] as! String
            let strImg: String = self.strPhoto
            
            ivUserPhoto.layer.cornerRadius = (ivUserPhoto.frame.height)/2
            ivUserPhoto.layer.masksToBounds = true
            ivUserPhoto.sd_imageTransition = .fade
            ivUserPhoto.sd_setImage(with: URL(string: strImg), placeholderImage: UIImage(named:"user_avatar_placeholder"))
            ivUserPhoto.layer.cornerRadius = ivUserPhoto.frame.size.width / 2
        }
        
//        let nDevType: Int = PointtersHelper.sharedInstance.getDeviceType()
        
        let sideWidth: CGFloat = 60
        let totalWidth = UIScreen.main.bounds.size.width
        if self.bIncoming {
            self.conUserViewLeading.constant = 0
            self.conMessageViewLeading.constant = sideWidth + 20 - 25
            self.conMessageViewTrailing.constant = sideWidth - 20 + 25
            self.conCheckIconLeading.constant = 15
            self.viewUser.isHidden = false
        } else {
            self.conUserViewLeading.constant = totalWidth - sideWidth
            self.conMessageViewTrailing.constant = 10
            self.conMessageViewLeading.constant = sideWidth * 2 - 10
            self.conCheckIconLeading.constant = 10
            
            self.viewUser.isHidden = true
        }
        
        self.backgroundColor = UIColor.clear
        self.backgroundView = nil
        self.setNeedsLayout()
    }
    
    func setData(message:[String:Any]) {}
}
