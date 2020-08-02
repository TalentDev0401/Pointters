//
//  PopularJobCell.swift
//  Pointters
//
//  Created by super on 3/5/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol PopularJobDelegate {
    func didSelectedJob(index: Int, isPopular: Bool)
    func didClickPlayVideoFromJob(url: String)
}

class PopularJobCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnShowAll: UIButton!
    
    var isPopular = true
    
    var delegate: PopularJobDelegate!
    
    var popularJobs = [[String:Any]]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func playVideo(guesture: MyTapGesture){
        self.delegate.didClickPlayVideoFromJob(url: guesture.param)
    }
}

extension PopularJobCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularJobs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PopularJobCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularJobCollectionCell", for: indexPath) as! PopularJobCollectionCell
        cell.darkView.layer.cornerRadius = 6
        cell.catImageView.layer.cornerRadius = 6
        let item = self.popularJobs[indexPath.row] as NSDictionary
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
        } else {
            cell.buttonVideoPlay.isHidden = true
            cell.darkView.isHidden = true
        }
        
        if let _ = item.value(forKey: "user"){
            let user = item.value(forKey: "user") as! NSDictionary
            let firstName = user.value(forKey: "firstName") as! String
            let lastName = user.value(forKey: "lastName") as! String
            cell.lblName.text = "\(firstName) \(lastName)"
        }else{
            cell.lblName.text = "Unknown"
        }
        
        if let _ = item.value(forKey: "description"){
            cell.lblDescription.text = item.value(forKey: "description") as? String
        }else{
            cell.lblDescription.text = ""
        }
        var currencyCode = "$"
        if let _ = item.value(forKey: "currencyCode") {
            currencyCode = item.value(forKey: "currencyCode") as! String
        }
       
        if let _ = item.value(forKey: "maxPrice"){
            let maxPrice = item.value(forKey: "maxPrice") as! NSNumber
            var minPrice: NSNumber = 0
            if let _ = item.value(forKey: "minPrice"){
                minPrice = item.value(forKey: "minPrice") as! NSNumber
            }
            cell.lblPrice.text = "\(currencyCode)\(String(format: "%.2f", minPrice.floatValue))~\(currencyCode)\(String(format: "%.2f", maxPrice.floatValue))"
            
        }else{
            cell.lblPrice.text = ""
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate.didSelectedJob(index: indexPath.row, isPopular: self.isPopular)
    }
    
}

class PopularJobCollectionCell : UICollectionViewCell{
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var buttonVideoPlay: UIButton!
    @IBOutlet weak var darkView: UIView!
}
