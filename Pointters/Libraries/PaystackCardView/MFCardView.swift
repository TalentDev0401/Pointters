//
//  MFCardView.swift
//  MFCard
//
//  Created by MobileFirst Applications on 03/11/16.
//  Copyright © 2016 MobileFirst Applications. All rights reserved.
//

import UIKit
import STPopup

public protocol MFCardDelegate {
    func cardPayButtonClicked()
    func cardDidClose()
    func didEdit(number: String)
    func didEdit(expiryDate: String)
    func didEdit(cvc: String)
}

class MFCardView: UIView {
        
    // MARK: - IBOutlets
    
    @IBOutlet fileprivate var view: UIView!
    @IBOutlet fileprivate var cardView: UIView!
    @IBOutlet weak fileprivate var btnClose: UIButton!
    @IBOutlet weak fileprivate var btnPay: UIButton!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var cardNumberView: UIView!
    @IBOutlet weak var cardExpiryView: UIView!
    @IBOutlet weak var cardCVVView: UIView!
    @IBOutlet weak var cardNumber_txt: CreditCardInfoTextField!
    @IBOutlet weak var cardExpiry_txt: CreditCardInfoTextField!
    @IBOutlet weak var cardCvv_txt: CreditCardInfoTextField!
    @IBOutlet weak var cardImage: UIImageView!
    
    // MARK: - Properties
    
    public var delegate: MFCardDelegate?
    fileprivate var mfBundel :Bundle? = Bundle()
    fileprivate var nibName: String = "MFCardView"
    weak fileprivate var rootViewController: UIViewController!
            
    //MARK: - initialization
    
    public init(withViewController:UIViewController, email: String, price: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 330, height: 422))
        rootViewController = withViewController
        setup()
        setupUI()
        configureCardTextField()
        self.lblEmail.text = email
        self.lblPrice.text = "NGN \(price)"
        self.btnPay.setTitle("Pay NGN \(price)", for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupUI()
        configureCardTextField()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        setupUI()
        configureCardTextField()
    }
   
    //MARK: - Setup
    
    fileprivate func setup() {
        // 1. load a nib
        view = loadViewFromNib()
        // 2. add as subview
        self.addSubview(self.view)
        
        // 3. allow for autolayout
        self.view.translatesAutoresizingMaskIntoConstraints = false
        // 4. add constraints to span entire view
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": self.view]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": self.view]))
        self.layoutIfNeeded()
        self.updateConstraintsIfNeeded()
        
    }
    
    func configureCardTextField() {
        // - configure infoDelegate
        cardNumber_txt.infoDelegate = self
        cardExpiry_txt.infoDelegate = self
        cardCvv_txt.infoDelegate = self
                
        let numberFormatter = CreditCardTextFormatter(style: .number)
        let expiryFormatter = CreditCardTextFormatter(style: .expiryDate)
        
        cardNumber_txt.configure(info: .number,
                                      validator: CreditCardNumberValidator(),
                                      formatter: numberFormatter)
        
        cardExpiry_txt.configure(info:.expiryDate,
                                      validator: CreditCardExpiryDateValidator(),
                                      formatter: expiryFormatter)
        
        cardCvv_txt.configure(info: .cvc, validator: CreditCardCvcValidator())
    }
    
    fileprivate func setupUI(){
        self.layoutIfNeeded()
        self.view.layer.cornerRadius = 10.0
        self.view.layer.masksToBounds = true
        self.cardView.layer.cornerRadius = 10.0
        self.cardView.layer.masksToBounds = true
        
        self.cardNumberView.layer.cornerRadius = 3.0
        self.cardNumberView.layer.masksToBounds = true
        self.cardNumberView.layer.borderColor = UIColor.darkGray.cgColor
        self.cardNumberView.layer.borderWidth = 1.0
        
        self.cardExpiryView.layer.cornerRadius = 3.0
        self.cardExpiryView.layer.masksToBounds = true
        self.cardExpiryView.layer.borderColor = UIColor.darkGray.cgColor
        self.cardExpiryView.layer.borderWidth = 1.0
        
        self.cardCVVView.layer.cornerRadius = 3.0
        self.cardCVVView.layer.masksToBounds = true
        self.cardCVVView.layer.borderColor = UIColor.darkGray.cgColor
        self.cardCVVView.layer.borderWidth = 1.0
    }
  
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Helping Methods
    
    fileprivate func loadViewFromNib() -> UIView {
        
        let bundle = getBundle()
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    fileprivate func getBundle() -> Bundle {
        
        let podBundle = Bundle(for: MFCardView.self)
        let bundleURL = podBundle.url(forResource: "MFCard", withExtension: "bundle")
        if bundleURL == nil{
            mfBundel = podBundle
        }else{
            mfBundel = Bundle(url: bundleURL!)!
        }
        return mfBundel!

    }
    
    // MARK: - IBAction methods
    
    @IBAction func closeCardView(_ sender: Any) {
        delegate?.cardDidClose()
    }
    
    @IBAction func paywithCard(_ sender: Any) {
        let numberValidator = CreditCardNumberValidator()
        let expiryValidator = CreditCardExpiryDateValidator()
        let cvvValidator = CreditCardCvcValidator()
//        if cardNumber_txt.text?.count != 19 && cardNumber_txt.text?.count != 22 && cardNumber_txt.text?.count != numberValidator.maxLength {
//            UIApplication.topViewController()?.view.makeToast("Input valid card number")
//            return
//        }
        guard numberValidator.validate(text: cardNumber_txt.text!) else {
            UIApplication.topViewController()?.view.makeToast("Wrong card number")
            return
        }
        guard cardExpiry_txt.text?.count ==  expiryValidator.maxLength else {
            UIApplication.topViewController()?.view.makeToast("Input valid expiry date")
            return
        }
        guard expiryValidator.validate(text: cardExpiry_txt.text!) else {
            UIApplication.topViewController()?.view.makeToast("Wrong expiry date")
            return
        }
        guard cardCvv_txt.text?.count == cvvValidator.maxLength else {
            UIApplication.topViewController()?.view.makeToast("Input valid cvv number")
            return
        }
        guard cvvValidator.validate(text: cardCvv_txt.text!) else {
            UIApplication.topViewController()?.view.makeToast("Wrong cvv number")
            return
        }
        
        delegate?.cardPayButtonClicked()
    }
}

