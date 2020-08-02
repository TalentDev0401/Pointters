//
//  AboutMeViewController.swift
//  Pointters
//
//  Created by Mac on 2/14/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage
import AVFoundation
import AVKit

protocol AboutMeVCDelegate {
    func selectJobRequest(request: RequestDetail)
}

class AboutMeViewController: UIViewController {

    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var lblMenuTitle: UILabel!
    @IBOutlet var segmentCtrl: UISegmentedControl!
    @IBOutlet var userCollectionView: UICollectionView!
    
    @IBOutlet weak var noContentView: UIView!
    @IBOutlet weak var noContentIV: UIImageView!
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var noContentRedirectBtn: UIButton!
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    
    var vcDelegate : AboutMeVCDelegate?

    var selTabIndex = 0
    var segmentIndex = 0
    
    var ordersTableView = UITableView()
    var offersTableView = UITableView()
    var jobsTableView = UITableView()
    
    var arrBuyOrders = [[String:Any]]()
    var arrSellOrders = [[String:Any]]()
    var arrBuyOffers = [[String:Any]]()
    var arrSellOffers = [[String:Any]]()
    var arrBuyRequests = [[String:Any]]()
    var arrSellJobs = [[String:Any]]()
    
    var userLocation: CLLocation?
    var loginUserId = ""
    
    var limitCnt = 0
    var totalCnt = 0
    var lastDocId = ""
    
    // order index
    let orderIndexForProfile = 100000
    let orderIndexForCall    = 1000000
    let orderIndexForChat    = 10000000
    
