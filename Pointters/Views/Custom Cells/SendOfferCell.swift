//
//  SendOfferCell.swift
//  Pointters
//
//  Created by super on 4/2/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class SendOfferCell: UITableViewCell {
    
    // service cell
    @IBOutlet var imgService: UIImageView!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var btnSellerName: UIButton!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var btnDelete: UIButton!
    
    // offer price
    @IBOutlet weak var tfOfferPrice: UITextField!
    
    // offer description
    @IBOutlet var tvOfferDesc: UITextView!
    @IBOutlet var btnDescClear: UIButton!
    
    // time select
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgArrow: UIImageView!
    
    // online cell, local cell
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
    @IBOutlet var imgCheck: UIImageView!
    
    // request cell
    @IBOutlet weak var imgClose: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
