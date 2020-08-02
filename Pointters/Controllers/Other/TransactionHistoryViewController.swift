//
//  TransactionHistoryViewController.swift
//  Pointters
//
//  Created by super on 4/4/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class TransactionHistoryViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var picker: UIPickerView!
    @IBOutlet var bottomView: UIView!
    
    var transactionHistoryDict = [String:Any]()
    var arrHistory = [[String:Any]]()
    var arrCatTransaction = [[String:String]]()
    var arrCatBuyTransaction = [[String:String]]()
    var arrCatSellTransaction = [[String:String]]()
    var arrSelectionList = [[String:Any]]()
    var arrBuyFilterList = [[String:Any]]()
    var arrSellFilterList = [[String:Any]]()
    var arrYearsList = [Int]()
    
    var showPicker = false
    var selectedMonth = ""
    var selectedYear = ""
    var lastDocId = ""
    var filter = ""
    var indexType = ""
    var period = ""
    var currentPage = 1
    var totalPage = 0
    var totalItems = 0
    
    var fromGuide = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrCatTransaction = [
            ["category": "Personal Balance", "amount" : "$0.00"],
            ["category": "Purchases", "amount" : "$0.00"],
            ["category": "Completed Sales", "amount" : "$0.00"],
            ["category": "Active Order Purchases", "amount" : "$0.00"],
            ["category": "Active Order Sales", "amount" : "$0.00"],
            ["category": "Withdrawal", "amount" : "$0.00"],
            ["category": "Refund", "amount": "$0.00"]
        ]
        arrCatBuyTransaction = [
            ["category": "Purchases", "amount" : "$0.00"],
            ["category": "Active Order Purchases", "amount" : "$0.00"],
            ["category": "Completed Order Purchases", "amount" : "$0.00"],
            ["category": "Personal Balance", "amount" : "$0.00"],
            ["category": "Refund", "amount": "$0.00"]
        ]
        arrCatSellTransaction = [
            ["category": "Personal Balance", "amount" : "$0.00"],
            ["category": "Completed Sales", "amount" : "$0.00"],
            ["category": "Active Order Sales", "amount" : "$0.00"]
        ]
        
        arrSelectionList = [["category" : "Showing all Transactions", "filterKey": ""]]
        
        arrBuyFilterList = [
            ["category": "Purchases", "filterKey": "buy"],
            ["category": "Refunds", "filterKey": "refund"]
        ]//["category": "Withdrawal", "filterKey": "withdraw"],
        arrSellFilterList = [
            ["category": "Completed Sales", "filterKey": "earning"],
            ["category": "Active Order Sales", "filterKey": "future_earning"]
        ]
        
        generateYears()
        initUI()
        initData()
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
    }
    
    func generateYears(){
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        self.selectedMonth = dateFormatter.string(from: now)
        dateFormatter.dateFormat = "yyyy"
        self.selectedYear = dateFormatter.string(from: now)
        if let year = Int(self.selectedYear){
            self.arrYearsList = Array(2018...year)
        }
        self.picker.selectRow(kMonthItems.firstIndex(of: self.selectedMonth)!, inComponent: 0, animated: false)
        self.picker.selectRow(self.arrYearsList.firstIndex(of: Int(self.selectedYear)!)!, inComponent: 1, animated: false)
        self.period = "\(self.selectedYear)-\(self.selectedMonth)"
    }
    
    func initData() {
        callGetTransactionHistoryAPI(inited: true, filter: self.indexType, period: self.period, page: self.currentPage)
    }
    
    func setView(view: UIView, hidden: Bool) {
        showPicker = !hidden
        UIView.transition(with: view, duration: 0.5, options: .showHideTransitionViews, animations: {
            view.isHidden = hidden
        })
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        if self.fromGuide{
            let viewControllers = self.navigationController?.viewControllers
            self.navigationController?.popToViewController(viewControllers![viewControllers!.count-3], animated: true)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnCancelTapped(_ sender: Any) {
        setView(view: bottomView, hidden: true)
    }
            
    @IBAction func btnDoneTapped(_ sender: Any) {
        setView(view: bottomView, hidden: true)
        self.selectedMonth = kMonthItems[picker.selectedRow(inComponent: 0)]
        self.selectedYear = String(arrYearsList[picker.selectedRow(inComponent: 1)])
        self.lastDocId = ""
        self.period = "\(self.selectedYear)-\(self.selectedMonth)"
        self.currentPage = 1
        self.callGetTransactionHistoryAPI(inited: true, filter: self.filter, period: self.period, page: self.currentPage)
    }
    
    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    func callGetTransactionHistoryAPI(inited: Bool, filter: String, period: String, page: Int) {
        if inited {
            PointtersHelper.sharedInstance.startLoader(view: view)
            self.arrHistory.removeAll()
            self.lastDocId = ""
        }
        ApiHandler.callGetTransactionHistory(filter: filter, period: period,  page: page, withCompletionHandler: { (result,statusCode,response) in
            if inited {
                PointtersHelper.sharedInstance.stopLoader()
            }
            if result == true {
                let responseDict = response.value as! [String:Any]
                print(responseDict as NSDictionary)
                if statusCode == 200 {
                    self.transactionHistoryDict = responseDict
                    if let pageNumber = responseDict["page"] as? NSNumber {
                        self.currentPage = pageNumber.intValue + 1
                    } else {
                        self.currentPage = Int(responseDict["page"] as! String)! + 1
                    }
                    
                    self.totalPage = responseDict["pages"]  as! Int
                    self.totalItems = responseDict["total"] as! Int
                    if responseDict["lastDocId"] is NSNull{
                        self.lastDocId = ""
                    }else{
                        self.lastDocId = responseDict["lastDocId"] as! String
                    }
                    
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for itemHistory in arr {
                            self.arrHistory.append(itemHistory)
                        }
                    }
                    let currencySymbol = self.transactionHistoryDict["currencySymbol"] as! String
                    let personalBalance = self.transactionHistoryDict["totalPersonalBalance"] as! String
                    let totalPurchase = self.transactionHistoryDict["totalPurchases"] as! String
                    let totalCompletedSales = self.transactionHistoryDict["totalSalesEarning"] as! String
                    let totalActivePurchases = self.transactionHistoryDict["totalActiveOrderPurchases"] as! String
                    let totalCompletedOrderPurchases = self.transactionHistoryDict["totalCompletedOrderPurchases"] as! String
                    let totalActiveSales = self.transactionHistoryDict["totalActiveOrderSalesEarning"] as! String
                    let withdrawal = self.transactionHistoryDict["totalWithdrawal"] as! String
                    let refund = self.transactionHistoryDict["totalRefund"] as! String
                    
                    self.arrCatTransaction[0]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(personalBalance)!))"
                    self.arrCatTransaction[1]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(totalPurchase)!))"
                    self.arrCatTransaction[2]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(totalCompletedSales)!))"
                    self.arrCatTransaction[3]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(totalActivePurchases)!))"
                    self.arrCatTransaction[4]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(totalActiveSales)!))"
                    self.arrCatTransaction[5]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(withdrawal)!))"
                    self.arrCatTransaction[6]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(refund)!))"
                    
                    self.arrCatBuyTransaction[0]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(totalPurchase)!))"
                    self.arrCatBuyTransaction[1]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(totalActivePurchases)!))"
                    self.arrCatBuyTransaction[2]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(totalCompletedOrderPurchases)!))"
                    self.arrCatBuyTransaction[3]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(personalBalance)!))"
                    self.arrCatBuyTransaction[4]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(refund)!))"
                    
                    self.arrCatSellTransaction[0]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(personalBalance)!))"
                    self.arrCatSellTransaction[1]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(totalCompletedSales)!))"
                    self.arrCatSellTransaction[2]["amount"] = "\(currencySymbol)\(String.init(format: "%.2f", Float(totalActiveSales)!))"
                    
                    self.tableView.reloadData()
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        })
    }

}

