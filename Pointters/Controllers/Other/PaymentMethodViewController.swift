//
//  PaymentMethodViewController.swift
//  Pointters
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol PaymentMethodVCDelegate {
    func selectedMethod(method : StripePaymentMethod)
    func selectCash(isCashPayment : Bool)
}

class PaymentMethodViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet var labelHeaderTitle: UILabel!
    
    var paymentDelegate: PaymentMethodVCDelegate?

    var isProcessingCall = false
    
    var isSelectionMode = false
    var selectedIndex: IndexPath?

    var isOnlineService = false
    var isCashPayment = false
    var sellerCompletedGetPaid: Bool = false
    
    var arrCards = [StripePaymentMethod]()
    var paypal = StripePaymentMethod()
    var applePay = StripePaymentMethod()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnEdit.isHidden = !self.isSelectionMode
        initUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        callGetPaymentMethods()
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
        if self.isSelectionMode {
            labelHeaderTitle.text = "Select Payment Method"
        } else {
            labelHeaderTitle.text = "Edit Payment Method"
        }
    }
    
    func callGetPaymentMethods() {
        
        if !isProcessingCall {
//            isProcessingCall = true
            
            self.arrCards.removeAll()
//            PointtersHelper.sharedInstance.startLoader(view: view)
            
            ApiHandler.callGetStripePaymentMethods { (result, statusCode, response, error) in
//                PointtersHelper.sharedInstance.stopLoader()
                if result == true {
                    let responseDict = response.value as! [[String:Any]]
                    if statusCode == 200 {
                        for paymentDic in responseDict {
                            let paymentMethod = StripePaymentMethod.init(dict: paymentDic)
                            if paymentMethod.isCreditCard {
                                self.arrCards.append(paymentMethod)
                            }
                            if paymentMethod.isApplePay {
                                self.applePay = paymentMethod
                                UserCache.sharedInstance.setApplePayEmail(email: paymentMethod.brand + " : ****" + paymentMethod.last4)
                            }
                            if paymentMethod.isPayPal {
                                
                            }
                        }
                        self.tableView.reloadData()
                    } else {
                        PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Server Error!", buttonTitles: ["OK"], viewController: self, completion: nil)
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
        }
    }    
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func btnEditTapped(_ sender: Any) {
        let paymentVC = storyboard?.instantiateViewController(withIdentifier: "PaymentMethodVC") as! PaymentMethodViewController
        navigationController?.pushViewController(paymentVC, animated: true)
    }
    
}
//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//


// MARK: - PayPal Apple Pay Delegate

extension PaymentMethodViewController: PaypalApplePayVCDelegate {
    func addedMethod(method: StripePaymentMethod, isPayPal: Bool) {
//        callGetPaymentMethods()
    }
    
    func refreshForUpdate() {
//        callGetPaymentMethods()
    }
    
    func deletedMethod(isPayPal: Bool) {
//        if isPayPal {
//            UserCache.sharedInstance.deletePaypalEmail()
////            paypal = PaymentMethod()
//        } else {
//            UserCache.sharedInstance.deleteApplePayEmail()
//            applePay = StripePaymentMethod()
//        }
//        callGetPaymentMethods()
    }
    
    
}


// AddCardDelegate
extension PaymentMethodViewController: AddCardDelegate {
    func refreshPage() {
//        callGetPaymentMethods()
    }
    
    func deletedCard(index: Int) {
//        callGetPaymentMethods()
    }
}

// UITableViewDataSource
extension PaymentMethodViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isOnlineService == true {
            return 2
        } else {
            if self.isSelectionMode == true {
                return 3
            } else {
                return 2
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return 2
            case 1:// if isSelectionMode { return arrCards.count } else { return arrCards.count + 1 }
                return arrCards.count + 1
            case 2: return 2
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 0
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            return 0
        }
        if indexPath.section == 1 && indexPath.row == arrCards.count+1 {
            return 44.0
        } else {
            return 60.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        let headerLabel = UILabel(frame: CGRect(x: 13, y: 25, width: tableView.bounds.size.width - 30, height: 20))
        headerLabel.font = UIFont(name: "Helvetica", size: 14)
        headerLabel.textColor = UIColor.getCustomGrayTextColor()
        switch section {
            case 0: headerLabel.text = "APPLE PAY"
            case 1: headerLabel.text = "CARDS"
            case 2: headerLabel.text = "CASH"
            default: headerLabel.text = ""
        }
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell") as! PaymentCell
            
            if isSelectionMode {
                cell.imgRightArrow.isHidden = true
                
                if selectedIndex == indexPath {
                    cell.imgCheck.isHidden = false
                } else {
                    cell.imgCheck.isHidden = true
                }
                
            } else {
                cell.imgRightArrow.isHidden = false
                cell.imgCheck.isHidden = true
            }
            
            if indexPath.row == 0 {
                cell.imgIcon.image = UIImage(named: "icon-paypal")
                cell.lblTitle.text = "Paypal"
                cell.lblSubTitle.text = UserCache.sharedInstance.getPaypalEmail()
                cell.lblDefault.isHidden = !paypal.defaultOption
                cell.constantPaymentIconRatio.constant = 1.0
            } else {
                cell.imgIcon.image = UIImage(named: "icon-applepay")
                cell.lblTitle.text = "Apple Pay"
                cell.lblSubTitle.text = UserCache.sharedInstance.getApplePayEmail()
                cell.lblDefault.isHidden = !applePay.defaultOption
                cell.constantPaymentIconRatio.constant = 1.0/1.56
            }
            
            return cell
        }
        else if indexPath.section == 1 {
            if indexPath.row == arrCards.count {
                if isSelectionMode{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! PaymentCell
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "addcardCell") as! PaymentCell
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell") as! PaymentCell
                
                if isSelectionMode {
                    cell.imgRightArrow.isHidden = true
                    
                    if selectedIndex == indexPath {
                        cell.imgCheck.isHidden = false
                    } else {
                        cell.imgCheck.isHidden = true
                    }
                    
                } else {
                    cell.imgRightArrow.isHidden = false
                    cell.imgCheck.isHidden = true
                }
                
                let method = arrCards[indexPath.row]
                cell.imgIcon.sd_imageTransition = .fade
                cell.imgIcon.sd_setImage(with: URL(string: method.imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"icon-credit"))
                cell.lblTitle.text = method.brand
                cell.lblSubTitle.text = "*****" + method.last4
                cell.lblDefault.isHidden = !method.defaultOption
                return cell
            }
        } else if indexPath.section == 2 && self.isSelectionMode == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell") as! PaymentCell
            cell.imgIcon.image = UIImage(named: "icon-payment")
            cell.constantPaymentIconRatio.constant = 1.0
            cell.lblTitle.text = "CASH"
            cell.lblSubTitle.text = "Pay with cash"
            cell.lblDefault.isHidden = true
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
}

// UITableViewDelegate
extension PaymentMethodViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            if isSelectionMode == true {
                
                    selectedIndex = indexPath
                    if indexPath.row == 0 {
                        if !paypal.id.isEmpty {
                           /* PointtersHelper.sharedInstance.showAlertViewWithTitle("Warning", message: "You didn't setup your Paypal account, Please go to account page and connect your account", buttonTitles: ["OK"], viewController: self, completion: nil)
                            tableView.reloadData()
                        } else { */
                            if sellerCompletedGetPaid == false {
                                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Seller is in process of setting up get paid option. Only CASH payment is accepted now.", buttonTitles: ["OK"], viewController: self, completion: nil)
                            } else {
                                if paymentDelegate != nil {
                                    paymentDelegate?.selectedMethod(method: paypal)
                                    self.isCashPayment = false
                                    navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    }
                    
                    if indexPath.row == 1 {
                        if !applePay.id.isEmpty {
                            /* PointtersHelper.sharedInstance.showAlertViewWithTitle("Warning", message: "You didn't setup your Apple Pay account, Please click Add button or go to account page and connect your account", buttonTitles: ["OK"], viewController: self, completion: nil)
                            tableView.reloadData()
                        } else { */
                            if sellerCompletedGetPaid == false {
                                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Seller is in process of setting up get paid option. Only CASH payment is accepted now.", buttonTitles: ["OK"], viewController: self, completion: nil)
                            } else {
                                if paymentDelegate != nil {
                                    paymentDelegate?.selectedMethod(method: applePay)
                                    self.isCashPayment = false
                                    navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    }
                
                
            } else {
                let payaplAppleVC = storyboard?.instantiateViewController(withIdentifier: "PaypalApplePayVC") as! PaypalApplePayViewController
                payaplAppleVC.isPayPal = true
                payaplAppleVC.addDelegate = self

                if indexPath.row == 0 {
                    payaplAppleVC.initWithPaymentMethod(paymentMethod: paypal, isPayPal: true)
                }

                if indexPath.row == 1 {
                    payaplAppleVC.isPayPal = false
                    payaplAppleVC.initWithPaymentMethod(paymentMethod: applePay, isPayPal: false)
                }
                present(payaplAppleVC, animated: true, completion: nil)
            }
        } else if indexPath.section == 1 {
            
            if isSelectionMode == true {
                    if arrCards.count == 0 {
                        return
                    }
                    selectedIndex = indexPath
                    let method = arrCards[indexPath.row]
                    
                    if !method.id.isEmpty {
                       /* tableView.reloadData()
                    } else { */
                        if sellerCompletedGetPaid == false {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Seller is in process of setting up get paid option. Only CASH payment is accepted now.", buttonTitles: ["OK"], viewController: self, completion: nil)
                        } else {
                            if paymentDelegate != nil {
                                paymentDelegate?.selectedMethod(method: method)
                                self.isCashPayment = false
                                navigationController?.popViewController(animated: true)
                            }
                        }
                    }
            } else {
                let addCardVC = storyboard?.instantiateViewController(withIdentifier: "AddCardVC") as! AddCardViewController
                addCardVC.addDelegate = self
                
                if indexPath.row != arrCards.count {
                    let method = arrCards[indexPath.row]
                    addCardVC.initPaymentMethodWithIndex(method: method, index: indexPath.row)
                }
                present(addCardVC, animated: true, completion: nil)
            }
        }  else if indexPath.section == 2 {
            if paymentDelegate != nil {
                self.isCashPayment = true
                paymentDelegate?.selectCash(isCashPayment: true)
                navigationController?.popViewController(animated: true)
            }
        }
    }
}
