//
//  FollowCell.swift
//  Pointters
//
//  Created by Mac on 2/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class FollowCell: UITableViewCell {
    
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var btnFollow: UIButton!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
