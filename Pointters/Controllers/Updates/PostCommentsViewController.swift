//
//  PostCommentsViewController.swift
//  Pointters
//
//  Created by super on 4/13/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import MapKit

class PostCommentsViewController: UIViewController {

    @IBOutlet weak var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var likeSeperator: UIView!
    @IBOutlet weak var commentSeperator: UIView!
    @IBOutlet weak var shareSeperator: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ivProfilePic: UIImageView!
    @IBOutlet weak var tfComment: UITextField!
    @IBOutlet weak var consWriteCommentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var writeCommentView: UIView!
    @IBOutlet weak var consWriteCommentBottom: NSLayoutConstraint!
    @IBOutlet weak var labelPostname: UILabel!
    
    var tabSelectIndex = 0
    var lastId = ""
    var currentPage = 0
    var totalPages = 0
    var pageTitle = "POST"
    
    var arrLikes = [[String:Any]]()
    var arrComments = [[String:Any]]()
    var arrShares = [[String:Any]]()
    
    var countLikes = 0
    var countComments = 0
    var countShares = 0
    
    var postId = ""
    var commentString = ""
    var loginUserId = UserCache.sharedInstance.getAccountData().id
    
    var sharelink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI(){
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 125.0
            consWriteCommentViewHeight.constant = 71.0
        } else {
            consNavBarHeight.constant = 104.0
            consWriteCommentViewHeight.constant = 50.0
        }
        labelPostname.text = (self.pageTitle == "") ? "Post" : self.pageTitle
        ivProfilePic.sd_imageTransition = .fade
        ivProfilePic.sd_setImage(with: URL(string: UserCache.sharedInstance.getAccountData().profilePic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"user_avatar_placeholder"))
        ivProfilePic.layer.cornerRadius = ivProfilePic.frame.size.width / 2
        btnLike.setTitle("\(countLikes) Likes", for: .normal)
        btnComment.setTitle("\(countComments) Comments", for: .normal)
        btnShare.setTitle("\(countShares) Shares", for: .normal)
        setTabView()
    }
    
    func setTabView() {
        likeSeperator.isHidden = self.tabSelectIndex != 0
        commentSeperator.isHidden = self.tabSelectIndex != 1
        shareSeperator.isHidden = self.tabSelectIndex != 2
        if self.tabSelectIndex == 1 {
            consWriteCommentBottom.constant = 0.0
        } else {
            consWriteCommentBottom.constant = 0 - consWriteCommentViewHeight.constant
        }
        callAPIs()
    }
    
    func callAPIs(){
        if self.postId != "" {
            switch self.tabSelectIndex {
            case 0:
                callGetLikesAPI(inited: true, lastId: self.lastId)
                break
            case 1:
                callGetCommentsAPI(inited: true, lastId: self.lastId)
                break
            case 2:
                callGetSharesAPI(inited: true, lastId: self.lastId)
                break
            default:
                break
            }
        }
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnbackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLikeTapped(_ sender: Any) {
        self.tabSelectIndex = 0
        setTabView()
    }
    
    @IBAction func btnCommentTapped(_ sender: Any) {
        self.tabSelectIndex = 1
        setTabView()
    }
    
    @IBAction func btnShareTapped(_ sender: Any) {
        self.tabSelectIndex = 2
        setTabView()
    }
    
    @IBAction func btnSendTapped(_ sender: Any) {
        tfComment.resignFirstResponder()
        commentString = tfComment.text!
        tfComment.text = ""
        if commentString == "" {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Comment is required", buttonTitles: ["OK"], viewController: self, completion: nil)
        } else {
            self.callSendCommentAPI()
        }
    }
    
    @IBAction func btnSharePostTapped(_ sender: Any) {
        
        let shareService = "Checkout this awesome post on Pointters app: " + "\n" + self.sharelink
        let shareViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [shareService], applicationActivities: nil)
        shareViewController.completionWithItemsHandler = { activity, success, items, error in
            if error != nil || !success{
                return
            }
            self.callSharePostAPI()
        }
        DispatchQueue.main.async {
            self.present(shareViewController, animated: true, completion: nil)
        }
    }
    
    func callSharePostAPI(){
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callSharePost(postId: self.postId, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Post shared successfully.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
            else {
                print(response.error ?? "get like service failure")
            }
        })
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.consWriteCommentBottom?.constant = 0.0
            } else {
                self.consWriteCommentBottom?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    @objc func gotoUserProfile(_ sender: MyTapGesture){
        let strOtherId = sender.param
        if strOtherId == self.loginUserId {
            UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
        } else {
            UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
        }
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        navigationController?.pushViewController(userProfileVC, animated:true)
    }
    
    //*******************************************************//
    //                 MARK: - Call API Method               //
    //*******************************************************//
    
    func callGetLikesAPI(inited: Bool, lastId: String) {
        if inited {
            PointtersHelper.sharedInstance.startLoader(view: view)
            self.lastId = ""
        }
        ApiHandler.callGetLikes(postId: self.postId, lastId: self.lastId, withCompletionHandler: { (result,statusCode,response) in
            if inited {
                PointtersHelper.sharedInstance.stopLoader()
                self.arrLikes.removeAll()
            }
            if result == true {
                let responseDict = response.value as! [String:Any]
                print(responseDict as NSDictionary)
                if statusCode == 200 {
                    self.currentPage = responseDict["page"] as! Int + 1
                    self.totalPages = responseDict["pages"] as! Int
                    self.lastId = responseDict["lastDocId"] as? String ?? ""
                    if let share = responseDict["shareLink"] as? String {
                        self.sharelink = share
                    }
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for itemLike in arr {
                            self.arrLikes.append(itemLike)
                        }
                    }
                } else {
                    print(responseDict["message"] as! String)
                }
            } else {
                print(response.error ?? "")
            }
            self.tableView.reloadData()
        })
    }
    
    func callGetCommentsAPI(inited: Bool, lastId: String) {
        if inited {
            PointtersHelper.sharedInstance.startLoader(view: view)
            self.lastId = ""
        }
        ApiHandler.callGetComments(postId: self.postId, lastId: self.lastId, withCompletionHandler: { (result,statusCode,response) in
            if inited {
                PointtersHelper.sharedInstance.stopLoader()
                self.arrComments.removeAll()
            }
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.currentPage = responseDict["page"] as! Int + 1
                    self.totalPages = responseDict["pages"] as! Int
                    self.lastId = responseDict["lastDocId"] as? String ?? ""
                    if let share = responseDict["shareLink"] as? String {
                        self.sharelink = share
                    }
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for itemComment in arr {
                            self.arrComments.append(itemComment)
                        }
                    }
                } else {
                    print(responseDict["message"] as! String)
                }
            } else {
                print(response.error ?? "")
            }
            self.tableView.reloadData()
        })
    }
    
    func callGetSharesAPI(inited: Bool, lastId: String) {
        if inited {
            PointtersHelper.sharedInstance.startLoader(view: view)
            self.lastId = ""
        }
        ApiHandler.callGetShares(postId: self.postId, lastId: self.lastId, withCompletionHandler: { (result,statusCode,response) in
            if inited {
                PointtersHelper.sharedInstance.stopLoader()
                self.arrShares.removeAll()
            }
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.currentPage = responseDict["page"] as! Int + 1
                    self.totalPages = responseDict["pages"] as! Int
                    self.lastId = responseDict["lastDocId"] as? String ?? ""
                    if let share = responseDict["shareLink"] as? String {
                        self.sharelink = share
                    }
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for itemShare in arr {
                            self.arrShares.append(itemShare)
                        }
                    }
                } else {
                    print(responseDict["message"] as! String)
                }
            } else {
                print(response.error ?? "")
            }
            self.tableView.reloadData()
        })
    }
    
    func callSendCommentAPI() {
        ApiHandler.callSendComment(postId:postId, comment:commentString, withCompletionHandler:{ (result,statusCode,response) in
            if result == true {
                if statusCode == 200 {
                    self.countComments += 1
                    self.initUI()
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

extension PostCommentsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.tabSelectIndex == 0 {
            if (indexPath.row == arrLikes.count - 1) && (self.currentPage - 1 < self.totalPages) {
                callGetLikesAPI(inited: false, lastId: self.lastId)
            }
        }
        else if self.tabSelectIndex == 1 {
            if (indexPath.row == arrComments.count - 1) && (self.currentPage - 1 < self.totalPages) {
                callGetCommentsAPI(inited: false, lastId: self.lastId)
            }
        }
        else if self.tabSelectIndex == 2 {
            if (indexPath.row == arrShares.count - 1) && (self.currentPage - 1 < self.totalPages) {
                callGetSharesAPI(inited: false, lastId: self.lastId)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.tabSelectIndex == 0){
            return arrLikes.count
        } else if self.tabSelectIndex == 1{
            return arrComments.count
        } else {
            return arrShares.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.tabSelectIndex {
        case 0:
            return 50.0
        case 1:
            let cellItem = self.arrComments[indexPath.row]
            let commentUser = PostUser.init(dict: cellItem["user"] as! [String:Any])
            let userName = commentUser.firstName + " " + commentUser.lastName
            let comment = cellItem["comment"] as! [String:Any]
            let commentText = comment["comment"] as! String
            return userName.height(withConstrainedWidth: CGFloat(UIScreen.main.bounds.size.width - 70), font: UIFont(name: "Helvetica", size: 13)!) + commentText.height(withConstrainedWidth: CGFloat(UIScreen.main.bounds.size.width - 65), font: UIFont(name: "Helvetica", size: 11)!) + 13
        case 2:
            return 40.0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.tabSelectIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "likeCell", for: indexPath) as! CommentCell
            let cellItem = self.arrLikes[indexPath.row]
            let likeUser = LikeUser.init(dict: cellItem["user"] as! [String:Any])
            cell.ivUserPic.sd_imageTransition = .fade
            cell.ivUserPic.sd_setImage(with: URL(string: likeUser.profilePic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"user_avatar_placeholder"))
            cell.lblUserName.text = likeUser.firstName + " " + likeUser.lastName
            
            let tapGesture1 = MyTapGesture(target: self, action: #selector(self.gotoUserProfile(_:)))
            tapGesture1.param = likeUser.id
            cell.ivUserPic.addGestureRecognizer(tapGesture1)
            let tapGesture2 = MyTapGesture(target: self, action: #selector(self.gotoUserProfile(_:)))
            tapGesture2.param = likeUser.id
            cell.lblUserName.addGestureRecognizer(tapGesture2)
            cell.lblUserName.isUserInteractionEnabled = true
            cell.ivUserPic.isUserInteractionEnabled = true
            
            let likeUserCoord = CLLocation(latitude: likeUser.location.geoJson.coordinates[1],  longitude:likeUser.location.geoJson.coordinates[0])
            let userCoord = CLLocation(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
            let distanceInMeter = userCoord.distance(from: likeUserCoord)
            let distanceInKilo = Double(round(10*(distanceInMeter / 1000)/10))
            cell.lblLocation.text = "\(distanceInKilo)km " + likeUser.location.city + " " + likeUser.location.state
            
            let like = cellItem["like"] as! [String:Any]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            let createdTime = dateFormatter.date(from:like["createdAt"] as! String)!
            let calendar = Calendar.current
            if calendar.isDateInToday(createdTime){
                cell.lblTime.text = "Today \(calendar.component(.hour, from: createdTime)):\(calendar.component(.minute, from: createdTime))"
            }else{
                let days = calendar.component(.day, from: createdTime)
                cell.lblTime.text = "\(days)d"
//                if days == 1 {
//                    cell.lblTime.text = "\(days) day ago"
//                } else{
//                    cell.lblTime.text = "\(days) days ago"
//                }
            }
            return cell
        } else if self.tabSelectIndex == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
            let cellItem = self.arrComments[indexPath.row]
            let commentUser = PostUser.init(dict: cellItem["user"] as! [String:Any])
            cell.ivUserPic.sd_imageTransition = .fade
            cell.ivUserPic.sd_setImage(with: URL(string: commentUser.profilePic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"user_avatar_placeholder"))
            cell.lblUserName.text = commentUser.firstName + " " + commentUser.lastName
            
            let tapGesture1 = MyTapGesture(target: self, action: #selector(self.gotoUserProfile(_:)))
            tapGesture1.param = commentUser.id
            cell.ivUserPic.addGestureRecognizer(tapGesture1)
            let tapGesture2 = MyTapGesture(target: self, action: #selector(self.gotoUserProfile(_:)))
            tapGesture2.param = commentUser.id
            cell.lblUserName.addGestureRecognizer(tapGesture2)
            cell.lblUserName.isUserInteractionEnabled = true
            cell.ivUserPic.isUserInteractionEnabled = true

            let comment = cellItem["comment"] as! [String:Any]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            let createdTime = dateFormatter.date(from:comment["updatedAt"] as! String)!
            let calendar = Calendar.current
            if calendar.isDateInToday(createdTime){
                cell.lblTime.text = "Today \(calendar.component(.hour, from: createdTime)):\(calendar.component(.minute, from: createdTime))"
            }else{
                let days = calendar.component(.day, from: createdTime)
                cell.lblTime.text = "\(days)d"
//                if days == 1 {
//                    cell.lblTime.text = "\(days) day ago"
//                } else{
//                    cell.lblTime.text = "\(days) days ago"
//                }
            }
            cell.lblComment.text = comment["comment"] as? String
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shareCell", for: indexPath) as! CommentCell
            let cellItem = self.arrShares[indexPath.row]
            let shareUser = LikeUser.init(dict: cellItem["user"] as! [String:Any])
            cell.ivUserPic.sd_imageTransition = .fade
            cell.ivUserPic.sd_setImage(with: URL(string: shareUser.profilePic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"user_avatar_placeholder"))
            cell.lblUserName.text = shareUser.firstName + " " + shareUser.lastName
            
            let tapGesture1 = MyTapGesture(target: self, action: #selector(self.gotoUserProfile(_:)))
            tapGesture1.param = shareUser.id
            cell.ivUserPic.addGestureRecognizer(tapGesture1)
            let tapGesture2 = MyTapGesture(target: self, action: #selector(self.gotoUserProfile(_:)))
            tapGesture2.param = shareUser.id
            cell.lblUserName.addGestureRecognizer(tapGesture2)
            cell.lblUserName.isUserInteractionEnabled = true
            cell.ivUserPic.isUserInteractionEnabled = true
            
            let share = cellItem["share"] as! [String:Any]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            let createdTime = dateFormatter.date(from:share["createdAt"] as! String)!
            let calendar = Calendar.current
            if calendar.isDateInToday(createdTime){
                cell.lblTime.text = "Today \(calendar.component(.hour, from: createdTime)):\(calendar.component(.minute, from: createdTime))"
            }else{
                let days = calendar.component(.day, from: createdTime)
                cell.lblTime.text = "\(days)d"
//                if days == 1 {
//                    cell.lblTime.text = "\(days) day ago"
//                } else{
//                    cell.lblTime.text = "\(days) days ago"
//                }
            }
            return cell
        }
    }
    
}

extension PostCommentsViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfComment.resignFirstResponder()
        commentString = tfComment.text!
        tfComment.text = ""
        if commentString == "" {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Comment is required", buttonTitles: ["OK"], viewController: self, completion: nil)
        } else {
            self.callSendCommentAPI()
        }
        return true
    }
}




