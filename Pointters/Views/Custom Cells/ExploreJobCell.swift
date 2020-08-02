//
//  ExploreJobCell.swift
//  Pointters
//
//  Created by super on 3/7/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ExploreJobCell: UITableViewCell {
    
    @IBOutlet weak var ivJob: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPostDate: UILabel!
    @IBOutlet weak var lblOfferSent: UILabel!
    @IBOutlet weak var btnMakeOffer: UIButton!
    @IBOutlet weak var btnEditOffer: UIButton!
    @IBOutlet weak var lblPriceRange: UILabel!
    @IBOutlet weak var lblNumOffers: UILabel!
    @IBOutlet weak var lblExpireDate: UILabel!
    @IBOutlet weak var lblJobType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivJob.layer.cornerRadius = 5.0
        lblOfferSent.layer.cornerRadius = 5.0
        lblOfferSent.layer.masksToBounds = true
        btnMakeOffer.layer.cornerRadius = 5.0
        btnMakeOffer.layer.masksToBounds = true
        btnMakeOffer.layer.borderWidth = 1.0
        btnEditOffer.layer.cornerRadius = 5.0
        btnEditOffer.layer.masksToBounds = true
        btnEditOffer.layer.borderWidth = 1.0
        if #available(iOS 10.0, *) {
            btnMakeOffer.layer.borderColor = UIColor(displayP3Red: 0, green: 122/255, blue: 1, alpha: 1).cgColor
            btnEditOffer.layer.borderColor = UIColor(displayP3Red: 0, green: 122/255, blue: 1, alpha: 1).cgColor
        } else {
            btnMakeOffer.layer.borderColor = UIColor(red: 0, green: 122/255, blue:1, alpha: 1).cgColor
            btnEditOffer.layer.borderColor = UIColor(red: 0, green: 122/255, blue:1, alpha: 1).cgColor
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
