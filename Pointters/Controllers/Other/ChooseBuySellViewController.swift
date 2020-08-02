//
//  ChooseBuySellViewController.swift
//  Pointters
//
//  Created by Mac on 2/21/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol BuySellDelegate {
    func selectBuySell(selected : Int)
}

class ChooseBuySellViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var lblMenuTitle: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var imgBackground: UIImageView!
    
    var chooseDelegate: BuySellDelegate?
    var chooseIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
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
        imgBackground.addBlurEffect()
        tableView.layer.cornerRadius = 15.0
        tableView.layer.masksToBounds = true
        lblMenuTitle.text = kChooseMenuItems[chooseIndex!]
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnAwayTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITableViewDataSource
extension ChooseBuySellViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kChooseMenuItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chooseCell") as! ChooseCell
        
        cell.lblTitle.text = kChooseMenuItems[indexPath.row]
        cell.imgCheck.isHidden = (indexPath.row == chooseIndex!) ? false : true
        
        if indexPath.row == kChooseMenuItems.count-1 {
            cell.imgSeperator.isHidden = true
        } else {
            cell.imgSeperator.isHidden = false
        }
        
        return cell
    }
}

// UITableViewDelegate
extension ChooseBuySellViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if chooseDelegate != nil {
            dismiss(animated: true, completion: {
                self.chooseDelegate?.selectBuySell(selected: indexPath.row)
            })
        }        
    }
}

extension UIImageView
{
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}
