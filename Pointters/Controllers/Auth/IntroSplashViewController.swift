//
//  IntroSplashViewController.swift
//  Pointters
//
//  Created by Mac on 2/13/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class IntroSplashViewController: UIViewController {
    
    @IBOutlet var consBtnSkipTop: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var lblDesc1: UILabel!
    @IBOutlet var lblDesc2: UILabel!
    @IBOutlet var pageCtrl: UIPageControl!
    @IBOutlet var btnSkip: UIButton!
    @IBOutlet var btnSignIn: UIButton!
    @IBOutlet var btnJoin: UIButton!
    
    var timer: Timer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserCache.sharedInstance.getUserCredentials() != nil {
            
        }
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configContentView()
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consBtnSkipTop.constant = 58.0
        } else {
            consBtnSkipTop.constant = 36.0
        }
        
        btnJoin.layer.cornerRadius = 3.0
        btnJoin.layer.masksToBounds = true
        
        btnSignIn.layer.cornerRadius = 3.0
        btnSignIn.layer.masksToBounds = true
        btnSignIn.layer.borderWidth = 1.0
        btnSignIn.layer.borderColor = UIColor.white.cgColor
        
        pageCtrl.currentPage = 0
        lblDesc1.text = kIntroDescription.kIntroDesc00
        lblDesc2.text = kIntroDescription.kIntroDesc01
    }
    
    func configContentView() {
        let screenWidth = UIScreen.main.bounds.size.width
        let scrollViewHeight = scrollView.frame.size.height
        
        let contentView0 = UIImageView.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: scrollViewHeight))
        contentView0.image = UIImage(named: "bgSplash1")
        contentView0.contentMode = .scaleAspectFill
        contentView0.clipsToBounds = true
        
        let contentView1 = UIImageView.init(frame: CGRect(x: screenWidth, y: 0, width: screenWidth, height: scrollViewHeight))
        contentView1.image = UIImage(named: "bgSplash2")
        contentView1.contentMode = .scaleAspectFill
        contentView1.clipsToBounds = true
        
        let contentView2 = UIImageView.init(frame: CGRect(x: screenWidth*2, y: 0, width: screenWidth, height: scrollViewHeight))
        contentView2.image = UIImage(named: "bgSplash3")
        contentView2.contentMode = .scaleAspectFill
        contentView2.clipsToBounds = true
        
        let contentView3 = UIImageView.init(frame: CGRect(x: screenWidth*3, y: 0, width: screenWidth, height: scrollViewHeight))
        contentView3.image = UIImage(named: "bgSplash4")
        contentView3.contentMode = .scaleAspectFill
        contentView3.clipsToBounds = true
        
        scrollView.addSubview(contentView0)
        scrollView.addSubview(contentView1)
        scrollView.addSubview(contentView2)
        scrollView.addSubview(contentView3)
        
        scrollView.contentSize = CGSize(width: screenWidth*4, height: scrollViewHeight)
    }

    @objc func moveToNextPage() {
        let pageWidth = scrollView.frame.size.width
        let pageHeight = scrollView.frame.size.height
        
        let maxWidth = pageWidth * 4
        let contentOffset = scrollView.contentOffset.x
        
        var slideToX = contentOffset + pageWidth
        if slideToX == maxWidth {
            slideToX = 0
        }
        
        let currentPage = floor((slideToX - pageWidth/2) / pageWidth) + 1
        pageCtrl.currentPage = Int(currentPage)
        
        switch Int(currentPage) {
            case 0:
                lblDesc1.text = kIntroDescription.kIntroDesc00
                lblDesc2.text = kIntroDescription.kIntroDesc01
                btnSkip.setTitleColor(UIColor.black, for: .normal)
                break
            case 1:
                lblDesc1.text = kIntroDescription.kIntroDesc10
                lblDesc2.text = kIntroDescription.kIntroDesc11
                btnSkip.setTitleColor(UIColor.white, for: .normal)
                break
            case 2:
                lblDesc1.text = kIntroDescription.kIntroDesc20
                lblDesc2.text = kIntroDescription.kIntroDesc21
                btnSkip.setTitleColor(UIColor.white, for: .normal)
                break
            case 3:
                lblDesc1.text = kIntroDescription.kIntroDesc30
                lblDesc2.text = kIntroDescription.kIntroDesc31
                btnSkip.setTitleColor(UIColor.black, for: .normal)
                break
            default:
                break
        }
        
        scrollView.scrollRectToVisible(CGRect(x:slideToX, y:0, width:pageWidth, height:pageHeight), animated:true)
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnSkipTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let containerVC = storyboard.instantiateViewController(withIdentifier: "ContainerTabVC") as! ContainerTabViewController
        self.navigationController?.pushViewController(containerVC, animated: true)
    }
    
    @IBAction func btnSignInTapped(_ sender: Any) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        navigationController?.pushViewController(loginVC, animated: true)
    }

    @IBAction func btnJoinTapped(_ sender: Any) {
        let signupVC = storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpViewController
        navigationController?.pushViewController(signupVC, animated: true)
    }
}

//*******************************************************//
//              MARK: - IBAction Method                  //
//*******************************************************//

// UIScrollViewDelegate
extension IntroSplashViewController:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = UIScreen.main.bounds.size.width
        let fractionalPage = scrollView.contentOffset.x/pageWidth
        let page = lroundf(Float(fractionalPage))
        
        pageCtrl.currentPage = page
    }
}


