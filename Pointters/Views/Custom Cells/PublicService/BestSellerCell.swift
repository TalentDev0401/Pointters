//
//  BestSellerCell.swift
//  Pointters
//
//  Created by super on 3/5/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol BestSellerDelegate {
    func didSelectedSeller(index: Int)
}

class BestSellerCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnShowAll: UIButton!
    
    var arrSellers = [[String:Any]]()
    
    var delegate: BestSellerDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension BestSellerCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSellers.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BestSellerCatCell = collectionView.dequeueReusableCell(withReuseIdentifier: "bestSellerCatCell", for: indexPath) as! BestSellerCatCell
        cell.catImageView.layer.cornerRadius = 31
        let item = self.arrSellers[indexPath.row] as NSDictionary
        if let _ = item.value(forKey: "media"){
            let media = item.value(forKey: "media") as! NSDictionary
            let type = media.value(forKey: "mediaType") as! String
            if type == "image"{
                let itemImageUrl = media.value(forKey: "fileName") as! String
                cell.catImageView.sd_imageTransition = .fade
                cell.catImageView.sd_setImage(with: URL(string: itemImageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
            }else{
                let itemImageUrl = media.value(forKey: "fileName") as! String
                cell.catImageView.sd_imageTransition = .fade
                cell.catImageView.sd_setImage(with: URL(string: itemImageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
            }
        }
        if let _ = item.value(forKey: "name"){
            cell.lblName.text = item.value(forKey: "name") as? String
        }else{
            cell.lblName.text = "Unknown"
        }
        if let _ = item.value(forKey: "title"){
            cell.lblSubTitle.text = item.value(forKey: "title") as? String
        }else{
            cell.lblSubTitle.text = "Unknown"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate.didSelectedSeller(index: indexPath.row)
    }
    
}

class BestSellerCatCell : UICollectionViewCell{
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
}
