//
//  AccountViewController.swift
//  Pointters
//
//  Created by Mac on 2/14/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import SDWebImage
import FBSDKLoginKit
import STPopup

protocol AccountDelegate {
    func selectAboutMe(tabIdx:Int, segIdx:Int)
}

class AccountViewController: UIViewController {
    
    var webservice: PushWebservice!
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    
    var loginUserId = ""
    var userProfile = Profile.init()
    var userDetails = UserMenu.init()
    
    var accountDelegate: AccountDelegate?
    
    var showedTransactionTip = false
    var showedBuyTip = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webservice = self
        initUI()
        loginUserId = UserCache.sharedInstance.getAccountData().id
        guard let profile = appDelegate.userProfile else {
            if loginUserId != "" {
                callGetUserProfileApi(userId: loginUserId)
            }
            return
        }
        self.userProfile = profile
        guard let detail = appDelegate.userDetails else {
            if loginUserId != "" {
                callGetUserProfileApi(userId: loginUserId)
            }
            return
        }
        self.userDetails = detail
        guard let badges = appDelegate.badgeNumbers else {
            if loginUserId != "" {
                callGetUserProfileApi(userId: loginUserId)
                return
            }
            return
        }
        self.setNotificationBadgeNumber(dict: badges as NSDictionary)
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
    }
    
    func moveToAboutMe(tabIdx:Int, segIdx:Int) {
        let aboutMeVC = storyboard?.instantiateViewController(withIdentifier: "AboutMeVC") as! AboutMeViewController
        accountDelegate?.selectAboutMe(tabIdx: tabIdx, segIdx: segIdx)
        aboutMeVC.selTabIndex = tabIdx
        aboutMeVC.segmentIndex = segIdx
        self.navigationController?.pushViewController(aboutMeVC, animated: true)
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//

    @IBAction func btnEditTapped(_ sender: Any) {
        let editProfileVC = storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileViewController
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    func callGetUserProfileApi(userId: String) {
        ApiHandler.callGetUserProfile(userId: userId, withCompletionHandler:{ (result,statusCode,response) in
            
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    if let dict = responseDict["result"] as? NSDictionary {
                        self.userProfile = Profile.init(dict: dict as! [String : Any])
                        appDelegate.userProfile = self.userProfile
                        self.callGetUserMenuApi()
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Can't find user profile! Try Again.", buttonTitles: ["OK", "No, thanks"], viewController: self, completion: { (index) in
                        if index == 0 {
                            self.callGetUserProfileApi(userId: self.loginUserId)
                        } else if index == 1 {
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            }
            else {
                print(response.error ?? "account failure")
            }
        })
    }
    
    func callGetUserMenuApi() {
        ApiHandler.callGetUserMenu(withCompletionHandler:{ (result,statusCode,response) in
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    if let dict = responseDict["counts"] as? [String:Any] {
                        self.setNotificationBadgeNumber(dict: dict as NSDictionary)
                        self.userDetails = UserMenu.init(dict: dict)
                        
                        appDelegate.userDetails = UserMenu.init(dict: dict)
                        appDelegate.badgeNumbers = dict
                        self.tableView.reloadData()
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Can't find user profile! Try Again.", buttonTitles: ["OK", "No, thanks"], viewController: self, completion: { (index) in
                        if index == 0 {
                            self.callGetUserProfileApi(userId: self.loginUserId)
                        } else if index == 1 {
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            }
            else {
                print(response.error ?? "menu failure")
            }
            
        })
    }

    func callUserLogoutApi() {
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        ApiHandler.callUserLogOut(withCompletionHandler: { (result,statusCode) in
            PointtersHelper.sharedInstance.stopLoader()
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let introNavVC = storyboard.instantiateViewController(withIdentifier: "IntroNavVC") as! UINavigationController
            let introVC = storyboard.instantiateViewController(withIdentifier: "IntroSplashVC") as! IntroSplashViewController
            introNavVC.viewControllers = [introVC]
            SDImageCache.shared().clearMemory()
            SDImageCache.shared().clearDisk()
            if result == true {
                if statusCode == 200 {
                    UserCache.sharedInstance.setUserCredentials(userDict:[:])
                    let loginManager = LoginManager()
                    loginManager.logOut()
                    self.webservice.deleteToken()
                    let userDefault = UserDefaults.standard
                    userDefault.setValue(nil, forKey:kCacheParam.kUserLoggedInAccess)
//                    UIApplication.shared.keyWindow?.rootViewController = introNavVC
                    self.gotoPublicExplorer(selectedTabIndex: 0)
                } else {
                    let userDefault = UserDefaults.standard
                    userDefault.setValue(nil, forKey:kCacheParam.kUserLoggedInAccess)
//                    UIApplication.shared.keyWindow?.rootViewController = introNavVC
                    self.gotoPublicExplorer(selectedTabIndex: 0)
//                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Logout failed! Please try again.", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
                let domain = Bundle.main.bundleIdentifier!
                let fcmToken = UserCache.sharedInstance.getFCMToken()
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserCache.sharedInstance.setFCMToken(token: fcmToken ?? "")
                UserDefaults.standard.synchronize()
                UIApplication.shared.applicationIconBadgeNumber = 0
            } else {
                let userDefault = UserDefaults.standard
                userDefault.setValue(nil, forKey:kCacheParam.kUserLoggedInAccess)
                UIApplication.shared.keyWindow?.rootViewController = introNavVC
                let domain = Bundle.main.bundleIdentifier!
                let fcmToken = UserCache.sharedInstance.getFCMToken()
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserCache.sharedInstance.setFCMToken(token: fcmToken!)
                UserDefaults.standard.synchronize()
                UIApplication.shared.applicationIconBadgeNumber = 0
                print("logout failure")
            }
        })
    }
    
    func gotoPublicExplorer(selectedTabIndex: Int) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let containerNavVC = storyBoard.instantiateViewController(withIdentifier: "ContainerTabsNavVC") as! UINavigationController
        let containerVC = storyBoard.instantiateViewController(withIdentifier: "ContainerTabVC") as! ContainerTabViewController
        containerNavVC.viewControllers = [containerVC]
        containerVC.selectedExplorerTabIndex = selectedTabIndex
        let window: UIWindow = PointtersHelper.sharedInstance.mainWindow()
        window.rootViewController = containerNavVC
        window.makeKeyAndVisible()
    }
    
    func setNotificationBadgeNumber(dict: NSDictionary){
        var totalCnt = 0
        totalCnt += dict.value(forKey: "notifications") as! Int
        let buyDic = dict.value(forKey: "buy") as! NSDictionary
        totalCnt += buyDic.value(forKey: "offers") as! Int
        totalCnt += buyDic.value(forKey: "orders") as! Int
        totalCnt += buyDic.value(forKey: "request") as! Int
        let sellDic = dict.value(forKey: "sell") as! NSDictionary
        totalCnt += sellDic.value(forKey: "jobs") as! Int
        totalCnt += sellDic.value(forKey: "offers") as! Int
        totalCnt += sellDic.value(forKey: "orders") as! Int
        
        UIApplication.shared.applicationIconBadgeNumber = totalCnt
    }
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITableViewDataSource
extension AccountViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return kAccountSectionTitles.count + 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return 1
            case 1: return 1
            case 2: return kAccountBuyItems.count
            case 3: return kAccountSellItems.count
            case 4: return kAccountSettingItems.count
            case 5: return kAccountGeneralItems.count + 1
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else if section == 1 {
            return 16.0
        } else {
            return 45.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 137.0
        } else {
            if indexPath.section == 4 && indexPath.row == 4 {
                return 0 //hide shipping address
            }
            if indexPath.section == 5 && indexPath.row == kAccountGeneralItems.count {
                return 100.0
            } else if indexPath.section == 3 && indexPath.row == 7 {
                return 0  //hide background check
            }else{
                return 44.0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        if section > 1 {
            let headerLabel = UILabel(frame: CGRect(x: 15, y: 25, width: tableView.bounds.size.width - 30, height: 20))
            headerLabel.font = UIFont(name: "Helvetica", size: 14)
            headerLabel.textColor = UIColor.getCustomGrayTextColor()
            headerLabel.text = kAccountSectionTitles[section-2]
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell") as! AccountCell
            
            cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.height/2
            cell.imgProfile.layer.masksToBounds = true

            if userProfile.profilePic != "" {
                cell.imgProfile.sd_imageTransition = .fade
                cell.imgProfile.sd_setImage(with: URL(string: userProfile.profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
            }
            
            cell.lblName.text = userProfile.firstName + " " + userProfile.lastName
            
            var attributes1 = Dictionary<NSAttributedStringKey, AnyObject>()
            attributes1[.foregroundColor] = UIColor.black

            var attributes2 = Dictionary<NSAttributedStringKey, AnyObject>()
            attributes2[.foregroundColor] = UIColor.getCustomGrayTextColor()
            
            var strCnt = NSAttributedString(string: PointtersHelper.sharedInstance.formatCount(value: userDetails.followers), attributes: attributes1)
            let strFollowers = NSMutableAttributedString(attributedString: strCnt)
            strFollowers.append(NSAttributedString(string: " Followers", attributes: attributes2))
            cell.lblFollowers.attributedText = strFollowers
            
            strCnt = NSAttributedString(string: PointtersHelper.sharedInstance.formatCount(value: userDetails.following), attributes: attributes1)
            let strFollowing = NSMutableAttributedString(attributedString: strCnt)
            strFollowing.append(NSAttributedString(string: " Following", attributes: attributes2))
            cell.lblFollowing.attributedText = strFollowing
            
            strCnt = NSAttributedString(string: PointtersHelper.sharedInstance.formatCount(value: userDetails.points), attributes: attributes1)
            let strPoints = NSMutableAttributedString(attributedString: strCnt)
            strPoints.append(NSAttributedString(string: " Points", attributes: attributes2))
            cell.lblPoints.attributedText = strPoints

            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! AccountCell
            
            cell.imgMark.image = UIImage(named: kAccountNotification["icon"]!)
            cell.lblTitle.text = kAccountNotification["title"]!
            
            if userDetails.notifications > 0 {
                cell.imgNoteBg.isHidden = false
                cell.lblNoteCnt.isHidden = false
                cell.lblNoteCnt.text = String(format:"%d", userDetails.notifications)
            } else {
                cell.imgNoteBg.isHidden = true
                cell.lblNoteCnt.isHidden = true
            }
            
            return cell
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! AccountCell
            
            cell.imgMark.image = UIImage(named: kAccountBuyItems[indexPath.row]["icon"]!)
            
            print("kAccountBuyItems \(kAccountBuyItems)")
            cell.lblTitle.text = kAccountBuyItems[indexPath.row]["title"]!
            
            if indexPath.row < 3 {
                if indexPath.row == 0 {
                    cell.imgNoteBg.isHidden = (userDetails.buy.orders > 0) ? false : true
                    cell.lblNoteCnt.isHidden = (userDetails.buy.orders > 0) ? false : true
                    cell.lblNoteCnt.text = String(format:"%d", userDetails.buy.orders)
                } else if indexPath.row == 1 {
                    cell.imgNoteBg.isHidden = (userDetails.buy.offers > 0) ? false : true
                    cell.lblNoteCnt.isHidden = (userDetails.buy.offers > 0) ? false : true
                    cell.lblNoteCnt.text = String(format:"%d", userDetails.buy.offers)
                } else {
                    cell.imgNoteBg.isHidden = (userDetails.buy.request > 0) ? false : true
                    cell.lblNoteCnt.isHidden = (userDetails.buy.request > 0) ? false : true
                    cell.lblNoteCnt.text = String(format:"%d", userDetails.buy.request)
                }
            } else {
                cell.imgNoteBg.isHidden = true
                cell.lblNoteCnt.isHidden = true
            }
            
            return cell
        }
        else if indexPath.section == 3 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "normalCell") as! AccountCell
                
                cell.lblDesc.text = kAccountSellItems[indexPath.row]["title"]!
                cell.imgCross.isHidden = false
                cell.separatorInset = UIEdgeInsetsMake(cell.bounds.size.height-1, 15, 0, 0)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! AccountCell
                print("kAccountSellItems \(kAccountSellItems)")
                cell.imgMark.image = UIImage(named: kAccountSellItems[indexPath.row]["icon"]!)
                cell.lblTitle.text = kAccountSellItems[indexPath.row]["title"]!
                
                if indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 4 {
                    if indexPath.row == 1 {
                        cell.imgNoteBg.isHidden = (userDetails.sell.orders > 0) ? false : true
                        cell.lblNoteCnt.isHidden = (userDetails.sell.orders > 0) ? false : true
                        cell.lblNoteCnt.text = String(format:"%d", userDetails.sell.orders)
                    } else if indexPath.row == 3 {
                        cell.imgNoteBg.isHidden = (userDetails.sell.offers > 0) ? false : true
                        cell.lblNoteCnt.isHidden = (userDetails.sell.offers > 0) ? false : true
                        cell.lblNoteCnt.text = String(format:"%d", userDetails.sell.offers)
                    } else {
                        cell.imgNoteBg.isHidden = (userDetails.sell.jobs > 0) ? false : true
                        cell.lblNoteCnt.isHidden = (userDetails.sell.jobs > 0) ? false : true
                        cell.lblNoteCnt.text = String(format:"%d", userDetails.sell.jobs)
                    }
                } else {
                    cell.imgNoteBg.isHidden = true
                    cell.lblNoteCnt.isHidden = true
                }
                
                return cell
            }
        }
        else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! AccountCell
            
            cell.imgMark.image = UIImage(named: kAccountSettingItems[indexPath.row]["icon"]!)
            cell.lblTitle.text = kAccountSettingItems[indexPath.row]["title"]!
            
            cell.imgNoteBg.isHidden = true
            cell.lblNoteCnt.isHidden = true

            return cell
        }
        else if indexPath.section == 5 {
            if indexPath.row == kAccountGeneralItems.count-1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "normalCell") as! AccountCell
                cell.lblDesc.text = kAccountGeneralItems[indexPath.row]["title"]!
                cell.imgCross.isHidden = true
                cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
                return cell
            } else if indexPath.row < kAccountGeneralItems.count-1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! AccountCell
                
                cell.imgMark.image = UIImage(named: kAccountGeneralItems[indexPath.row]["icon"]!)
                cell.lblTitle.text = kAccountGeneralItems[indexPath.row]["title"]!
                
                cell.imgNoteBg.isHidden = true
                cell.lblNoteCnt.isHidden = true
                
                return cell
            } else {
                let cell = UITableViewCell()
                cell.backgroundColor = UIColor.clear
                cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
                return cell
            }
        }
        else {
            return UITableViewCell()
        }
    }
}

