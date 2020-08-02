//
//  ContainerTabViewController.swift
//  Pointters
//
//  Created by Mac on 2/13/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import CoreLocation

class ContainerTabViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet var tabExplore: UIButton!
    @IBOutlet var tabUpdate: UIButton!
    @IBOutlet var tabPost: UIButton!
    @IBOutlet var tabChat: UIButton!
    @IBOutlet var tabUser: UIButton!
    @IBOutlet var consTabsViewHeight: NSLayoutConstraint!
    @IBOutlet var consTabsViewBottom: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    
    var currView = ""
    var currentVC: UIViewController?
    
    var explorePublicServiceVC = ExplorePublicViewController()
    var exploreServiceVC = ExploreServiceViewController()
    var updatesVC = UpdatesViewController()
    var chatsVC = ChatsViewController()
    var accountVC = AccountViewController()
    
    var selectedExplorerTabIndex = 0
    
    var selectedRequest: RequestDetail!
    
    var selectedUserId = ""
    var selectedRequestId = ""
    var selectedServiceId = ""
    var arrAmount = [Int]()
    var totalPrice:Float = 0.0
    
    var chatUserId = ""
    var chatUserPic = ""
    var chatUserName = ""
    
    var showedExploreTip = false
    var showedUpdateTip = false
    var showedChatTip = false
    
    var selectedTab = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        setupLocationManager()
        if let userDict = UserCache.sharedInstance.getUserCredentials() {
            if let val = userDict[kUserCredentials.kLoginType] as? String {
                if val == "E" || val == "F" {
                    if let registered = userDict[kUserCredentials.kCompletedRegistration] as? Bool, registered == true {
                        if self.selectedTab == "Updates" {
                            let storyboard = UIStoryboard(name: "Updates", bundle: nil)
                            updatesVC = storyboard.instantiateViewController(withIdentifier: "updatesVC") as! UpdatesViewController
                            showVC(vc: updatesVC, currentView: "Updates")
                        } else if self.selectedTab == "Posts" {
                            let storyboard = UIStoryboard(name: "Updates", bundle: nil)
                            let postUpdateVC = storyboard.instantiateViewController(withIdentifier: "PostUpdateVC") as! PostUpdateViewController
                            postUpdateVC.selTabIndex = 0
                            postUpdateVC.postUpdateDelegate = self
                            navigationController?.pushViewController(postUpdateVC, animated: true)
                        } else if self.selectedTab == "Chats" {
                            let storyboard = UIStoryboard(name: "Chats", bundle: nil)
                            chatsVC = storyboard.instantiateViewController(withIdentifier: "ChatsVC") as! ChatsViewController
                            showVC(vc: chatsVC, currentView: "Chats")
                        } else if self.selectedTab == "Me" {
                            let storyboard = UIStoryboard(name: "Account", bundle: nil)
                            accountVC = storyboard.instantiateViewController(withIdentifier: "AccountVC") as! AccountViewController
                            showVC(vc: accountVC, currentView: "Me")
                        } else {
//                            let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
//                            exploreServiceVC = storyboard.instantiateViewController(withIdentifier: "ExploreServiceVC") as! ExploreServiceViewController
//                            exploreServiceVC.selectedTabIndex = self.selectedExplorerTabIndex
//                            exploreServiceVC.selectedUserId = self.selectedUserId
//                            exploreServiceVC.selectedRequestId = self.selectedRequestId
//                            exploreServiceVC.selectedRequest = selectedRequest
//                            exploreServiceVC.selectedServiceId = self.selectedServiceId
//                            exploreServiceVC.arrAmount = self.arrAmount
//                            exploreServiceVC.totalPrice = self.totalPrice
//                            exploreServiceVC.chatUserId = self.chatUserId
//                            exploreServiceVC.chatUserPic = self.chatUserPic
//                            exploreServiceVC.chatUserName = self.chatUserName
//                            showVC(vc: exploreServiceVC, currentView: "Explore")
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            explorePublicServiceVC = storyboard.instantiateViewController(withIdentifier: "explorePublicVC") as! ExplorePublicViewController
                            showVC(vc: explorePublicServiceVC, currentView: "ExplorePublic")
                        }
                        
                    } else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        explorePublicServiceVC = storyboard.instantiateViewController(withIdentifier: "explorePublicVC") as! ExplorePublicViewController
                        showVC(vc: explorePublicServiceVC, currentView: "ExplorePublic")
                    }
                }
            }
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            explorePublicServiceVC = storyboard.instantiateViewController(withIdentifier: "explorePublicVC") as! ExplorePublicViewController
            showVC(vc: explorePublicServiceVC, currentView: "ExplorePublic")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consTabsViewHeight.constant = 70.0
            consTabsViewBottom.constant = 20.0
        } else {
            consTabsViewHeight.constant = 50.0
            consTabsViewBottom.constant = 0.0
        }
    }
    
    func selectedTab(currentView: String) {
        tabExplore.setImage(UIImage(named:"tab-explorer-normal"), for: .normal)
        tabUpdate.setImage(UIImage(named:"tab-update-normal"), for: .normal)
        tabPost.setImage(UIImage(named:"tab-post-normal"), for: .normal)
        tabChat.setImage(UIImage(named:"tab-chat-normal"), for: .normal)
        tabUser.setImage(UIImage(named:"tab-me-normal"), for: .normal)
        
        switch currentView {
            case "Explore":
                tabExplore.setImage(UIImage(named:"tab-explorer-select"), for: .normal)
                break
            case "Updates":
                tabUpdate.setImage(UIImage(named:"tab-update-select"), for: .normal)
                break
            case "Chats":
                tabChat.setImage(UIImage(named:"tab-chat-select"), for: .normal)
                break
            case "Me":
                tabUser.setImage(UIImage(named:"tab-me-select"), for: .normal)
                break
            default:
                break
        }
    }
    
    func showVC(vc: UIViewController, currentView: String) {
        if currView != currentView {
            currView = currentView
            selectedTab(currentView: currentView)
            addChildViewController(vc)
            
            vc.view.frame = containerView.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            vc.didMove(toParentViewController: self)
            containerView.addSubview(vc.view)
            
            if currentVC != nil {
                currentVC?.view.removeFromSuperview()
            }
            currentVC = vc
        }
    }
    
    func showRequestMenu() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let postUpdateAction: UIAlertAction = UIAlertAction(title: "Post Update", style: .default) { action -> Void in
            let storyboard = UIStoryboard(name: "Updates", bundle: nil)
            let postUpdateVC = storyboard.instantiateViewController(withIdentifier: "PostUpdateVC") as! PostUpdateViewController
            self.navigationController?.pushViewController(postUpdateVC, animated: true)
        }
        let addServiceAction: UIAlertAction = UIAlertAction(title: "Add Service", style: .default) { action -> Void in
            let storyboard = UIStoryboard(name: "Updates", bundle: nil)
            let serviceVC = storyboard.instantiateViewController(withIdentifier: "ServiceViewController") as! ServiceViewController
            self.navigationController?.pushViewController(serviceVC, animated: true)
        }
        let postNewJobAction: UIAlertAction = UIAlertAction(title: "Post New Job", style: .default) { action -> Void in
            let storyboard = UIStoryboard(name: "Explore", bundle: nil)
                    let requestDetailVC = storyboard.instantiateViewController(withIdentifier: "RequestDetailVC") as! RequestDetailViewController
                    requestDetailVC.pageFlag = 1
                    requestDetailVC.requestDelegate = self
                    self.navigationController?.pushViewController(requestDetailVC, animated: true)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

        // add actions
        actionSheetController.addAction(postUpdateAction)
        actionSheetController.addAction(addServiceAction)
        actionSheetController.addAction(postNewJobAction)
        actionSheetController.addAction(cancelAction)

        // present an actionSheet
        present(actionSheetController, animated: true, completion: nil)
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
 
    @IBAction func tabExploreTapped(_ sender: Any) {
        if let userDict = UserCache.sharedInstance.getUserCredentials() {
            if let val = userDict[kUserCredentials.kLoginType] as? String {
                if val == "E" || val == "F" {
                    if let registered = userDict[kUserCredentials.kCompletedRegistration] as? Bool, registered == true {
//                        let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
//                        exploreServiceVC = storyboard.instantiateViewController(withIdentifier: "ExploreServiceVC") as! ExploreServiceViewController
//                        showVC(vc: exploreServiceVC, currentView: "Explore")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        explorePublicServiceVC = storyboard.instantiateViewController(withIdentifier: "explorePublicVC") as! ExplorePublicViewController
                        showVC(vc: explorePublicServiceVC, currentView: "ExplorePublic")
                    } else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        explorePublicServiceVC = storyboard.instantiateViewController(withIdentifier: "explorePublicVC") as! ExplorePublicViewController
                        showVC(vc: explorePublicServiceVC, currentView: "ExplorePublic")
                    }
                }
            }
        }else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            explorePublicServiceVC = storyboard.instantiateViewController(withIdentifier: "explorePublicVC") as! ExplorePublicViewController
            showVC(vc: explorePublicServiceVC, currentView: "ExplorePublic")
        }
    }
    
    @IBAction func tabUpdatesTapped(_ sender: Any) {
        if let userDict = UserCache.sharedInstance.getUserCredentials() {
            if let val = userDict[kUserCredentials.kLoginType] as? String {
                if val == "E" || val == "F" {
                    if let registered = userDict[kUserCredentials.kCompletedRegistration] as? Bool, registered == true {
                        let storyboard = UIStoryboard(name: "Updates", bundle: nil)
                        updatesVC = storyboard.instantiateViewController(withIdentifier: "updatesVC") as! UpdatesViewController
                        showVC(vc: updatesVC, currentView: "Updates")
                    } else {
                        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                        loginVC.currentTap = "Updates"
                        self.navigationController?.pushViewController(loginVC, animated: false)
                    }
                }
            }
        }else {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            loginVC.currentTap = "Updates"
            self.navigationController?.pushViewController(loginVC, animated: false)
        }
    }
    
    @IBAction func tabPostTapped(_ sender: Any) {
        if let userDict = UserCache.sharedInstance.getUserCredentials() {
            if let val = userDict[kUserCredentials.kLoginType] as? String {
                if val == "E" || val == "F" {
                    if let registered = userDict[kUserCredentials.kCompletedRegistration] as? Bool, registered == true {
//                        let storyboard = UIStoryboard(name: "Updates", bundle: nil)
//                        let postUpdateVC = storyboard.instantiateViewController(withIdentifier: "PostUpdateVC") as! PostUpdateViewController
//                        postUpdateVC.selTabIndex = 0
//                        postUpdateVC.postUpdateDelegate = self
//                        navigationController?.pushViewController(postUpdateVC, animated: true)
                        self.showRequestMenu()
                    } else {
                        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                        loginVC.currentTap = "Posts"
                        self.navigationController?.pushViewController(loginVC, animated: false)
                    }
                }
            }
        }else {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            loginVC.currentTap = "Posts"
            self.navigationController?.pushViewController(loginVC, animated: false)
        }
    }
  
    @IBAction func tabChatTapped(_ sender: Any) {
        if let userDict = UserCache.sharedInstance.getUserCredentials() {
            if let val = userDict[kUserCredentials.kLoginType] as? String {
                if val == "E" || val == "F" {
                    if let registered = userDict[kUserCredentials.kCompletedRegistration] as? Bool, registered == true {
                        let storyboard = UIStoryboard(name: "Chats", bundle: nil)
                        chatsVC = storyboard.instantiateViewController(withIdentifier: "ChatsVC") as! ChatsViewController
                        showVC(vc: chatsVC, currentView: "Chats")
                    } else {
                        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                        loginVC.currentTap = "Chats"
                        self.navigationController?.pushViewController(loginVC, animated: false)
                    }
                }
            }
        }else {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            loginVC.currentTap = "Chats"
            self.navigationController?.pushViewController(loginVC, animated: false)
        }
    }
 
    @IBAction func tabUserTapped(_ sender: Any) {
        if let userDict = UserCache.sharedInstance.getUserCredentials() {
            if let val = userDict[kUserCredentials.kLoginType] as? String {
                if val == "E" || val == "F" {
                    if let registered = userDict[kUserCredentials.kCompletedRegistration] as? Bool, registered == true {
                        let storyboard = UIStoryboard(name: "Account", bundle: nil)
                        accountVC = storyboard.instantiateViewController(withIdentifier: "AccountVC") as! AccountViewController
                        showVC(vc: accountVC, currentView: "Me")
                    } else {
                        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                        loginVC.currentTap = "Me"
                        self.navigationController?.pushViewController(loginVC, animated: false)
                    }
                }
            }
        } else {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            loginVC.currentTap = "Me"
            self.navigationController?.pushViewController(loginVC, animated: false)
        }
    }
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

