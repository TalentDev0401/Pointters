//
//  SendServicesViewController.swift
//  Pointters
//
//  Created by Mac on 2/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import AVFoundation

protocol SendServiceDelegate {
    func selectSendService(selected:[String:Any], serviceType: Bool)
    func returnFromSendService(reload: Bool)
}

class SendServicesViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    var sendDelegate : SendServiceDelegate?
    
    var lastId = ""
    var currentPage = 1
    var totalPages = 0
    var loginUserId = ""
    var toUserId = ""
    var filterString = ""
    var searchFlag = false
    
    var arrUserServices = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginUserId = UserCache.sharedInstance.getAccountData().id
        initUI()
        initData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        searchBar.textField?.clearButtonMode = .always
    }
    
    func initData() {
        callGetUserServicesAPI(inited: true, lastId: self.lastId)
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        if self.sendDelegate != nil {
            self.sendDelegate?.returnFromSendService(reload: false)
        }
        navigationController?.popViewController(animated: true)
    }
    
    // move to profile page
    @objc func btnNameTapped(sender: UIButton) {
        UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        navigationController?.pushViewController(userProfileVC, animated:true)
    }
    
    @objc func btnSendTapped(sender: UIButton) {
        callSendServiceAPI(fromUserId: self.loginUserId, toUserId: self.toUserId, service: arrUserServices[sender.tag])
    }
    
    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    func callGetUserServicesAPI(inited: Bool, lastId: String) {
        if inited {
            PointtersHelper.sharedInstance.startLoader(view: view)
            self.lastId = ""
        }
        ApiHandler.callGetUserServices(userId: "", categoryId: "", lastId: self.lastId, withCompletionHandler: { (result,statusCode,response, error) in
            if inited {
                PointtersHelper.sharedInstance.stopLoader()
                self.arrUserServices.removeAll()
            }
            self.view.endEditing(true)
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.currentPage = responseDict["page"] as! Int + 1
                    self.totalPages = responseDict["pages"] as! Int
                    self.lastId = responseDict["lastDocId"] as! String
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for itemService in arr {
                            self.arrUserServices.append(itemService)
                        }
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
            self.tableView.reloadData()
        })
    }
    
    func callGetSearchServicesAPI(filterString:String, page: Int) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        self.arrUserServices.removeAll()
        ApiHandler.callGetSendSearchServices(filterString: filterString, page: page, withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            self.view.endEditing(true)
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [[String:Any]]
                    for val in responseDict {
                        var serviceDict = val["_source"] as! [String:Any]
                        serviceDict["id"] = val["_id"] as! String
                        self.arrUserServices.append(serviceDict)
                    }
                    self.tableView.reloadData()
                } else {
                    let responseDict = response.value as! [String:Any]
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                    self.tableView.reloadData()
                }
            } else {
                print(response.error ?? "")
                self.tableView.reloadData()
            }
            
        })
    }
    
    func callSendServiceAPI(fromUserId: String, toUserId: String, service: [String:Any]) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        if searchFlag == false {
            let itemService = UserService.init(dict: service)
            ApiHandler.callSendService(fromUserId: fromUserId, toUserId: toUserId, serviceId: itemService.service.id, withCompletionHandler: { (result,statusCode,response) in
                PointtersHelper.sharedInstance.stopLoader()
                if result == true {
                    let responseDict = response.value as! [String:Any]
                    if statusCode == 200 {
//                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Service successfully sent!", buttonTitles: ["OK"], viewController: self, completion: { (index) in
//                            if index == 0 {
//                                if self.sendDelegate != nil {
//                                    self.sendDelegate?.selectSendService(selected: service)
//                                }
//                                self.navigationController?.popViewController(animated: true)
//                            }
//                        })
                        if self.sendDelegate != nil {
                            self.sendDelegate?.selectSendService(selected: service, serviceType: self.searchFlag)
                        }
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                    }
                } else {
                    print(response.error ?? "")
                }
            })
        } else {
            let itemService = Service.init(dict: service)
            ApiHandler.callSendService(fromUserId: fromUserId, toUserId: toUserId, serviceId: itemService.id, withCompletionHandler: { (result,statusCode,response) in
                PointtersHelper.sharedInstance.stopLoader()
                if result == true {
                    let responseDict = response.value as! [String:Any]
                    if statusCode == 200 {
//                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Service successfully sent!", buttonTitles: ["OK"], viewController: self, completion: { (index) in
//                            if index == 0 {
//                                if self.sendDelegate != nil {
//                                    self.sendDelegate?.selectSendService(selected: service, serviceType: self.searchFlag)
//                                }
//                                self.navigationController?.popViewController(animated: true)
//                            }
//                        })
                        if self.sendDelegate != nil {
                            self.sendDelegate?.selectSendService(selected: service, serviceType: self.searchFlag)
                        }
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                    }
                } else {
                    print(response.error ?? "")
                }
            })
        }
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
    
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITableViewDataSource
extension SendServicesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrUserServices.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground

        let headerLabel = UILabel(frame: CGRect(x: 13, y: 25, width: tableView.bounds.size.width - 30, height: 20))
        headerLabel.font = UIFont(name: "Helvetica", size: 14)
        headerLabel.textColor = UIColor.getCustomGrayTextColor()
        headerLabel.text = "YOUR SERVICES"
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sendServicesCell") as! SendServicesCell
        if searchFlag == false {
            let itemService = UserService.init(dict: self.arrUserServices[indexPath.row])
            
            if itemService.service.media.mediaType == "image" {
                if itemService.service.media.fileName != "" {
                    cell.imgService.sd_imageTransition = .fade
                    cell.imgService.sd_setImage(with: URL(string: itemService.service.media.fileName)!, placeholderImage: UIImage(named:"photo_placeholder"))
                }
            } else {
                if itemService.service.media.fileName != "" {
                    let thumbImage = generateThumbnailForVideoAtURL(filePathLocal: itemService.service.media.fileName as NSString)
                    cell.imgService.image = thumbImage
                }
            }
            
            cell.lblDesc.text = itemService.service.tagline
            cell.lblPrice.text = itemService.service.prices.currencySymbol + String(format:"%.2f", itemService.service.prices.price)
            cell.lblTime.text = "Per " + String(format: "%d", itemService.service.prices.time) + itemService.service.prices.timeUnitOfMeasure
        } else {
            let itemService = Service.init(dict: self.arrUserServices[indexPath.row])
            if itemService.media.mediaType == "image" {
                if itemService.media.fileName != "" {
                    cell.imgService.sd_imageTransition = .fade
                    cell.imgService.sd_setImage(with: URL(string: itemService.media.fileName)!, placeholderImage: UIImage(named:"photo_placeholder"))
                }
            } else {
                if itemService.media.fileName != "" {
                    let thumbImage = generateThumbnailForVideoAtURL(filePathLocal: itemService.media.fileName as NSString)
                    cell.imgService.image = thumbImage
                }
            }
            cell.lblDesc.text = itemService.tagline
            cell.lblPrice.text = itemService.prices.currencySymbol + String(format:"%.2f", itemService.prices.price)
            cell.lblTime.text = "Per " + String(format: "%d", itemService.prices.time) + itemService.prices.timeUnitOfMeasure
        }
        cell.btnName.setTitle(UserCache.sharedInstance.getAccountData().firstName + " " + UserCache.sharedInstance.getAccountData().lastName, for: .normal)
        cell.btnName.addTarget(self, action: #selector(btnNameTapped(sender:)), for: .touchUpInside)
        cell.btnSend.tag = indexPath.row
        cell.btnSend.addTarget(self, action: #selector(btnSendTapped(sender:)), for: .touchUpInside)
        return cell
    }
}

// UITableViewDelegate
extension SendServicesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
        if searchFlag == false {
            let itemService = UserService.init(dict: self.arrUserServices[indexPath.row])
            let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
            serviceDetailVC.serviceId = itemService.service.id
            navigationController?.pushViewController(serviceDetailVC, animated: true)
        } else {
            let itemService = Service.init(dict: self.arrUserServices[indexPath.row])
            let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
            serviceDetailVC.serviceId = itemService.id
            navigationController?.pushViewController(serviceDetailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if searchFlag == false {
            if (indexPath.row == arrUserServices.count - 1) && (self.currentPage - 1 < self.totalPages) {
                callGetUserServicesAPI(inited: false, lastId: self.lastId)
            }
        }
    }
}

extension SendServicesViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchFlag = false
            callGetUserServicesAPI(inited: true, lastId: "")
        }else{
            searchFlag = true
            self.callGetSearchServicesAPI(filterString:searchBar.text!, page: 1)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0
        {
            searchFlag = false
            callGetUserServicesAPI(inited: true, lastId: "")
        }
    }
}


