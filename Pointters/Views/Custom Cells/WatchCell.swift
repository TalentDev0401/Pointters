//
//  WatchCell.swift
//  Pointters
//
//  Created by Mac on 2/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class WatchCell: UITableViewCell {
    
    @IBOutlet var imgService: UIImageView!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var btnName: UIButton!
    @IBOutlet var lblPoint: UILabel!
    @IBOutlet var lblBusiness: UILabel!
    @IBOutlet var lblRating: UILabel!
    @IBOutlet var iconPromotion: UIImageView!
    @IBOutlet var lblPromotion: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
