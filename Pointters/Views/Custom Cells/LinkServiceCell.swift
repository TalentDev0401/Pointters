//
//  LinkServiceCell.swift
//  Pointters
//
//  Created by super on 4/16/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class LinkServiceCell: UITableViewCell {

    @IBOutlet var containerView: UIView!
    @IBOutlet var imgService: UIImageView!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var btnName: UIButton!
    @IBOutlet var btnLink: UIButton!
    @IBOutlet weak var btnClickLink: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 5.0
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize.init(width: 1.0, height: 1.0)
        containerView.layer.shadowRadius = 3.0
        imgService.layer.cornerRadius = 5.0
        imgService.layer.masksToBounds = true
        
        btnLink.layer.borderWidth = 1.0
        btnLink.layer.borderColor = UIColor.getCustomLightBlueColor().cgColor
        btnLink.layer.cornerRadius = 3.0
        btnLink.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
