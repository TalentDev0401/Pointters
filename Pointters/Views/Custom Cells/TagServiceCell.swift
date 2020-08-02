//
//  TagServiceCell.swift
//  Pointters
//
//  Created by Mac on 2/22/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class TagServiceCell: UITableViewCell {
    
    @IBOutlet var imgService: UIImageView!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblWorkTime: UILabel!
    @IBOutlet weak var labelPrefixName: UILabel!
    @IBOutlet var btnName: UIButton!
    @IBOutlet var lblPoint: UILabel!
    @IBOutlet var lblBusiness: UILabel!
    @IBOutlet var lblRating: UILabel!
    @IBOutlet var imgCheck: UIImageView!
    
    @IBOutlet var backView: UIView!
    @IBOutlet var btnDelete: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
