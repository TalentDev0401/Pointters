//
//  OrdersCell.swift
//  Pointters
//
//  Created by Mac on 2/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class OrdersCell: UITableViewCell {
    
    // order cell
    @IBOutlet var imgService: UIImageView!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblWorkTime: UILabel!
    @IBOutlet var btnPaid: UIButton!
    @IBOutlet var btnName: UIButton!
    @IBOutlet var btnPending: UIButton!
    @IBOutlet var btnChat: UIButton!
    @IBOutlet var btnCall: UIButton!
    @IBOutlet var btnBell: UIButton!
    @IBOutlet var bgRed: UIImageView!
    @IBOutlet var lblBell: UILabel!
    @IBOutlet weak var imgRightArrow: UIImageView!
    @IBOutlet weak var imagePending: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
