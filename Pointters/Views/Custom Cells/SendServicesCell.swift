//
//  SendServicesCell.swift
//  Pointters
//
//  Created by Mac on 2/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class SendServicesCell: UITableViewCell {
    
    @IBOutlet var imgService: UIImageView!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var btnName: UIButton!
    @IBOutlet var btnSend: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgService.layer.cornerRadius = 5.0
        imgService.layer.masksToBounds = true
        
        btnSend.layer.borderWidth = 1.0
        btnSend.layer.borderColor = UIColor.getCustomLightBlueColor().cgColor
        btnSend.layer.cornerRadius = 3.0
        btnSend.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
