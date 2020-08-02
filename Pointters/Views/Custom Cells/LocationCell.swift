//
//  LocationCell.swift
//  Pointters
//
//  Created by C on 7/7/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelAddressDetail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
