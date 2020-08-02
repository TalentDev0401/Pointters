//
//  InitialSearchViewController.swift
//  Pointters
//
//  Created by dreams on 10/1/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import CoreLocation

class InitialSearchViewController: UIViewController {

    @IBOutlet weak var searchBarKey: UISearchBar!
    @IBOutlet weak var searchBarLocation: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var isPublic = true
    var recentAll = false
    
    let sectionButtonTag = 10000
    
    var headerArray = ["RECENT SEARCHES", "POPULAR SERVICE CATEGORIES", "POPULAR JOB CATEGORIES", "POPULAR USERS"]
    var headerArrayWithKey = ["RECENT SEARCHES", "SERVICES", "JOBS", "USERS"]
    var recentKeyArr = [[String: Any]]()
    var showRecentKeys = true
    
    var popularServices = [[String: Any]]()
    var popularRequest = [[String: Any]]()
    var popularUsers = [[String: Any]]()
    
    var currentQuery = ""
    
    var location = Location.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        location.city = ""
        location.country = ""
        if #available(iOS 13.0, *) {
            self.searchBarLocation.searchTextField.clearButtonMode = .never
        } else {
            self.searchBarLocation.textField?.clearButtonMode = .never
        }
        self.searchBarLocation.showsCancelButton = false
        self.searchBarLocation.setImage(UIImage(named: "public_icon_filters"), for: .search, state: .normal)
        searchBarKey.becomeFirstResponder()
        tableView.tableFooterView = UIView()
        self.callInitialSearchAPI()
        self.getCurrentLocation()
    }
    
    func getCurrentLocation() {
        PointtersHelper.sharedInstance.startLoader(view: view)
        let geocoder = CLGeocoder()
        let lat:Double = UserCache.sharedInstance.getUserLatitude()!
        let lng:Double = UserCache.sharedInstance.getUserLongitude()!
        let userLocation = CLLocation(latitude: lat, longitude: lng)
        geocoder.reverseGeocodeLocation(userLocation, completionHandler: {
            placemarks, error in
            PointtersHelper.sharedInstance.stopLoader()
            if let err = error {
                self.location = Location.init()
                print(err.localizedDescription)
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    print(placemark)
                    self.location.city = placemark.locality ?? "NA"
                    self.location.country = placemark.country ?? "NA"
                    self.location.postalCode = placemark.postalCode ?? "NA"
                    self.location.province = placemark.subAdministrativeArea ?? "NA"
                    self.location.state = placemark.administrativeArea ?? ""
                    self.location.geoJson.coordinates = [userLocation.coordinate.longitude, userLocation.coordinate.latitude]
                    self.tableView.reloadData()
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
    
    //MARK:- API calls
    
    func callInitialSearchAPI() {
        self.recentKeyArr.removeAll()
        self.popularServices.removeAll()
        self.popularRequest.removeAll()
        self.popularUsers.removeAll()
        ApiHandler.callInitialExploreSearch(recentAll: self.recentAll, withCompletionHandler:{ (result,statusCode,response) in
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    
                    if responseDict["SearchString"] != nil {
                        self.recentKeyArr = responseDict["SearchString"] as! [[String: Any]]
                    }
                    
                    if responseDict["service"] != nil {
                        self.popularServices = responseDict["service"] as! [[String: Any]]
                    }
                    if responseDict["request"] != nil {
                        self.popularRequest = responseDict["request"] as! [[String: Any]]
                    }
                    if responseDict["user"] != nil && self.currentQuery != ""{
                        self.popularUsers = responseDict["user"] as! [[String: Any]]
                    }
                    
                    self.tableView.reloadData()
                }
            }
            else {
                print(response.error ?? "get service detail failure")
            }
        })
    }
    
    func callAutoCompleteResult() {
        ApiHandler.callGetAutoCompleteResult(query: self.currentQuery, withCompletionHandler:{ (result,statusCode,response) in
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [[String:Any]]
                    self.popularServices.removeAll()
                    self.popularRequest.removeAll()
                    self.popularUsers.removeAll()
                    for res in responseDict {
                        if let _ = res["type"] {
                            let type = res["type"] as! String
                            if type == "service" {
                                self.popularServices.append(res)
                            } else if type == "request" {
                                self.popularRequest.append(res)
                            } else if type == "user" {
                                self.popularUsers.append(res)
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
            else {
                print(response.error ?? "get service detail failure")
            }
        })
    }
    
    @objc func onClickSeeAll(sender: UIButton) {
        let type = sender.tag - self.sectionButtonTag
        switch type {
        case 0:
            self.recentAll = true
            self.callInitialSearchAPI()
        case 1:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "searchResultViewController") as! SearchResultViewController
            vc.isPublic = self.isPublic
            vc.searchTitle = self.currentQuery
//            if self.location.city != "" {
//                if self.currentQuery != "" {
//                    vc.searchTitle = "\(self.currentQuery), \(self.location.city)"
//                } else {
//                    vc.searchTitle = "\(self.location.city)"
//                }
//
//            }
            vc.query = self.currentQuery
            vc.type = "services"
//            vc.location = self.location
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 2:
            if self.isPublic {
                let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                loginVC.targetTapIndex = 2
                self.navigationController?.pushViewController(loginVC, animated: false)
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "searchResultViewController") as! SearchResultViewController
                vc.isPublic = self.isPublic
                vc.searchTitle = self.currentQuery
//                if self.location.city != "" {
//                    if self.currentQuery != "" {
//                        vc.searchTitle = "\(self.currentQuery), \(self.location.city)"
//                    } else {
//                        vc.searchTitle = "\(self.location.city)"
//                    }
//                }
                vc.query = self.currentQuery
                vc.type = "requests"
//                vc.location = self.location
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 3:
            if self.isPublic{
                let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                self.navigationController?.pushViewController(loginVC, animated: false)
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "searchResultViewController") as! SearchResultViewController
                vc.isPublic = self.isPublic
                vc.searchTitle = self.currentQuery
//                if self.location.city != "" {
//                    vc.searchTitle = "\(self.currentQuery), \(self.location.city)"
//                }
                vc.query = self.currentQuery
                vc.type = "users"
//                vc.location = self.location
                self.navigationController?.pushViewController(vc, animated: true)
            }
        default:
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            self.navigationController?.pushViewController(loginVC, animated: false)
            return
        }
    }
    
}

extension InitialSearchViewController: UISearchBarDelegate{
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if searchBar == self.searchBarLocation {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let locationVC = storyboard.instantiateViewController(withIdentifier: "SetLocationVC") as! SetLocationViewController
            locationVC.locationDelegate = self
            locationVC.keyword = self.location.city
            navigationController?.pushViewController(locationVC, animated:true)
            return true
        }
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar == self.searchBarKey {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.searchBarLocation.endEditing(true)
            self.searchBarLocation.text = ""
            self.location = Location.init()
            self.location.city = ""
            self.location.country = ""
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.currentQuery = searchBar.text!
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "searchResultViewController") as! SearchResultViewController
        vc.isPublic = self.isPublic
        vc.searchTitle = self.currentQuery
        if self.location.city != "" {
            if self.currentQuery != "" {
                vc.searchTitle = "\(self.currentQuery), \(self.location.city)"
            } else {
                vc.searchTitle = "\(self.location.city)"
            }
            
        }
        vc.query = self.currentQuery
        vc.type = "services"
        vc.location = self.location
     
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        print("hello")
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if searchBar == self.searchBarKey{
            let text_inputed = (text == "\n") ? "" : text
            guard let currentText = (searchBar.text as NSString?)?.replacingCharacters(in: range, with: text_inputed) else { return true }
            self.currentQuery = currentText
//            self.searchBarKey.text = currentText
            if currentText != "" {
                self.showRecentKeys = false
                callAutoCompleteResult()
            }else {
                self.showRecentKeys = true
                self.recentAll = false
                callInitialSearchAPI()
            }
            
        }

        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar == self.searchBarKey{
            if searchText == "" {
                self.currentQuery = ""
                self.showRecentKeys = true
                self.recentAll = false
                self.callInitialSearchAPI()
            }
        }
    }
}

extension InitialSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return recentKeyArr.count
        case 1:
            return self.popularServices.count
        case 2:
            return self.popularRequest.count
        case 3:
            return self.popularUsers.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (self.currentQuery != "") ? headerArray[section] : headerArrayWithKey[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if isPublic{
                return 0
            }
            return (recentKeyArr.count == 0 || !self.showRecentKeys) ? 0 : 45
        case 1:
            return (popularServices.count == 0) ? 0 : 45
        case 2:
            return (popularRequest.count == 0) ? 0 : 45
        case 3:
            return (popularUsers.count == 0) ? 0 : 45
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && self.isPublic {
            return 0
        }
        if indexPath.section == 0 && !self.showRecentKeys{
            return 0
        }else{
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 20, width: tableView.bounds.size.width - 100, height: 20))
        headerLabel.font = UIFont(name: "Helvetica", size: 14)
        headerLabel.textColor = UIColor.getCustomGrayTextColor()
        headerLabel.text = (self.currentQuery == "") ? headerArray[section] : headerArrayWithKey[section]
        headerView.addSubview(headerLabel)
        
        let frame: CGRect = tableView.frame
        let btnSeeAll = UIButton(frame: CGRect(x: frame.width - 60, y: 15, width: 60, height: 20))
        btnSeeAll.setTitle("See All", for: .normal)
        btnSeeAll.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
        btnSeeAll.setTitleColor(UIColor.getCustomLightBlueColor(), for: .normal)
        btnSeeAll.sizeToFit()
        btnSeeAll.tag = self.sectionButtonTag + section
        btnSeeAll.addTarget(self, action: #selector(self.onClickSeeAll(sender:)), for: .touchUpInside)
        headerView.addSubview(btnSeeAll)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "recentItemCell") as! SearchCell
            let recentItem = self.recentKeyArr[indexPath.row]
            cell.labelRecent.text = recentItem["name"] as? String
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "popularItemCell") as! SearchCell
            let serviceTitle = self.popularServices[indexPath.row]["name"] as! String
            cell.imageCategory.image = UIImage(named: "icon_photo_cell")
            cell.labelCategory.text = serviceTitle
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "popularItemCell") as! SearchCell
            let requestTitle = self.popularRequest[indexPath.row]["name"] as! String
            cell.labelCategory.text = requestTitle
            cell.imageCategory.image = UIImage(named: "icon_wedding_cell")
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "popularItemCell") as! SearchCell
            let requestTitle = self.popularUsers[indexPath.row]["name"] as! String
            cell.imageCategory.image = UIImage(named: "icon_entertainer_cell")
            cell.labelCategory.text = requestTitle
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBarKey.endEditing(true)
        self.searchBarLocation.endEditing(true)
        
        self.searchBarKey.showsCancelButton = true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            let recentItem = recentKeyArr[indexPath.row]
            self.currentQuery = recentItem["name"] as! String
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "searchResultViewController") as! SearchResultViewController
            vc.isPublic = self.isPublic
            vc.searchTitle = self.currentQuery
            vc.query = self.currentQuery
            if let _ = recentItem["type"] {
                vc.type = recentItem["type"] as! String
            } else {
                vc.type = "services"
            }
            self.currentQuery = ""
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "searchResultViewController") as! SearchResultViewController
            vc.isPublic = self.isPublic
            vc.searchTitle = self.currentQuery
            if self.location.city != "" {
                vc.searchTitle = "\(self.currentQuery), \(self.location.city)"
            }
            vc.query = self.currentQuery
            vc.type = "services"
            vc.location = self.location
            if let _ = self.popularServices[indexPath.row]["id"] {
                vc.categoryId = self.popularServices[indexPath.row]["id"] as! String
            }
            if let _ = self.popularServices[indexPath.row]["name"] {
                vc.searchTitle = self.popularServices[indexPath.row]["name"] as! String
                if self.currentQuery != ""{
                    if self.location.city != "" {
                        vc.searchTitle = "\(vc.searchTitle), \(self.location.city)"
                    }
                    vc.query = self.popularServices[indexPath.row]["name"] as! String
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            if isPublic {
                let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                self.navigationController?.pushViewController(loginVC, animated: false)
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "searchResultViewController") as! SearchResultViewController
                vc.isPublic = self.isPublic
                vc.searchTitle = self.currentQuery
                if self.location.city != "" {
                    vc.searchTitle = "\(self.currentQuery), \(self.location.city)"
                }
                vc.query = self.currentQuery
                vc.type = "requests"
                vc.location = self.location
                if let _ = self.popularRequest[indexPath.row]["id"] {
                    vc.categoryId = self.popularServices[indexPath.row]["id"] as! String
                }
                if let _ = self.popularRequest[indexPath.row]["name"] {
                    vc.searchTitle = self.popularRequest[indexPath.row]["name"] as! String
                    if self.currentQuery != ""{
                        if self.location.city != "" {
                            vc.searchTitle = "\(vc.searchTitle), \(self.location.city)"
                        }
                        vc.query = self.popularRequest[indexPath.row]["name"] as! String
                    }
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case 3:
            if isPublic {
                let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                if let _ = self.popularUsers[indexPath.row]["id"] {
                    loginVC.userId = self.popularUsers[indexPath.row]["id"] as! String
                }
                self.navigationController?.pushViewController(loginVC, animated: false)
            }else {
                let storyboard = UIStoryboard.init(name: "Account", bundle: nil)
                let strOtherId = self.popularUsers[indexPath.row]["id"] as! String
                if strOtherId == UserCache.sharedInstance.getAccountData().id {
                    UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
                } else {
                    UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
                }
                let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
                self.navigationController?.pushViewController(userProfileVC, animated: true)
            }
        default:
            return
        }
    }
}

extension InitialSearchViewController: SetLocationVCDelegate {
    func selectedLocation(location: Location) {
        self.location = location
        self.searchBarLocation.text = self.location.city
    }
    
    func backWithStreet(street: String) {
        self.location = Location.init()
        self.location.city = ""
        self.location.country = ""
        self.searchBarLocation.text = self.location.city
    }
}

