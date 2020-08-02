//
//  UpdateCell.swift
//  Pointters
//
//  Created by super on 4/12/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import AVFoundation

class UpdateCell: UITableViewCell {

    // user cell
    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblActivity: UILabel!
    @IBOutlet weak var imgLiked: UIImageView!
    @IBOutlet weak var btnLiked: UIButton!
    
    // message cell
    @IBOutlet weak var lblMessage: UILabel!
    
    // post media cell
    @IBOutlet weak var ivPostMedia: UIImageView!
    @IBOutlet weak var player: AAPlayer!
    
    // post tag cell
    @IBOutlet weak var ivTagUser: UIImageView!
    @IBOutlet weak var lblTagUserName: UILabel!
    @IBOutlet weak var lblTagUserLocation: UILabel!
    
    // like cell
    @IBOutlet weak var lblCountLikes: UILabel!
    @IBOutlet weak var lblCountComments: UILabel!
    @IBOutlet weak var lblCountShares: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var likeSepView: UIView!
    
    // write comment cell
    @IBOutlet weak var ivWriteCommentUser: UIImageView!
    @IBOutlet weak var tfComment: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    
    // comment cell
    @IBOutlet weak var ivCommentUser: UIImageView!
    @IBOutlet weak var lblCommentUserName: UILabel!
    @IBOutlet weak var lblCommentTime: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    
    // service cell
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var ivServiceMedia: UIImageView!
    @IBOutlet weak var lblPointValue: UILabel!
    @IBOutlet weak var lblNumOrders: UILabel!
    @IBOutlet weak var lblAvgRating: UILabel!
    @IBOutlet weak var lblServiceDesc: UILabel!
    @IBOutlet weak var lblServicePrice: UILabel!
    @IBOutlet weak var lblServiceLocation: UILabel!
    @IBOutlet weak var ivSeller: UIImageView!
    @IBOutlet weak var mediaCV: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // view all cell
    @IBOutlet weak var lblViewAll: UILabel!
    @IBOutlet weak var btnViewAll: UIButton!
    
    var mediaArray: [Media] = []
    var superViewController: UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if mediaCV != nil {
            mediaCV.delegate = self
            mediaCV.dataSource = self
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func generateThumbnailForVideoAtURL(filePathLocal: NSString) -> UIImage? {
        
        let vidURL = NSURL(fileURLWithPath:filePathLocal as String)
        let asset = AVURLAsset(url: vidURL as URL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
        
    }
    
    func setupMediaCell(media: [Media], viewController: UIViewController) {
        mediaArray = media
        superViewController = viewController
        mediaCV.isPagingEnabled = true
        mediaCV.reloadData()
    }
}


// MARK: - AAPlayerModeDelegate

extension UpdateCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if pageControl != nil {
            if mediaArray.count > 0 {
                pageControl.isHidden = false
                pageControl.numberOfPages = mediaArray.count
            } else {
                pageControl.isHidden = true
            }
        }
        
        return mediaArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCVCell", for: indexPath) as! MediaCVCell
        let item = mediaArray[indexPath.row]
        
        if item.mediaType == "image" {
            cell.ivServiceImage.isHidden = false
            cell.player.isHidden = true
            cell.ivServiceImage.sd_imageTransition = .fade
            cell.ivServiceImage.sd_setImage(with: URL(string: item.fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
        } else {
            cell.player.isHidden = false
            cell.player.delegate = self
            cell.player.playVideo(item.fileName)
            if item.fileName != "" {
                if let thumbnailImage = generateThumbnailForVideoAtURL(filePathLocal: item.fileName as NSString) {
                    cell.ivServiceImage.image = thumbnailImage
                }
            }
        }
        cell.ivServiceImage.layer.cornerRadius = 5.0
        
        return cell;
    }
}


// MARK: - ScrollViewDelegate

extension UpdateCell: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if pageControl != nil {
            let pageWidth = scrollView.frame.size.width
            pageControl.currentPage = Int(scrollView.contentOffset.x / pageWidth)
        }
    }
}

// MARK: - AAPlayerModeDelegate

extension UpdateCell: AAPlayerModeDelegate {
    func callBackDownloadDidModeChange(_ status:Bool, tag:Int) {
        let item = mediaArray[tag]
        if item.fileName != "" {
            let fullScreenVC = superViewController.storyboard?.instantiateViewController(withIdentifier: "FullScreenVC") as! FullScreenViewController
            fullScreenVC.videoURL = item.fileName
            superViewController.navigationController?.pushViewController(fullScreenVC, animated: true)
        }
    }
}

// MARK: - AAPlayerDelegate
extension UpdateCell: AAPlayerDelegate {
    func callBackDownloadDidFinish(_ status: playerItemStatus?) {
        let status:playerItemStatus = status!
        switch status {
        case .readyToPlay:
            break
        case .failed:
            break
        default:
            break
        }
    }
}
