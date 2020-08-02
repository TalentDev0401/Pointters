//
//  ShippingAddressCell.swift
//  Pointters
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ShippingAddressCell: UITableViewCell {
    
    // shipping cell
    @IBOutlet var imgIcon: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lbldefault: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
    @IBOutlet var imgCheck: UIImageView!
    @IBOutlet weak var labelInvalid: UILabel!
    
    // new address cell
    @IBOutlet var lblNewAddress: UILabel!
    
    
    // edit address cell
    @IBOutlet var tfDesc: UITextField!
    @IBOutlet var seperator: UIView!
    @IBOutlet var lblCountry: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
