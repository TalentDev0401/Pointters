//
//  ThirdStyleCell.swift
//  Pointters
//
//  Created by super on 3/5/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol LocalServiceDelegate {
    func didClickPlayVideoFromLocalService(url: String)
    func didSelectedFromLocalService(index: Int)
}

class LocalServiceCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnShowAll: UIButton!
    
    var delegate: LocalServiceDelegate!
    
    var localServices = [[String:Any]]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func playVideo(guesture: MyTapGesture){
        self.delegate.didClickPlayVideoFromLocalService(url: guesture.param)
    }

}

extension LocalServiceCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return localServices.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LocalServiceCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "localServiceCollectionCell", for: indexPath) as! LocalServiceCollectionCell
        cell.catImageView.layer.cornerRadius = 6
        cell.darkView.layer.cornerRadius = 6
        let item = self.localServices[indexPath.row] as NSDictionary
        if let _ = item.value(forKey: "media"){
            let media = item.value(forKey: "media") as! NSDictionary
            let type = media.value(forKey: "mediaType") as! String
            if type == "image"{
                cell.darkView.isHidden = true
                cell.buttonVideoPlay.isHidden = true
                let itemImageUrl = media.value(forKey: "fileName") as! String
                cell.catImageView.sd_imageTransition = .fade
                cell.catImageView.sd_setImage(with: URL(string: itemImageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
            }else{
                cell.darkView.isHidden = false
                cell.buttonVideoPlay.isHidden = false
                let itemImageUrl = media.value(forKey: "videoThumbnail") as? String ?? ""
                cell.catImageView.sd_imageTransition = .fade
                cell.catImageView.sd_setImage(with: URL(string: itemImageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                let tapGuesture = MyTapGesture(target: self, action: #selector(self.playVideo(guesture:)))
                tapGuesture.param = media.value(forKey: "fileName") as? String ?? ""
                cell.buttonVideoPlay.addGestureRecognizer(tapGuesture)
            }
        }
        
        if let _ = item.value(forKey: "seller"){
            let user = item.value(forKey: "seller") as! NSDictionary
            let firstName = user.value(forKey: "firstName") as! String
            let lastName = user.value(forKey: "lastName") as! String
            cell.lblName.text = "\(firstName) \(lastName)"
        }else{
            cell.lblName.text = "Unknown"
        }
        
        if let _ = item.value(forKey: "tagline"){
            cell.lblDescription.text = item.value(forKey: "tagline") as? String
        }else{
            cell.lblDescription.text = ""
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate.didSelectedFromLocalService(index: indexPath.row)
    }
}

class LocalServiceCollectionCell : UICollectionViewCell{
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var buttonVideoPlay: UIButton!
}
