//
//  PopularCategoryCell.swift
//  Pointters
//
//  Created by super on 3/4/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol PopularCagegoryDelegate {
    func didSelectedPopularCategory(index: Int)
    func didClickPlayVideoOnPopular(url: String)
}

class PopularCategoryCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnShowAll: UIButton!
    
    var delegate: PopularCagegoryDelegate!
    
    var popularCategories = [[String:Any]]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func playVideo(guesture: MyTapGesture){
        self.delegate.didClickPlayVideoOnPopular(url: guesture.param)
    }

}

extension PopularCategoryCell : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PopularCatCollectCell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularCatCollectCell", for: indexPath) as! PopularCatCollectCell
        let item = self.popularCategories[indexPath.row] as NSDictionary
        if let _ = item.value(forKey: "media"){
            let media = item.value(forKey: "media") as! NSDictionary
            let type = media.value(forKey: "mediaType") as! String
            if type == "image"{
                cell.buttonVideoPlay.isHidden = true
                let itemImageUrl = media.value(forKey: "fileName") as! String
                cell.contentImage.sd_imageTransition = .fade
                cell.contentImage.sd_setImage(with: URL(string: itemImageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                cell.contentImage.layer.cornerRadius = 8
                cell.contentImage.layer.masksToBounds = true
            }else{
                cell.buttonVideoPlay.isHidden = false
                let itemImageUrl = media.value(forKey: "videoThumbnail") as? String ?? ""
                cell.contentImage.sd_imageTransition = .fade
                cell.contentImage.sd_setImage(with: URL(string: itemImageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                let tapGuesture = MyTapGesture(target: self, action: #selector(self.playVideo(guesture:)))
                tapGuesture.param = media.value(forKey: "fileName") as? String ?? ""
                cell.buttonVideoPlay.addGestureRecognizer(tapGuesture)
            }
        }
        
        if let _ = item.value(forKey: "name"){
            let title = item.value(forKey: "name") as! String
            cell.labelTitle.text = title
        }else{
            cell.labelTitle.text = ""
        }
        
        if let _ = item.value(forKey: "countLocal"), let _ = item.value(forKey: "countOnline"), let _ = item.value(forKey: "countTotal") {
            let total = item.value(forKey: "countTotal") as! Int
            let subtite = "(\(total))"
            cell.labelSubtitle.text = subtite
        }else{
            cell.labelSubtitle.text = ""
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate.didSelectedPopularCategory(index: indexPath.row)
    }
    
}

class PopularCatCollectCell : UICollectionViewCell{
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    @IBOutlet weak var buttonVideoPlay: UIButton!
    
}
