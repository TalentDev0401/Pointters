//
//  PriceCell.swift
//  Pointters
//
//  Created by Mac on 2/24/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class PriceCell: UITableViewCell {
    
    // add price cell
    @IBOutlet var tfPrice: UITextField!
    // desc cell
    @IBOutlet var tvDesc: UITextView!
    @IBOutlet var btnClose: UIButton!
    // time cell
    @IBOutlet var tfTime: UITextField!
    @IBOutlet var imgArrow: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
