//
//  LikeWatchViewController.swift
//  Pointters
//
//  Created by Mac on 2/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import SDWebImage
import CoreLocation

class LikeWatchViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var lblMenuTitle: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblMessage: UILabel!
    
    var userLocation: CLLocation?
    var arrServices = [[String:Any]]()
 
    var limitCnt = 0
    var totalCnt = 0
    var lastDocId = ""
    
    var likeWatchType = false
    var loginUserId = ""
    let profileIndex = 100
    
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
        
        likeWatchType = UserDefaults.standard.bool(forKey: "like_watch_type")
        lblMenuTitle.text = likeWatchType ? "Liked" : "Watching"
    }
    
    func initData() {
        let lat:Double = UserCache.sharedInstance.getUserLatitude()!
        let lng:Double = UserCache.sharedInstance.getUserLongitude()!
        userLocation = CLLocation(latitude: lat, longitude: lng)
        
        loginUserId = UserCache.sharedInstance.getAccountData().id
        
        if likeWatchType {
            callGetLikedApi(inited: true, lastID: "")
        } else {
            callGetWatchingApi(inited: true, lastID: "")
        }
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func btnNameTapped(sender:UIButton) {
        let result = UserService.init(dict: arrServices[sender.tag - profileIndex])
        let strOtherId = result.user.id
        
        if strOtherId != "" && strOtherId == loginUserId {
            UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
        } else {
            UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
        }
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    //*******************************************************//
    //                 MARK: - Call API Method               //
    //*******************************************************//
    
    func callGetWatchingApi(inited: Bool, lastID: String){
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetWatchingServices(lastId: lastID, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if inited {
                self.arrServices.removeAll()
            }
            
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    
                    self.limitCnt = 10
                    self.totalCnt = responseDict["total"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String
                    
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for watching in arr {
                            self.arrServices.append(watching)
                        }
                    }
                }
            }
            else {
                print(response.error ?? "watching failure")
            }
            
            self.tableView.reloadData()
        })
    }
    
    func callGetLikedApi(inited: Bool, lastID: String){
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetLikedServices(lastId: lastID, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if inited {
                self.arrServices.removeAll()
            }
            
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    
                    self.limitCnt = responseDict["limit"] as! Int
                    self.totalCnt = responseDict["total"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String
                    
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for liked in arr {
                            self.arrServices.append(liked)
                        }
                    }
                }
            }
            else {
                print(response.error ?? "liked failure")
            }
            
            self.tableView.reloadData()
        })
    }
    
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITableViewDataSource
extension LikeWatchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        self.lblMessage.isHidden = true
        self.tableView.isHidden = false
        
        if arrServices.count > 0 {
            return arrServices.count
        }
        else {
            lblMessage.text = (likeWatchType) ? "No liked service found" : "No watched service found"
            self.lblMessage.isHidden = false
            self.tableView.isHidden = true
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 123.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "watchCell") as! WatchCell
        let result = UserService.init(dict: arrServices[indexPath.section])
        
        cell.imgService.layer.cornerRadius = 5.0
        cell.imgService.layer.masksToBounds = true
        
        if result.service.media.fileName != "" && result.service.media.mediaType != "video" {
            cell.imgService.sd_imageTransition = .fade
            cell.imgService.sd_setImage(with: URL(string: result.service.media.fileName)!, placeholderImage: UIImage(named:"photo_placeholder"))
        } else {
            cell.imgService.image = UIImage(named:"photo_placeholder")
        }
        
        cell.lblDesc.text = (result.service.desc != "") ? result.service.desc : "NA"
        
        let strSymbol = (result.service.prices.currencySymbol != "") ? result.service.prices.currencySymbol : "$"
        cell.lblPrice.text = strSymbol + String(format:"%.2f", result.service.prices.price)

        let strUnit = (result.service.prices.timeUnitOfMeasure != "hour") ? result.service.prices.timeUnitOfMeasure : "hr"
        cell.lblTime.text = "Per " + String(format:"%d", result.service.prices.time) + " " + strUnit
        
        var strKm = ""
        if result.service.location.geoJson.coordinates.count > 1 {
            let serviceLocation = CLLocation(latitude: result.service.location.geoJson.coordinates[0], longitude: result.service.location.geoJson.coordinates[1])
            let kilometers = (userLocation?.distance(from: serviceLocation))! / 1000
            strKm = String(format: "%.2f", kilometers) + "km"
        }
        if strKm != "" {
            cell.lblAddress.text = strKm + " " + result.service.location.city + ", " + result.service.location.state
        } else {
            cell.lblAddress.text = "Online"
        }
        let item = arrServices[indexPath.row]
        if item.keys.contains("promoted") {
            cell.iconPromotion.isHidden = item["promoted"] as! Bool == false
            cell.lblPromotion.isHidden = item["promoted"] as! Bool == false
        }else{
            cell.iconPromotion.isHidden = true
            cell.lblPromotion.isHidden = true
        }
        let strName = (result.user.firstName != "") ? result.user.firstName : "NA"
        cell.btnName.setTitle(strName, for: .normal)
        cell.btnName.tag = profileIndex + indexPath.section
        cell.btnName.addTarget(self, action: #selector(btnNameTapped(sender:)), for: .touchUpInside)
        
        cell.lblPoint.text = String(format:"%d", result.pointValue)
        cell.lblBusiness.text = String(format:"%d", result.numOrders)
        cell.lblRating.text = String(format:"%.1f", result.avgRating) + "%"
        
        return cell
    }
}

// UITableViewDelegate
extension LikeWatchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == arrServices.count-1) && (self.totalCnt > self.limitCnt) {
            if likeWatchType {
                callGetLikedApi(inited: false, lastID: self.lastDocId)
            } else {
                callGetWatchingApi(inited: false, lastID: self.lastDocId)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = UserService.init(dict: arrServices[indexPath.section])
        let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
        let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
        serviceDetailVC.serviceId = result.service.id
        navigationController?.pushViewController(serviceDetailVC, animated: true)
    }
}
