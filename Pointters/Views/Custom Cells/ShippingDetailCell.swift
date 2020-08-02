//
//  ShippingDetailCell.swift
//  Pointters
//
//  Created by super on 5/29/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ShippingDetailCell: UITableViewCell {
    
    @IBOutlet weak var tfDesc: UITextField!
    @IBOutlet weak var lblUnit: UILabel!
    @IBOutlet weak var labelInvalid: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
