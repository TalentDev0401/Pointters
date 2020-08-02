//
//  CategoryCell.swift
//  Pointters
//
//  Created by Mac on 2/26/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgArrow: UIImageView!
    @IBOutlet var btnCategory: UIButton!
    
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
