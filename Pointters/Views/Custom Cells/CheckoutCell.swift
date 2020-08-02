//
//  CheckoutCell.swift
//  Pointters
//
//  Created by super on 4/4/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class CheckoutCell: UITableViewCell {
    
    // service cell
    @IBOutlet var imgService: UIImageView!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnSellerName: UIButton!
    
    //prices cell
    @IBOutlet weak var lblServicePrice: UILabel!
    @IBOutlet weak var btnAddAmount: UIButton!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var btnDownAmount: UIButton!
    
    //service fee cell
    @IBOutlet weak var lblTax: UILabel!
    @IBOutlet weak var constantTaxHeight: NSLayoutConstraint!
    @IBOutlet weak var viewTax: UIView!
    
    @IBOutlet weak var lblFee: UILabel!
    @IBOutlet weak var lblCompleteTime: UILabel!
    @IBOutlet weak var lblTotalFee: UILabel!
    @IBOutlet weak var lblbuyerlocation: UILabel!
    @IBOutlet weak var addLocationBtn: UIButton!
    
    @IBOutlet weak var lblstartDate: UILabel!
    @IBOutlet weak var lblendDate: UILabel!
    
    @IBOutlet weak var imgPaymentMethod: UIImageView!
    @IBOutlet weak var lblPaymentMethod: UILabel!
    @IBOutlet weak var lblPaymentInfo: UILabel!
    @IBOutlet weak var constantPaymentIconRatio: NSLayoutConstraint!
    
    //shipping cell
    @IBOutlet weak var lblShippingAddress: UILabel!

    //shipping rate cell
    @IBOutlet weak var lblShippingPrice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
