//
//  FulfillmentCell.swift
//  Pointters
//
//  Created by super on 5/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol FulfillmentCellDelegate {
    func onSelectMedia(media: Media)
}

class FulfillmentCell: UITableViewCell {
    
    var delegate: FulfillmentCellDelegate!
    
    // status cell
    @IBOutlet weak var lblStatusDesc: UILabel!
    @IBOutlet weak var lblStarted: UILabel!
    @IBOutlet weak var lblOrderId: UILabel!
    
    // action button cell
    @IBOutlet weak var lblActionButton: UIButton!
    
    //delivered media cell
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var btnAddDownload: UILabel!
    
    // user cell
    @IBOutlet weak var ivUserPic: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblVerified: UILabel!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    
    // description cell
    @IBOutlet weak var lblDescription: UILabel!
    
    // order item cell
    @IBOutlet weak var lblPriceDesc: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    
    // total price cell
    @IBOutlet weak var lblServiceFee: UILabel!
    @IBOutlet weak var lblTaxes: UILabel!
    @IBOutlet weak var lblShippingFee: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var shippingFeeView: UIView!
    @IBOutlet weak var taxView: UIView!
    
    // buyer/seller schedule cell
    @IBOutlet weak var btnClickChange: UIButton!
    @IBOutlet weak var lblScheduleDate: UILabel!
    
    // work complete cell
    @IBOutlet weak var ivLeftIcon: UIImageView!
    @IBOutlet weak var lblWorkComplete: UILabel!
    
    // shipment cell
    @IBOutlet weak var packageDate: UILabel!
    @IBOutlet weak var courierValue: UILabel!
    @IBOutlet weak var trackingValue: UILabel!
    @IBOutlet weak var arrivalDate: UILabel!
    
    var deliveredMedia = [Media]()
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

extension FulfillmentCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deliveredMedia.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DeliverMediaCollectCell = collectionView.dequeueReusableCell(withReuseIdentifier: "deliverMediaCollectCell", for: indexPath) as! DeliverMediaCollectCell
        let item = self.deliveredMedia[indexPath.item]
        let fileName = item.fileName
        var placeholderType = ""
        switch item.mediaType {
        case "image":
            placeholderType = "photo_placeholder"
        case "doument":
            placeholderType = "doc-placeholder"
        case "video":
            placeholderType = "video-placeholder"
        default:
            placeholderType = "doc-placeholder"
        }
        cell.ivDeliver.sd_imageTransition = .fade
        cell.ivDeliver.sd_setImage(with: URL(string: fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:placeholderType))
        cell.ivDeliver.layer.cornerRadius = 5.0
        cell.lblFileName.text = "File \(String(format: "%02d", indexPath.row + 1))"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let media = self.deliveredMedia[indexPath.row]
        if self.delegate != nil{
            self.delegate.onSelectMedia(media: media)
        }
    }
}

class DeliverMediaCollectCell : UICollectionViewCell{
    @IBOutlet weak var ivDeliver: UIImageView!
    @IBOutlet weak var lblFileName: UILabel!
    
}




