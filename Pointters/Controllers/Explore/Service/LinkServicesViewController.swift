//
//  LinkServicesViewController.swift
//  Pointters
//
//  Created by Mac on 2/18/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import AVFoundation

protocol LinkServiceDelegate {
    func selectLinkService(selected : UserService)
}

class LinkServicesViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchView: UIView!
    @IBOutlet var tfSearch: UITextField!
    
    var lastId = ""
    var currentPage = 1
    var totalPages = 0
    var loginUserId = ""
    var toUserId = ""
    
    var categoryId = ""
    
    var linkDelegate : LinkServiceDelegate?
    
    var arrUserServices = [[String:Any]]()
    var searchFlag = false
    var searchString = ""
    var isFromRequest = false

    override func viewDidLoad() {
        super.viewDidLoad()
        loginUserId = UserCache.sharedInstance.getAccountData().id
        initUI()
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
        searchView.layer.cornerRadius = 10.0
        searchView.layer.masksToBounds = true
        tfSearch.clearButtonMode = .always
    }
    
    func initData() {
        if isFromRequest {
            callGetUserServicesAPI(inited: true, userId: self.toUserId, lastId: self.lastId)
        } else {
            callGetUserServicesAPI(inited: true, userId: self.loginUserId, lastId: self.lastId)
        }
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // move to profile page
    @objc func btnNameTapped(sender: UIButton) {
        UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        navigationController?.pushViewController(userProfileVC, animated:true)
    }
    
    @objc func btnLinkTapped(sender: UIButton) {
        let itemService = UserService.init(dict: arrUserServices[sender.tag])
        if linkDelegate != nil {
            linkDelegate?.selectLinkService(selected: itemService)
        }
        navigationController?.popViewController(animated: true)
    }
    
    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    func callGetUserServicesAPI(inited: Bool, userId: String, lastId: String) {
        if inited {
            PointtersHelper.sharedInstance.startLoader(view: view)
            self.lastId = ""
        }
        ApiHandler.callGetUserServices(userId: userId, categoryId: self.categoryId, lastId: self.lastId, withCompletionHandler: { (result,statusCode,response,error) in
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
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
            self.tableView.reloadData()
        })
    }
    
    func callGetSearchServicesAPI(filterString:String, page: Int) {
        if page == 1 {
            PointtersHelper.sharedInstance.startLoader(view: view)
        }
        ApiHandler.callGetLinkSearchServices(filterString: filterString, categoryId: self.categoryId, page: page, withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            self.view.endEditing(true)
            if page == 1 {
                self.arrUserServices.removeAll()
            }
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [String:Any]
                    let services = responseDict["docs"] as! [[String:Any]]
                    for serviceDict in services {
                        self.arrUserServices.append(serviceDict)
                    }
                    self.tableView.reloadData()
                } else {
                    let responseDict = response.value as! [String:Any]
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
            
        })
        
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
extension LinkServicesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrUserServices.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        let headerLabel = UILabel(frame: CGRect(x: 13, y: 10, width: tableView.bounds.size.width - 30, height: 20))
        headerLabel.font = UIFont(name: "Helvetica", size: 14)
        headerLabel.textColor = UIColor.getCustomGrayTextColor()
        headerLabel.text = "YOUR SERVICES"
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "linkServicesCell") as! LinkServiceCell
        let itemService = UserService.init(dict: self.arrUserServices[indexPath.row])
        cell.imgService.sd_imageTransition = .fade
        cell.imgService.sd_setImage(with: URL(string: itemService.service.media.fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
        
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
        
        cell.btnName.setTitle(UserCache.sharedInstance.getAccountData().firstName + " " + UserCache.sharedInstance.getAccountData().lastName, for: .normal)
        cell.btnName.addTarget(self, action: #selector(btnNameTapped(sender:)), for: .touchUpInside)
        cell.btnClickLink.tag = indexPath.row
        cell.btnClickLink.addTarget(self, action: #selector(btnLinkTapped(sender:)), for: .touchUpInside)
        return cell
    }
}

// UITableViewDelegate
extension LinkServicesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if searchFlag == false {
            if (indexPath.row == arrUserServices.count - 1) && (self.currentPage - 1 < self.totalPages) {
                if isFromRequest {
                    callGetUserServicesAPI(inited: false, userId: self.toUserId, lastId: self.lastId)
                } else {
                    callGetUserServicesAPI(inited: false, userId: self.loginUserId, lastId: self.lastId)
                }
            }
        } else {
            if (indexPath.row == arrUserServices.count - 1) && self.searchString != "" {
                self.currentPage += 1
                callGetSearchServicesAPI(filterString: self.searchString, page: self.currentPage)
            }
        }
    }
    
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
}

extension LinkServicesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text == "" {
            self.lastId = ""
            searchFlag = false
            if isFromRequest {
                callGetUserServicesAPI(inited: false, userId: self.toUserId, lastId: self.lastId)
            } else {
                callGetUserServicesAPI(inited: false, userId: self.loginUserId, lastId: self.lastId)
            }
        } else {
            searchFlag = true
            self.currentPage = 1
            self.searchString = textField.text!
            self.callGetSearchServicesAPI(filterString:textField.text!, page: 1)
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.lastId = ""
        searchFlag = false
        if isFromRequest {
            callGetUserServicesAPI(inited: false, userId: self.toUserId, lastId: self.lastId)
        } else {
            callGetUserServicesAPI(inited: false, userId: self.loginUserId, lastId: self.lastId)
        }
        return true
    }

}




