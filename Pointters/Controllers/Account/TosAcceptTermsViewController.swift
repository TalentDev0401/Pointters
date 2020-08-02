//
//  TosAcceptTermsViewController.swift
//  Pointters
//
//  Created by dreams on 11/7/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import ActiveLabel

protocol TosAcceptDelegate {
    func onClickAgree()
}

class TosAcceptTermsViewController: UIViewController {
    
    var delegate: TosAcceptDelegate!
    
    @IBOutlet weak var labelContent: ActiveLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelContent.URLColor = UIColor.getCustomLightBlueColor()
        labelContent.lineSpacing = 5
        labelContent.handleURLTap { (url) in
            UIApplication.shared.open(url)
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func onClickAgree(_ sender: Any) {
        self.delegate.onClickAgree()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
