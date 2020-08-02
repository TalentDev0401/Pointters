//
//  PopularServiceCell.swift
//  Pointters
//
//  Created by super on 3/5/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol PopularServiceDelegate {
    func didSelectedPopularService(index: Int)
    func didClickPlayVideoOnPopularService(url: String)
}

class PopularServiceCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnShowAll: UIButton!
    
    var popularServices = [[String:Any]]()
    
    var delegate: PopularServiceDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func playVideo(guesture: MyTapGesture){
        self.delegate.didClickPlayVideoOnPopularService(url: guesture.param)
    }
    
}

extension PopularServiceCell : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularServices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PopularServiceCollectCell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularServiceCollectCell", for: indexPath) as! PopularServiceCollectCell
        let item = self.popularServices[indexPath.row] as NSDictionary
        
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
        self.delegate.didSelectedPopularService(index: indexPath.row)
    }
    
}

class PopularServiceCollectCell : UICollectionViewCell{
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

extension UIView {
    
    func dropShadow() {
        layer.cornerRadius = 5.0
        let shadowSize : CGFloat = 5.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: self.frame.size.width + shadowSize,
                                                   height: self.frame.size.height + shadowSize))
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.5
        layer.shadowPath = shadowPath.cgPath
    }
}
