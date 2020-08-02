//
//  ServiceReviewsViewController.swift
//  Pointters
//
//  Created by super on 5/10/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ServiceReviewsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var consNavViewHeight: NSLayoutConstraint!
    
    var arrServiceReviews = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        tableView.reloadData()
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavViewHeight.constant = 80.0
        } else {
            consNavViewHeight.constant = 64.0
        }
    }
    
    //    *******************************************************//
    //                  MARK: - IBAction Method                  //
    //    *******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}

extension ServiceReviewsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrServiceReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ServiceDetailCell
        let cellItem = self.arrServiceReviews[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        let createdTime = dateFormatter.date(from:cellItem["createdAt"] as! String)!
        let calendar = Calendar.current
        if calendar.isDateInToday(createdTime){
            cell.lblDate.text = "Today \(calendar.component(.hour, from: createdTime)):\(calendar.component(.minute, from: createdTime))"
        }else{
            let days = calendar.component(.day, from: createdTime)
            if days == 1 {
                cell.lblDate.text = "\(days) day ago"
            } else{
                cell.lblDate.text = "\(days) days ago"
            }
        }
        if let comment = cellItem["comment"] as? String {
            cell.lblComment.text = comment
        }
        if let qualityOfService = cellItem["qualityOfService"] as? Float {
            cell.lblQuality.text = String(format:"%.1f", qualityOfService)
        }
        if let overallRating = cellItem["overallRating"] as? Int {
            cell.lblRating.text = "\(overallRating)%"
        }
        if let onTime = cellItem["onTime"] as? Bool {
            cell.imgOnTime.image = onTime ? UIImage(named:"icon-done") : UIImage(named:"icon-red-mask")
        }
        if let buyAgain = cellItem["willingToBuyServiceAgain"] as? Bool {
            cell.imgBuyAgain.image = buyAgain ? UIImage(named:"icon-done") : UIImage(named:"icon-red-mask")
        }
        cell.imgBuyerPic.layer.cornerRadius = cell.imgBuyerPic.frame.size.width / 2
        return cell
    }
}

extension ServiceReviewsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}









