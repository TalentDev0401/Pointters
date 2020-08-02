//
//  PaymentCell.swift
//  Pointters
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {

    // payment cell
    @IBOutlet var imgIcon: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
    @IBOutlet var lblDefault: UILabel!
    
    @IBOutlet weak var imgRightArrow: UIImageView!
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var constantPaymentIconRatio: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
