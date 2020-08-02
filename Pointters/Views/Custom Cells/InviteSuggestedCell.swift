//
//  InviteSuggestedCell.swift
//  Pointters
//
//  Created by super on 4/26/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class InviteSuggestedCell: UITableViewCell {
    
    //user cell
    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblServiceCount: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    
    //info cell
    @IBOutlet weak var lblPointValue: UILabel!
    @IBOutlet weak var lblNumFollower: UILabel!
    @IBOutlet weak var lblNumOrder: UILabel!
    @IBOutlet weak var lblAvgRate: UILabel!
    
    //service cell
    @IBOutlet weak var collectionView: UICollectionView!
    
    var parentVC: InviteFriendViewController!
    
    var arrServices = [Service]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if collectionView != nil {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setCollectionView() {
        collectionView.reloadData()
    }

}

extension InviteSuggestedCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrServices.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionServiceCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionServiceCell
        let cellItem = arrServices[indexPath.item]
        cell.ivService.sd_imageTransition = .fade
        cell.ivService.sd_setImage(with: URL(string: cellItem.media.fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
//        cell.ivService.image = UIImage(named: "service_card")
        cell.ivService.layer.cornerRadius = 5.0
        cell.lblDesc.text = cellItem.desc
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellItem = arrServices[indexPath.item]
        let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
        let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
        serviceDetailVC.serviceId = cellItem.id
        parentVC.navigationController?.pushViewController(serviceDetailVC, animated: true)
    }
}

class CollectionServiceCell : UICollectionViewCell{
    @IBOutlet weak var ivService: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
}
