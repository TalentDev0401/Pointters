//
//  SendRequestViewController.swift
//  Pointters
//
//  Created by Billiard ball on 22.06.2020.
//  Copyright © 2020 Kenji. All rights reserved.
//

import UIKit

protocol SendRequestDelegate {
    func selectSendRequest(request:[String:Any])
    func returnFromRequest(reload: Bool)
    func selectSendRequestOffer(selId:String, selPrice:[String:Any], linkedService: [String:Any], link:Bool)
    func returnFromSendRequestOffer(reload: Bool)
}

class SendRequestViewController: UIViewController {

    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonSend: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    
    var sendRequestDelegate: SendRequestDelegate?
    var isJobOffer = false
    
    var requestId = ""
    var loginUserId = ""
    var buyerId = ""
    var sellerId = ""
    var offerId = ""
    var requestDescription = "I need ..."

    var serviceId = ""
    var isLinkService = false
    var linkCellCount = 1
    var linkService = Service.init()
    
    var pageFlag = 0  // 0 -> from explore job, 1-> from new request, 2-> from edit request
    var requestAgain: Bool = false
    var snapPhotos = [Media]()
    var categoryId = ""
    var isEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginUserId = UserCache.sharedInstance.getAccountData().id
        initUI()
        if isJobOffer {
            self.navTitle.text = "View Request"
            callGetRequestAPI(requestId: self.requestId)
        } else {
            if isEdit {
                self.navTitle.text = "Send Request"
                callGetRequestAPI(requestId: self.requestId)
            }
        }
    }
    
    // MARK: - Private methods
    
    func initUI(){
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        
        if isJobOffer {
            buttonDelete.isHidden = true
        } else {
            if requestId == "" {
                buttonDelete.isHidden = true
            } else {
                buttonDelete.isHidden = false
            }
        }
                
        if isJobOffer {
            if isEdit {
                buttonSend.setTitle("Edit Offer", for: .normal)
            } else {
                buttonSend.setTitle("Send Offer", for: .normal)
            }
        }
        validateMandatoryFields()
    }
    
    @objc func btnDeleteTapped(sender: UIButton) {
        isLinkService = false
        linkCellCount = 1
        linkService = Service.init()
        tableView.reloadData()
        validateMandatoryFields()
    }
    
    func validateMandatoryFields() {
        
        var isValid = true
        
        if !isLinkService || requestDescription == "" || requestDescription == "I need ..." {
            isValid = false
        }
                
        if !isValid {
            buttonSend.isUserInteractionEnabled = false
            buttonSend.alpha = 0.3
        } else {
            buttonSend.isUserInteractionEnabled = true
            buttonSend.alpha = 1.0
        }

    }
    
    func moveToLinkServicePage() {
        let linkServiceVC = storyboard?.instantiateViewController(withIdentifier: "LinkServicesVC") as! LinkServicesViewController
        linkServiceVC.categoryId = self.categoryId
        linkServiceVC.linkDelegate = self
        linkServiceVC.isFromRequest = true
        linkServiceVC.toUserId = self.sellerId
        navigationController?.pushViewController(linkServiceVC, animated: true)
    }
    
    // MARK: - Call APIs
    
    func callGetRequestAPI(requestId: String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callGetRequest(requestId: requestId, withCompletionHandler:{ (result,statusCode,response, error) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    print("response : \(responseDict)")
                    if let serviceId = responseDict["serviceId"] {
                        self.serviceId = serviceId as! String
                    }
                    if let serviceDict = responseDict["service"] {
                        self.linkService = Service.init(dict: serviceDict as! [String:Any])
                        self.isLinkService = true
                        self.linkCellCount = 2
                    }
                    
                    if let descriptionTxt = responseDict["description"] {
                        self.requestDescription = descriptionTxt as! String
                    }

                    if let media = responseDict["media"] {
                        if media is Dictionary<AnyHashable,Any> {
                            let arr = [media as! [String:Any]]
                            for item in arr {
                                let snapPhoto = Media.init(dict: item)
                                self.snapPhotos.append(snapPhoto)
                            }
                        } else if media is Array<Any> {
                            let arr = media as! [[String:Any]]
                            for item in arr {
                                let snapPhoto = Media.init(dict: item)
                                self.snapPhotos.append(snapPhoto)
                            }
                        }
                    }

                    self.validateMandatoryFields()
                    self.tableView.reloadData()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.stopLoader()
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: { (code) in
                    self.navigationController?.popViewController(animated: true)
                })
            }
        })
    }
    
    func callPostRequestAPI() {
        PointtersHelper.sharedInstance.startLoader(view: view)
        let serviceId = linkService.id == "" ? self.serviceId : linkService.id
        
        var arrMedia = [[String:String]]()
        for media in snapPhotos {
            arrMedia.append(media.dict())
        }
                
        ApiHandler.postRequest(serviceId: serviceId, sellerId: self.sellerId, media: arrMedia, isPrivate: true, description: requestDescription) { (status, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()
            if status == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {                    
                    self.sendRequestDelegate?.selectSendRequest(request: responseDict)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        }
    }
    
    func callEditRequestAPI() {
        PointtersHelper.sharedInstance.startLoader(view: view)
        let serviceId = linkService.id == "" ? self.serviceId : linkService.id
        
        var arrMedia = [[String:String]]()
        for media in snapPhotos {
            arrMedia.append(media.dict())
        }
        
        ApiHandler.editRequest(requestId: self.requestId, serviceId: serviceId, sellerId: self.sellerId, media: arrMedia, isPrivate: true, description: self.requestDescription) { (status, statusCode, response) in
            PointtersHelper.sharedInstance.stopLoader()
            if status == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    
                    self.sendRequestDelegate?.returnFromRequest(reload: true)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        }
    }
            
    // MARK: - IBAction methods
    
    @IBAction func btnBackClicked(_ sender: Any) {
        if self.sendRequestDelegate != nil {
            self.sendRequestDelegate?.returnFromRequest(reload: false)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendClicked(_ sender: Any) {
        
        if isJobOffer {
            
            UserDefaults.standard.set(1, forKey: "Custom_Offer_Message")
            UserDefaults.standard.synchronize()
            let storyboard = UIStoryboard(name: "Explore", bundle: nil)
            let sendRequestOfferVC = storyboard.instantiateViewController(withIdentifier: "SendOfferVC") as! SendOfferViewController
            sendRequestOfferVC.requestId = requestId
            sendRequestOfferVC.isJobOffer = true
            sendRequestOfferVC.isFromRequest = true
            sendRequestOfferVC.buyerId = self.sellerId
            if isEdit {
                sendRequestOfferVC.offerId = offerId
                sendRequestOfferVC.isEdit = true
            } else {
                sendRequestOfferVC.linkService = self.linkService
                sendRequestOfferVC.linkCellCount = self.linkCellCount
            }
            sendRequestOfferVC.requestOfferDelegate = self
            self.navigationController?.pushViewController(sendRequestOfferVC, animated:true)
        } else {
            let descriptionCell: RequestDetailCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! RequestDetailCell
            requestDescription = descriptionCell.tvDescription.text
                    
            if isEdit {
                callEditRequestAPI()
            } else {
                callPostRequestAPI()
            }
        }
    }
    
    @IBAction func btnDeleteClicked(_ sender: Any) {
        PointtersHelper.sharedInstance.showAlertViewWithTitle("Confirm", message: "Are you sure you want to delete this request?", buttonTitles: ["OK", "Cancel"], viewController: self) { (code) in
            if code == 0 {
                PointtersHelper.sharedInstance.startLoader(view: self.view)
                ApiHandler.deleteRequest(requestId: self.requestId) { (status, statusCode, response, error) in
                    PointtersHelper.sharedInstance.stopLoader()
                    if status == true {
                        let responseDict = response.value as! [String:Any]
                        if statusCode == 200 {
                            
                            if self.sendRequestDelegate != nil {
                                self.sendRequestDelegate?.returnFromRequest(reload: true)
                            }
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                        }
                    } else {
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: { (type) in
                            if self.sendRequestDelegate != nil {
                                self.sendRequestDelegate?.returnFromRequest(reload: true)
                            }
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                }                
            }
        }
    }

}

// MARK: - Link ServiceDelegate

extension SendRequestViewController: SendRequestOfferDelegate {
    func selectSendRequestOffers(selId: String, selPrice: [String : Any], linkedService: [String : Any], link: Bool) {
        self.sendRequestDelegate?.selectSendRequestOffer(selId: selId, selPrice: selPrice, linkedService: linkedService, link: link)
    }
    
    func returnFromRequestOffers(reload: Bool) {
        self.sendRequestDelegate?.returnFromSendRequestOffer(reload: reload)
    }
}

extension SendRequestViewController:LinkServiceDelegate {
    func selectLinkService(selected : UserService) {
        isLinkService = true
        linkCellCount = 2
        linkService = selected.service
        validateMandatoryFields()
        tableView.reloadData()
    }
}

// MARK: - UITextFieldDelegate

// UITextFieldDelegate
extension SendRequestViewController: UITextFieldDelegate {
    
    @objc func donePressed() {
        view.endEditing(true)
    }
    
    func addToolBar(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
}

// MARK: - UITextViewDelegate

extension SendRequestViewController : UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "I need ..."
            textView.textColor = UIColor.lightGray
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        self.requestDescription = textView.text
        validateMandatoryFields()
        let cell = tableView.cellForRow(at: IndexPath.init(item: 0, section: 1)) as! RequestDetailCell
        cell.btnClose.isHidden = (self.requestDescription == "") ? true: false
        cell.imgClose.isHidden = (self.requestDescription == "") ? true: false
    }
}

// MARK: - Snap Photo delegate method

extension SendRequestViewController: RequestDetailCellDelegate {
    func edittedPhotos(snapShots: [Media]) {
        let requestCell3 = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! RequestDetailCell
        snapPhotos = requestCell3.arrSnapPhotos        
    }
}

// MARK: - UITableViewDelegate and Datasource

extension SendRequestViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return linkCellCount
        case 1: return 1
        case 2: return 1        
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return 50.0
            } else {
                return 100.0
            }
        case 1: return 135.0
        case 2: return 130.0
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 20
        case 1: return 40
        case 2: return 10
        default:
           return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        if section == 1 {
            let headerLabel = UILabel(frame: CGRect(x: 15, y: 20, width: tableView.bounds.size.width - 30, height: 20))
            headerLabel.font = UIFont(name: "Helvetica", size: 14)
            headerLabel.textColor = UIColor.black
            headerLabel.text = "What are you looking for?"
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "linkServiceCell") as! SendOfferCell
                if isJobOffer {
                    cell.isUserInteractionEnabled = false
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell") as! SendOfferCell
                cell.imgService.layer.cornerRadius = 3.0
                cell.imgService.layer.masksToBounds = true
                cell.imgService.sd_imageTransition = .fade
                cell.imgService.sd_setImage(with: URL(string: linkService.media.fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                cell.lblDesc.text = !self.linkService.tagline.isEmpty ? self.linkService.tagline : self.linkService.desc
                cell.lblPrice.text = self.linkService.prices.currencySymbol + String(format: "%.2f", self.linkService.prices.price)
                cell.btnSellerName.setTitle(UserCache.sharedInstance.getAccountData().firstName + " " + UserCache.sharedInstance.getAccountData().lastName, for: .normal)
                cell.btnDelete.tag = 1001
                cell.btnDelete.addTarget(self, action: #selector(btnDeleteTapped(sender:)), for: .touchUpInside)
                
                if isJobOffer {
                    cell.isUserInteractionEnabled = false
                    cell.btnDelete.isHidden = true
                    cell.imgClose.isHidden = true
                }
                return cell
            }
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "descCell", for: indexPath) as! RequestDetailCell
            cell.tvDescription.delegate = self
            if self.requestDescription == "" || self.requestDescription == "I need ..."{
                cell.tvDescription.text = "I need ..."
                cell.tvDescription.textColor = UIColor.lightGray
                cell.btnClose.isHidden = true
                cell.imgClose.isHidden = true
            }else {
                cell.tvDescription.text = self.requestDescription
                cell.tvDescription.textColor = UIColor.black
                cell.btnClose.isHidden = false
                cell.imgClose.isHidden = false
            }
            if pageFlag == 0 && !requestAgain{
                cell.tvDescription.isUserInteractionEnabled = false
                if isJobOffer {
                    cell.btnClose.isHidden = true
                    cell.imgClose.isHidden = true
                }
            }else {
                cell.tvDescription.isUserInteractionEnabled = true
            }
            if isJobOffer {
                cell.isUserInteractionEnabled = false
                cell.btnClose.isHidden = true
                cell.imgClose.isHidden = true
            }
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "snapCell", for: indexPath) as! RequestDetailCell
            let tempflag = (self.requestAgain) ? 1 : self.pageFlag
            cell.setCollectionView(snapPhotos: snapPhotos, pageFlag: tempflag, rootViewController: self)
            cell.photoEditDelegate = self
            if isJobOffer {
                cell.isJobOffer = true                
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                moveToLinkServicePage()
            } else {
                let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
                let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
                serviceDetailVC.serviceId = linkService.id
                navigationController?.pushViewController(serviceDetailVC, animated:true)
            }
        }
    }
}
