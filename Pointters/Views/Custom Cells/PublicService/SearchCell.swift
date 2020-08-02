//
//  SearchCell.swift
//  Pointters
//
//  Created by dreams on 11/1/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {
    @IBOutlet weak var labelRecent: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var imageCategory: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
