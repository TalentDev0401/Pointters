//
//  PopularCategoryFlowLayout.swift
//  Pointters
//
//  Created by dreams on 9/25/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class PopularCategoryFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 15
        minimumLineSpacing = 15
        scrollDirection = .horizontal
        sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    override var itemSize: CGSize{
        set {
            
        }
        get {
            let itemWidth  = (self.collectionView?.frame.width)!
            return CGSize(width: itemWidth/2-10, height: 86)
        }
    }
}
