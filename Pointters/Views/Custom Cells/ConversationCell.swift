//
//  ConversationCell.swift
//  Pointters
//
//  Created by Mac on 2/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    @IBOutlet var imgOnline: UIImageView!
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