    // offer index
    let offerIndexForProfile = 200000
    let offerIndexForCall    = 2000000
    let offerIndexForChat    = 20000000
    let offerIndexForAccept = 500000
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        if self.selTabIndex == 0 {
            PointtersHelper.sharedInstance.sendAnalyticsToFirebase(event: kFirebaseEvents.screenBuy)
        } else {
            PointtersHelper.sharedInstance.sendAnalyticsToFirebase(event: kFirebaseEvents.screenSell)
        }
        self.loginUserId = UserCache.sharedInstance.getAccountData().id
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segmentIndex = segmentCtrl.selectedSegmentIndex
        let indexToScrollTo = IndexPath(item: segmentIndex, section: 0)
        userCollectionView.scrollToItem(at: indexToScrollTo, at: .left, animated: false)
        setBuySell(index: selTabIndex)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let indexToScrollTo = IndexPath(item: segmentIndex, section: 0)
        userCollectionView.scrollToItem(at: indexToScrollTo, at: .left, animated: false)
        userCollectionView.reloadData()
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//

    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 137.0
        } else {
            consNavBarHeight.constant = 116.0
        }
        
        loadingActivityIndicator.isHidden = true
        noContentView.isHidden = true
        noContentRedirectBtn.addTarget(self, action: #selector(redirectToAnotherView(sender:)), for: .touchUpInside)
        
        noContentRedirectBtn.layer.cornerRadius = 17.5
        noContentRedirectBtn.clipsToBounds = true
        
        segmentCtrl.selectedSegmentIndex = segmentIndex
    }
    
    @objc func redirectToAnotherView(sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let containerNavVC = storyBoard.instantiateViewController(withIdentifier: "ContainerTabsNavVC") as! UINavigationController
        let containerVC = storyBoard.instantiateViewController(withIdentifier: "ContainerTabVC") as! ContainerTabViewController
        if segmentIndex == 0 {
            if selTabIndex == 0 {
                // goto explorer service page
                containerVC.selectedExplorerTabIndex = 0
            } else {
                // goto explorer job page
                containerVC.selectedExplorerTabIndex = 2
            }
        }
        else if segmentIndex == 1 {
            if selTabIndex == 0 {
                // goto explorer live offer page
                 containerVC.selectedExplorerTabIndex = 1
            } else {
                //explorer job page
                 containerVC.selectedExplorerTabIndex = 2
            }
        }
        else if segmentIndex == 2 {
            if selTabIndex == 0 {
                // explorer live offer page
                 containerVC.selectedExplorerTabIndex = 1
            } else {
                // goto explorer job page
                 containerVC.selectedExplorerTabIndex = 2
            }
        }
        containerNavVC.viewControllers = [containerVC]
        let window: UIWindow = PointtersHelper.sharedInstance.mainWindow()
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = containerNavVC
        }, completion: { completed in
           window.makeKeyAndVisible()
        })
    }
    
    func setBuySell(index: Int) {
        selTabIndex = index
        lblMenuTitle.text = kChooseMenuItems[selTabIndex]
        
        segmentCtrl.setTitle(kBuySellSubItems[index][0], forSegmentAt: 0)
        segmentCtrl.setTitle(kBuySellSubItems[index][1], forSegmentAt: 1)
        segmentCtrl.setTitle(kBuySellSubItems[index][2], forSegmentAt: 2)
        
        callAPIs()
    }
    
    func callAPIs() {
        if segmentIndex == 0 {
            if selTabIndex == 0 {
                callGetBuyOrders(inited: true, lastID: "")
            } else {
                callGetSellOrders(inited: true, lastID: "")
            }
        }
        else if segmentIndex == 1 {
            if selTabIndex == 0 {
                callGetBuyOffers(inited: true, lastID: "")
            } else {
                callGetSellOffers(inited: true, lastID: "")
            }
        }
        else if segmentIndex == 2 {
            if selTabIndex == 0 {
                callGetBuyRequests(inited: true, lastID: "")
            } else {
                callGetSellJobs(inited: true, lastID: "")
            }
        }
        
        userCollectionView.reloadData()
        ordersTableView.reloadData()
        offersTableView.reloadData()
        jobsTableView.reloadData()
    }
    
    
    
    func getFormatDate(origin:String, type:Int) -> String {
        if origin == "" { return "" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        
        let dt = dateFormatter.date(from:origin)
        let dateFormatter1 = DateFormatter()
        
        switch type {
            case 0:
                dateFormatter1.dateFormat = "d/M"
                break
            case 1:
                dateFormatter1.dateFormat = "d/M/yy @ H:mm a"
                break
            case 2:
                let now = Date()
                return now.offsetOmit(from:dt!)
            case 3:
                dateFormatter1.dateFormat = "d/M/yy Ha"
                break;
            default:
                break
        }
        
        return dateFormatter1.string(from:dt!)
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnMenuTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let accountVC = storyboard.instantiateViewController(withIdentifier: "AccountVC") as! AccountViewController
        accountVC.accountDelegate = self
        navigationController?.pushViewController(accountVC, animated: true)
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnChooseTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chooseVC = storyboard.instantiateViewController(withIdentifier: "ChooseBuySellVC") as! ChooseBuySellViewController
        chooseVC.chooseDelegate = self
        chooseVC.chooseIndex = selTabIndex
        chooseVC.modalPresentationStyle = .overFullScreen
        present(chooseVC, animated: true, completion: nil)
    }
    
    @IBAction func segIndexChanged(_ sender: Any) {
        segmentIndex = segmentCtrl.selectedSegmentIndex
        
        let indexToScrollTo = IndexPath(item: segmentIndex, section: 0)
        userCollectionView.scrollToItem(at: indexToScrollTo, at: .left, animated: false)
        
        callAPIs()
    }
    
    //goto fulfillment
    
    @objc func onClickAccept(sender: UIButton){
        if segmentIndex == 1{
            let dictOffer = (selTabIndex == 0) ? arrBuyOffers[sender.tag - offerIndexForAccept] : arrSellOffers[sender.tag - offerIndexForAccept]
            let result = Offer.init(dict: dictOffer)
            if result.closed{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let fulfillmentVC = storyboard.instantiateViewController(withIdentifier: "FulfillmentVC") as! FulfillmentViewController
                fulfillmentVC.orderId = result.orderId
                navigationController?.pushViewController(fulfillmentVC, animated: true)
            }else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let offerDetailVC = storyboard.instantiateViewController(withIdentifier: "OfferDetailVC") as! OfferDetailViewController
                offerDetailVC.offerId = result.offerId
                offerDetailVC.offerFlag = 1
                navigationController?.pushViewController(offerDetailVC, animated: true)
            }
        }
    }
    
    
    // move to chat page
    @objc func btnCallTapped(sender: UIButton) {
        var strOtherPhone = ""
        
        if segmentIndex == 0 {
            let dictOrder = (selTabIndex == 0) ? arrBuyOrders[sender.tag - orderIndexForCall] : arrSellOrders[sender.tag - orderIndexForCall]
            let result = ResultData.init(dict: dictOrder)
            strOtherPhone = (selTabIndex == 0) ? result.seller.phone : result.buyer.phone
        } else if segmentIndex == 1 {
            let dictOffer = (selTabIndex == 0) ? arrBuyOffers[sender.tag - offerIndexForCall] : arrSellOffers[sender.tag - offerIndexForCall]
            let result = Offer.init(dict: dictOffer)
            strOtherPhone = (selTabIndex == 0) ? result.seller.phone : result.buyer.phone
        }
        
        PointtersHelper.sharedInstance.callByPhone(phone: strOtherPhone, ctrl: self)
    }
    
    // move to chat page
    @objc func btnChatTapped(sender: UIButton) {
        var strOtherId = "", strOtherName = "", strOtherPic = ""
        
        if segmentIndex == 0 {
            let dictOrder = (selTabIndex == 0) ? arrBuyOrders[sender.tag - orderIndexForChat] : arrSellOrders[sender.tag - orderIndexForChat]
            let result = ResultData.init(dict: dictOrder)
            strOtherId = (selTabIndex == 0) ? result.seller.id : result.buyer.id
            strOtherName = (selTabIndex == 0) ? result.seller.firstName+" "+result.seller.lastName : result.buyer.firstName+" "+result.buyer.lastName
            strOtherPic = (selTabIndex == 0) ? result.seller.profilePic : result.buyer.profilePic
        } else if segmentIndex == 1 {
            let dictOffer = (selTabIndex == 0) ? arrBuyOffers[sender.tag - offerIndexForChat] : arrSellOffers[sender.tag - offerIndexForChat]
            let result = Offer.init(dict: dictOffer)
            strOtherId = (selTabIndex == 0) ? result.seller.sellerId : result.buyer.buyerId
            strOtherName = (selTabIndex == 0) ? result.seller.firstName+" "+result.seller.lastName : result.buyer.firstName+" "+result.buyer.lastName
            strOtherPic = (selTabIndex == 0) ? result.seller.profilePic : result.buyer.profilePic
        }
        
        UserCache.sharedInstance.setChatCredentials(id: "", userId: strOtherId, name: strOtherName, pic: strOtherPic, verified: false)
        let storyboard = UIStoryboard(name: "Chats", bundle: nil)
        let privateChatVC = storyboard.instantiateViewController(withIdentifier: "PrivateChatVC") as! PrivateChatViewController
        privateChatVC.otherUserId = strOtherId
        privateChatVC.otherUserPic = strOtherPic
        privateChatVC.otherUsername = strOtherName
        navigationController?.pushViewController(privateChatVC, animated:true)
        
    }
    
    // move to profile page
    @objc func btnNameTapped(sender: UIButton) {
        var strOtherId = ""
        
        if segmentIndex == 0 {
            let dictOrder = (selTabIndex == 0) ? arrBuyOrders[sender.tag - orderIndexForProfile] : arrSellOrders[sender.tag - orderIndexForProfile]
            let result = ResultData.init(dict: dictOrder)
            strOtherId = (selTabIndex == 0) ? result.seller.id : result.buyer.id
        } else if segmentIndex == 1 {
            let dictOffer = (selTabIndex == 0) ? arrBuyOffers[sender.tag - offerIndexForProfile] : arrSellOffers[sender.tag - offerIndexForProfile]
            let result = Offer.init(dict: dictOffer)
            strOtherId = (selTabIndex == 0) ? result.seller.sellerId : result.buyer.buyerId
        }
        
        if strOtherId == self.loginUserId {
            UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
        } else {
            UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
        }
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        navigationController?.pushViewController(userProfileVC, animated:true)
    }
    
    // move to send custom offer page
    @objc func editJobOffer(sender: UIButton) {

        let jobDict = arrSellJobs[sender.tag]["requestOffers"] as! [String:Any]
        let result = ResultData.init(dict: arrSellJobs[sender.tag])
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        let sendCustomOfferVC = storyboard.instantiateViewController(withIdentifier: "SendOfferVC") as! SendOfferViewController
        if let offerId = jobDict["requestOfferId"] {
            sendCustomOfferVC.offerId = offerId as! String
        }
        sendCustomOfferVC.buyerId = result.requestOffers.requester.userId
        sendCustomOfferVC.isJobOffer = true
        sendCustomOfferVC.requestId = result.requestOffers.request.requestId
        sendCustomOfferVC.customOfferDelegate = self
        navigationController?.pushViewController(sendCustomOfferVC, animated:true)
    }
    
    @objc func makeJobOffer(sender: UIButton) {
        let result = ResultData.init(dict: arrSellJobs[sender.tag / 100])
        if result.requestOffers.request.cloesd {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let fulfillmentVC = storyboard.instantiateViewController(withIdentifier: "FulfillmentVC") as! FulfillmentViewController
            fulfillmentVC.orderId = result.requestOffers.request.orderId
            navigationController?.pushViewController(fulfillmentVC, animated: true)
        }else {
            let storyboard = UIStoryboard(name: "Explore", bundle: nil)
            let sendCustomOfferVC = storyboard.instantiateViewController(withIdentifier: "SendOfferVC") as! SendOfferViewController
            sendCustomOfferVC.buyerId = result.requestOffers.requester.userId
            sendCustomOfferVC.isJobOffer = true
            sendCustomOfferVC.customOfferDelegate = self
            navigationController?.pushViewController(sendCustomOfferVC, animated:true)
        }
        
    }
    
    @objc func viewJobRequest(sender: UIButton) {
        let result = ResultData.init(dict: arrBuyRequests[sender.tag / 100])
        if result.requests.cloesd{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let fulfillmentVC = storyboard.instantiateViewController(withIdentifier: "FulfillmentVC") as! FulfillmentViewController
            fulfillmentVC.orderId = result.requests.orderId
            navigationController?.pushViewController(fulfillmentVC, animated: true)
        }else{
            let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
            let requestDetailVC = storyboard.instantiateViewController(withIdentifier: "RequestDetailVC") as! RequestDetailViewController
            requestDetailVC.pageFlag = 0
            requestDetailVC.requestId = result.requests.id
            self.navigationController?.pushViewController(requestDetailVC, animated: true)
        }
    }
    
    @objc func RequestAgain(sender: UIButton) {
        let result = ResultData.init(dict: arrBuyRequests[sender.tag / 100])
        let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
        let requestDetailVC = storyboard.instantiateViewController(withIdentifier: "RequestDetailVC") as! RequestDetailViewController
        requestDetailVC.requestDelegate = self
        requestDetailVC.pageFlag = 0
        requestDetailVC.requestAgain = true
        requestDetailVC.requestId = result.requests.id
        self.navigationController?.pushViewController(requestDetailVC, animated: true)
    }

    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    
    func showLoadingAnimator() {
        
        self.noContentView.isHidden = true
        
        loadingActivityIndicator.isHidden = false
        loadingActivityIndicator.startAnimating()
        segmentCtrl.isUserInteractionEnabled = false
    }
    
    func hideLoadingAnimator() {
        loadingActivityIndicator.isHidden = true
        loadingActivityIndicator.stopAnimating()
        segmentCtrl.isUserInteractionEnabled = true
    }
    
    func configNoContentView() {
        
        if segmentIndex == 0 {
            if selTabIndex == 0 {
                if self.arrBuyOrders.count == 0 {
                    self.noContentView.isHidden = false
                    self.noContentIV.image = UIImage(named: "icon-buy-order")
                    self.noContentLabel.text = "There aren’t any orders for you at the moment."
                    self.noContentRedirectBtn.setTitle("Explore Services", for: .normal)
                } else {
                    self.noContentView.isHidden = true
                }
            } else {
                if self.arrSellOrders.count == 0 {
                    self.noContentView.isHidden = false
                    self.noContentIV.image = UIImage(named: "icon-sell-order")
                    self.noContentLabel.text = "There aren’t any orders for you at the moment."
                    self.noContentRedirectBtn.setTitle("Explore Jobs", for: .normal)
                } else {
                    self.noContentView.isHidden = true
                }
            }
        }
        else if segmentIndex == 1 {
            if selTabIndex == 0 {
                if self.arrBuyOffers.count == 0 {
                    self.noContentView.isHidden = false
                    self.noContentIV.image = UIImage(named: "icon-sell-order")
                    self.noContentLabel.text = "There aren’t any offers for you at the moment."
                    self.noContentRedirectBtn.setTitle("Explore Live Offers", for: .normal)
                } else {
                    self.noContentView.isHidden = true
                }
            } else {
                if self.arrSellOffers.count == 0 {
                    self.noContentView.isHidden = false
                    self.noContentIV.image = UIImage(named: "icon-sent-mail")
                    self.noContentLabel.text = "There aren’t any offers for you at the moment."
                    self.noContentRedirectBtn.setTitle("Explore Jobs", for: .normal)
                } else {
                    self.noContentView.isHidden = true
                }
            }
        }
        else if segmentIndex == 2 {
            if selTabIndex == 0 {
                if self.arrBuyRequests.count == 0 {
                    self.noContentView.isHidden = false
                    self.noContentIV.image = UIImage(named: "icon-job-search")
                    self.noContentLabel.text = "There aren’t any job requests for you at the moment."
                    self.noContentRedirectBtn.setTitle("Explore Live Offers", for: .normal)
                } else {
                    self.noContentView.isHidden = true
                }
            } else {
                if self.arrSellJobs.count == 0 {
                    self.noContentView.isHidden = false
                    self.noContentIV.image = UIImage(named: "icon-job-search")
                    self.noContentLabel.text = "There aren’t any job opportunities for you at the moment."
                    self.noContentRedirectBtn.setTitle("Explore Jobs", for: .normal)
                } else {
                    self.noContentView.isHidden = true
                }
            }
        }
    }
    
    func callGetBuyOrders(inited: Bool, lastID: String){
        
        showLoadingAnimator()
        ApiHandler.callGetBuyOrder(lastId: lastID, withCompletionHandler:{ (result,statusCode,response) in

            self.hideLoadingAnimator()
            
            if inited {
                self.arrBuyOrders.removeAll()
            }
            
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    if let limitCount = responseDict["limit"] as? Int {
                        self.limitCnt = limitCount
                    } else {
                        self.limitCnt = self.totalCnt
                    }
                    self.totalCnt = responseDict["total"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as? String ?? ""
                    
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for buyOrder in arr {
                            self.arrBuyOrders.append(buyOrder)
                        }
                    }
                }
            }
            else {
                print(response.error ?? "buy orders failure")
            }
            
            self.configNoContentView()
            
            self.ordersTableView.reloadData()
        })
    }
    
    func callGetSellOrders(inited: Bool, lastID: String){

        showLoadingAnimator()
        ApiHandler.callGetSellOrder(lastId: lastID, withCompletionHandler:{ (result,statusCode,response) in

            self.hideLoadingAnimator()
            
            if inited {
                self.arrSellOrders.removeAll()
            }
            
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    
                    if let limitCount = responseDict["limit"] as? Int {
                        self.limitCnt = limitCount
                    } else {
                        self.limitCnt = self.totalCnt
                    }
                    self.totalCnt = responseDict["total"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as? String ?? ""
                    
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for sellOrder in arr {
                            self.arrSellOrders.append(sellOrder)
                        }
                    }
                }
            }
            else {
                print(response.error ?? "sell orders failure")
            }
            
            self.configNoContentView()
            
            self.ordersTableView.reloadData()
        })
    }
    
    func callGetBuyOffers(inited: Bool, lastID: String){

        showLoadingAnimator()
        ApiHandler.callGetOffersReceived(lastId: lastID, withCompletionHandler:{ (result,statusCode,response) in

            self.hideLoadingAnimator()
            
            if inited {
                self.arrBuyOffers.removeAll()
            }
            
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    
                    if let limitCount = responseDict["limit"] as? Int {
                        self.limitCnt = limitCount
                    } else {
                        self.limitCnt = self.totalCnt
                    }
                    self.totalCnt = responseDict["total"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String
                    
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        
                        for received in arr {
                            self.arrBuyOffers.append(received)
                        }
                    }
                }
            }
            else {
                print(response.error ?? "buy offers failure")
            }
            
            self.configNoContentView()
            
            self.offersTableView.reloadData()
        })
    }
    
    func callGetSellOffers(inited: Bool, lastID: String){

        showLoadingAnimator()
        ApiHandler.callGetOffersSent(lastId: lastID, withCompletionHandler:{ (result,statusCode,response) in

            self.hideLoadingAnimator()
            
            if inited {
                self.arrSellOffers.removeAll()
            }
            
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    if let limitCount = responseDict["limit"] as? Int {
                        self.limitCnt = limitCount
                    } else {
                        self.limitCnt = self.totalCnt
                    }
                    self.totalCnt = responseDict["total"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String
                    
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for sent in arr {
                            self.arrSellOffers.append(sent)
                        }
                    }
                }
            }
            else {
                print(response.error ?? "sell offers failure")
            }
            
            self.configNoContentView()
            
            self.offersTableView.reloadData()
        })
    }
    
    func callGetBuyRequests(inited: Bool, lastID: String){

        showLoadingAnimator()
        ApiHandler.callGetLiveOfferRequests(lastId: lastID, withCompletionHandler:{ (result,statusCode,response) in

            self.hideLoadingAnimator()
            
            if inited {
                self.arrBuyRequests.removeAll()
            }
            
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    if let limitCount = responseDict["limit"] as? Int {
                        self.limitCnt = limitCount
                    } else {
                        self.limitCnt = self.totalCnt
                    }
                    self.totalCnt = responseDict["total"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String
                    
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for liveOffer in arr {
                            self.arrBuyRequests.append(liveOffer)
                        }
                    }
                }
            }
            else {
                print(response.error ?? "buy requests failure")
            }
            
            self.configNoContentView()
            
            self.jobsTableView.reloadData()
        })
    }
    
    func callGetSellJobs(inited: Bool, lastID: String){

        showLoadingAnimator()
        ApiHandler.callGetSellJobs(lastId: lastID, withCompletionHandler:{ (result,statusCode,response) in

            self.hideLoadingAnimator()
            
            if inited {
                self.arrSellJobs.removeAll()
            }
            
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    if let limitCount = responseDict["limit"] as? Int {
                        self.limitCnt = limitCount
                    } else {
                        self.limitCnt = self.totalCnt
                    }
                    self.totalCnt = responseDict["total"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String
                    
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for sellJob in arr {
                            self.arrSellJobs.append(sellJob)
                        }
                    }
                }
            }
            else {
                print(response.error ?? "sell jobs failure")
            }
            
            self.configNoContentView()
            
            self.jobsTableView.reloadData()
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

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// AccountDelegate
extension AboutMeViewController: AccountDelegate {
    func selectAboutMe(tabIdx: Int, segIdx: Int) {
        segmentIndex = segIdx
        segmentCtrl.selectedSegmentIndex = segmentIndex
        setBuySell(index: tabIdx)
    }
}

// BuySellDelegate
extension AboutMeViewController: BuySellDelegate {
    func selectBuySell(selected : Int) {
        if selected == 2 {
            let storyboard = UIStoryboard(name: "Account", bundle: nil)
            let transactionHistoryVC = storyboard.instantiateViewController(withIdentifier: "TransactionHistoryVC") as! TransactionHistoryViewController
            self.navigationController?.pushViewController(transactionHistoryVC, animated: true)
        } else {
            setBuySell(index: selected)
        }        
    }
}

// UICollectionViewDataSource
extension AboutMeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath)
            
            segmentIndex = 0
            ordersTableView = cell.viewWithTag(1003) as! UITableView
            
            return cell
        }
        else if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath)
            
            segmentIndex = 1
            offersTableView = cell.viewWithTag(1006) as! UITableView

            return cell
        }
        else if indexPath.item == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell3", for: indexPath)
            
            segmentIndex = 2
            jobsTableView = cell.viewWithTag(1009) as! UITableView

            return cell
        }
        else {
            return UICollectionViewCell()
        }
    }
}