extension TransactionHistoryViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            if (indexPath.row == self.arrHistory.count - 1) && (self.currentPage < self.totalPage) {
                callGetTransactionHistoryAPI(inited: false, filter: self.filter, period: self.period, page: self.currentPage)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2: return arrSelectionList.count
        case 3: return arrHistory.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 150.0
        case 1,2:
            return 50.0
        case 3:
            return 60.0
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1: return 46
        case 2,3: return 20
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 25, width: tableView.bounds.size.width - 30, height: 20))
        headerLabel.font = UIFont(name: "Helvetica", size: 14)
        headerLabel.textColor = UIColor.getCustomGrayTextColor()
        
        switch section {
        case 1:
            headerLabel.text = "STATEMENT PERIOD"
            break
        default:
            break
        }
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 {
            return 0.0
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "swipeCell") as! TransactionHistoryCell
            if self.indexType == "buy" {
                cell.setCollectionView(arrCatTransition: self.arrCatBuyTransaction)
            } else if self.indexType == "sell" {
                cell.setCollectionView(arrCatTransition: self.arrCatSellTransaction)
            }
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "periodCell") as! TransactionHistoryCell
            cell.lblPeriod.text = "\(self.selectedMonth) \(self.selectedYear)"
            return cell
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "catCell") as! TransactionHistoryCell
            let itemDict = arrSelectionList[indexPath.row]
            cell.lblCategory.text = itemDict["category"] as? String
            cell.imgDrop.isHidden = indexPath.row != 0
            if arrSelectionList.count == 1 {
                cell.imgDrop.image = UIImage(named:"down-arrow-gray")
            }else {
                cell.imgDrop.image = UIImage(named:"up-arrow-gray")
            }
            return cell
        }
        else if indexPath.section == 3 {
            let historyItem = TransactionHistory.init(dict: self.arrHistory[indexPath.row])
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as! TransactionHistoryCell
            cell.lblDescrition.text = historyItem.desc
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.calendar = Calendar(identifier: .iso8601)
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            if let date = dateFormatter.date(from: historyItem.date){
                dateFormatter.dateFormat = "MM/dd/yyyy"
                cell.lblDate.text = dateFormatter.string(from: date)
            }
            if historyItem.amount < 0{
                cell.lblAmount.textColor = UIColor.init(red: 1, green: 59/255, blue: 48/255, alpha: 1)
            }else{
                cell.lblAmount.textColor = UIColor.init(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
            }
            cell.lblAmount.text = "\(historyItem.currencySymbol)\(String(format:"%.2f", historyItem.amount))"
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            self.setView(view: self.bottomView, hidden: false)
        case 2:
            if arrSelectionList.count == 1 {
                arrSelectionList.append(["category": "Showing all Transactions", "filterKey": ""])
                if self.indexType == "buy" {
                    for item in self.arrBuyFilterList{
                        arrSelectionList.append(item)
                    }
                } else if self.indexType == "sell" {
                    for item in self.arrSellFilterList{
                        arrSelectionList.append(item)
                    }
                }
            } else {
                if indexPath.row == 0 {
                    self.filter = ""
                    let item = arrSelectionList[0]
                    arrSelectionList.removeAll()
                    arrSelectionList.append(item)
                } else {
                    let item = arrSelectionList[indexPath.row]
                    arrSelectionList.removeAll()
                    arrSelectionList.append(item)
                    if indexPath.row == 1{
                        self.filter = ""
                        self.lastDocId = ""
                    }else{
                        if self.indexType == "buy" {
                            self.filter = self.arrBuyFilterList[indexPath.row-2]["filterKey"] as! String
                        } else if self.indexType == "sell" {
                            self.filter = self.arrSellFilterList[indexPath.row-2]["filterKey"] as! String
                        }
                        self.lastDocId = ""
                    }
                    self.currentPage = 1
                    self.callGetTransactionHistoryAPI(inited: true, filter: self.filter, period: self.period, page: self.currentPage)
                }
            }
            tableView.reloadData()
        case 3:
            if let orderId = arrHistory[indexPath.row]["orderId"] as? String{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let fulfillmentVC = storyboard.instantiateViewController(withIdentifier: "FulfillmentVC") as! FulfillmentViewController
                fulfillmentVC.orderId = orderId
                navigationController?.pushViewController(fulfillmentVC, animated: true)
            }
        default:
            break
        }
    }
}

// UIPickerViewDataSource
extension TransactionHistoryViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 {
            return arrYearsList.count
        } else {
            return 12
        }
    }
}

// UIPickerViewDelegate
extension TransactionHistoryViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 28.0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
            return String(arrYearsList[row])
        } else {
            return kMonthItems[row]
        }
    }
}

extension UITableView {
    func reloadData(with animation: UITableViewRowAnimation) {
        reloadSections(IndexSet(integersIn: 0..<numberOfSections), with: animation)
    }
}
