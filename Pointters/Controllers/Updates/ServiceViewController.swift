//
//  ServiceViewController.swift
//  Pointters
//
//  Created by Billiard ball on 15.06.2020.
//  Copyright © 2020 Kenji. All rights reserved.
//

import UIKit

class ServiceViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var categoryTableView: UITableView!
    @IBOutlet var categoryView: UIView!
    
    // MARK: - Properties
    
    var arrSortCategories = [Any]()
    var arrNewCategories = [[String:Any]]()
    var arrCategoryKeys = [String]()
    var arrTitlePositions = [Int]()
    var selCategoryId = ""
    var selSubCategory = [String:Any]()
    var openCategories = [String]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    // MARK: - Private methods
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
        self.categoryView.isHidden = false
        self.categoryTableView.isHidden = false
        callGetUserCategories()
    }
    
    func sortCategory(arrCategory: [[String:Any]]) {
        self.arrSortCategories.removeAll()
        self.arrNewCategories.removeAll()
        self.arrCategoryKeys.removeAll()
        self.arrTitlePositions.removeAll()

        for obj in arrCategory {
            if let val = obj["keywords"] as? [String], val.count > 0 && val[0] != "" {
                if !arrCategoryKeys.contains(val[0]) {
                    arrCategoryKeys.append(val[0])
                }
            }
        }
        
        var index = 0
        for i in 0..<arrCategoryKeys.count {
            var arrValues = [[String:Any]]()
            for j in 0..<arrCategory.count {
                if let val = arrCategory[j]["keywords"] as? [String], val.count > 0 && val[0] != "" {
                    if val[0] == arrCategoryKeys[i] {
                        index = index + 1
                        arrValues.append(arrCategory[j])
                        self.arrNewCategories.append(arrCategory[j])
                    }
                }
            }
            
            self.arrTitlePositions.append(index)
            self.arrSortCategories.append(arrValues)
        }
    }
    
    @objc func btnCategoryTapped(sender: UIButton) {
        let category = arrNewCategories[sender.tag - 1]
        
        if openCategories.contains(category["_id"] as! String) {
            openCategories.remove(at: openCategories.index(of: category["_id"] as! String)!)
        } else {
            openCategories.insert(category["_id"] as! String, at: openCategories.count)
        }
        
        categoryTableView.reloadData()
    }
    
    // MARK: - IBAction methods
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNext(_ sender: Any) {
        if self.selSubCategory.count > 0{
            let storyboard = UIStoryboard(name: "Explore", bundle: nil)
            let addServicesVC = storyboard.instantiateViewController(withIdentifier: "AddServiceVC") as! AddServiceViewController
            addServicesVC.serviceCategory = Category.init(dict: self.selSubCategory)
            navigationController?.pushViewController(addServicesVC, animated: true)
        }else{
            PointtersHelper.sharedInstance.showAlertViewWithTitle("Warning", message: "Please select at least one category.", buttonTitles: ["OK"], viewController: self, completion: nil)
        }
    }
    
    //*******************************************************//
        //              MARK: - Call API Method                  //
        //*******************************************************//
        
        func callGetUserCategories(){
            PointtersHelper.sharedInstance.startLoader(view: view)
            ApiHandler.callGetCategories{ (result,statusCode,response) in
                PointtersHelper.sharedInstance.stopLoader()
                
                if result == true {
                    let responseDict = response.value as! [String:Any]
                    if statusCode == 200 {
                        let arr = responseDict["categories"] as! [[String:Any]]
                        self.sortCategory(arrCategory: arr)
                    }
                }
                else {
                    print(response.error ?? "")
                }
    //            self.lblWarning.text = "No Category."
                self.categoryTableView.reloadData()
            }
        }
}

// UITableViewDataSource
extension ServiceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if arrNewCategories.count > 0 {
            categoryTableView.isHidden = false
            return arrNewCategories.count + 1
        } else {
            categoryTableView.isHidden = true
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section != 0 {
            let category = arrNewCategories[section-1]
            if openCategories.contains(category["_id"] as! String) {
                let arrSubCategories = category["subCategories"] as! [Any]
                return arrSubCategories.count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        } else {
            if arrTitlePositions.contains(section) {
                if section == arrNewCategories.count {
                    return 100.0
                } else {
                    return 0.0
                }
            } else {
                return 0.0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        
        if arrCategoryKeys.count > 0 {
            if section == 0 || (arrTitlePositions.contains(section) && section != arrNewCategories.count) {
                let posY:CGFloat = (section == 0) ? 0 : 25
                let footerLabel = UILabel(frame: CGRect(x: 15, y: posY, width: tableView.bounds.size.width - 30, height: 20))
                footerLabel.font = UIFont(name: "Helvetica", size: 14)
                footerLabel.textColor = UIColor.getCustomGrayTextColor()
                
                if section == 0 {
                    footerLabel.text = arrCategoryKeys[0].uppercased()
                } else {
                    footerLabel.text = arrCategoryKeys[arrTitlePositions.index(of: section)!+1].uppercased()
                }

                footerLabel.sizeToFit()
                footerView.addSubview(footerLabel)
            }
        }
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        } else {
            return 44.0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let view = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryCell

            view.btnCategory.tag = section
            view.btnCategory.addTarget(self, action: #selector(btnCategoryTapped(sender:)), for: .touchUpInside)

            let category = arrNewCategories[section-1]
            view.lblTitle.text = category["name"] as? String
            view.lblTitle.font = UIFont.boldSystemFont(ofSize: 15)
            view.imgArrow.isHidden = false
            if openCategories.contains(category["_id"] as! String) {
                view.imgArrow.image = UIImage(named:"up-arrow-gray")
            } else {
                view.imgArrow.image = UIImage(named:"down-arrow-gray")
            }
            return view
        } else {
            let view = UIView()
            view.backgroundColor = UIColor.clear
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "subCategoryCell") as! CategoryCell
            
            let category = arrNewCategories[indexPath.section-1]
            let arrSubCategories = category["subCategories"] as! [Any]
            let subCategory = arrSubCategories[indexPath.row] as! [String:Any]
            
            cell.lblSubTitle.text = subCategory["name"] as? String
            
            cell.imgCheck.isHidden = false
            cell.imgCheck.image = UIImage(named: "icon-checkbox-normal")
            
            if let _ = selSubCategory["name"] {
                if subCategory["name"] as! String ==  selSubCategory["name"] as! String  {
                    cell.imgCheck.isHidden = false
                    cell.imgCheck.image = UIImage(named: "icon-checkbox-blue")
                }
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

// UITableViewDelegate
extension ServiceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = arrNewCategories[indexPath.section-1]
        print(category as NSDictionary)
        let arrSubCategories = category["subCategories"] as! [Any]
        let subCategory = arrSubCategories[indexPath.row] as! [String:Any]
        self.selSubCategory["name"] = subCategory["name"] as! String
        self.selSubCategory["_id"] = subCategory["_id"] as! String
        tableView.reloadData()
    }
}