extension AccountViewController: PushWebservice{
    func webServiceGetError(receivedError: String) {
        
    }
    
    func webServiceGetResponse() {
        
    }
    
    
}

// UITableViewDelegate
extension AccountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
            let storyboard = UIStoryboard(name: "Account", bundle: nil)
            let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
            navigationController?.pushViewController(userProfileVC, animated: true)
        } else if indexPath.section == 1 {
            let storyboard = UIStoryboard(name: "Notification", bundle: nil)
            let notificationsVC = storyboard.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsViewController
            navigationController?.pushViewController(notificationsVC, animated: true)
        } else if indexPath.section == 2 {
            switch indexPath.row {
                case 0:
                    moveToAboutMe(tabIdx: 0, segIdx: 0)
                    break
                case 1:
                    moveToAboutMe(tabIdx: 0, segIdx: 1)
                    break
                case 2:
                    moveToAboutMe(tabIdx: 0, segIdx: 2)
                    break
                case 3:
                    UserDefaults.standard.set(false, forKey: "like_watch_type")
                    UserDefaults.standard.synchronize()
                    let watchingVC = storyboard?.instantiateViewController(withIdentifier: "LikeWatchVC") as! LikeWatchViewController
                    navigationController?.pushViewController(watchingVC, animated: true)
                    break
                case 4:
                    UserDefaults.standard.set(true, forKey: "like_watch_type")
                    UserDefaults.standard.synchronize()
                    let likesVC = storyboard?.instantiateViewController(withIdentifier: "LikeWatchVC") as! LikeWatchViewController
                    navigationController?.pushViewController(likesVC, animated: true)
                    break
                case 5:
                    let buyLocationVC = storyboard?.instantiateViewController(withIdentifier: "LocationVC") as! BuyLocationViewController
                    self.navigationController?.pushViewController(buyLocationVC, animated: true)
                    break
                case 6:
                let transactionHistoryVC = storyboard?.instantiateViewController(withIdentifier: "TransactionHistoryVC") as! TransactionHistoryViewController
                transactionHistoryVC.indexType = "buy"
                navigationController?.pushViewController(transactionHistoryVC, animated: true)
                break
                default:
                    break
            }
        } else if indexPath.section == 3 {
            switch indexPath.row {
                case 0:
                    let becomeVC = storyboard?.instantiateViewController(withIdentifier: "BecomeSellerVC") as! BecomeSellerViewController
                    navigationController?.pushViewController(becomeVC, animated: true)
//                    let storyboard = UIStoryboard(name: "Updates", bundle: nil)
//                    let addServiceVC = storyboard.instantiateViewController(withIdentifier: "PostUpdateVC") as! PostUpdateViewController
//                    addServiceVC.selTabIndex = 1
//                    navigationController?.pushViewController(addServiceVC, animated: true)
                    break
                case 1:
                    moveToAboutMe(tabIdx: 1, segIdx: 0)
                    break
                case 2:
                    let becomeVC = storyboard?.instantiateViewController(withIdentifier: "BecomeSellerVC") as! BecomeSellerViewController
                    navigationController?.pushViewController(becomeVC, animated: true)
                    break
                case 3:
                    moveToAboutMe(tabIdx: 1, segIdx: 1)
                    break
                case 4:
                    moveToAboutMe(tabIdx: 1, segIdx: 2)
                    break
                case 5:
                    let shippingAddressVC = storyboard?.instantiateViewController(withIdentifier: "ShippingAddressVC") as! ShippingAddressViewController
                    shippingAddressVC.shippingFlag = 1
                    navigationController?.pushViewController(shippingAddressVC, animated: true)
                    break
                case 6:
                let transactionHistoryVC = storyboard?.instantiateViewController(withIdentifier: "TransactionHistoryVC") as! TransactionHistoryViewController
                transactionHistoryVC.indexType = "sell"
                navigationController?.pushViewController(transactionHistoryVC, animated: true)
                break
                default:
                    break
            }
        } else if indexPath.section == 4 {
            switch indexPath.row {
                case 0:
                    let editProfileVC = storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileViewController
                    navigationController?.pushViewController(editProfileVC, animated: true)
                    break
                case 1:
                    let userSettingsVC = storyboard?.instantiateViewController(withIdentifier: "UserSettingsVC") as! UserSettingsViewController
                    navigationController?.pushViewController(userSettingsVC, animated: true)
                    break
                case 2:
                    let notificationSettingsVC = storyboard?.instantiateViewController(withIdentifier: "NotificationOptionVC") as! NotificationOptionViewController
                    navigationController?.pushViewController(notificationSettingsVC, animated: true)
                    break
//                case 3:
//                    let paymentVC = storyboard?.instantiateViewController(withIdentifier: "PaymentMethodVC") as! PaymentMethodViewController
//                    navigationController?.pushViewController(paymentVC, animated: true)
//                    break
                case 3:
                    let shippingAddressVC = storyboard?.instantiateViewController(withIdentifier: "ShippingAddressVC") as! ShippingAddressViewController
                    shippingAddressVC.shippingFlag = 0
                    navigationController?.pushViewController(shippingAddressVC, animated: true)
                    break
                default:
                    break
            }
            
        } else if indexPath.section == 5 {
            switch indexPath.row {
                case 0:
                    UserDefaults.standard.set(false, forKey: "follow_type")
                    UserDefaults.standard.synchronize()
                    let storyboard = UIStoryboard(name: "GeneralSetting", bundle: nil)
                    let followingVC = storyboard.instantiateViewController(withIdentifier: "FollowVC") as! FollowViewController
                    navigationController?.pushViewController(followingVC, animated: true)
                    break
                case 1:
                    UserDefaults.standard.set(true, forKey: "follow_type")
                    UserDefaults.standard.synchronize()
                    let storyboard = UIStoryboard(name: "GeneralSetting", bundle: nil)
                    let followersVC = storyboard.instantiateViewController(withIdentifier: "FollowVC") as! FollowViewController
                    navigationController?.pushViewController(followersVC, animated: true)
                    break
                case 2:
                    let storyboard = UIStoryboard(name: "GeneralSetting", bundle: nil)
                    let inviteFriendVC = storyboard.instantiateViewController(withIdentifier: "InviteFriendVC") as! InviteFriendViewController
                    navigationController?.pushViewController(inviteFriendVC, animated: true)
                    break
                case 3:
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "feedbackViewController") as! FeedbackViewController
                    vc.contentSizeInPopup = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
                    let popupController = STPopupController(rootViewController: vc)
                    popupController.style = .formSheet
                    popupController.navigationBarHidden = true
                    popupController.containerView.backgroundColor = UIColor.clear
                    popupController.present(in: self)
                    break
                case 4:
                    let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                    let termsVC = storyboard.instantiateViewController(withIdentifier: "TermsVC") as! TermsViewController
                    navigationController?.pushViewController(termsVC, animated: true)
                    break
                case 5:
                    let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                    let privacyVC = storyboard.instantiateViewController(withIdentifier: "PrivacyVC") as! PrivacyViewController
                    navigationController?.pushViewController(privacyVC, animated: true)
                    break
                case 6:
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Are you going to logout?", buttonTitles: ["Yes", "No"], viewController: self, completion:  { (index) in
                        if index == 0 {
                            self.callUserLogoutApi()
                        }
                    })
                    break
                default:
                    break
            }
        } else {
            return
        }
    }
}
