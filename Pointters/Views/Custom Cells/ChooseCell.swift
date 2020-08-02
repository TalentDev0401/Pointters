//
//  ChooseCell.swift
//  Pointters
//
//  Created by Mac on 2/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ChooseCell: UITableViewCell {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgCheck: UIImageView!
    @IBOutlet var imgSeperator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