extension ContainerTabViewController : RequestDetailVCDelegate {
    func submittedRequest(request: RequestDetail) {
        print("submitted request successfully")
    }

    func onUpdateRequest(request: RequestDetail, index: Int) {
        print("updated request successfully")
    }

    func onDeleteRequest(index: Int) {
        print("deleted request successfully")
    }

}

extension ContainerTabViewController : PostUpdateDelegate {
    func postUpdate() {
        let storyboard = UIStoryboard(name: "Updates", bundle: nil)
        updatesVC = storyboard.instantiateViewController(withIdentifier: "updatesVC") as! UpdatesViewController
        updatesVC.scrollToTop = true
        showVC(vc: updatesVC, currentView: "Updates")
    }
}

extension NSObject{
    func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat = pdblLatitude
        //21.228124
        let lon = pdblLongitude
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                if let _ = placemarks{
                    let pm = placemarks! as [CLPlacemark]
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        if pm.country != nil {
                            UserCache.sharedInstance.setUserCountry(country: pm.country!)
                        }
                        if pm.administrativeArea != nil {
                            UserCache.sharedInstance.setUserState(state: pm.administrativeArea!)
                        }
                        if pm.subAdministrativeArea != nil {
                            UserCache.sharedInstance.setUserCity(city: pm.subAdministrativeArea!)
                        }
                        if pm.subLocality != nil {
                            UserCache.sharedInstance.setUserStreet(street: pm.subLocality!)
                        }
                        if pm.postalCode != nil {
                            UserCache.sharedInstance.setUserZip(zip: pm.postalCode!)
                        }
                        
                    }
                }
                
                
        })
    }
}

extension ContainerTabViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        UserCache.sharedInstance.setUserLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        getAddressFromLatLon(pdblLatitude: userLocation.coordinate.latitude, withLongitude: userLocation.coordinate.longitude)
        locationManager.stopUpdatingLocation()
    }
}
