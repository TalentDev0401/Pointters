//
//  OnlineServiceCell.swift
//  Pointters
//
//  Created by Billiard ball on 15.06.2020.
//  Copyright © 2020 Kenji. All rights reserved.
//

import UIKit

protocol OnlineServiceDelegate {
    func didSelectedOnlineService(index: Int)
    func didClickPlayVideoOnOnlineService(url: String)
}

class OnlineServiceCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnShowAll: UIButton!
    
    var onlineServices = [[String:Any]]()
    
    var delegate: OnlineServiceDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func playVideo(guesture: MyTapGesture){
        self.delegate.didClickPlayVideoOnOnlineService(url: guesture.param)
    }
    
}

extension OnlineServiceCell : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onlineServices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OnlineServiceCollectCell = collectionView.dequeueReusableCell(withReuseIdentifier: "onlineServiceCollectCell", for: indexPath) as! OnlineServiceCollectCell
        let item = self.onlineServices[indexPath.row] as NSDictionary
        
        if let _ = item.value(forKey: "media"){
            let media = item.value(forKey: "media") as! NSDictionary
            let type = media.value(forKey: "mediaType") as! String
            if type == "image"{
                let itemImageUrl = media.value(forKey: "fileName") as! String
                cell.contentImage.sd_imageTransition = .fade
                cell.contentImage.sd_setImage(with: URL(string: itemImageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                cell.contentImage.layer.cornerRadius = 8
                cell.contentImage.layer.masksToBounds = true
                cell.darkView.isHidden = true
                cell.btnVideoPlay.isHidden = true
            }else{
                cell.btnVideoPlay.isHidden = false
                cell.darkView.isHidden = false
                cell.darkView.layer.cornerRadius = 8
                cell.darkView.layer.masksToBounds = true
                
                let itemImageUrl = media.value(forKey: "videoThumbnail") as? String ?? ""
                cell.contentImage.sd_imageTransition = .fade
                cell.contentImage.sd_setImage(with: URL(string: itemImageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                let tapGuesture = MyTapGesture(target: self, action: #selector(self.playVideo(guesture:)))
                tapGuesture.param = media.value(forKey: "fileName") as? String ?? ""
                cell.btnVideoPlay.addGestureRecognizer(tapGuesture)
            }
        }
        
        if let _ = item.value(forKey: "tagline"){
            cell.lblDesc.text = item.value(forKey: "tagline") as? String
        }else{
            cell.lblDesc.text = ""
        }
        
        if let _ = item.value(forKey: "seller"){
            let seller = item.value(forKey: "seller") as! NSDictionary
            let firstName = seller.value(forKey: "firstName") as! String
            let lastName = seller.value(forKey: "lastName") as! String
            cell.lblName.text = "\(firstName) \(lastName)"
        }else{
            cell.lblName.text = "Unknown"
        }
        
        if let _ = item.value(forKey: "prices"){
            let prices = item.value(forKey: "prices") as! NSDictionary
            let currencySymbol = prices.value(forKey: "currencySymbol") as! String
            let timeAmount = prices.value(forKey: "time") as! Int
            let timeUnit = prices.value(forKey: "timeUnitOfMeasure") as! String
            let price = prices.value(forKey: "price") as! NSNumber
            cell.lblPrice.text = "\(currencySymbol)\(String(format:"%.2f", price.floatValue))"
            cell.lblTime.text = "\(timeAmount) \(timeUnit)"
        }
        
        if let _ = item.value(forKey: "numOrders"){
            let orders = item.value(forKey: "numOrders") as! Int
            cell.lblOrder.text = "\(orders)"
        }else{
            cell.lblOrder.text = "0"
        }
        
        if let _ = item.value(forKey: "pointValue"){
            let point = item.value(forKey: "pointValue") as! NSNumber
            cell.lblPoint.text = "\(point.intValue)"
        }else{
            cell.lblPoint.text = "0"
        }
        
        if let _ = item.value(forKey: "avgRating"){
            let rating = item.value(forKey: "avgRating") as! NSNumber
            cell.lblRating.text = "\(rating.intValue)%"
        }else{
            cell.lblRating.text = "0%"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate.didSelectedOnlineService(index: indexPath.row)
    }
    
}

class OnlineServiceCollectCell : UICollectionViewCell{
    @IBOutlet weak var btnVideoPlay: UIButton!
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPoint: UILabel!
    @IBOutlet weak var lblOrder: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 6
        layer.masksToBounds = true
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 2.0, height: 4.0)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        let shadowRect = CGRect(x: 0, y: 0, width: self.bounds.width-12, height: self.bounds.height-4)
        layer.shadowPath = UIBezierPath(roundedRect:shadowRect, cornerRadius:self.contentView.layer.cornerRadius).cgPath
    }
}
