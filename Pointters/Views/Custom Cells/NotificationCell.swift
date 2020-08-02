//
//  NotificationCell.swift
//  Pointters
//
//  Created by super on 4/3/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblActivity: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgMedia: UIImageView!
    @IBOutlet weak var imgUnread: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
