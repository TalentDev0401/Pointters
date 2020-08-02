//
//  CancelOrderCell.swift
//  Pointters
//
//  Created by Dream Software on 9/14/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class CancelOrderCell: UITableViewCell {

    @IBOutlet weak var labelReason: UILabel!
    @IBOutlet weak var imageCheck: UIImageView!
    
    @IBOutlet weak var textViewMessage: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
