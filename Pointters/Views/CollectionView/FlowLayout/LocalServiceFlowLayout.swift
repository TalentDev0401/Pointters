//
//  LocalServiceFlowLayout.swift
//  Pointters
//
//  Created by dreams on 9/25/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class LocalServiceFlowLayout: UICollectionViewFlowLayout {
    
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
        minimumLineSpacing = 10
        scrollDirection = .horizontal
        sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    override var itemSize: CGSize{
        set {
            
        }
        get {
            return CGSize(width: 336.0, height: 190.0)
        }
    }
}

