//
//  LiveOfferCell.swift
//  Pointters
//
//  Created by super on 3/7/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class LiveOfferCell: UITableViewCell {
    
    @IBOutlet weak var ivSeller: UIImageView!
    @IBOutlet weak var lblSellerName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivSeller.layer.cornerRadius = ivSeller.frame.size.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
