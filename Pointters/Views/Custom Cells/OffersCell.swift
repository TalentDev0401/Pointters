//
//  OffersCell.swift
//  Pointters
//
//  Created by Mac on 2/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class OffersCell: UITableViewCell {
    
    // buy custom offer, sell offer
    @IBOutlet var imgService: UIImageView!
    @IBOutlet var btnAccept: UIButton!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblWorkTime: UILabel!
    @IBOutlet var lblPostTime: UILabel!
    @IBOutlet var btnChat: UIButton!
    @IBOutlet var btnCall: UIButton!
    @IBOutlet var btnName: UIButton!
    @IBOutlet weak var btnSeeOrderSeller: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
