//
//  ProfileCell.swift
//  Pointters
//
//  Created by Mac on 2/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {
    
    // user cell
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var imgCamera: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblVerfied: UILabel!
    @IBOutlet var btnFollow: UIButton!
    @IBOutlet var btnEdit: UIButton!
    
    // desc cell
    @IBOutlet weak var tvDesc: UITextView!
    @IBOutlet weak var lblTag: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var moreTvDesc: ReadMoreTextView!

    // contact cell
    @IBOutlet var lblCompany: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblPhone: UILabel!
    @IBOutlet var btnCall: UIButton!
    @IBOutlet var btnChat: UIButton!
    @IBOutlet var imgPhone: UIImageView!
    @IBOutlet var imgAddress: UIImageView!
    @IBOutlet weak var imageCompany: UIImageView!
    
    // info cell
    @IBOutlet var lblPoint: UILabel!
    @IBOutlet var lblLikes: UILabel!
    @IBOutlet var lblWatching: UILabel!
    @IBOutlet var iconLikes: UIImageView!
    @IBOutlet var btnLikes: UIButton!
    @IBOutlet var iconWatch: UIImageView!
    @IBOutlet var btnWatch: UIButton!
    
    // metrics cell
    @IBOutlet var lblOnTime: UILabel!
    @IBOutlet var lblQuality: UILabel!
    @IBOutlet var lblResponse: UILabel!
    @IBOutlet var lblMetricOrders: UILabel!
    @IBOutlet var lblMetricRatings: UILabel!
    @IBOutlet var lblMetricCustomers: UILabel!
        
    // service cell
    @IBOutlet var imgService: UIImageView!
    @IBOutlet var lblServiceDesc: UILabel!
    @IBOutlet var lblServicePrice: UILabel!
    @IBOutlet var lblServiceTime: UILabel!
    @IBOutlet var lblServiceAddress: UILabel!
    @IBOutlet var btnSellerName: UIButton!
    @IBOutlet var lblServicePoint: UILabel!
    @IBOutlet var lblServiceBusiness: UILabel!
    @IBOutlet var lblServiceRating: UILabel!
    @IBOutlet var btnPic: UIButton!
    @IBOutlet var iconPromotion: UIImageView!
    @IBOutlet var lblPromotion: UILabel!
    
    // labeled text field cell, labeled text view cell
    @IBOutlet var tfTitle: JVFloatLabeledTextField!
    @IBOutlet var tfDesc: JVFloatLabeledTextView!
    
    // address cell
    @IBOutlet var lblLocation: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
