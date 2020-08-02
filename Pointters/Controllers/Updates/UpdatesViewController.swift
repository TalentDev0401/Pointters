//
//  UpdatesViewController.swift
//  Pointters
//
//  Created by super on 3/8/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation

class UpdatesViewController: UIViewController {

    @IBOutlet var consNavViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainTableView: UITableView!
    
    var loginUserId = ""
    var commentString = ""
    var arrPosts = [Update]()
    var scrollToTop = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginUserId = UserCache.sharedInstance.getAccountData().id
        initData()
        initUI()
    }
        
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavViewHeight.constant = 41.0
        } else {
            consNavViewHeight.constant = 20.0
        }
    }
    
    func initData() {
        commentString = ""
        guard let posts = appDelegate.arrPosts else {
            callGetPostsAPI(initialize: true)
            return
        }
        self.arrPosts = posts
        DispatchQueue.main.async {
            self.callGetPostsAPI(initialize: false)
        }
    }
    
    func setShadowView(view:UIView) {
        view.layer.cornerRadius = 5.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.init(width: 1.0, height: 1.0)
        view.layer.shadowRadius = 3.0
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
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @objc func btnLikeTapped(sender: UIButton) {
        let updateItem = self.arrPosts[sender.tag]
        let postCommentsVC = storyboard?.instantiateViewController(withIdentifier: "PostCommentsVC") as! PostCommentsViewController
        postCommentsVC.tabSelectIndex = 0
        postCommentsVC.pageTitle = updateItem.service.desc
        postCommentsVC.postId = updateItem.post.id
        postCommentsVC.countLikes = updateItem.post.countLikes
        postCommentsVC.countComments = updateItem.post.countComments
        postCommentsVC.countShares = updateItem.post.countShares
        navigationController?.pushViewController(postCommentsVC, animated:true)
    }
    
    @objc func btnCommentTapped(sender: UIButton) {
        let updateItem = self.arrPosts[sender.tag]
        let postCommentsVC = storyboard?.instantiateViewController(withIdentifier: "PostCommentsVC") as! PostCommentsViewController
        postCommentsVC.tabSelectIndex = 1
        postCommentsVC.postId = updateItem.post.id
        postCommentsVC.pageTitle = updateItem.service.desc
        postCommentsVC.countLikes = updateItem.post.countLikes
        postCommentsVC.countComments = updateItem.post.countComments
        postCommentsVC.countShares = updateItem.post.countShares
        navigationController?.pushViewController(postCommentsVC, animated:true)
    }
    
    @objc func btnShareTapped(sender: UIButton) {
        let updateItem = self.arrPosts[sender.tag]
        let postCommentsVC = storyboard?.instantiateViewController(withIdentifier: "PostCommentsVC") as! PostCommentsViewController
        postCommentsVC.tabSelectIndex = 2
        postCommentsVC.pageTitle = updateItem.service.desc
        postCommentsVC.postId = updateItem.post.id
        postCommentsVC.countLikes = updateItem.post.countLikes
        postCommentsVC.countComments = updateItem.post.countComments
        postCommentsVC.countShares = updateItem.post.countShares
        navigationController?.pushViewController(postCommentsVC, animated:true)
    }
    
    @objc func btnLikedTapped(sender: UIButton) {
        if sender.tag > self.arrPosts.count - 1 {
            return
        }
        let updateItem = self.arrPosts[sender.tag]
        if updateItem.liked {
            callPostUnLikeAPI(postId: updateItem.post.id, index: sender.tag)
        } else {
            callPostLikeAPI(postId:updateItem.post.id, index: sender.tag)
        }
    }
    
    @objc func btnSendTapped(sender: UIButton) {
        let updateItem = self.arrPosts[sender.tag]
        let postId = updateItem.post.id
        if commentString == "" {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Comment is required", buttonTitles: ["OK"], viewController: self, completion: nil)
        } else {
            PointtersHelper.sharedInstance.startLoader(view: self.view)
            self.callSendCommentAPI(postId:postId, commentPostIndex: sender.tag)
        }
    }
    
    //*******************************************************//
    //                 MARK: - Call API Method               //
    //*******************************************************//
    
    func callGetPostsAPI(initialize: Bool) {
        self.arrPosts.removeAll()
        
        if initialize {
            PointtersHelper.sharedInstance.startLoader(view: view)
        }
        ApiHandler.callGetPosts(withCompletionHandler:{ (result,statusCode,response) in
            if initialize {
                PointtersHelper.sharedInstance.stopLoader()
            }
            if result == true {
                if statusCode == 200 {
                    
                    let items = response.value as! [[String:Any]]
                    for item in items {
                        let updateItem = Update.init(dict: item)
                        self.arrPosts.append(updateItem)
                    }
                    appDelegate.arrPosts = self.arrPosts
                    self.mainTableView.reloadData()
                    if self.scrollToTop {
                        self.scrollToTop = false
                        self.mainTableView.setContentOffset(.zero, animated: true)
                    }
                } else {
                    let responseDict = response.value as! [String:Any]
                    let message = responseDict["message"] as! String
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: message, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                print(response.error ?? "share service failure")
            }
        })
    }
    
    func callPostLikeAPI(postId:String, index: Int) {
        ApiHandler.callPostLike(postId:postId, withCompletionHandler:{ (result,statusCode,response) in
            if result == true {
                if statusCode == 200 {
                    self.initData()
                } else {
                    let responseDict = response.value as! [String:Any]
                    let message = responseDict["message"] as! String
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: message, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                print(response.error ?? "share service failure")
            }
        })
    }
    
    func callPostUnLikeAPI(postId:String, index: Int) {
        ApiHandler.callPostUnLike(postId:postId, withCompletionHandler:{ (result,statusCode,response) in
            if result == true {
                if statusCode == 200 {
                    self.initData()
                } else {
                    let responseDict = response.value as! [String:Any]
                    let message = responseDict["message"] as! String
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: message, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                print(response.error ?? "share service failure")
            }
        })
    }
    
    func callSendCommentAPI(postId: String, commentPostIndex: Int) {
        ApiHandler.callSendComment(postId:postId, comment:commentString, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    
                    let updateItem = self.arrPosts[commentPostIndex]

                    let commentDict = response.value as! [String:Any]
                    let comment = Comment.init(dict: commentDict)
                    updateItem.comments.append(comment)
                    self.arrPosts[commentPostIndex] = updateItem
                    self.commentString = ""
                    self.mainTableView.reloadData()
                } else {
                    let responseDict = response.value as! [String:Any]
                    let message = responseDict["message"] as! String
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: message, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                print(response.error ?? "share service failure")
            }
        })
    }
   
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// AAPlayerDelegate
extension UpdatesViewController:AAPlayerDelegate {
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

// AAPlayerModeDelegate
extension UpdatesViewController: AAPlayerModeDelegate {
    func callBackDownloadDidModeChange(_ status:Bool, tag:Int) {
//        let updateItem = arrPosts[tag]
//        if updateItem.post.media.fileName != "" {
//            let fullScreenVC = storyboard?.instantiateViewController(withIdentifier: "FullScreenVC") as! FullScreenViewController
//            fullScreenVC.videoURL = updateItem.post.media.fileName
//            navigationController?.pushViewController(fullScreenVC, animated: true)
//        }
    }
}

extension UpdatesViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrPosts.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            let updateItem = arrPosts[section - 1]
            if updateItem.post.type == "service" {
                if updateItem.post.countComments > 2 {
                    if updateItem.post.message != "" {
                        return 8
                    }else {
                        return 7
                    }
                } else {
                    if updateItem.post.message != "" {
                        return 5 + updateItem.comments.count
                    }else {
                        return 4 + updateItem.comments.count
                    }
                }
            } else {
                if updateItem.post.countComments > 2 {
                    if updateItem.post.message != "" {
                        return 9
                    }else {
                        return 8
                    }
                } else {
                    if updateItem.post.message != "" {
                        return 6 + updateItem.comments.count
                    }else {
                        return 5 + updateItem.comments.count
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        } else {
            return 20.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 62 * view.frame.size.width / 375
        } else {
            if arrPosts.count == 0 {
                return 0
            }
            let updateItem = arrPosts[indexPath.section - 1]
            if indexPath.row == 0 {
                return 62 * view.frame.size.width / 375
            } else {
                if updateItem.post.type == "service" {
                    if updateItem.post.countComments > 2 {
                        if updateItem.post.message != "" {
                            if indexPath.row == 1 {
                                return 0//updateItem.post.message.height(withConstrainedWidth: CGFloat(UIScreen.main.bounds.size.width - 30), font: UIFont(name: "Helvetica", size: 12)!) + 10
                            } else if indexPath.row == 2{
                                return 252 * view.frame.size.width / 375
                            } else if indexPath.row == 6 {
                                return 25 * view.frame.size.width / 375
                            } else {
                                return 52 * view.frame.size.width / 375
                            }
                        }else {
                            if indexPath.row == 1{
                                return 252 * view.frame.size.width / 375
                            } else if indexPath.row == 5 {
                                return 25 * view.frame.size.width / 375
                            } else {
                                return 52 * view.frame.size.width / 375
                            }
                        }
                    } else {
                        if updateItem.post.message != "" {
                            if indexPath.row == 1 {
                                return 0//updateItem.post.message.height(withConstrainedWidth: CGFloat(UIScreen.main.bounds.size.width - 30), font: UIFont(name: "Helvetica", size: 12)!) + 10
                            } else if indexPath.row == 2{
                                return 252 * view.frame.size.width / 375
                            } else {
                                return 52 * view.frame.size.width / 375
                            }
                        }else {
                            if indexPath.row == 1{
                                return 252 * view.frame.size.width / 375
                            } else {
                                return 52 * view.frame.size.width / 375
                            }
                        }
                    }
                } else {
                    if updateItem.post.countComments > 2 {
                        if updateItem.post.message != "" {
                            if indexPath.row == 1 {
                                return updateItem.post.message.height(withConstrainedWidth: CGFloat(UIScreen.main.bounds.size.width - 30), font: UIFont(name: "Helvetica", size: 14)!) + 15
                            } else if indexPath.row == 2{
                                if updateItem.post.media.count > 0 {
                                    return 208 * view.frame.size.width / 375
                                } else {
                                    return 0.0
                                }
                            } else if indexPath.row == 3 {
                                if updateItem.post.tag.type.isEmpty {
                                    return 0
                                } else {
                                    return 52 * view.frame.size.width / 375
                                }
                            } else if indexPath.row == 7 {
                                return 25 * view.frame.size.width / 375
                            } else {
                                return 52 * view.frame.size.width / 375
                            }
                        }else {
                            if indexPath.row == 1{
                                if updateItem.post.media.count > 0 {
                                    return 208 * view.frame.size.width / 375
                                } else {
                                    return 0.0
                                }
                            } else if indexPath.row == 7 {
                                return 25 * view.frame.size.width / 375
                            } else {
                                return 52 * view.frame.size.width / 375
                            }
                        }
                    } else {
                        if updateItem.post.message != "" {
                            if indexPath.row == 1 {
                                return updateItem.post.message.height(withConstrainedWidth: CGFloat(UIScreen.main.bounds.size.width - 30), font: UIFont(name: "Helvetica", size: 14)!) + 15
                            } else if indexPath.row == 2 {
                                if updateItem.post.media.count > 0 {
                                    return 208 * view.frame.size.width / 375
                                } else {
                                    return 0.0
                                }
                            } else if indexPath.row == 3 {
                                if updateItem.post.tag.type.isEmpty {
                                    return 0
                                } else {
                                    return 52 * view.frame.size.width / 375
                                }
                            } else {
                                return 52 * view.frame.size.width / 375
                            }
                        }else {
                            if indexPath.row == 1{
                                if updateItem.post.media.count > 0 {
                                    return 208 * view.frame.size.width / 375
                                } else {
                                    return 0.0
                                }
                            } else {
                                return 52 * view.frame.size.width / 375
                            }
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell: PostUpdateCell = tableView.dequeueReusableCell(withIdentifier: "postUpdateCell") as! PostUpdateCell
            cell.ivUser.sd_imageTransition = .fade
            cell.ivUser.sd_setImage(with: URL(string: UserCache.sharedInstance.getAccountData().profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
            cell.ivUser.layer.cornerRadius = cell.ivUser.frame.size.width / 2
            return cell
        } else {
            if self.arrPosts.count == 0 {
                return UITableViewCell()
            }
            let updateItem = arrPosts[indexPath.section - 1]
            if indexPath.row == 0 {
                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UpdateCell
                cell.ivUser.sd_imageTransition = .fade
                cell.ivUser.sd_setImage(with: URL(string: updateItem.user.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                cell.ivUser.layer.cornerRadius = cell.ivUser.frame.size.width / 2
                cell.lblUserName.text = updateItem.user.firstName + " " + updateItem.user.lastName
                if updateItem.post.type == "service"{
                    cell.lblActivity.text = "Posted a Service"
                } else {
                    cell.lblActivity.text = "Shared a Update"
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                let createdTime = dateFormatter.date(from:updateItem.post.updatedAt)!
                let calendar = Calendar.current
                if calendar.isDateInToday(createdTime){
                    cell.lblTime.text = "Today " + String(format: "%02d:%02d", calendar.component(.hour, from: createdTime), calendar.component(.minute, from: createdTime))
                }else{
                    let days = Date().interval(ofComponent: .day, fromDate: createdTime)
                    if days == 1 {
                        cell.lblTime.text = "\(days) day ago"
                    } else{
                        cell.lblTime.text = "\(days) days ago"
                    }
                }
                if updateItem.liked {
                    cell.imgLiked.image = UIImage(named: "icon-like-selected")
                } else {
                    cell.imgLiked.image = UIImage(named: "icon-like-normal")
                }
                cell.btnLiked.tag = indexPath.section - 1
                cell.btnLiked.addTarget(self, action: #selector(btnLikedTapped(sender:)), for: .touchUpInside)
                return cell
            } else {
                if updateItem.post.type == "service" {
                    if updateItem.post.countComments > 2 {
                        if updateItem.post.message != "" {
                            if indexPath.row == 1 {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! UpdateCell
                                cell.lblMessage.text = updateItem.post.message
                                return cell
                            } else if indexPath.row == 2{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "serviceCell") as! UpdateCell
                                cell.setupMediaCell(media: updateItem.service.media, viewController: self)
                                
                                setShadowView(view: cell.frameView)
                                cell.ivSeller.layer.cornerRadius = cell.ivSeller.frame.size.width / 2
                                cell.ivSeller.sd_imageTransition = .fade
                                cell.ivSeller.sd_setImage(with: URL(string: updateItem.user.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.lblServiceDesc.text = updateItem.service.desc
                                cell.lblServicePrice.text = updateItem.service.prices.currencySymbol + "\(updateItem.service.prices.price) " + updateItem.service.prices.desc
                                
                                let serviceCoord = CLLocation(latitude: updateItem.service.location.geoJson.coordinates[1],  longitude:updateItem.service.location.geoJson.coordinates[0])
                                let userCoord = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
                                let distanceInMeter = userCoord.distance(from: serviceCoord)
                                let distanceInKilo = Double(round(10*(distanceInMeter / 1000)/10))
                                cell.lblServiceLocation.text = "\(distanceInKilo)km " + updateItem.service.location.city + " " + updateItem.service.location.state
                                cell.lblPointValue.text = "\(updateItem.service.pointValue)"
                                cell.lblNumOrders.text = "\(updateItem.service.numOrders)"
                                cell.lblAvgRating.text = "\(updateItem.service.avgRating)%"
                                return cell
                            } else if indexPath.row == 3{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "likeCell") as! UpdateCell
                                cell.lblCountLikes.text = "\(updateItem.post.countLikes) Likes"
                                cell.lblCountComments.text = "\(updateItem.post.countComments) Comments"
                                cell.lblCountShares.text = "\(updateItem.post.countShares) Shares"
                                if updateItem.liked {
                                    cell.imgLike.image = UIImage(named: "icon-like-selected")
                                }else {
                                    cell.imgLike.image = UIImage(named: "icon-like-normal")
                                }
                                cell.likeSepView.isHidden = updateItem.comments.count == 0
                                cell.btnLike.tag = indexPath.section - 1
                                cell.btnComment.tag = indexPath.section - 1
                                cell.btnShare.tag = indexPath.section - 1
                                cell.btnLike.addTarget(self, action: #selector(btnLikeTapped(sender:)), for: .touchUpInside)
                                cell.btnComment.addTarget(self, action: #selector(btnCommentTapped(sender:)), for: .touchUpInside)
                                cell.btnShare.addTarget(self, action: #selector(btnShareTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else if indexPath.row == 6 {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "viewAllCell") as! UpdateCell
                                cell.lblViewAll.text = "View all \(updateItem.post.countComments) comments"
                                cell.btnViewAll.tag = indexPath.section - 1
                                cell.btnViewAll.addTarget(self, action: #selector(btnCommentTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else if indexPath.row == 7 {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "writeCommentCell") as! UpdateCell
                                cell.ivWriteCommentUser.sd_imageTransition = .fade
                                cell.ivWriteCommentUser.sd_setImage(with: URL(string: UserCache.sharedInstance.getAccountData().profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivWriteCommentUser.layer.cornerRadius = cell.ivWriteCommentUser.frame.size.width / 2
                                cell.tfComment.text = ""
                                cell.btnSend.tag = indexPath.section - 1
                                cell.btnSend.addTarget(self, action: #selector(btnSendTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! UpdateCell
                                cell.ivCommentUser.sd_imageTransition = .fade
                                cell.ivCommentUser.sd_setImage(with: URL(string: updateItem.comments[indexPath.row - 4].user.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivCommentUser.layer.cornerRadius = cell.ivCommentUser.frame.size.width / 2
                                cell.lblCommentUserName.text = updateItem.comments[indexPath.row - 4].user.firstName + " " + updateItem.comments[indexPath.row - 4].user.lastName
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                let createdTime = dateFormatter.date(from:updateItem.comments[indexPath.row - 4].updatedAt)!
                                let calendar = Calendar.current
                                if calendar.isDateInToday(createdTime){
                                    cell.lblCommentTime.text = "\(calendar.component(.hour, from: createdTime))h"
                                }else{
                                    let days = Date().interval(ofComponent: .day, fromDate: createdTime)
                                    cell.lblCommentTime.text = "\(days)d"
                                }
                                cell.lblComment.text = updateItem.comments[indexPath.row - 4].comment
                                return cell
                            }
                        }else {
                            if indexPath.row == 1{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "serviceCell") as! UpdateCell
                                cell.setupMediaCell(media: updateItem.service.media, viewController: self)
                                
                                setShadowView(view: cell.frameView)
                                cell.ivSeller.layer.cornerRadius = cell.ivSeller.frame.size.width / 2
                                cell.ivSeller.sd_imageTransition = .fade
                                cell.ivSeller.sd_setImage(with: URL(string: updateItem.user.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.lblServiceDesc.text = updateItem.service.desc
                                cell.lblServicePrice.text = updateItem.service.prices.currencySymbol + "\(updateItem.service.prices.price) " + updateItem.service.prices.desc
                                
                                let serviceCoord = CLLocation(latitude: updateItem.service.location.geoJson.coordinates[1],  longitude:updateItem.service.location.geoJson.coordinates[0])
                                let userCoord = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
                                let distanceInMeter = userCoord.distance(from: serviceCoord)
                                let distanceInKilo = Double(round(10*(distanceInMeter / 1000)/10))
                                cell.lblServiceLocation.text = "\(distanceInKilo)km " + updateItem.service.location.city + " " + updateItem.service.location.state
                                cell.lblPointValue.text = "\(updateItem.service.pointValue)"
                                cell.lblNumOrders.text = "\(updateItem.service.numOrders)"
                                cell.lblAvgRating.text = "\(updateItem.service.avgRating)%"
                                return cell
                            } else if indexPath.row == 2{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "likeCell") as! UpdateCell
                                cell.lblCountLikes.text = "\(updateItem.post.countLikes) Likes"
                                cell.lblCountComments.text = "\(updateItem.post.countComments) Comments"
                                cell.lblCountShares.text = "\(updateItem.post.countShares) Shares"
                                if updateItem.liked {
                                    cell.imgLike.image = UIImage(named: "icon-like-selected")
                                }else {
                                    cell.imgLike.image = UIImage(named: "icon-like-normal")
                                }
                                cell.likeSepView.isHidden = updateItem.comments.count == 0
                                cell.btnLike.tag = indexPath.section - 1
                                cell.btnComment.tag = indexPath.section - 1
                                cell.btnShare.tag = indexPath.section - 1
                                cell.btnLike.addTarget(self, action: #selector(btnLikeTapped(sender:)), for: .touchUpInside)
                                cell.btnComment.addTarget(self, action: #selector(btnCommentTapped(sender:)), for: .touchUpInside)
                                cell.btnShare.addTarget(self, action: #selector(btnShareTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else if indexPath.row == 5 {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "viewAllCell") as! UpdateCell
                                cell.lblViewAll.text = "View all \(updateItem.post.countComments) comments"
                                cell.btnViewAll.tag = indexPath.section - 1
                                cell.btnViewAll.addTarget(self, action: #selector(btnCommentTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else if indexPath.row == 6 {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "writeCommentCell") as! UpdateCell
                                cell.ivWriteCommentUser.sd_imageTransition = .fade
                                cell.ivWriteCommentUser.sd_setImage(with: URL(string: UserCache.sharedInstance.getAccountData().profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivWriteCommentUser.layer.cornerRadius = cell.ivWriteCommentUser.frame.size.width / 2
                                cell.tfComment.text = ""
                                cell.btnSend.tag = indexPath.section - 1
                                cell.btnSend.addTarget(self, action: #selector(btnSendTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! UpdateCell
                                cell.ivCommentUser.sd_imageTransition = .fade
                                cell.ivCommentUser.sd_setImage(with: URL(string: updateItem.comments[indexPath.row - 3].user.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivCommentUser.layer.cornerRadius = cell.ivCommentUser.frame.size.width / 2
                                cell.lblCommentUserName.text = updateItem.comments[indexPath.row - 3].user.firstName + " " + updateItem.comments[indexPath.row - 3].user.lastName
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                let createdTime = dateFormatter.date(from:updateItem.comments[indexPath.row - 3].updatedAt)!
                                let calendar = Calendar.current
                                if calendar.isDateInToday(createdTime){
                                    cell.lblCommentTime.text = "\(calendar.component(.hour, from: createdTime))h"
                                }else{
                                    let days = Date().interval(ofComponent: .day, fromDate: createdTime)
                                    cell.lblCommentTime.text = "\(days)d"
                                }
                                cell.lblComment.text = updateItem.comments[indexPath.row - 3].comment
                                return cell
                            }
                        }
                    } else {
                        if updateItem.post.message != "" {
                            if indexPath.row == 1 {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! UpdateCell
                                cell.lblMessage.text = updateItem.post.message
                                return cell
                            } else if indexPath.row == 2{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "serviceCell") as! UpdateCell
                                cell.setupMediaCell(media: updateItem.service.media, viewController: self)

                                setShadowView(view: cell.frameView)
                                cell.ivSeller.layer.cornerRadius = cell.ivSeller.frame.size.width / 2
                                cell.ivSeller.sd_imageTransition = .fade
                                cell.ivSeller.sd_setImage(with: URL(string: updateItem.user.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.lblServiceDesc.text = updateItem.service.desc
                                cell.lblServicePrice.text = updateItem.service.prices.currencySymbol + "\(updateItem.service.prices.price) " + updateItem.service.prices.desc
                                if updateItem.service.location.geoJson.coordinates.count > 0{
                                    let serviceCoord = CLLocation(latitude: updateItem.service.location.geoJson.coordinates[1],  longitude:updateItem.service.location.geoJson.coordinates[0])
                                    let userCoord = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
                                    let distanceInMeter = userCoord.distance(from: serviceCoord)
                                    let distanceInKilo = Double(round(10*(distanceInMeter / 1000)/10))
                                    cell.lblServiceLocation.text = "\(distanceInKilo)km " + updateItem.service.location.city + " " + updateItem.service.location.state
                                }else{
                                    cell.lblServiceLocation.text = "Unknown Location"
                                }
                                
                                cell.lblPointValue.text = "\(updateItem.service.pointValue)"
                                cell.lblNumOrders.text = "\(updateItem.service.numOrders)"
                                cell.lblAvgRating.text = "\(updateItem.service.avgRating)%"
                                return cell
                            } else if indexPath.row == 3{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "likeCell") as! UpdateCell
                                cell.lblCountLikes.text = "\(updateItem.post.countLikes) Likes"
                                cell.lblCountComments.text = "\(updateItem.post.countComments) Comments"
                                cell.lblCountShares.text = "\(updateItem.post.countShares) Shares"
                                if updateItem.liked {
                                    cell.imgLike.image = UIImage(named: "icon-like-selected")
                                }else {
                                    cell.imgLike.image = UIImage(named: "icon-like-normal")
                                }
                                cell.likeSepView.isHidden = updateItem.comments.count == 0
                                cell.btnLike.tag = indexPath.section - 1
                                cell.btnComment.tag = indexPath.section - 1
                                cell.btnShare.tag = indexPath.section - 1
                                cell.btnLike.addTarget(self, action: #selector(btnLikeTapped(sender:)), for: .touchUpInside)
                                cell.btnComment.addTarget(self, action: #selector(btnCommentTapped(sender:)), for: .touchUpInside)
                                cell.btnShare.addTarget(self, action: #selector(btnShareTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else if indexPath.row == 4 + updateItem.comments.count {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "writeCommentCell") as! UpdateCell
                                cell.ivWriteCommentUser.sd_imageTransition = .fade
                                cell.ivWriteCommentUser.sd_setImage(with: URL(string: UserCache.sharedInstance.getAccountData().profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivWriteCommentUser.layer.cornerRadius = cell.ivWriteCommentUser.frame.size.width / 2
                                cell.tfComment.text = ""
                                cell.btnSend.tag = indexPath.section - 1
                                cell.btnSend.addTarget(self, action: #selector(btnSendTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! UpdateCell
                                cell.ivCommentUser.sd_imageTransition = .fade
                                cell.ivCommentUser.sd_setImage(with: URL(string: updateItem.comments[indexPath.row - 4].user.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivCommentUser.layer.cornerRadius = cell.ivCommentUser.frame.size.width / 2
                                cell.lblCommentUserName.text = updateItem.comments[indexPath.row - 4].user.firstName + " " + updateItem.comments[indexPath.row - 4].user.lastName
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                let createdTime = dateFormatter.date(from:updateItem.comments[indexPath.row - 4].updatedAt)!
                                let calendar = Calendar.current
                                if calendar.isDateInToday(createdTime){
                                    cell.lblCommentTime.text = "\(calendar.component(.hour, from: createdTime))h"
                                }else{
                                    let days = Date().interval(ofComponent: .day, fromDate: createdTime)
                                    cell.lblCommentTime.text = "\(days)d"
                                }
                                cell.lblComment.text = updateItem.comments[indexPath.row - 4].comment
                                return cell
                            }
                        }else {
                            if indexPath.row == 1{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "serviceCell") as! UpdateCell
                                cell.setupMediaCell(media: updateItem.service.media, viewController: self)
                                
                                cell.ivServiceMedia.layer.cornerRadius = 5.0
                                setShadowView(view: cell.frameView)
                                cell.ivSeller.layer.cornerRadius = cell.ivSeller.frame.size.width / 2
                                cell.ivSeller.sd_imageTransition = .fade
                                cell.ivSeller.sd_setImage(with: URL(string: updateItem.user.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.lblServiceDesc.text = updateItem.service.desc
                                cell.lblServicePrice.text = updateItem.service.prices.currencySymbol + "\(updateItem.service.prices.price) " + updateItem.service.prices.desc
                                
                                let serviceCoord = CLLocation(latitude: updateItem.service.location.geoJson.coordinates[1],  longitude:updateItem.service.location.geoJson.coordinates[0])
                                let userCoord = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
                                let distanceInMeter = userCoord.distance(from: serviceCoord)
                                let distanceInKilo = Double(round(10*(distanceInMeter / 1000)/10))
                                cell.lblServiceLocation.text = "\(distanceInKilo)km " + updateItem.service.location.city + " " + updateItem.service.location.state
                                cell.lblPointValue.text = "\(updateItem.service.pointValue)"
                                cell.lblNumOrders.text = "\(updateItem.service.numOrders)"
                                cell.lblAvgRating.text = "\(updateItem.service.avgRating)%"
                                return cell
                            } else if indexPath.row == 2{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "likeCell") as! UpdateCell
                                cell.lblCountLikes.text = "\(updateItem.post.countLikes) Likes"
                                cell.lblCountComments.text = "\(updateItem.post.countComments) Comments"
                                cell.lblCountShares.text = "\(updateItem.post.countShares) Shares"
                                if updateItem.liked {
                                    cell.imgLike.image = UIImage(named: "icon-like-selected")
                                }else {
                                    cell.imgLike.image = UIImage(named: "icon-like-normal")
                                }
                                cell.likeSepView.isHidden = updateItem.comments.count == 0
                                cell.btnLike.tag = indexPath.section - 1
                                cell.btnComment.tag = indexPath.section - 1
                                cell.btnShare.tag = indexPath.section - 1
                                cell.btnLike.addTarget(self, action: #selector(btnLikeTapped(sender:)), for: .touchUpInside)
                                cell.btnComment.addTarget(self, action: #selector(btnCommentTapped(sender:)), for: .touchUpInside)
                                cell.btnShare.addTarget(self, action: #selector(btnShareTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else if indexPath.row == 3 + updateItem.comments.count {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "writeCommentCell") as! UpdateCell
                                cell.ivWriteCommentUser.sd_imageTransition = .fade
                                cell.ivWriteCommentUser.sd_setImage(with: URL(string: UserCache.sharedInstance.getAccountData().profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivWriteCommentUser.layer.cornerRadius = cell.ivWriteCommentUser.frame.size.width / 2
                                cell.tfComment.text = ""
                                cell.btnSend.tag = indexPath.section - 1
                                cell.btnSend.addTarget(self, action: #selector(btnSendTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! UpdateCell
                                cell.ivCommentUser.sd_imageTransition = .fade
                                cell.ivCommentUser.sd_setImage(with: URL(string: updateItem.comments[indexPath.row - 3].user.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivCommentUser.layer.cornerRadius = cell.ivCommentUser.frame.size.width / 2
                                cell.lblCommentUserName.text = updateItem.comments[indexPath.row - 3].user.firstName + " " + updateItem.comments[indexPath.row - 3].user.lastName
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                let createdTime = dateFormatter.date(from:updateItem.comments[indexPath.row - 3].updatedAt)!
                                let calendar = Calendar.current
                                if calendar.isDateInToday(createdTime){
                                    cell.lblCommentTime.text = "\(calendar.component(.hour, from: createdTime))h"
                                }else{
                                    let days = Date().interval(ofComponent: .day, fromDate: createdTime)
                                    cell.lblCommentTime.text = "\(days)d"
                                }
                                cell.lblComment.text = updateItem.comments[indexPath.row - 3].comment
                                return cell
                            }
                        }
                    }
                } else {
                    if updateItem.post.countComments > 2 {
                        if updateItem.post.message != "" {
                            if indexPath.row == 1 {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! UpdateCell
                                cell.lblMessage.text = updateItem.post.message
                                return cell
                            } else if indexPath.row == 2{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "postMediaCell") as! UpdateCell
                                
                                cell.setupMediaCell(media: updateItem.post.media, viewController: self)

                                return cell
                            } else if indexPath.row == 3{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "postTagCell") as! UpdateCell

                                cell.ivTagUser.layer.cornerRadius = cell.ivTagUser.frame.size.width / 2
                                
                                if updateItem.post.tag.type == "service" {
                                    cell.ivTagUser.sd_imageTransition = .fade
                                    cell.ivTagUser.sd_setImage(with: URL(string: updateItem.post.tag.media.fileName), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                    if !updateItem.post.tag.serviceDesc.isEmpty {
                                        cell.lblTagUserName.text = updateItem.post.tag.serviceDesc
                                    }
                                    
                                } else {
                                    cell.ivTagUser.sd_imageTransition = .fade
                                    cell.ivTagUser.sd_setImage(with: URL(string: updateItem.post.tag.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                    cell.lblTagUserName.text = updateItem.post.tag.firstName + " " + updateItem.post.tag.lastName
                                }
                                if updateItem.post.tag.location.geoJson.coordinates.count > 0 {
                                    let tagCoord = CLLocation(latitude: updateItem.post.tag.location.geoJson.coordinates[1],  longitude:updateItem.post.tag.location.geoJson.coordinates[0])
                                    let userCoord = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
                                    let distanceInMeter = userCoord.distance(from: tagCoord)
                                    let distanceInKilo = Double(round(10*(distanceInMeter / 1000)/10))
                                    cell.lblTagUserLocation.text = "\(distanceInKilo)km " + updateItem.post.tag.location.city + " " + updateItem.post.tag.location.state
                                }
                                
                                return cell
                            } else if indexPath.row == 4{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "likeCell") as! UpdateCell
                                cell.lblCountLikes.text = "\(updateItem.post.countLikes) Likes"
                                cell.lblCountComments.text = "\(updateItem.post.countComments) Comments"
                                cell.lblCountShares.text = "\(updateItem.post.countShares) Shares"
                                if updateItem.liked {
                                    cell.imgLike.image = UIImage(named: "icon-like-selected")
                                }else {
                                    cell.imgLike.image = UIImage(named: "icon-like-normal")
                                }
                                cell.likeSepView.isHidden = updateItem.comments.count == 0
                                cell.btnLike.tag = indexPath.section - 1
                                cell.btnComment.tag = indexPath.section - 1
                                cell.btnShare.tag = indexPath.section - 1
                                cell.btnLike.addTarget(self, action: #selector(btnLikeTapped(sender:)), for: .touchUpInside)
                                cell.btnComment.addTarget(self, action: #selector(btnCommentTapped(sender:)), for: .touchUpInside)
                                cell.btnShare.addTarget(self, action: #selector(btnShareTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else if indexPath.row == 7 {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "viewAllCell") as! UpdateCell
                                cell.lblViewAll.text = "View all \(updateItem.post.countComments) comments"
                                cell.btnViewAll.tag = indexPath.section - 1
                                cell.btnViewAll.addTarget(self, action: #selector(btnCommentTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else if indexPath.row == 8 {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "writeCommentCell") as! UpdateCell
                                cell.ivWriteCommentUser.sd_imageTransition = .fade
                                cell.ivWriteCommentUser.sd_setImage(with: URL(string: UserCache.sharedInstance.getAccountData().profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivWriteCommentUser.layer.cornerRadius = cell.ivWriteCommentUser.frame.size.width / 2
                                cell.tfComment.text = ""
                                cell.btnSend.tag = indexPath.section - 1
                                cell.btnSend.addTarget(self, action: #selector(btnSendTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! UpdateCell
                                cell.ivCommentUser.sd_imageTransition = .fade
                                cell.ivCommentUser.sd_setImage(with: URL(string: updateItem.comments[indexPath.row - 5].user.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivCommentUser.layer.cornerRadius = cell.ivCommentUser.frame.size.width / 2
                                cell.lblCommentUserName.text = updateItem.comments[indexPath.row - 5].user.firstName + " " + updateItem.comments[indexPath.row - 5].user.lastName
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                let createdTime = dateFormatter.date(from:updateItem.comments[indexPath.row - 5].updatedAt)!
                                let calendar = Calendar.current
                                if calendar.isDateInToday(createdTime){
                                    cell.lblCommentTime.text = "\(calendar.component(.hour, from: createdTime))h"
                                }else{
                                    let days = Date().interval(ofComponent: .day, fromDate: createdTime)
                                    cell.lblCommentTime.text = "\(days)d"
                                }
                                cell.lblComment.text = updateItem.comments[indexPath.row - 5].comment
                                return cell
                            }
                        }else {
                            if indexPath.row == 1{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "postMediaCell") as! UpdateCell
                                
                                cell.setupMediaCell(media: updateItem.post.media, viewController: self)
                                return cell
                            } else if indexPath.row == 2{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "postTagCell") as! UpdateCell
                    
                                cell.ivTagUser.layer.cornerRadius = cell.ivTagUser.frame.size.width / 2
                                
                                if updateItem.post.tag.type == "service" {
                                    cell.ivTagUser.sd_imageTransition = .fade
                                    cell.ivTagUser.sd_setImage(with: URL(string: updateItem.post.tag.media.fileName), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                    if !updateItem.post.tag.serviceDesc.isEmpty {
                                        cell.lblTagUserName.text = updateItem.post.tag.serviceDesc
                                    }
                                    
                                } else {
                                    cell.ivTagUser.sd_imageTransition = .fade
                                    cell.ivTagUser.sd_setImage(with: URL(string: updateItem.post.tag.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                    cell.lblTagUserName.text = updateItem.post.tag.firstName + " " + updateItem.post.tag.lastName
                                }
                                if updateItem.post.tag.location.geoJson.coordinates.count > 0 {
                                    let tagCoord = CLLocation(latitude: updateItem.post.tag.location.geoJson.coordinates[1],  longitude:updateItem.post.tag.location.geoJson.coordinates[0])
                                    let userCoord = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
                                    let distanceInMeter = userCoord.distance(from: tagCoord)
                                    let distanceInKilo = Double(round(10*(distanceInMeter / 1000)/10))
                                    cell.lblTagUserLocation.text = "\(distanceInKilo)km " + updateItem.post.tag.location.city + " " + updateItem.post.tag.location.state
                                }
                                
                                return cell
                            } else if indexPath.row == 3{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "likeCell") as! UpdateCell
                                cell.lblCountLikes.text = "\(updateItem.post.countLikes) Likes"
                                cell.lblCountComments.text = "\(updateItem.post.countComments) Comments"
                                cell.lblCountShares.text = "\(updateItem.post.countShares) Shares"
                                if updateItem.liked {
                                    cell.imgLike.image = UIImage(named: "icon-like-selected")
                                }else {
                                    cell.imgLike.image = UIImage(named: "icon-like-normal")
                                }
                                cell.likeSepView.isHidden = updateItem.comments.count == 0
                                cell.btnLike.tag = indexPath.section - 1
                                cell.btnComment.tag = indexPath.section - 1
                                cell.btnShare.tag = indexPath.section - 1
                                cell.btnLike.addTarget(self, action: #selector(btnLikeTapped(sender:)), for: .touchUpInside)
                                cell.btnComment.addTarget(self, action: #selector(btnCommentTapped(sender:)), for: .touchUpInside)
                                cell.btnShare.addTarget(self, action: #selector(btnShareTapped(sender:)), for: .touchUpInside)
                                return cell
                            }else if indexPath.row == 6 {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "viewAllCell") as! UpdateCell
                                cell.lblViewAll.text = "View all \(updateItem.post.countComments) comments"
                                cell.btnViewAll.tag = indexPath.section - 1
                                cell.btnViewAll.addTarget(self, action: #selector(btnCommentTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else if indexPath.row == 7 {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "writeCommentCell") as! UpdateCell
                                cell.ivWriteCommentUser.sd_imageTransition = .fade
                                cell.ivWriteCommentUser.sd_setImage(with: URL(string: UserCache.sharedInstance.getAccountData().profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivWriteCommentUser.layer.cornerRadius = cell.ivWriteCommentUser.frame.size.width / 2
                                cell.tfComment.text = ""
                                cell.btnSend.tag = indexPath.section - 1
                                cell.btnSend.addTarget(self, action: #selector(btnSendTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! UpdateCell
                                cell.ivCommentUser.sd_imageTransition = .fade
                                cell.ivCommentUser.sd_setImage(with: URL(string: updateItem.comments[indexPath.row - 4].user.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivCommentUser.layer.cornerRadius = cell.ivCommentUser.frame.size.width / 2
                                cell.lblCommentUserName.text = updateItem.comments[indexPath.row - 4].user.firstName + " " + updateItem.comments[indexPath.row - 4].user.lastName
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                let createdTime = dateFormatter.date(from:updateItem.comments[indexPath.row - 4].updatedAt)!
                                let calendar = Calendar.current
                                if calendar.isDateInToday(createdTime){
                                    cell.lblCommentTime.text = "\(calendar.component(.hour, from: createdTime))h"
                                }else{
                                    let days = Date().interval(ofComponent: .day, fromDate: createdTime)
                                    cell.lblCommentTime.text = "\(days)d"
                                }
                                cell.lblComment.text = updateItem.comments[indexPath.row - 4].comment
                                return cell
                            }
                        }
                    } else {
                        if updateItem.post.message != "" {
                            if indexPath.row == 1 {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! UpdateCell
                                cell.lblMessage.text = updateItem.post.message
                                return cell
                            } else if indexPath.row == 2{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "postMediaCell") as! UpdateCell
                                cell.setupMediaCell(media: updateItem.post.media, viewController: self)

                                return cell
                            } else if indexPath.row == 3{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "postTagCell") as! UpdateCell
                                
                                if updateItem.post.tag.type == "service" {
                                    if updateItem.post.tag.media.mediaType == "video" {
                                        cell.ivTagUser.image = generateThumbnailForVideoAtURL(filePathLocal: updateItem.post.tag.media.fileName as NSString)
                                    } else {
                                        cell.ivTagUser.sd_imageTransition = .fade
                                        cell.ivTagUser.sd_setImage(with: URL(string: updateItem.post.tag.media.fileName), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                    }
                                    
                                    if !updateItem.post.tag.serviceDesc.isEmpty {
                                        cell.lblTagUserName.text = updateItem.post.tag.serviceDesc
                                    }
                                } else {
                                    cell.ivTagUser.sd_imageTransition = .fade
                                    cell.ivTagUser.sd_setImage(with: URL(string: updateItem.post.tag.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                    cell.lblTagUserName.text = updateItem.post.tag.firstName + " " + updateItem.post.tag.lastName
                                }
                                
                                if updateItem.post.tag.location.geoJson.coordinates.count > 0 {
                                    let tagCoord = CLLocation(latitude: updateItem.post.tag.location.geoJson.coordinates[1],  longitude:updateItem.post.tag.location.geoJson.coordinates[0])
                                    let userCoord = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
                                    let distanceInMeter = userCoord.distance(from: tagCoord)
                                    let distanceInKilo = Double(round(10*(distanceInMeter / 1000)/10))
                                    cell.lblTagUserLocation.text = "\(distanceInKilo)km " + updateItem.post.tag.location.city + " " + updateItem.post.tag.location.state
                                }
                                
                                cell.ivTagUser.layer.cornerRadius = cell.ivTagUser.frame.size.width / 2
                                return cell
                            } else if indexPath.row == 4 {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "likeCell") as! UpdateCell
                                cell.lblCountLikes.text = "\(updateItem.post.countLikes) Likes"
                                cell.lblCountComments.text = "\(updateItem.post.countComments) Comments"
                                cell.lblCountShares.text = "\(updateItem.post.countShares) Shares"
                                if updateItem.liked {
                                    cell.imgLike.image = UIImage(named: "icon-like-selected")
                                }else {
                                    cell.imgLike.image = UIImage(named: "icon-like-normal")
                                }
                                cell.likeSepView.isHidden = updateItem.comments.count == 0
                                cell.btnLike.tag = indexPath.section - 1
                                cell.btnComment.tag = indexPath.section - 1
                                cell.btnShare.tag = indexPath.section - 1
                                cell.btnLike.addTarget(self, action: #selector(btnLikeTapped(sender:)), for: .touchUpInside)
                                cell.btnComment.addTarget(self, action: #selector(btnCommentTapped(sender:)), for: .touchUpInside)
                                cell.btnShare.addTarget(self, action: #selector(btnShareTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else if indexPath.row == 5 + updateItem.comments.count {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "writeCommentCell") as! UpdateCell
                                cell.ivWriteCommentUser.sd_imageTransition = .fade
                                cell.ivWriteCommentUser.sd_setImage(with: URL(string: UserCache.sharedInstance.getAccountData().profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivWriteCommentUser.layer.cornerRadius = cell.ivWriteCommentUser.frame.size.width / 2
                                cell.tfComment.text = ""
                                cell.btnSend.tag = indexPath.section - 1
                                cell.btnSend.addTarget(self, action: #selector(btnSendTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! UpdateCell
                                cell.ivCommentUser.sd_imageTransition = .fade
                                cell.ivCommentUser.sd_setImage(with: URL(string: updateItem.comments[indexPath.row - 5].user.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivCommentUser.layer.cornerRadius = cell.ivCommentUser.frame.size.width / 2
                                cell.lblCommentUserName.text = updateItem.comments[indexPath.row - 5].user.firstName + " " + updateItem.comments[indexPath.row - 5].user.lastName
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                let createdTime = dateFormatter.date(from:updateItem.comments[indexPath.row - 5].updatedAt)!
                                let calendar = Calendar.current
                                if calendar.isDateInToday(createdTime){
                                    cell.lblCommentTime.text = "\(calendar.component(.hour, from: createdTime))h"
                                }else{
                                    let days = Date().interval(ofComponent: .day, fromDate: createdTime)
                                    cell.lblCommentTime.text = "\(days)d"
                                }
                                cell.lblComment.text = updateItem.comments[indexPath.row - 5].comment
                                return cell
                            }
                        }else {
                            if indexPath.row == 1{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "postMediaCell") as! UpdateCell
                                cell.setupMediaCell(media: updateItem.post.media, viewController: self)

                                return cell
                            } else if indexPath.row == 2{
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "postTagCell") as! UpdateCell
                                cell.ivTagUser.sd_imageTransition = .fade
                                cell.ivTagUser.sd_setImage(with: URL(string: updateItem.post.tag.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                
                                if updateItem.post.tag.type == "service" {
                                    cell.ivTagUser.sd_imageTransition = .fade
                                    cell.ivTagUser.sd_setImage(with: URL(string: updateItem.post.tag.media.fileName), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                    if !updateItem.post.tag.serviceDesc.isEmpty {
                                        cell.lblTagUserName.text = updateItem.post.tag.serviceDesc
                                    }
                                    
                                } else {
                                    cell.ivTagUser.sd_imageTransition = .fade
                                    cell.ivTagUser.sd_setImage(with: URL(string: updateItem.post.tag.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                    cell.lblTagUserName.text = updateItem.post.tag.firstName + " " + updateItem.post.tag.lastName
                                }
                                if updateItem.post.tag.location.geoJson.coordinates.count > 0 {
                                    let tagCoord = CLLocation(latitude: updateItem.post.tag.location.geoJson.coordinates[1],  longitude:updateItem.post.tag.location.geoJson.coordinates[0])
                                    let userCoord = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
                                    let distanceInMeter = userCoord.distance(from: tagCoord)
                                    let distanceInKilo = Double(round(10*(distanceInMeter / 1000)/10))
                                    cell.lblTagUserLocation.text = "\(distanceInKilo)km " + updateItem.post.tag.location.city + " " + updateItem.post.tag.location.state
                                }
                                
                                cell.ivTagUser.layer.cornerRadius = cell.ivTagUser.frame.size.width / 2
                                return cell
                            } else if indexPath.row == 3 {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "likeCell") as! UpdateCell
                                cell.lblCountLikes.text = "\(updateItem.post.countLikes) Likes"
                                cell.lblCountComments.text = "\(updateItem.post.countComments) Comments"
                                cell.lblCountShares.text = "\(updateItem.post.countShares) Shares"
                                if updateItem.liked {
                                    cell.imgLike.image = UIImage(named: "icon-like-selected")
                                }else {
                                    cell.imgLike.image = UIImage(named: "icon-like-normal")
                                }
                                cell.likeSepView.isHidden = updateItem.comments.count == 0
                                cell.btnLike.tag = indexPath.section - 1
                                cell.btnComment.tag = indexPath.section - 1
                                cell.btnShare.tag = indexPath.section - 1
                                cell.btnLike.addTarget(self, action: #selector(btnLikeTapped(sender:)), for: .touchUpInside)
                                cell.btnComment.addTarget(self, action: #selector(btnCommentTapped(sender:)), for: .touchUpInside)
                                cell.btnShare.addTarget(self, action: #selector(btnShareTapped(sender:)), for: .touchUpInside)
                                return cell
                            }else if indexPath.row == 4 + updateItem.comments.count {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "writeCommentCell") as! UpdateCell
                                cell.ivWriteCommentUser.sd_imageTransition = .fade
                                cell.ivWriteCommentUser.sd_setImage(with: URL(string: UserCache.sharedInstance.getAccountData().profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivWriteCommentUser.layer.cornerRadius = cell.ivWriteCommentUser.frame.size.width / 2
                                cell.tfComment.text = ""
                                cell.btnSend.tag = indexPath.section - 1
                                cell.btnSend.addTarget(self, action: #selector(btnSendTapped(sender:)), for: .touchUpInside)
                                return cell
                            } else {
                                let cell: UpdateCell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! UpdateCell
                                cell.ivCommentUser.sd_imageTransition = .fade
                                cell.ivCommentUser.sd_setImage(with: URL(string: updateItem.comments[indexPath.row - 4].user.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                                cell.ivCommentUser.layer.cornerRadius = cell.ivCommentUser.frame.size.width / 2
                                cell.lblCommentUserName.text = updateItem.comments[indexPath.row - 4].user.firstName + " " + updateItem.comments[indexPath.row - 4].user.lastName
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                let createdTime = dateFormatter.date(from:updateItem.comments[indexPath.row - 4].updatedAt)!
                                let calendar = Calendar.current
                                if calendar.isDateInToday(createdTime){
                                    cell.lblCommentTime.text = "\(calendar.component(.hour, from: createdTime))h"
                                }else{
                                    let days = Date().interval(ofComponent: .day, fromDate: createdTime)
                                    cell.lblCommentTime.text = "\(days)d"
                                }
                                cell.lblComment.text = updateItem.comments[indexPath.row - 4].comment
                                return cell
                            }
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0) {
            let postUpdateVC = self.storyboard?.instantiateViewController(withIdentifier: "PostUpdateVC") as! PostUpdateViewController
            postUpdateVC.postUpdateDelegate = self
            self.navigationController?.pushViewController(postUpdateVC, animated: true)
        } else {
            let updateItem = arrPosts[indexPath.section - 1]
            if indexPath.row == 0 {
                var strOtherId = ""
                strOtherId = updateItem.user.id
                if strOtherId == self.loginUserId {
                    UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
                } else {
                    UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
                }
                let storyboard = UIStoryboard(name: "Account", bundle: nil)
                let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
                navigationController?.pushViewController(userProfileVC, animated:true)
            } else {
                
                var isPostService = false
                var isTagService = false
                var isTagUser = false
                
                if updateItem.post.type == "service" {
                    if updateItem.post.message != "" {
                        if indexPath.row == 2{
                            isPostService = true
                        }
                    } else {
                        if indexPath.row == 1{
                            isPostService = true
                        }
                    }
                } else {
                    if updateItem.post.message != "" {
                        if indexPath.row == 3 {
                            if updateItem.post.tag.type == "service" {
                                isTagService = true
                            } else {
                                isTagUser = true
                            }
                        }
                    } else {
                        if indexPath.row == 2 {
                            if updateItem.post.tag.type == "service" {
                                isTagService = true
                            } else {
                                isTagUser = true
                            }
                        }
                    }
                }
                
                let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
                if isPostService {
                    let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
                    serviceDetailVC.serviceId = updateItem.service.id
                    navigationController?.pushViewController(serviceDetailVC, animated: true)
                } else if isTagService {
                    let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
                    serviceDetailVC.serviceId = updateItem.post.tag.serviceId
                    navigationController?.pushViewController(serviceDetailVC, animated: true)
                } else if isTagUser {
                    var strOtherId = ""
                    strOtherId = updateItem.post.tag.userId
                    if strOtherId == self.loginUserId {
                        UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
                    } else {
                        UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
                    }
                    let storyboard = UIStoryboard(name: "Account", bundle: nil)
                    let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
                    navigationController?.pushViewController(userProfileVC, animated:true)
                }
            }
        }
    }
}

extension UpdatesViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typeCasteToStringFirst = textField.text as NSString?
        let newString = typeCasteToStringFirst?.replacingCharacters(in: range, with: string)
        commentString = newString!
        return true
    }
}

extension UpdatesViewController: PostUpdateDelegate {
    func postUpdate() {
        scrollToTop = true
        self.initData()
    }
}

