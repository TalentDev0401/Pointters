//
//  ReviewOrderCell.swift
//  Pointters
//
//  Created by dreams on 9/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ReviewOrderCell: UITableViewCell {

    @IBOutlet weak var textViewMessage: UITextView!
    @IBOutlet weak var qualitySlider: UISlider!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var againSwitch: UISegmentedControl!
    @IBOutlet weak var labelRating: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onChangeRating(_ sender: UISlider) {
        let step: Float = 1
        let roundedValue = round(sender.value / step) * step
        self.labelRating.text = "\(Int(roundedValue))%"
    }
}
