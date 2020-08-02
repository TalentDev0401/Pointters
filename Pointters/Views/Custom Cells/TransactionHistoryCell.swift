//
//  TransactionHistoryCell.swift
//  Pointters
//
//  Created by super on 4/4/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class TransactionHistoryCell: UITableViewCell {
    
    // swipe cell
    @IBOutlet var collectionView: UICollectionView!
    
    // period cell
    @IBOutlet var lblPeriod: UILabel!
    
    // cat cell
    @IBOutlet var lblCategory: UILabel!
    @IBOutlet var imgDrop: UIImageView!
    
    // history cell
    @IBOutlet var lblAmount: UILabel!
    @IBOutlet var lblDescrition: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    var arrCatTransition = [[String:Any]]()

    override func awakeFromNib() {
        super.awakeFromNib()
        if collectionView != nil {
            self.collectionView.delegate = self as UICollectionViewDelegate
            self.collectionView.dataSource = self as UICollectionViewDataSource
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension TransactionHistoryCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func setCollectionView (arrCatTransition : [[String:Any]]){
        self.arrCatTransition = arrCatTransition
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCatTransition.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "catItemCell", for: indexPath) as! TransitionCatCell
        cell.containerView.layer.cornerRadius = 8.0
        cell.containerView.layer.shadowColor = UIColor.lightGray.cgColor
        cell.containerView.layer.shadowOpacity = 1
        cell.containerView.layer.shadowOffset = CGSize.init(width: 2.0, height: 2.0)
        cell.containerView.layer.shadowRadius = 5.0
        let itemDict = arrCatTransition[indexPath.item]
        cell.lblCategory.text = itemDict["category"] as? String
        cell.lblAmount.text = itemDict["amount"] as? String
        return cell
    }
}

// UICollectionViewDelegateFlowLayout
extension TransactionHistoryCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height - 30
        let width = UIScreen.main.bounds.size.width
        let cellSize = CGSize(width: CGFloat(width), height: height)
        return cellSize
    }
}

class TransitionCatCell : UICollectionViewCell{
    @IBOutlet var containerView: UIView!
    @IBOutlet var lblCategory: UILabel!
    @IBOutlet var lblAmount: UILabel!
}
