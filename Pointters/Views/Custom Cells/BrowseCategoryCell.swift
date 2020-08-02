//
//  BrowseCategoryCell.swift
//  Pointters
//
//  Created by super on 3/5/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class BrowseCategoryCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnShowAll: UIButton!
    
    var arrCat = [[String:Any]]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension BrowseCategoryCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCat.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BrowseCategotyCatCell = collectionView.dequeueReusableCell(withReuseIdentifier: "browseCategoryCatCell", for: indexPath) as! BrowseCategotyCatCell
        let item = self.arrCat[indexPath.item]
        let fileName = item["image"] as! String
        cell.catImageView.sd_imageTransition = .fade
        cell.catImageView.sd_setImage(with: URL(string: fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
        cell.catImageView.layer.cornerRadius = 5.0
        cell.lblTitle.text = item["title"] as? String
        cell.lblSubtitle.text = item["subTitle"] as? String
        return cell
    }
    
}

class BrowseCategotyCatCell : UICollectionViewCell{
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
}
