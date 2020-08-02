//
//  CommentCell.swift
//  Pointters
//
//  Created by super on 4/13/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet var ivUserPic: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblComment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivUserPic.layer.cornerRadius = ivUserPic.frame.size.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
