//
//  FollowViewController.swift
//  Pointters
//
//  Created by Mac on 2/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class FollowViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var lblMenuTitle: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblMessage: UILabel!
    
    var arrFollows = [[String:Any]]()
    var arrFollowStatus = [Bool]()
    var loginUserId = ""
    
    var limitCnt = 0
    var totalCnt = 0
    var lastDocId = ""
    
    var followType = false
    let folloIndex = 100

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        initData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lblMessage.text = ""
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        
        followType = UserDefaults.standard.bool(forKey: "follow_type")
        lblMenuTitle.text = followType ? "Followers" : "Following"
    }
    
    func initData() {
        if followType {
            callGetFollowersApi(inited: true, lastID: "")
        } else {
            callGetFollowingApi(inited: true, lastID: "")
        }
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func btnFollowTapped(sender:UIButton) {
        let index = sender.tag - folloIndex
        let result = Follow.init(dict: arrFollows[index])
        
        if followType {
            if arrFollowStatus[index] {
                callDeleteUserFollowingStatusApi(id: result.followFrom.id, index: index)
            } else {
                callPostUserFollowingStatusApi(id: result.followFrom.id, index: index)
            }
        } else {
//            if arrFollowStatus[index] {
//                callPostUserFollowingStatusApi(id: result.followTo.id, index: index)
//            } else {
//                callDeleteUserFollowingStatusApi(id: result.followTo.id, index: index)
//            }
            callDeleteUserFollowingStatusApi(id: result.followTo.id, index: index)
        }
    }
    
    //*******************************************************//
    //                 MARK: - Call API Method               //
    //*******************************************************//
    
    func callGetFollowersApi(inited: Bool, lastID: String) {
        self.lblMessage.text = ""
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetFollowers(lastId: lastID, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if inited {
                self.arrFollows.removeAll()
                self.arrFollowStatus.removeAll()
            }
            
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    
                    self.limitCnt = responseDict["limit"] as! Int
                    self.totalCnt = responseDict["total"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String
                    
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for follower in arr {
                            self.arrFollows.append(follower)
                            let result = Follow.init(dict: follower)
                            self.arrFollowStatus.append(result.followFrom.isMutualFollow)
                        }
                    }
                }
            }
            else {
                print(response.error ?? "follower failure")
            }
            self.tableView.reloadData()
            if self.arrFollows.count == 0 {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "You have no followers.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                    self.navigationController?.popViewController(animated: true)
                })
            }
        })
    }
    
    func callGetFollowingApi(inited: Bool, lastID: String) {
        self.lblMessage.text = ""
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetFollowing(lastId: lastID, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if inited {
                self.arrFollows.removeAll()
                self.arrFollowStatus.removeAll()
            }
            
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    
                    self.limitCnt = responseDict["limit"] as! Int
                    self.totalCnt = responseDict["total"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String
                    
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for following in arr {
                            self.arrFollows.append(following)
                            let result = Follow.init(dict: following)
                            self.arrFollowStatus.append(result.followTo.isMutualFollow)
                        }
                    }
                }
            }
            else {
                print(response.error ?? "following failure")
            }
            self.tableView.reloadData()
            if self.arrFollows.count == 0 {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "You are not following anyone.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                    self.navigationController?.popViewController(animated: true)
                })
            }
        })
    }
    
    func callPostUserFollowingStatusApi(id:String, index:Int) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callPostUserFollowingStatus(userId:id, withCompletionHandler:{ (result,statusCode,response,error) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if result == true {
                let _ = response.value as! [String:Any]
                if statusCode == 200 {
                    self.arrFollowStatus[index] = true
                }
            }
            else {
               PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
            
            self.tableView.reloadData()
        })
    }
    
    func callDeleteUserFollowingStatusApi(id:String, index:Int) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callDelUserFollowingStatus(userId:id, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if result == true {
                let _ = response.value as! [String:Any]
                if statusCode == 200 {
                    if self.followType {
                        self.arrFollowStatus[index] = false
                    } else {
                        self.arrFollows.remove(at: index)
                    }
//                    self.arrFollowStatus[index] = false
                }
            }
            else {
                print(response.error ?? "delete follow failure")
            }
            
            self.tableView.reloadData()
        })
    }

}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITableViewDataSource
extension FollowViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.lblMessage.isHidden = true
        self.tableView.isHidden = false
        
        if arrFollows.count > 0 {
            return arrFollows.count
        }
        else {
            lblMessage.text = (followType) ? "No follower found" : "No following found"
            self.lblMessage.isHidden = false
            self.tableView.isHidden = true
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followCell") as! FollowCell
        let result = Follow.init(dict: arrFollows[indexPath.row])

        cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height/2
        cell.imgUser.layer.masksToBounds = true
        
        let strPic = (followType) ? result.followFrom.profilePic : result.followTo.profilePic
        
        if strPic != "" {
            cell.imgUser.sd_imageTransition = .fade
            cell.imgUser.sd_setImage(with: URL(string: strPic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"user_avatar_placeholder"))
        } else {
            cell.imgUser.image = UIImage(named:"user_avatar_placeholder")
        }
        
        let strFirst = (followType) ? result.followFrom.firstName : result.followTo.firstName
        let strLast = (followType) ? result.followFrom.lastName : result.followTo.lastName
        cell.lblName.text = strFirst + " " + strLast
        
        var strCategory = ""
        if result.categories.count > 0 {
            for index in 0..<result.categories.count {
                if index != 0 {
                    strCategory = strCategory + ", "
                }
                strCategory = strCategory + result.categories[index]
            }
        } else {
            strCategory = ""
        }
        cell.lblDesc.text = strCategory
        
        if followType {
            let str = (arrFollowStatus[indexPath.row]) ? "Following" : "Follow"
            cell.btnFollow.setTitle(str, for: .normal)

            if arrFollowStatus[indexPath.row] {
                cell.btnFollow.setTitleColor(UIColor.getCustomBlueColor(), for: .normal)
                cell.btnFollow.layer.borderColor = UIColor.getCustomBlueColor().cgColor
            } else {
                cell.btnFollow.setTitleColor(UIColor.black, for: .normal)
                cell.btnFollow.layer.borderColor = UIColor.black.cgColor
            }
        } else {
//            cell.btnFollow.setTitle("Following", for: .normal)
//            cell.btnFollow.setTitleColor(UIColor.getCustomBlueColor(), for: .normal)
//            cell.btnFollow.layer.borderColor = UIColor.getCustomBlueColor().cgColor
            let str = (arrFollowStatus[indexPath.row]) ? "Follow" : "Following"
            cell.btnFollow.setTitle(str, for: .normal)
            
            if arrFollowStatus[indexPath.row] {
                cell.btnFollow.setTitleColor(UIColor.black, for: .normal)
                cell.btnFollow.layer.borderColor = UIColor.black.cgColor
            } else {
                cell.btnFollow.setTitleColor(UIColor.getCustomBlueColor(), for: .normal)
                cell.btnFollow.layer.borderColor = UIColor.getCustomBlueColor().cgColor
            }
        }
        
        cell.btnFollow.layer.borderWidth = 1.0
        cell.btnFollow.layer.cornerRadius = 5.0
        cell.btnFollow.layer.masksToBounds = true
        
        cell.btnFollow.tag = folloIndex + indexPath.row
        cell.btnFollow.addTarget(self, action: #selector(btnFollowTapped(sender:)), for: .touchUpInside)
        
        return cell
    }
}

// UITableViewDelegate
extension FollowViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == arrFollows.count-1) && (self.totalCnt > self.limitCnt) {
            if followType {
                callGetFollowersApi(inited: false, lastID: self.lastDocId)
            }
            else {
                callGetFollowingApi(inited: false, lastID: self.lastDocId)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = Follow.init(dict: arrFollows[indexPath.row])
        let strOtherId = (followType) ? result.followFrom.id : result.followTo.id
        UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        navigationController?.pushViewController(userProfileVC, animated:true)
    }
}
