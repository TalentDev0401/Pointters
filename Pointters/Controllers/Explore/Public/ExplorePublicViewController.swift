//
//  ExplorePublicViewController.swift
//  Pointters
//
//  Created by super on 3/4/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer
import CoreLocation

class ExplorePublicViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var player:AVPlayer!
    let playerController = AVPlayerViewController()

    @IBOutlet var consNavViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainTableView: UITableView!
    
    var arrBanner = [[String:Any]]()
    var popularCategories = [[String:Any]]()
    var popularServices = [[String:Any]]()
    var popularJobs = [[String:Any]]()
    var onlineServices = [[String:Any]]()
    var onlineJobs = [[String:Any]]()
    var localServices = [[String:Any]]()
    var localJobs = [[String:Any]]()
    var bestSellers = [[String: Any]]()
    
    var location = Location.init()
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    // MARK: - Private methods
    
    func initUI(){
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavViewHeight.constant = 101.0
        } else {
            consNavViewHeight.constant = 80.0
        }
        
        guard let banner = appDelegate.arrBanner else {
            callPublicExploreAPI(initialize: true)
            return
        }
        self.arrBanner = banner
        guard let categories = appDelegate.popularCategories else {
            callPublicExploreAPI(initialize: true)
            return
        }
        self.popularCategories = categories
        guard let pServices = appDelegate.popularServices else {
            callPublicExploreAPI(initialize: true)
            return
        }
        self.popularServices = pServices
        guard let pJobs = appDelegate.popularJobs else {
            callPublicExploreAPI(initialize: true)
            return
        }
        self.popularJobs = pJobs
        guard let lServices = appDelegate.localServices else {
            callPublicExploreAPI(initialize: true)
            return
        }
        self.localServices = lServices
        guard let lJobs = appDelegate.localJobs else {
            callPublicExploreAPI(initialize: true)
            return
        }
        self.localJobs = lJobs
        guard let bSellers = appDelegate.bestSellers else {
            callPublicExploreAPI(initialize: true)
            return
        }
        self.bestSellers = bSellers
        guard let oServices = appDelegate.onlineServices else {
            callPublicExploreAPI(initialize: true)
            return
        }
        self.onlineServices = oServices
        guard let oJobs = appDelegate.onlineJobs else {
            callPublicExploreAPI(initialize: true)
            return
        }
        self.onlineJobs = oJobs       
        DispatchQueue.main.async {
            self.callPublicExploreAPI(initialize: false)
        }
    }
    
    func playVideo(url: String){
        if let url = URL(string: url){
            player = AVPlayer(url: url)
            playerController.player = player
            playerController.showsPlaybackControls = true
            self.present(playerController, animated: true, completion: {
                self.player.play()
            })
        }
    }
    
    func getCurrentLocation() {
        let geocoder = CLGeocoder()
        let lat:Double = UserCache.sharedInstance.getUserLatitude()!
        let lng:Double = UserCache.sharedInstance.getUserLongitude()!
        let userLocation = CLLocation(latitude: lat, longitude: lng)
        geocoder.reverseGeocodeLocation(userLocation, completionHandler: {
            placemarks, error in
            if let err = error {
                self.location = Location.init()
                print(err.localizedDescription)
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    self.location.city = placemark.locality ?? "NA"
                    self.location.country = placemark.country ?? "NA"
                    self.location.postalCode = placemark.postalCode ?? "NA"
                    self.location.province = placemark.subAdministrativeArea ?? "NA"
                    self.location.state = placemark.administrativeArea ?? ""
                    self.location.geoJson.coordinates = [userLocation.coordinate.longitude, userLocation.coordinate.latitude]
                } else {
                    self.location = Location.init()
                    print("Placemark was nil")
                }
            } else {
                self.location = Location.init()
                print("Unknown error")
            }
        })
    }
    
    func gotoRequestView(requestId: String) {
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        let requestDetailVC = storyboard.instantiateViewController(withIdentifier: "RequestDetailVC") as! RequestDetailViewController
        requestDetailVC.pageFlag = 0
        requestDetailVC.requestId = requestId
        navigationController?.pushViewController(requestDetailVC, animated: true)
    }
    
    @objc func onClickShowAll(guesture: MyTapGesture){
        let myGesture = guesture
        switch myGesture.param {
        case pItemType.pPopularCategory:
            let storyboard = UIStoryboard(name: "Public", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "categorySelectViewController") as! CategorySelectViewController
            vc.isPublic = true
            vc.type = "requests"
            self.navigationController?.pushViewController(vc, animated: true)
        case pItemType.pPopularService:
//            let storyboard = UIStoryboard(name: "Public", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "categorySelectViewController") as! CategorySelectViewController
//            vc.isPublic = true
//            vc.type = "services"
//            self.navigationController?.pushViewController(vc, animated: true)
            let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
            let exploreServiceVC = storyboard.instantiateViewController(withIdentifier: "ExploreServiceVC") as! ExploreServiceViewController
            exploreServiceVC.isService = true
            exploreServiceVC.type = ""
            self.navigationController?.pushViewController(exploreServiceVC, animated: true)
        case pItemType.pLocalService:
            let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
            let exploreServiceVC = storyboard.instantiateViewController(withIdentifier: "ExploreServiceVC") as! ExploreServiceViewController
            exploreServiceVC.isService = true
            exploreServiceVC.type = "local"
            self.navigationController?.pushViewController(exploreServiceVC, animated: true)
        case pItemType.pOnlineService:
            let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
            let exploreServiceVC = storyboard.instantiateViewController(withIdentifier: "ExploreServiceVC") as! ExploreServiceViewController
            exploreServiceVC.isService = true
            exploreServiceVC.type = "online"
            self.navigationController?.pushViewController(exploreServiceVC, animated: true)
        case pItemType.pOnlineJob:
            let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
            let exploreServiceVC = storyboard.instantiateViewController(withIdentifier: "ExploreServiceVC") as! ExploreServiceViewController
            exploreServiceVC.isService = false
            exploreServiceVC.type = "online"
            self.navigationController?.pushViewController(exploreServiceVC, animated: true)
        case pItemType.pPopularJob:
            let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
            let exploreServiceVC = storyboard.instantiateViewController(withIdentifier: "ExploreServiceVC") as! ExploreServiceViewController
            exploreServiceVC.isService = false
            exploreServiceVC.type = ""
            self.navigationController?.pushViewController(exploreServiceVC, animated: true)
        case pItemType.pLocalJob:
            let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
            let exploreServiceVC = storyboard.instantiateViewController(withIdentifier: "ExploreServiceVC") as! ExploreServiceViewController
            exploreServiceVC.isService = false
            exploreServiceVC.type = "local"
            self.navigationController?.pushViewController(exploreServiceVC, animated: true)
        default:
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            self.navigationController?.pushViewController(loginVC, animated: false)
            return
        }
        
    }
    
    //*******************************************************//
    //                 MARK: - Call API Method               //
    //*******************************************************//
    
    func callPublicExploreAPI(initialize: Bool) {
        if initialize {
            PointtersHelper.sharedInstance.startLoader(view: view)
        }
        ApiHandler.callPublicExplore(withCompletionHandler:{ (result,statusCode,response) in
            if initialize {
                PointtersHelper.sharedInstance.stopLoader()
            }
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    self.arrBanner = responseDict["banner"] as! [[String:Any]]
                    appDelegate.arrBanner = self.arrBanner
                    self.popularCategories = responseDict["categories"] as! [[String:Any]]
                    appDelegate.popularCategories = self.popularCategories
                    self.popularServices = responseDict["popularServices"] as! [[String:Any]]
                    appDelegate.popularServices = self.popularServices
                    self.popularJobs = responseDict["popularJobs"] as! [[String:Any]]
                    appDelegate.popularJobs = self.popularJobs
                    self.localServices = responseDict["localServices"] as! [[String:Any]]
                    appDelegate.localServices = self.localServices
                    self.localJobs = responseDict["localJobs"] as! [[String:Any]]
                    appDelegate.localJobs = self.localJobs
                    self.bestSellers = responseDict["bestSellers"] as! [[String: Any]]
                    appDelegate.bestSellers = self.bestSellers
                    self.onlineServices = responseDict["onlineServices"] as! [[String:Any]]
                    appDelegate.onlineServices = self.onlineServices
                    self.onlineJobs = responseDict["onlineJobs"] as! [[String:Any]]
                    appDelegate.onlineJobs = self.onlineJobs
                    self.mainTableView.reloadData()
                    
                    let job = UserDefaults.standard.value(forKey: "jobType") as? String
                    if let jobType = job {
                        if jobType == "online" {
                            let item = self.onlineJobs[self.index]
                            self.gotoRequestView(requestId: item["id"] as! String)
                        } else if jobType == "popular" {
                            let item = self.popularJobs[self.index]
                            self.gotoRequestView(requestId: item["id"] as! String)
                        } else if jobType == "local" {
                            let item = self.localJobs[self.index]
                            self.gotoRequestView(requestId: item["id"] as! String)
                        } else if jobType == "bestseller" {
                            let seller = self.bestSellers[self.index]
                            let userId = seller["userId"] as! String
                            UserCache.sharedInstance.setProfileUser(loginUser: false, userId: userId)
                            let storyboard = UIStoryboard(name: "Account", bundle: nil)
                            let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
                            self.navigationController?.pushViewController(userProfileVC, animated:true)
                        }
                        UserDefaults.standard.set(nil, forKey: "jobType")
                    }
                }
            } else {
                print(response.error ?? "get service detail failure")
            }
        })
    }
    
}

