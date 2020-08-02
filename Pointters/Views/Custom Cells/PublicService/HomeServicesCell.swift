//
//  HomeServicesCell.swift
//  Pointters
//
//  Created by super on 3/4/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol HomeServiceDelegate {
    func didSelectedBanner(index: Int)
    func didClickPlayVideo(url: String)
}

class HomeServicesCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var delegate: HomeServiceDelegate!
    
    var arrBanner = [[String:Any]]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        // Initialization code
    }

    @IBAction func onPageChanged(_ sender: UIPageControl) {
        let indexPath = IndexPath(row: sender.currentPage, section: 0)
        
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func playVideo(guesture: MyTapGesture){
        self.delegate.didClickPlayVideo(url: guesture.param)
    }
    
}

extension HomeServicesCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.pageControl.numberOfPages = self.arrBanner.count
        return self.arrBanner.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCollectionCell", for: indexPath) as! HomeServiceCollectionViewCell
        let banner = self.arrBanner[indexPath.row] as NSDictionary
        if let _ = banner.value(forKey: "media"){
            let media = banner.value(forKey: "media") as! NSDictionary
            let type = media.value(forKey: "mediaType") as! String
            if type == "image"{
                cell.buttonVideoPlay.isHidden = true
                let itemImageUrl = media.value(forKey: "fileName") as! String
                cell.contentImage.sd_imageTransition = .fade
                cell.contentImage.sd_setImage(with: URL(string: itemImageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
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
        
        if let _ = banner.value(forKey: "icon"){
            let icon = banner.value(forKey: "icon") as! String
            cell.iconImage.isHidden = false
            cell.iconImage.sd_imageTransition = .fade
            cell.iconImage.sd_setImage(with: URL(string: icon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named: "icon-seller"))
        }else{
            cell.iconImage.isHidden = true
        }
        
        if let _ = banner.value(forKey: "name"){
            let title = banner.value(forKey: "name") as! String
            cell.labelTitle.text = title
        }else{
            cell.labelTitle.text = ""
        }
        
        if let _ = banner.value(forKey: "countLocal"), let _ = banner.value(forKey: "countOnline"), let _ = banner.value(forKey: "countTotal") {
//            let local = banner.value(forKey: "countLocal") as! Int
//            let online = banner.value(forKey: "countOnline") as! Int
            let total = banner.value(forKey: "countTotal") as! Int
            let subtite = "\(total) Total"//\(local) Local | \(online) Online |
            cell.labelSubtitle.text = subtite
        }else{
            cell.labelSubtitle.text = ""
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate.didSelectedBanner(index: indexPath.row)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
}

class MyTapGesture: UITapGestureRecognizer {
    var param = String()
}
