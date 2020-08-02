//
//  BackgroundCell.swift
//  Pointters
//
//  Created by Mac on 2/17/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import iOSDropDown

class BackgroundCell: UITableViewCell {
    
    // edit cell, text cell
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var tfDesc: UITextField!
    @IBOutlet var bankname: DropDown!
    @IBOutlet weak var iconCheck: UIImageView!
    @IBOutlet weak var labelInvalid: UILabel!
    @IBOutlet weak var segmentType: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension BackgroundCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == bankname {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