// MARK: - CreditCardInfoTextFieldDelegate

extension MFCardView: CreditCardInfoTextFieldDelegate {
    
    func didEdit(textField: CreditCardInfoTextField, with text: String) {
        switch textField {
        case cardNumber_txt:
            cardImage.image = CreditCardImageValidator.image(side: .number(text))
            delegate?.didEdit(number: text)
        case cardExpiry_txt:
            delegate?.didEdit(expiryDate: text)
        case cardCvv_txt:
            delegate?.didEdit(cvc: text)
        default:
            break
        }
    }
    
    func didResignFirstResponder(textField: CreditCardInfoTextField) {
        switch textField {
        case cardNumber_txt:
            cardExpiry_txt.becomeFirstResponder()
        case cardExpiry_txt:
            cardCvv_txt.becomeFirstResponder()
        default:
            break
        }
        
        print("didResignFirstResponder")
    }
    
    func didBecomeFirstResponder(textField: CreditCardInfoTextField) {
        print("didBecomeFirstResponder")
        switch textField {
        case cardNumber_txt:
            cardNumberView.layer.borderColor = UIColor(hexString: "#3DB76D").cgColor
            cardNumberView.layer.borderWidth = 1.0
            cardNumberView.layoutIfNeeded()
            
            cardExpiryView.layer.borderColor = UIColor.darkGray.cgColor
            cardExpiryView.layer.borderWidth = 1.0
            cardExpiryView.layoutIfNeeded()
            cardCVVView.layer.borderColor = UIColor.darkGray.cgColor
            cardCVVView.layer.borderWidth = 1.0
            cardCVVView.layoutIfNeeded()
        case cardExpiry_txt:
            cardExpiryView.layer.borderColor = UIColor(hexString: "#3DB76D").cgColor
            cardExpiryView.layer.borderWidth = 1.0
            
            cardNumberView.layer.borderColor = UIColor.darkGray.cgColor
            cardNumberView.layer.borderWidth = 1.0
            cardCVVView.layer.borderColor = UIColor.darkGray.cgColor
            cardCVVView.layer.borderWidth = 1.0
            cardImage.image = CreditCardImageValidator.image(side: .cvc)
        case cardCvv_txt:
            cardCVVView.layer.borderColor = UIColor(hexString: "#3DB76D").cgColor
            cardCVVView.layer.borderWidth = 1.0
            
            cardNumberView.layer.borderColor = UIColor.darkGray.cgColor
            cardNumberView.layer.borderWidth = 1.0
            cardExpiryView.layer.borderColor = UIColor.darkGray.cgColor
            cardExpiryView.layer.borderWidth = 1.0
        default:
            break
        }
        self.layoutIfNeeded()
    }
}
