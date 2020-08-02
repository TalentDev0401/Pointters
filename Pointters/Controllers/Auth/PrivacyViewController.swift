//
//  PrivacyViewController.swift
//  Pointters
//
//  Created by Mac on 2/20/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import WebKit

class PrivacyViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PointtersHelper.sharedInstance.startLoader(view: self.webView)
        webView.navigationDelegate = self
        initUI()
        if let url = URL(string: "https://www.pointters.com/privacy.html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
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
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension PrivacyViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        PointtersHelper.sharedInstance.stopLoader()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        PointtersHelper.sharedInstance.stopLoader()
    }
}
