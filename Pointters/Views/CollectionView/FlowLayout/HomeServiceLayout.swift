//
//  HomeServiceLayout.swift
//  Pointters
//
//  Created by dreams on 9/24/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class HomeServiceLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = .horizontal
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    override var itemSize: CGSize{
        set {
            
        }
        get {
            let itemWidth  = (self.collectionView?.frame.width)!
            let itemHeight  = (self.collectionView?.frame.height)!
            return CGSize(width: itemWidth, height: itemHeight)
        }
    }
}