//MARK: search bar delegate

extension ExplorePublicViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.endEditing(true)
        let storyboard = UIStoryboard(name: "Public", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "initialSearchViewController") as! InitialSearchViewController
        vc.isPublic = false
        self.navigationController?.pushViewController(vc, animated: true)
        return false
    }
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

extension ExplorePublicViewController : UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 228.0
        case 1:
            return 150.0
        case 2:
            return 160.0
        case 3:
            return 255.0
        case 4:
            return 160.0
        case 5:
            return 255.0
        case 6:
            return 250.0
        case 7:
            return 255.0
        case 8:
            return 180.0
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell: HomeServicesCell = tableView.dequeueReusableCell(withIdentifier: "homeServicesCell", for: indexPath) as! HomeServicesCell
            cell.collectionView.tag = indexPath.row
            cell.arrBanner = self.arrBanner
            cell.delegate = self
            cell.collectionView.reloadData()
            return cell
        case 1:
            let cell: PopularCategoryCell = tableView.dequeueReusableCell(withIdentifier: "popularCategoryCell", for: indexPath) as! PopularCategoryCell
            cell.collectionView.tag = indexPath.row
            cell.popularCategories = self.popularCategories
            cell.delegate = self
            
            let tapGuesture = MyTapGesture(target: self, action: #selector(self.onClickShowAll(guesture:)))
            tapGuesture.param = pItemType.pPopularCategory
            cell.btnShowAll.addGestureRecognizer(tapGuesture)
            cell.collectionView.reloadData()
            return cell
        case 2:
            let cell: OnlineServiceCell = tableView.dequeueReusableCell(withIdentifier: "onlineServiceCell", for: indexPath) as! OnlineServiceCell
            cell.collectionView.tag = indexPath.row
            cell.delegate = self
            cell.onlineServices = self.onlineServices
            let tapGuesture = MyTapGesture(target: self, action: #selector(self.onClickShowAll(guesture:)))
            tapGuesture.param = pItemType.pOnlineService
            cell.btnShowAll.addGestureRecognizer(tapGuesture)
            cell.collectionView.reloadData()
            return cell
        case 3:
            let cell: OnlineJobCell = tableView.dequeueReusableCell(withIdentifier: "onlineJobCell", for: indexPath) as! OnlineJobCell
            cell.collectionView.tag = indexPath.row
            cell.delegate = self
            cell.onlineJobs = self.onlineJobs
            let tapGuesture = MyTapGesture(target: self, action: #selector(self.onClickShowAll(guesture:)))
            tapGuesture.param = pItemType.pOnlineJob
            cell.btnShowAll.addGestureRecognizer(tapGuesture)
            cell.collectionView.reloadData()
            return cell
        case 4:
            let cell: PopularServiceCell = tableView.dequeueReusableCell(withIdentifier: "popularServiceCell", for: indexPath) as! PopularServiceCell
            cell.collectionView.tag = indexPath.row
            cell.delegate = self
            cell.popularServices = self.popularServices
            let tapGuesture = MyTapGesture(target: self, action: #selector(self.onClickShowAll(guesture:)))
            tapGuesture.param = pItemType.pPopularService
            cell.btnShowAll.addGestureRecognizer(tapGuesture)
            cell.collectionView.reloadData()
            return cell
        case 5:
            let cell: PopularJobCell = tableView.dequeueReusableCell(withIdentifier: "popularJobCell", for: indexPath) as! PopularJobCell
            cell.lblTitle.text = "Popular Jobs"
            cell.collectionView.tag = indexPath.row
            cell.delegate = self
            cell.popularJobs = self.popularJobs
            cell.isPopular = true
            let tapGuesture = MyTapGesture(target: self, action: #selector(self.onClickShowAll(guesture:)))
            tapGuesture.param = pItemType.pPopularJob
            cell.btnShowAll.addGestureRecognizer(tapGuesture)
            cell.collectionView.reloadData()
            return cell
        case 6:
            let cell: LocalServiceCell = tableView.dequeueReusableCell(withIdentifier: "localServiceCell", for: indexPath) as! LocalServiceCell
            cell.localServices = self.localServices
            cell.collectionView.tag = indexPath.row
            cell.delegate = self
            let tapGuesture = MyTapGesture(target: self, action: #selector(self.onClickShowAll(guesture:)))
            tapGuesture.param = pItemType.pLocalService
            cell.btnShowAll.addGestureRecognizer(tapGuesture)
            cell.collectionView.reloadData()
            return cell
        case 7:
            let cell: PopularJobCell = tableView.dequeueReusableCell(withIdentifier: "popularJobCell", for: indexPath) as! PopularJobCell
            cell.lblTitle.text = "Local Jobs"
            cell.collectionView.tag = indexPath.row
            cell.delegate = self
            cell.popularJobs = self.localJobs
            cell.isPopular = false
            let tapGuesture = MyTapGesture(target: self, action: #selector(self.onClickShowAll(guesture:)))
            tapGuesture.param = pItemType.pLocalJob
            cell.btnShowAll.addGestureRecognizer(tapGuesture)
            cell.collectionView.reloadData()
            return cell
        case 8:
            let cell: BestSellerCell = tableView.dequeueReusableCell(withIdentifier: "bestSellerCell", for: indexPath) as! BestSellerCell
            cell.btnShowAll.isHidden = true
            cell.arrSellers = self.bestSellers
            cell.delegate = self
            cell.collectionView.reloadData()
            
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension ExplorePublicViewController: HomeServiceDelegate{
    
    func didClickPlayVideo(url: String) {
        self.playVideo(url: url)
    }
    
    func didSelectedBanner(index: Int) {
        let bannerItem = self.arrBanner[index]
        let type = bannerItem["type"] as! String
        if type == "category"{
            let categoryId = bannerItem["id"] as! String
            let storyboard = UIStoryboard(name: "Public", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "searchResultViewController") as! SearchResultViewController
            vc.isPublic = true
            vc.categoryId = categoryId
            vc.type = "services"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ExplorePublicViewController: PopularCagegoryDelegate{
    
    func didSelectedPopularCategory(index: Int) {
        let item = self.popularCategories[index]
        let type = item["type"] as! String
        if type == "category"{
            let categoryId = item["id"] as! String
            let storyboard = UIStoryboard(name: "Public", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "searchResultViewController") as! SearchResultViewController
            vc.isPublic = true
            vc.categoryId = categoryId
            vc.type = "services"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didClickPlayVideoOnPopular(url: String) {
        self.playVideo(url: url)
    }
}

extension ExplorePublicViewController: OnlineServiceDelegate {
    func didSelectedOnlineService(index: Int) {
        let item = self.onlineServices[index] as [String: Any]
        let serviceId = item["id"] as! String
        let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
        vc.serviceId = serviceId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didClickPlayVideoOnOnlineService(url: String) {
        self.playVideo(url: url)
    }
}

extension ExplorePublicViewController: OnlineJobDelegate {
    func didSelectedOnlineJob(index: Int) {
        if let userDict = UserCache.sharedInstance.getUserCredentials() {
            if let val = userDict[kUserCredentials.kLoginType] as? String {
                if val == "E" || val == "F" {
                    if let registered = userDict[kUserCredentials.kCompletedRegistration] as? Bool, registered == true {
                        let item = self.onlineJobs[index]
                        self.gotoRequestView(requestId: item["id"] as! String)
                    } else {
                        self.index = index
                        UserDefaults.standard.set("online", forKey: "jobType")
                        var job = [String: Any]()
                        job = self.onlineJobs[index]
                        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                        loginVC.requestId = job["id"] as! String
                        self.navigationController?.pushViewController(loginVC, animated: false)
                    }
                }
            }
        } else {
            self.index = index
            UserDefaults.standard.set("online", forKey: "jobType")
            var job = [String: Any]()
            job = self.onlineJobs[index]
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            loginVC.requestId = job["id"] as! String
            self.navigationController?.pushViewController(loginVC, animated: false)
        }
    }
    
    func didClickPlayVideoFromOnlineJob(url: String) {
        self.playVideo(url: url)
    }
    
    
}

extension ExplorePublicViewController: PopularServiceDelegate{
    
    func didSelectedPopularService(index: Int) {
        let item = self.popularServices[index] as [String: Any]
        let serviceId = item["id"] as! String
        let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
        vc.serviceId = serviceId
        self.navigationController?.pushViewController(vc, animated: true)        
    }
    
    func didClickPlayVideoOnPopularService(url: String) {
         self.playVideo(url: url)
    }
}

extension ExplorePublicViewController: PopularJobDelegate{
    func didClickPlayVideoFromJob(url: String) {
       self.playVideo(url: url)
    }
    
    func didSelectedJob(index: Int, isPopular: Bool) {
        if let userDict = UserCache.sharedInstance.getUserCredentials() {
            if let val = userDict[kUserCredentials.kLoginType] as? String {
                if val == "E" || val == "F" {
                    if let registered = userDict[kUserCredentials.kCompletedRegistration] as? Bool, registered == true {
                        var item = [String:Any]()
                        if isPopular {
                            item = self.popularJobs[index]
                        } else {
                            item = self.localJobs[index]
                        }
                        self.gotoRequestView(requestId: item["id"] as! String)
                    } else {
                        self.index = index
                        var job = [String: Any]()
                        if isPopular {
                            UserDefaults.standard.set("popular", forKey: "jobType")
                            job = self.popularJobs[index]
                        }else {
                            UserDefaults.standard.set("local", forKey: "jobType")
                            job = self.localJobs[index]
                        }
                        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                        loginVC.requestId = job["id"] as! String
                        self.navigationController?.pushViewController(loginVC, animated: false)
                    }
                }
            }
        } else {
            self.index = index
            var job = [String: Any]()
            if isPopular {
                UserDefaults.standard.set("popular", forKey: "jobType")
                job = self.popularJobs[index]
            }else {
                UserDefaults.standard.set("local", forKey: "jobType")
                job = self.localJobs[index]
            }
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            loginVC.requestId = job["id"] as! String
            self.navigationController?.pushViewController(loginVC, animated: false)
        }
    }
    
}

extension ExplorePublicViewController: LocalServiceDelegate{
    func didClickPlayVideoFromLocalService(url: String) {
        self.playVideo(url: url)
    }
    
    func didSelectedFromLocalService(index: Int) {
        let item = self.localServices[index] as [String: Any]
        let serviceId = item["id"] as! String
        let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
        vc.serviceId = serviceId
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ExplorePublicViewController: BestSellerDelegate{
    func didSelectedSeller(index: Int) {
        
        if let userDict = UserCache.sharedInstance.getUserCredentials() {
            if let val = userDict[kUserCredentials.kLoginType] as? String {
                if val == "E" || val == "F" {
                    if let registered = userDict[kUserCredentials.kCompletedRegistration] as? Bool, registered == true {
                        let seller = bestSellers[index]
                        let userId = seller["userId"] as! String
                        UserCache.sharedInstance.setProfileUser(loginUser: false, userId: userId)
                        let storyboard = UIStoryboard(name: "Account", bundle: nil)
                        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
                        navigationController?.pushViewController(userProfileVC, animated:true)
                    } else {
                        self.index = index
                        UserDefaults.standard.set("bestseller", forKey: "jobType")
                        let seller = bestSellers[index]
                        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                        loginVC.userId = seller["userId"] as! String
                        self.navigationController?.pushViewController(loginVC, animated: false)
                    }
                }
            }
        } else {
            self.index = index
            UserDefaults.standard.set("bestseller", forKey: "jobType")
            let seller = bestSellers[index]
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            loginVC.userId = seller["userId"] as! String
            self.navigationController?.pushViewController(loginVC, animated: false)
        }
    }
}
