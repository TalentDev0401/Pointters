//
//  NotificationsViewController.swift
//  Pointters
//
//  Created by super on 4/3/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noContentView: UIView!
    
    var arrNotifications = [[String:Any]]()
    
    var currentPage = 1
    var totalPages = 0
    var lastDocId = ""
    
    var loginUserId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginUserId = UserCache.sharedInstance.getAccountData().id
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI(){
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        
    }
    
    func initData(){
        callGetNotificationsAPI(inited: true, lastId: self.lastDocId)
    }
    
    func moveNextPage(notification : Notification) {
        if notification.type == "service" {
            let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
            let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
            serviceDetailVC.serviceId = notification.serviceId
            navigationController?.pushViewController(serviceDetailVC, animated: true)
        } else if notification.type == "post" {
            let storyboard = UIStoryboard(name: "Updates", bundle: nil)
            let postCommentsVC = storyboard.instantiateViewController(withIdentifier: "PostCommentsVC") as! PostCommentsViewController
            postCommentsVC.tabSelectIndex = 0
            postCommentsVC.postId = notification.postId
//            postCommentsVC.countLikes = updateItem.post.countLikes
//            postCommentsVC.countComments = updateItem.post.countComments
//            postCommentsVC.countShares = updateItem.post.countShares
            navigationController?.pushViewController(postCommentsVC, animated:true)
        }else if notification.type == "order"{
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let fulfillmentVC = storyboard.instantiateViewController(withIdentifier: "FulfillmentVC") as! FulfillmentViewController
            fulfillmentVC.orderId = notification.orderId
            navigationController?.pushViewController(fulfillmentVC, animated: true)
        }else if notification.type == "chat" {
            UserCache.sharedInstance.setChatCredentials(id: "", userId: notification.userId, name: notification.names, pic: notification.profilePic, verified: false)
            let storyboard = UIStoryboard(name: "Chats", bundle: nil)
            let privateChatVC = storyboard.instantiateViewController(withIdentifier: "PrivateChatVC") as! PrivateChatViewController
            privateChatVC.otherUserId = notification.userId
            privateChatVC.otherUserPic = notification.profilePic
            privateChatVC.otherUsername = notification.names
            privateChatVC.conversationId = notification.conversationId
            navigationController?.pushViewController(privateChatVC, animated:true)
        }else if notification.type == "live-offer"{
            self.callRequestDetailAPI(requestId: notification.requestId)
        } else {
            if notification.userId == self.loginUserId {
                UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
            } else {
                UserCache.sharedInstance.setProfileUser(loginUser: false, userId: notification.userId)
            }
            let storyboard = UIStoryboard(name: "Account", bundle: nil)
            let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
            navigationController?.pushViewController(userProfileVC, animated:true)
        }
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnbackClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    func callGetNotificationsAPI(inited: Bool, lastId: String) {
        if inited {
            PointtersHelper.sharedInstance.startLoader(view: view)
            self.lastDocId = ""
        }
        ApiHandler.callGetNotifications(lastId: self.lastDocId, withCompletionHandler: { (result,statusCode,response) in
            if inited {
                PointtersHelper.sharedInstance.stopLoader()
                self.arrNotifications.removeAll()
            }
            if result == true {
                let responseDict = response.value as! [String:Any]
                print(responseDict as NSDictionary)
                if statusCode == 200 {
                    self.currentPage = responseDict["page"] as! Int + 1
                    self.totalPages = responseDict["pages"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for notification in arr {
                            self.arrNotifications.append(notification)
                        }
                    }
                    if self.arrNotifications.count > 0{
                        self.noContentView.isHidden = true
                    }else{
                        self.noContentView.isHidden = false
                    }
                    self.tableView.reloadData()
                }else if statusCode == 404 {
                    self.noContentView.isHidden = false
                }else {
                    self.noContentView.isHidden = false
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                self.noContentView.isHidden = false
                print(response.error ?? "")
            }
        })
    }
    
    func callMarkAsReadAPI(notification : Notification) {
        ApiHandler.callMarkAsRead(id: notification.id, withCompletionHandler: { (result,statusCode,response) in
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.moveNextPage(notification: notification)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        })
    }
    
    func callRequestDetailAPI(requestId: String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetRequestDetail(requestId: requestId, withCompletionHandler:{ (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                var responseDict: [String:Any] = [:]
                if response.value is Dictionary<AnyHashable,Any> {
                    responseDict = response.value as! [String:Any]
                } else if response.value is Array<Any> {
                    responseDict = (response.value as! [[String:Any]])[0]
                }
                if statusCode == 200 {
                    let requestDetail = RequestDetail.init(dict: responseDict)
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let containerNavVC = storyBoard.instantiateViewController(withIdentifier: "ContainerTabsNavVC") as! UINavigationController
                    let containerVC = storyBoard.instantiateViewController(withIdentifier: "ContainerTabVC") as! ContainerTabViewController
                    containerNavVC.viewControllers = [containerVC]
                    containerVC.selectedExplorerTabIndex = 1
                    containerVC.selectedRequest = requestDetail
                    let window: UIWindow = PointtersHelper.sharedInstance.mainWindow()
                    window.rootViewController = containerNavVC
                    window.makeKeyAndVisible()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        })
    }
    
}

extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == arrNotifications.count - 1) && (self.currentPage - 1 < self.totalPages) {
            callGetNotificationsAPI(inited: false, lastId: self.lastDocId)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = Notification.init(dict: arrNotifications[indexPath.row])
        if result.type == "service" || result.type == "post"{
            let serviceTypeCell = tableView.dequeueReusableCell(withIdentifier: "serviceTypeCell") as! NotificationCell
            if result.profilePic == ""{
                serviceTypeCell.imgProfilePic.image = #imageLiteral(resourceName: "user_avatar_placeholder")
            }else{
                serviceTypeCell.imgProfilePic.sd_imageTransition = .fade
                serviceTypeCell.imgProfilePic.sd_setImage(with: URL(string: result.profilePic)!, placeholderImage: UIImage(named:"user_avatar_placeholder"))
            }
            serviceTypeCell.lblName.text = result.names
            serviceTypeCell.lblActivity.text = result.activity
            let createdTimeString = result.time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            let createdTime = dateFormatter.date(from:createdTimeString)!
            let calendar = Calendar.current
            if calendar.isDateInToday(createdTime){
                serviceTypeCell.lblTime.text = "Today \(calendar.component(.hour, from: createdTime)):\(calendar.component(.minute, from: createdTime))"
            }else{
                let days = calendar.dateComponents([.day], from: createdTime, to: Date()).day
                if days == 0 {
                   serviceTypeCell.lblTime.text = "Today \(calendar.component(.hour, from: createdTime)):\(calendar.component(.minute, from: createdTime))"
                } else if days == 1 {
                    serviceTypeCell.lblTime.text = " \(days!) day ago"
                } else{
                    serviceTypeCell.lblTime.text = "\(days!) days ago"
                }
            }
            if result.media.fileName != ""{
                serviceTypeCell.imgMedia.sd_imageTransition = .fade
                serviceTypeCell.imgMedia.sd_setImage(with: URL(string: result.media.fileName)!, placeholderImage: UIImage(named:"photo_placeholder"))
            }
            serviceTypeCell.imgProfilePic.layer.cornerRadius = serviceTypeCell.imgProfilePic.frame.size.width / 2
            serviceTypeCell.imgMedia.layer.cornerRadius = 3.0
            serviceTypeCell.imgUnread.isHidden = result.markedRead
            return serviceTypeCell
        } else {
            let followTypeCell = tableView.dequeueReusableCell(withIdentifier: "followTypeCell") as! NotificationCell
            followTypeCell.imgProfilePic.sd_imageTransition = .fade
            if result.profilePic == ""{
                followTypeCell.imgProfilePic.image = #imageLiteral(resourceName: "user_avatar_placeholder")
            }else{
                followTypeCell.imgProfilePic.sd_imageTransition = .fade
                followTypeCell.imgProfilePic.sd_setImage(with: URL(string: result.profilePic)!, placeholderImage: UIImage(named:"user_avatar_placeholder"))
            }
            followTypeCell.lblName.text = result.names
            followTypeCell.lblActivity.text = result.activity
            let createdTimeString = result.time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            let createdTime = dateFormatter.date(from:createdTimeString)!
            let calendar = Calendar.current
            if calendar.isDateInToday(createdTime){
                followTypeCell.lblTime.text = "Today \(calendar.component(.hour, from: createdTime)):\(calendar.component(.minute, from: createdTime))"
            }else{
                let days = calendar.dateComponents([.day], from: createdTime, to: Date()).day
                if days == 0 {
                    followTypeCell.lblTime.text = "Today \(calendar.component(.hour, from: createdTime)):\(calendar.component(.minute, from: createdTime))"
                } else if days == 1 {
                    followTypeCell.lblTime.text = "\(days!) day ago"
                } else{
                    followTypeCell.lblTime.text = "\(days!) days ago"
                }
            }
            followTypeCell.imgProfilePic.layer.cornerRadius = followTypeCell.imgProfilePic.frame.size.width / 2
            followTypeCell.imgUnread.isHidden = result.markedRead
            return followTypeCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = Notification.init(dict: arrNotifications[indexPath.row])
        if !result.markedRead {
            self.callMarkAsReadAPI(notification : result)
        }else{
            self.moveNextPage(notification : result)
        }
    }
    
}
