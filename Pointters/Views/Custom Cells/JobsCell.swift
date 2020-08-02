//
//  JobsCell.swift
//  Pointters
//
//  Created by Mac on 2/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class JobsCell: UITableViewCell {
    
    // live offer cell, job cell
    @IBOutlet var imgService: UIImageView!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblOfferTime: UILabel!
    @IBOutlet var btnOffer: UIButton!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var lblOldOffers: UILabel!
    @IBOutlet var lblNewOffers: UILabel!
    @IBOutlet var btnExpires: UIButton!
    @IBOutlet weak var btnRequestAgain: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
