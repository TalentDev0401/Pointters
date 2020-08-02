//
//  ShippingRateCell.swift
//  Pointters
//
//  Created by Dream Software on 9/9/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ShippingRateCell: UITableViewCell {

    // shipping rate cell
    @IBOutlet var imgIcon: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblPrice: UILabel!
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
