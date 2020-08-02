//
//  TagServiceViewController.swift
//  Pointters
//
//  Created by Mac on 2/22/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol TagServiceDelegate {
    func selectTagService(selected : Service)
}

class TagServiceViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var searchView: UIView!
    @IBOutlet var tfSearch: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var btnDone: UIButton!
    
    var tagDelegate : TagServiceDelegate?
    var arrServices = [Service]()
    var arrCheckStatus = [Bool]()
    
    var limitCnt = 10
    var totalCnt = 0
    var strKey = ""
    
    var isSearch = false
    var selIndex = -1
    
    var isReachedLast = false
    
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        self.callGetTagServicesApi(inited: true, searchKey: "", lastNum: currentPage)
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
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        
        searchView.layer.cornerRadius = 10.0
        searchView.layer.masksToBounds = true
        
        btnDone.alpha = 0.3
        btnDone.isUserInteractionEnabled = false
    }
    
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnCancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        if tagDelegate != nil && selIndex >= 0 {
            let dictTags = arrServices[selIndex]
            tagDelegate?.selectTagService(selected: dictTags)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    func callGetTagServicesApi(inited: Bool, searchKey: String, lastNum: Int) {
        if inited {
            arrServices.removeAll()
            arrCheckStatus.removeAll()
            btnDone.alpha = 0.3
            btnDone.isUserInteractionEnabled = false
        }
        
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callSearchTagServices(query: searchKey, limitCnt: limitCnt, lastNo: lastNum, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if result == true {
                if statusCode == 200 {
                    let responseDict = response.value as! [[String:Any]]
                    if responseDict.count == 0 {
                        self.isReachedLast = true
                    } else {
                        self.isReachedLast = false
                        self.currentPage = self.currentPage + 1
                        for tagService in responseDict {
                            if(tagService.keys.contains("service")){
                                self.arrServices.append(Service.init(dict: tagService["service"] as! [String : Any]))
                                self.arrCheckStatus.append(false)
                            }
                        }
                    }
                } else {
                    self.isReachedLast = true
                }
            }
            else {
                self.isReachedLast = true
                print(response.error ?? "")
            }
            
            self.tableView.reloadData()
        })
    }

}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITextFieldDelegate
extension TagServiceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.strKey = textField.text!
        
        isSearch = true
        lblMessage.text = ""
        self.isReachedLast = false
        callGetTagServicesApi(inited: true, searchKey: self.strKey, lastNum: 0)
    }
}

// UITableViewDataSource
extension TagServiceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        lblMessage.isHidden = true
        tableView.isHidden = false
        
        if arrServices.count > 0 {
            return arrServices.count
        }
        else {
            tableView.isHidden = true
            lblMessage.isHidden = false
            
            if isSearch {
                lblMessage.text = "No service found or user"
            } else {
                lblMessage.text = "Enter a search key"
            }
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20.0
        } else {
            return 8.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        if section == 0 {
            let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width - 32, height: 20))
            headerLabel.font = UIFont(name: "Helvetica", size: 13)
            headerLabel.textColor = UIColor.getCustomGrayTextColor()
            headerLabel.text = "SUGGETIONS"
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagServiceCell") as! TagServiceCell
        let itemService = arrServices[indexPath.section]
        cell.layer.cornerRadius = 10.0
        cell.layer.masksToBounds = true
        
        cell.imgService.layer.cornerRadius = 3.0
        cell.imgService.layer.masksToBounds = true
        cell.imgService.sd_imageTransition = .fade
        cell.imgService.sd_setImage(with: URL(string: itemService.media.fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
        
        cell.lblDesc.text = itemService.tagline
        cell.lblPrice.text = "\(itemService.prices.currencySymbol)\(itemService.prices.price)"
        cell.lblWorkTime.text = "Per \(itemService.prices.time)\(itemService.prices.timeUnitOfMeasure)"
        let itemSeller = itemService.seller
        if itemSeller.keys.contains("firstName"){
            cell.btnName.setTitle("\(itemSeller["firstName"] as! String) \(itemSeller["lastName"] as! String)", for: .normal)
        }else {
            cell.btnName.setTitle("", for: .normal)
        }
        cell.imgCheck.isHidden = (arrCheckStatus[indexPath.section]) ? false : true
        
        return cell
    }
}

// UITableViewDelegate
extension TagServiceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == arrServices.count-1) {
            if (!self.isReachedLast) {
                callGetTagServicesApi(inited: false, searchKey: self.strKey, lastNum: self.currentPage)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selIndex = indexPath.section
        for index in 0..<arrCheckStatus.count {
            if index == indexPath.section {
                arrCheckStatus[index] = true
            } else {
                arrCheckStatus[index] = false
            }
        }
        
        btnDone.alpha = 1.0
        btnDone.isUserInteractionEnabled = true
        tableView.reloadData()
//        if tagDelegate != nil && selIndex >= 0 {
//            let dictTags = arrServices[selIndex]
//            tagDelegate?.selectTagService(selected: dictTags)
//        }
//        dismiss(animated: true, completion: nil)
    }
}
