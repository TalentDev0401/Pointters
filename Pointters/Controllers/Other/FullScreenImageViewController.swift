//
//  FullScreenImageViewController.swift
//  Pointters
//
//  Created by super on 5/29/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class FullScreenImageViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgPhoto: UIImageView!
    
    var imageUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        imgPhoto.sd_imageTransition = .fade
        imgPhoto.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named:"photo_placeholder"))
    }
    
    @IBAction func btnCloseTapped(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
}

extension FullScreenImageViewController : UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgPhoto
    }
    
}