// UICollectionViewDelegate
extension AboutMeViewController: UICollectionViewDelegate {
}

// UICollectionViewDelegateFlowLayout
extension AboutMeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = collectionView.frame.width
        let cellSize = CGSize(width: CGFloat(width), height: height)
        return cellSize
    }
}

// UITableViewDataSource
extension AboutMeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
                
        if tableView == ordersTableView {
            ordersTableView.isHidden = false
            
            if selTabIndex == 0 {
                if arrBuyOrders.count > 0 {
                    return arrBuyOrders.count
                } else {
                    ordersTableView.isHidden = true
                    return 0
                }
            } else {
                if arrSellOrders.count > 0 {
                    return arrSellOrders.count
                } else {
                    ordersTableView.isHidden = true
                    return 0
                }
            }
        }
        else if tableView == offersTableView {
            offersTableView.isHidden = false
            
            if selTabIndex == 0 {
                if arrBuyOffers.count > 0 {
                    return arrBuyOffers.count
                } else {
                    offersTableView.isHidden = true
                    return 0
                }
            } else {
                if arrSellOffers.count > 0 {
                    return arrSellOffers.count
                } else {
                    offersTableView.isHidden = true
                    return 0
                }
            }
        }
        else if tableView == jobsTableView {
            jobsTableView.isHidden = false
            
            if selTabIndex == 0 {
                if arrBuyRequests.count > 0 {
                    return arrBuyRequests.count
                } else {
                    jobsTableView.isHidden = true
                    return 0
                }
            } else {
                if arrSellJobs.count > 0 {
                    return arrSellJobs.count
                } else {
                    jobsTableView.isHidden = true
                    return 0
                }
            }
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if segmentIndex < 2 {
            if tableView == ordersTableView {
                if selTabIndex == 0 {
                    if arrBuyOrders.count > 0 {
                        if section == arrBuyOrders.count - 1 {
                            return 50.0
                        }else{
                            return 5.0
                        }
                    }else{
                        return 0.0
                    }
                }else {
                    if arrSellOrders.count > 0 {
                        if section == arrSellOrders.count - 1 {
                            return 50.0
                        }else{
                            return 5.0
                        }
                    }else{
                        return 0.0
                    }
                }
            }
            else {
                if selTabIndex == 0 {
                    if arrBuyOffers.count > 0 {
                        if section == arrBuyOffers.count - 1 {
                            return 50.0
                        }else{
                            return 5.0
                        }
                    }else{
                        return 0.0
                    }
                }else{
                    if arrSellOffers.count > 0 {
                        if section == arrSellOffers.count - 1 {
                            return 50.0
                        }else{
                            return 5.0
                        }
                    }else{
                        return 0.0
                    }
                }
            }
        } else {
            if selTabIndex == 0 {
                if arrBuyRequests.count > 0 {
                    if section == arrBuyRequests.count - 1 {
                        return 50.0
                    }else{
                        return 0.0
                    }
                }else{
                    return 0.0
                }
            }else{
                if arrSellJobs.count > 0 {
                    if section == arrSellJobs.count - 1 {
                        return 50.0
                    }else{
                        return 0.0
                    }
                }else{
                    return 0.0
                }
            }
        }
    }
    
    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == ordersTableView {
            return 141.0
        }
        else if tableView == offersTableView {
            if selTabIndex == 0 {
                return 141.0
            } else {
                return 119.0
            }
        }
        else if tableView == jobsTableView {
            if selTabIndex == 0 {
                return 136.0
            } else {
                return 118.0
            }
        }
        else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == ordersTableView {
            let cell = ordersTableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrdersCell
            let dictResult = (selTabIndex == 0) ? arrBuyOrders[indexPath.section] : arrSellOrders[indexPath.section]
            let result = ResultData.init(dict: dictResult)
            
            cell.imgService.layer.cornerRadius = 3.0
            cell.imgService.layer.masksToBounds = true
            
            if result.order.media.fileName != "" && result.order.media.mediaType != "video" {
                cell.imgService.sd_imageTransition = .fade
                cell.imgService.sd_setImage(with: URL(string: result.order.media.fileName)!, placeholderImage: UIImage(named:"photo_placeholder"))
            }
            if result.order.media.mediaType == "video" {
                let fileName = result.order.media.fileName
                let url = URL.init(string: fileName)
                DispatchQueue.global().async {
                    let asset = AVAsset(url: url!)
                    let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                    assetImgGenerate.appliesPreferredTrackTransform = true
                    let time = CMTimeMake(1, 2)
                    let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                    if img != nil {
                        let frameImg  = UIImage(cgImage: img!)
                        DispatchQueue.main.async(execute: {
                            cell.imgService.image = frameImg
                        })
                    }
                }
            }
            
            cell.lblDesc.text = (result.order.tagline != "") ? result.order.tagline : result.order.desc
            
            let strSymbol = (result.order.currencySymbol != "") ? result.order.currencySymbol : "$"
            cell.lblPrice.text = strSymbol + String(format:"%.2f", result.order.totalAmount)
            
            cell.lblWorkTime.text = result.order.priceDescription
            
            let strPaid = (result.order.paymentDate != "") ? getFormatDate(origin: result.order.paymentDate, type: 0) : "NA"
            cell.btnPaid.setTitle("Paid on " + strPaid, for: .normal)
            
            cell.btnPending.setTitle(result.order.status, for: .normal)
            if result.order.status == "" {
                cell.btnPaid.isHidden = true
                cell.imgRightArrow.isHidden = true
                cell.imagePending.isHidden = true
            }else {
                cell.btnPaid.isHidden = false
                cell.imgRightArrow.isHidden = false
                cell.imagePending.isHidden = false
            }
            
            var strName = (selTabIndex == 0) ? result.seller.firstName : result.buyer.firstName
            strName = (strName != "") ? strName : "NA"
            cell.btnName.setTitle(strName, for: .normal)
            cell.btnName.tag = orderIndexForProfile + indexPath.section
            cell.btnName.addTarget(self, action: #selector(btnNameTapped(sender:)), for: .touchUpInside)
            
            let strOtherId = (selTabIndex == 0) ? result.seller.id : result.buyer.id
            let strPhone = (selTabIndex == 0) ? result.seller.phone : result.buyer.phone
            
            if strOtherId != "" && strOtherId != loginUserId {
                cell.btnChat.isHidden = false
                cell.btnChat.tag = orderIndexForChat + indexPath.section
                cell.btnChat.addTarget(self, action: #selector(btnChatTapped(sender:)), for: .touchUpInside)
                
                cell.btnCall.isHidden = (strPhone != "") ? false : true
                cell.btnCall.tag = orderIndexForCall + indexPath.section
                cell.btnCall.addTarget(self, action: #selector(btnCallTapped(sender:)), for: .touchUpInside)
            } else {
                cell.btnChat.isHidden = true
                cell.btnCall.isHidden = true
            }
            
            if result.order.notificationCount > Int(0) {
                cell.bgRed.isHidden = false
                cell.lblBell.isHidden = false
                cell.lblBell.text = String(format:"%d", result.order.notificationCount)
            } else {
                cell.bgRed.isHidden = true
                cell.lblBell.isHidden = true
            }
            
            return cell
        }
        else if tableView == offersTableView {
            if selTabIndex == 0 {
                let cell = offersTableView.dequeueReusableCell(withIdentifier: "buyOffersCell", for: indexPath) as! OffersCell
                let result = Offer.init(dict: arrBuyOffers[indexPath.section])
                
                cell.imgService.layer.cornerRadius = 3.0
                cell.imgService.layer.masksToBounds = true
                
                if result.media.fileName != "" && result.media.mediaType != "video" {
                    cell.imgService.sd_imageTransition = .fade
                    cell.imgService.sd_setImage(with: URL(string: result.media.fileName)!, placeholderImage: UIImage(named:"photo_placeholder"))
                } else {
                    cell.imgService.image = UIImage(named:"photo_placeholder")
                }
                
                cell.lblDesc.text = (result.desc != "") ? result.desc : "NA"
                
                let strSymbol = (result.currencySymbol != "") ? result.currencySymbol : "$"
                cell.lblPrice.text = strSymbol + String(format:"%.2f", result.price)
                
                let strWorkTimeUom = (result.workDurationUom != "") ? result.workDurationUom : "hr"
                cell.lblWorkTime.text = "Per " + String(format:"%d", result.workDuration) + " " + strWorkTimeUom
                
                let strName = (result.seller.firstName != "") ? result.seller.firstName : "NA"
                cell.btnName.setTitle(strName, for: .normal)
                cell.btnName.tag = offerIndexForProfile + indexPath.section
                cell.btnName.addTarget(self, action: #selector(btnNameTapped(sender:)), for: .touchUpInside)
                
                let strPost = (result.createdAt != "") ? getFormatDate(origin: result.createdAt, type: 3) : "NA"
                
                if result.expiresIn > 0{
                    cell.lblPostTime.text = "Posted on " + strPost + " - expires in " + String(format:"%d", result.expiresIn) + " \(result.expiresIn == 1 ? "day" : "days")"
                }else{
                    cell.lblPostTime.text = "Posted on " + strPost + " - Offer Expired"
                }
                
                cell.btnAccept.layer.borderWidth = 1.0
                cell.btnAccept.layer.borderColor = UIColor.getCustomLightBlueColor().cgColor
                cell.btnAccept.layer.cornerRadius = 3.0
                cell.btnAccept.layer.masksToBounds = true
                cell.btnAccept.tag = offerIndexForAccept + indexPath.section
                cell.btnAccept.addTarget(self, action: #selector(onClickAccept(sender:)), for: .touchUpInside)
                if result.closed{
                    cell.lblPostTime.text = "Posted on " + strPost + " - Offer Closed"
                    cell.btnAccept.setTitle("See Order", for: .normal)
                }else{
                    if result.expiresIn > 0{
                        cell.btnAccept.isHidden = false
                    }else{
                        cell.btnAccept.isHidden = true
                    }
                }
                
                if result.seller.sellerId != "" && result.seller.sellerId != loginUserId {
                    cell.btnChat.isHidden = false
                    cell.btnChat.tag = offerIndexForChat + indexPath.section
                    cell.btnChat.addTarget(self, action: #selector(btnChatTapped(sender:)), for: .touchUpInside)
                    
                    cell.btnCall.isHidden = (result.seller.phone != "") ? false : true
                    cell.btnCall.tag = offerIndexForCall + indexPath.section
                    cell.btnCall.addTarget(self, action: #selector(btnCallTapped(sender:)), for: .touchUpInside)
                } else {
                    cell.btnChat.isHidden = true
                    cell.btnCall.isHidden = true
                }
                
                return cell
            }
            else {
                let cell = offersTableView.dequeueReusableCell(withIdentifier: "sellOffersCell", for: indexPath) as! OffersCell
                let result = Offer.init(dict: arrSellOffers[indexPath.section])
                
                cell.imgService.layer.cornerRadius = 3.0
                cell.imgService.layer.masksToBounds = true
                
                if result.media.fileName != "" && result.media.mediaType != "video" {
                    cell.imgService.sd_imageTransition = .fade
                    cell.imgService.sd_setImage(with: URL(string: result.media.fileName)!, placeholderImage: UIImage(named:"photo_placeholder"))
                } else {
                    cell.imgService.image = UIImage(named:"photo_placeholder")
                }
                
                cell.lblDesc.text = (result.desc != "") ? result.desc : "NA"
                
                let strSymbol = (result.currencySymbol != "") ? result.currencySymbol : "$"
                cell.lblPrice.text = strSymbol + String(format:"%.2f", result.price)
                
                let strWorkTimeUom = (result.workDurationUom != "") ? result.workDurationUom : "hr"
                cell.lblWorkTime.text = "Per " + String(format:"%d", result.workDuration) + " " + strWorkTimeUom
                
                let strName = (result.buyer.firstName != "") ? result.buyer.firstName : "NA"
                cell.btnName.setTitle(strName, for: .normal)
                cell.btnName.tag = offerIndexForProfile + indexPath.section
                cell.btnName.addTarget(self, action: #selector(btnNameTapped(sender:)), for: .touchUpInside)
                
                let strPost = (result.createdAt != "") ? getFormatDate(origin: result.createdAt, type: 3) : "NA"
                
                if result.expiresIn > 0{
                    cell.lblPostTime.text = "Posted on " + strPost + " - expires in " + String(format:"%d", result.expiresIn) + " \(result.expiresIn == 1 ? "day" : "days")"
                }else{
                    cell.lblPostTime.text = "Posted on " + strPost + " - Offer Expired"
                }
                
                if result.closed{
                    cell.lblPostTime.text = "Posted on " + strPost + " - Offer Closed"
                    if result.orderId != ""{
                        cell.btnSeeOrderSeller.isHidden = false
                    }else{
                        cell.btnSeeOrderSeller.isHidden = true
                    }
                }else{
                    cell.btnSeeOrderSeller.isHidden = true
                }
                cell.btnSeeOrderSeller.layer.borderWidth = 1.0
                cell.btnSeeOrderSeller.layer.borderColor = UIColor.getCustomLightBlueColor().cgColor
                cell.btnSeeOrderSeller.layer.cornerRadius = 3.0
                cell.btnSeeOrderSeller.layer.masksToBounds = true
                cell.btnSeeOrderSeller.tag = offerIndexForAccept + indexPath.section
                cell.btnSeeOrderSeller.addTarget(self, action: #selector(onClickAccept(sender:)), for: .touchUpInside)
                
                if result.buyer.buyerId != "" && result.buyer.buyerId != loginUserId {
                    cell.btnChat.isHidden = false
                    cell.btnChat.tag = offerIndexForChat + indexPath.section
                    cell.btnChat.addTarget(self, action: #selector(btnChatTapped(sender:)), for: .touchUpInside)
                    
                    cell.btnCall.isHidden = (result.seller.phone != "") ? false : true
                    cell.btnCall.tag = offerIndexForCall + indexPath.section
                    cell.btnCall.addTarget(self, action: #selector(btnCallTapped(sender:)), for: .touchUpInside)
                } else {
                    cell.btnChat.isHidden = true
                    cell.btnCall.isHidden = true
                }
                
                return cell
            }
        }
        else if tableView == jobsTableView {
            if selTabIndex == 0 {
                let cell = jobsTableView.dequeueReusableCell(withIdentifier: "liveOffersCell", for: indexPath) as! JobsCell
                let result = ResultData.init(dict: arrBuyRequests[indexPath.section])
                
                cell.imgService.layer.cornerRadius = 3.0
                cell.imgService.layer.masksToBounds = true
                
                if result.requests.media.fileName != "" && result.requests.media.mediaType != "video" {
                    cell.imgService.sd_imageTransition = .fade
                    cell.imgService.sd_setImage(with: URL(string: result.requests.media.fileName)!, placeholderImage: UIImage(named:"photo_placeholder"))
                } else {
                    cell.imgService.image = UIImage(named:"photo_placeholder")
                }
                
                cell.lblDesc.text = (result.requests.desc != "") ? result.requests.desc : "NA"
                
                let strSymbol = (result.requests.currencySymbol != "") ? result.requests.currencySymbol : "$"
                cell.lblPrice.text = strSymbol + String(format:"%.2f", result.requests.low) + " - " + strSymbol + String(format:"%.2f", result.requests.high)
                
                cell.lblOldOffers.text = String(format:"%d", result.requests.numOffers)
                cell.lblNewOffers.text = String(format:"%d", result.requests.numNewOffers)
                
                if result.requests.expiresIn > Int(0) {
                    let strExpiresIn = "Expires in " + String(format:"%d", result.requests.expiresIn) + " days"
                    cell.btnExpires.setTitle(strExpiresIn, for: .normal)
                    cell.btnOffer.isHidden = false
                } else {
                    cell.btnOffer.isHidden = true
                    cell.btnExpires.setTitle("Expired", for: .normal)
                }
                
                cell.lblOfferTime.text = (result.requests.createdAt != "") ? getFormatDate(origin: result.requests.createdAt, type: 2) : "NA"
                
                cell.btnOffer.layer.borderWidth = 1.0
                cell.btnOffer.layer.borderColor = UIColor.getCustomLightBlueColor().cgColor
                cell.btnOffer.layer.cornerRadius = 3.0
                cell.btnOffer.layer.masksToBounds = true

                cell.btnRequestAgain.setTitleColor(UIColor.white, for: .normal)
                cell.btnRequestAgain.layer.backgroundColor = UIColor.getCustomLightBlueColor().cgColor
                cell.btnRequestAgain.layer.cornerRadius = 3.0
                cell.btnRequestAgain.layer.masksToBounds = true
                
                if result.requests.cloesd{
                    cell.btnOffer.setTitle("See Order", for: .normal)
                    cell.btnExpires.setTitle("Closed", for: .normal)
                    cell.btnRequestAgain.isHidden = false
                }else{
                    cell.btnOffer.setTitle("View", for: .normal)
                    cell.btnOffer.isHidden = true
                    if result.requests.expiresIn > Int(0){
                        cell.btnRequestAgain.isHidden = true
                    }else{
                        cell.btnRequestAgain.isHidden = false
                    }
                    
                }
                
                
                cell.btnOffer.tag = indexPath.section * 100
                cell.btnOffer.addTarget(self, action: #selector(viewJobRequest(sender:)), for: .touchUpInside)
                
                cell.btnRequestAgain.tag = indexPath.section * 100
                cell.btnRequestAgain.addTarget(self, action: #selector(RequestAgain(sender:)), for: .touchUpInside)

                return cell
            }
            else {
                let cell = jobsTableView.dequeueReusableCell(withIdentifier: "jobsCell", for: indexPath) as! JobsCell
                let result = ResultData.init(dict: arrSellJobs[indexPath.section])
                cell.imgService.layer.cornerRadius = 3.0
                cell.imgService.layer.masksToBounds = true
                
                if result.requestOffers.request.media.fileName != "" && result.requestOffers.request.media.mediaType != "video" {
                    cell.imgService.sd_imageTransition = .fade
                    cell.imgService.sd_setImage(with: URL(string: result.requestOffers.request.media.fileName)!, placeholderImage: UIImage(named:"photo_placeholder"))
                } else {
                    cell.imgService.image = UIImage(named:"photo_placeholder")
                }
                
                cell.lblDesc.text = (result.requestOffers.request.desc != "") ? result.requestOffers.request.desc : "NA"
                
                let strSymbol = (result.requestOffers.requester.currencySymbol != "") ? result.requestOffers.requester.currencySymbol : "$"
                cell.lblPrice.text = strSymbol + String(format:"%.2f", result.requestOffers.requester.low) + " - " + strSymbol + String(format:"%.2f", result.requestOffers.requester.high)
                
                cell.lblOldOffers.text = String(format:"%d", result.requestOffers.numOffers)
                
                cell.lblOfferTime.text = (result.requestOffers.request.createdAt != "") ? getFormatDate(origin: result.requestOffers.request.createdAt, type: 2) : "NA"

                cell.btnOffer.layer.borderWidth = 1.0
                cell.btnOffer.layer.borderColor = UIColor.getCustomLightBlueColor().cgColor
                cell.btnOffer.layer.cornerRadius = 3.0
                cell.btnOffer.layer.masksToBounds = true
                
                let jobDict = arrSellJobs[indexPath.section]["requestOffers"] as! [String:Any]
                
                if jobDict["requestOfferId"] == nil {
                    cell.btnOffer.setTitle("Make Offer", for: .normal)
                    cell.btnOffer.setTitleColor(UIColor.getCustomLightBlueColor(), for: .normal)
                    cell.btnOffer.backgroundColor = UIColor.white
                    cell.btnEdit.isHidden = true
                    cell.btnOffer.tag = indexPath.section * 100
                    cell.btnOffer.addTarget(self, action: #selector(makeJobOffer(sender:)), for: .touchUpInside)
                } else {
                    cell.btnOffer.setTitle("Offer Sent", for: .normal)
                    cell.btnOffer.setTitleColor(UIColor.white, for: .normal)
                    cell.btnOffer.backgroundColor = UIColor.getCustomLightBlueColor()
                    cell.btnEdit.isHidden = false
                }
                
                if result.requestOffers.expiresIn > Int(0) {
                    let strExpiresIn = "Job expires in " + String(format:"%d", result.requestOffers.expiresIn) + " days"
                    cell.btnExpires.setTitle(strExpiresIn, for: .normal)
                    cell.btnEdit.isHidden = false
                    cell.btnOffer.isHidden = false
                } else {
                    cell.btnExpires.setTitle("Expired", for: .normal)
                    cell.btnEdit.isHidden = true
                    cell.btnOffer.isHidden = true
                }
                
                if result.requestOffers.request.cloesd{
                    cell.btnOffer.isHidden = false
                    cell.btnOffer.setTitleColor(UIColor.getCustomLightBlueColor(), for: .normal)
                    cell.btnOffer.backgroundColor = UIColor.white
                    cell.btnEdit.isHidden = true
                    cell.btnOffer.setTitle("See Order", for: .normal)
                    cell.btnOffer.tag = indexPath.section * 100
                    cell.btnOffer.addTarget(self, action: #selector(makeJobOffer(sender:)), for: .touchUpInside)
                }
                
                cell.btnEdit.tag = indexPath.section
                cell.btnEdit.addTarget(self, action: #selector(editJobOffer(sender:)), for: .touchUpInside)
                
                return cell
            }
        }
        else {
            return UITableViewCell()
        }
    }
}

// UITableViewDelegate
extension AboutMeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if segmentIndex == 0 {
            if selTabIndex == 0 {
                if (indexPath.section == arrBuyOrders.count-1) && (self.totalCnt > self.limitCnt) {
                    callGetBuyOrders(inited: false, lastID: self.lastDocId)
                }
            } else {
                if (indexPath.section == arrSellOrders.count-1) && (self.totalCnt > self.limitCnt) {
                    callGetSellOrders(inited: false, lastID: self.lastDocId)
                }
            }
        }
        else if segmentIndex == 1 {
            if selTabIndex == 0 {
                if (indexPath.section == arrBuyOffers.count-1) && (self.totalCnt > self.limitCnt) {
                    callGetBuyOffers(inited: false, lastID: self.lastDocId)
                }
            } else {
                if (indexPath.section == arrSellOffers.count-1) && (self.totalCnt > self.limitCnt) {
                    callGetSellOffers(inited: false, lastID: self.lastDocId)
                }
            }
        }
        else if segmentIndex == 2 {
            if selTabIndex == 0 {
                if (indexPath.section == arrBuyRequests.count-1) && (self.totalCnt > self.limitCnt) {
                    callGetBuyRequests(inited: false, lastID: self.lastDocId)
                }
            } else {
                if (indexPath.section == arrSellJobs.count-1) && (self.totalCnt > self.limitCnt) {
                    callGetSellJobs(inited: false, lastID: self.lastDocId)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentIndex == 0 {
            let dictResult = (selTabIndex == 0) ? arrBuyOrders[indexPath.section] : arrSellOrders[indexPath.section]
            let result = ResultData.init(dict: dictResult)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let fulfillmentVC = storyboard.instantiateViewController(withIdentifier: "FulfillmentVC") as! FulfillmentViewController
            fulfillmentVC.orderId = result.order.id
            navigationController?.pushViewController(fulfillmentVC, animated: true)
        }
        else if segmentIndex == 1 {
            if selTabIndex == 0 {
                let result = Offer.init(dict: arrBuyOffers[indexPath.section])
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let offerDetailVC = storyboard.instantiateViewController(withIdentifier: "OfferDetailVC") as! OfferDetailViewController
                offerDetailVC.offerId = result.offerId
                offerDetailVC.offerFlag = 1
                navigationController?.pushViewController(offerDetailVC, animated: true)
            } else {
                let result = Offer.init(dict: arrSellOffers[indexPath.section])
                let storyboard = UIStoryboard(name: "Explore", bundle: nil)
                let sendCustomOfferVC = storyboard.instantiateViewController(withIdentifier: "SendOfferVC") as! SendOfferViewController
                sendCustomOfferVC.buyerId = result.buyer.buyerId
                sendCustomOfferVC.offerId = result.offerId
                sendCustomOfferVC.isJobOffer = false
                sendCustomOfferVC.customOfferDelegate = self
                navigationController?.pushViewController(sendCustomOfferVC, animated:true)
            }
        }
        else if segmentIndex == 2 {
            if selTabIndex == 0 {
//                let result = ResultData.init(dict: arrBuyRequests[indexPath.section])
//                self.callRequestDetailAPI(requestId: result.requests.id)
                let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
                let exploreServiceVC = storyboard.instantiateViewController(withIdentifier: "ExploreServiceVC") as! ExploreServiceViewController
                exploreServiceVC.liveOffer = true
                let requestDetailDic = arrBuyRequests[indexPath.section]["requests"] as! [String : Any]
                let request = RequestDetail.init(dict: requestDetailDic)
                exploreServiceVC.selectedRequest = request
                exploreServiceVC.selectedTabIndex = 1
                self.navigationController?.pushViewController(exploreServiceVC, animated: true)
            } else {
                if arrSellJobs.count > 0 {
                    let result = ResultData.init(dict: arrSellJobs[indexPath.section])
                    let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
                    let requestDetailVC = storyboard.instantiateViewController(withIdentifier: "RequestDetailVC") as! RequestDetailViewController
                    requestDetailVC.pageFlag = 0
                    requestDetailVC.requestId = result.requestOffers.request.requestId
                    navigationController?.pushViewController(requestDetailVC, animated: true)
                }
            }
        }
    }
}

// MARK: - SendCustomOfferDelegate

extension AboutMeViewController: SendCustomOfferDelegate {
    func selectSendCustomOffer(selId:String, selPrice:[String:Any], linkedService: [String:Any], link:Bool) {

    }
    func returnFromCustomOffer(reload: Bool) {
        if reload {
            callAPIs()
        }
    }
}

//MARK:- RequestDetailVCD Delegate

extension AboutMeViewController: RequestDetailVCDelegate{
    func submittedRequest(request: RequestDetail) {
        self.callAPIs()
    }
    
    func onUpdateRequest(request: RequestDetail, index: Int) {
        
    }
    
    func onDeleteRequest(index: Int) {
        
    }
    

}
