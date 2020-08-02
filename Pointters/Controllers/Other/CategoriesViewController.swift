//
//  CategoriesViewController.swift
//  Pointters
//
//  Created by C on 7/6/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol CategoriesVCDelegate {
    func selectedCategory(category: [String:Any])
}

class CategoriesViewController: UIViewController {

    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var categoryTableView: UITableView!
    
    var categoryDelegate : CategoriesVCDelegate?

    var arrSortCategories = [Any]()
    var arrNewCategories = [[String:Any]]()
    var arrCategoryKeys = [String]()
    var arrTitlePositions = [Int]()
    var selCategoryId = ""
    var selSubCategory = [String:Any]()
    var openCategories = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        callGetUserCategories()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 85.0
        } else {
            consNavBarHeight.constant = 64.0
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
            
            self.categoryTableView.reloadData()
        }
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
                        
                        let subCategories: [[String: Any]] = arrCategory[j]["subCategories"] as! [[String : Any]]
                        for subCategory: [String: Any] in subCategories {
                            if let name = subCategory["name"], let selName = selSubCategory["name"] {
                                if (name as! String) == (selName as! String) {
                                    if openCategories.contains(arrCategory[j]["_id"] as! String) {
                                        openCategories.remove(at: openCategories.index(of: arrCategory[j]["_id"] as! String)!)
                                    } else {
                                        openCategories.insert(arrCategory[j]["_id"] as! String, at: openCategories.count)
                                    }
                                    break
                                }
                            }
                        }
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

    
    //MARK: - IBActions
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}


// MARK: - UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if arrNewCategories.count > 0 {
            return arrNewCategories.count + 1
        } else {
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


// MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = arrNewCategories[indexPath.section-1]
        let arrSubCategories = category["subCategories"] as! [Any]
        let subCategory = arrSubCategories[indexPath.row] as! [String:Any]
        self.selSubCategory["name"] = subCategory["name"] as! String
        self.selSubCategory["_id"] = subCategory["_id"] as! String
        if categoryDelegate != nil {
            categoryDelegate?.selectedCategory(category: self.selSubCategory)
            navigationController?.popViewController(animated: true)
        }
    }
}
