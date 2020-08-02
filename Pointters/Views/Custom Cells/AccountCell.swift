//
//  AccountCell.swift
//  Pointters
//
//  Created by Mac on 2/15/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {

    // account cell
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblVerified: UILabel!
    @IBOutlet var lblFollowers: UILabel!
    @IBOutlet var lblFollowing: UILabel!
    @IBOutlet var lblPoints: UILabel!
    
    // setting cell
    @IBOutlet var imgMark: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgNoteBg: UIImageView!
    @IBOutlet var lblNoteCnt: UILabel!
    
    // normal cell
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var imgCross: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
