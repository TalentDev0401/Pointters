//
//  ExploreServiceCell.swift
//  Pointters
//
//  Created by super on 3/6/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ExploreServiceCell: UITableViewCell {

    @IBOutlet weak var ivService: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTimeUnit: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var btnSellerName: UIButton!
    @IBOutlet weak var lblPoitValue: UILabel!
    @IBOutlet weak var lblNumOrders: UILabel!
    @IBOutlet weak var lblAvgRating: UILabel!
    @IBOutlet weak var promotedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivService.layer.cornerRadius = 5.0
        lblPrice.layer.cornerRadius = lblPrice.frame.size.height / 2
        lblPrice.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
