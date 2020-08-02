//
//  PrivateChatCell.swift
//  Pointters
//
//  Created by super on 4/10/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class PrivateChatCell: UITableViewCell {
    
    @IBOutlet var lblLeftTime: UILabel!
    @IBOutlet var lblRightTime: UILabel!
    @IBOutlet var imgProfilePic: UIImageView!
    
    // left text message cell
    @IBOutlet var leftTextBubbleView: UIView!
    @IBOutlet var lblLeftMsg: UILabel!
    
    // right text message cell
    @IBOutlet var rightTextBubbleView: UIView!
    @IBOutlet var lblRightMsg: UILabel!
    
    
    @IBOutlet var serviceContentView: UIView!
    @IBOutlet var imgService: UIImageView!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblHour: UILabel!
    @IBOutlet var btnSellerName: UIButton!
    @IBOutlet var btnBuy: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
