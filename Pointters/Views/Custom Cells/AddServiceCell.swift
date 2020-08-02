//
//  AddServiceCell.swift
//  Pointters
//
//  Created by Mac on 2/24/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class AddServiceCell: UITableViewCell {
    
    // price cell
    @IBOutlet var lblPrice: UILabel!
    //tag line
    @IBOutlet weak var tagTitle: UITextView!
    // desc cell
    @IBOutlet var tfDesc: UITextView!
     
    // online cell, local cell
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
    @IBOutlet var imgCheck: UIImageView!    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
