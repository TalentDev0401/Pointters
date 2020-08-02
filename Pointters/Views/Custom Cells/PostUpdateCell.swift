//
//  PostUpdateCell.swift
//  Pointters
//
//  Created by super on 3/9/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class PostUpdateCell: UITableViewCell {
    
    @IBOutlet weak var ivUser: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivUser.layer.cornerRadius = ivUser.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
