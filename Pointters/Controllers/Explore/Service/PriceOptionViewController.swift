//
//  PriceOptionViewController.swift
//  Pointters
//
//  Created by Mac on 2/24/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

protocol AddPriceDelegate {
    func updatePricingOption(price:Price, index:Int)
    func removePricingOption(index:Int)
}

class PriceOptionViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var lblMenuTitle: UILabel!
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var tfPrice: UITextField!
    @IBOutlet var tfDesc: UITextView!
    @IBOutlet var btnClose: UIButton!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var imgArrow: UIImageView!
    @IBOutlet var deleteView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var picker: UIPickerView!
    @IBOutlet var scrollView: UIScrollView!
    
    var updateDelegate: AddPriceDelegate?
    
    var editType = false
    var editIndex = -1
    var price = Price.init()
    var showPicker = false

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
        
        lblMenuTitle.text = (editType) ? "Edit Price Option" : "Add Price Option"
        
        addToolBar(textView: tfDesc)
 
        deleteView.isHidden = (editType) ? false : true
        bottomView.isHidden = true
        imgArrow.isHidden = false
        lblTime.isHidden = true
        
        if editType {
            btnAdd.alpha = 1.0
            btnAdd.isUserInteractionEnabled = true
            btnAdd.setTitle("Save", for: .normal)
            showPriceToEdit(info:price)
        } else {
            btnAdd.alpha = 0.3
            btnAdd.isUserInteractionEnabled = false
            btnAdd.setTitle("Add", for: .normal)
        }
    }

    func allowAddPrice() {
        if price.price >= 0 && price.desc != "" && price.time > 0 {
            btnAdd.alpha = 1.0
            btnAdd.isUserInteractionEnabled = true
        } else {
            btnAdd.alpha = 0.3
            btnAdd.isUserInteractionEnabled = false
        }
    }
    
    func setView(view: UIView, hidden: Bool) {
        self.view.endEditing(true)
        showPicker = !hidden
        UIView.transition(with: view, duration: 0.5, options: .showHideTransitionViews, animations: {
            view.isHidden = hidden
        })
    }
    
    func showPriceToEdit(info:Price) {
//        let strSymbol = (info.currencySymbol != "") ? info.currencySymbol : "$"
        tfPrice.text = String(format:"%.2f", info.price)
        tfDesc.text = info.desc
        
        if info.time > 0 && info.timeUnitOfMeasure != "" {
            imgArrow.isHidden = true
            lblTime.isHidden = false
            
            let strTime = String(format:"%d", info.time) + " " + info.timeUnitOfMeasure.capitalizingFirstLetter()
            lblTime.text = (info.time > 1) ? strTime + "s" : strTime
        } else {
            imgArrow.isHidden = false
            lblTime.isHidden = true
        }
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        if editType {
            view.endEditing(true)
            navigationController?.popViewController(animated: true)
        } else {
            view.endEditing(true)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCancelTapped(_ sender: Any) {
        setView(view: bottomView, hidden: true)
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        setView(view: bottomView, hidden: true)
        
        price.time = Int(picker.selectedRow(inComponent: 0)+1)
        price.timeUnitOfMeasure = kDeliveryTimeItems[picker.selectedRow(inComponent: 1)].lowercased()
        
        allowAddPrice()
        
        lblTime.isHidden = false
        imgArrow.isHidden = true
        
        let strTime = String(format:"%d", price.time) + " " + price.timeUnitOfMeasure.capitalizingFirstLetter()
        lblTime.text = (price.time > 1) ? strTime + "s" : strTime
    }
    
    @IBAction func btnShowTapped(_ sender: Any) {
        setView(view: bottomView, hidden: false)
    }
    
    @IBAction func btnCloseTapped(_ sender: Any) {
        tfDesc.text = ""
        price.desc = ""
        allowAddPrice()
        btnClose.isHidden = true
    }
    
    @IBAction func btnAddTapped(_ sender: Any) {
        guard price.price >= 2.0 else {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Amount must be at least $1.", buttonTitles: ["OK"], viewController: self, completion: nil)
            return
        }
        if updateDelegate != nil {
            updateDelegate?.updatePricingOption(price: price, index: editIndex)
            if editType {
                navigationController?.popViewController(animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func btnDeleteTapped(_ sender: Any) {
        if updateDelegate != nil {
            updateDelegate?.removePricingOption(index: editIndex)
            navigationController?.popViewController(animated: true)
        }
    }
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITextFieldDelegate
extension PriceOptionViewController: UITextFieldDelegate {
    
    func addToolBar(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let originText: NSString = (textField.text ?? "") as NSString
        let resultString = originText.replacingCharacters(in: range, with: string as String)
        price.currencySymbol = "$"
        price.currencyCode = "USD"
        price.price = Float(resultString) ?? 0.0
        allowAddPrice()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)  {
        let strValue = textField.text
        price.currencySymbol = "$"
        price.currencyCode = "USD"
        price.price = Float(strValue ?? "") ?? 0.0
//        if !(strValue?.isEmpty)! {
//            let startIdx = strValue!.index(strValue!.startIndex, offsetBy: 1)
//            price.currencySymbol = String(strValue![..<startIdx])
//
//            switch (price.currencySymbol) {
//                case "$":
//                    price.currencyCode = "USD"
//                    break
//                case "€":
//                    price.currencyCode = "EUR"
//                    break
//                case "£":
//                    price.currencyCode = "GBP"
//                    break
//                default:
//                    price.currencyCode = ""
//                    price.currencySymbol = ""
//                    break
//            }
//
//            if (strValue?.count)! > Int(1) {
//                let endIdx = strValue!.index(strValue!.endIndex, offsetBy: (1-strValue!.count))
//                price.price = Float(strValue![endIdx...])!
//            }
//        }
        
        allowAddPrice()
    }
}

// UITextViewDelegate
extension PriceOptionViewController: UITextViewDelegate {
    func addToolBar(textView: UITextView) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textView.text = "What's the price for... write it here"
        textView.textColor = UIColor.lightGray
        textView.delegate = self
        textView.inputAccessoryView = toolBar
    }
    
    @objc func donePressed() {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        let str = textView.text
        btnClose.isHidden = (str != "") ? false : true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let originText: NSString = (textView.text ?? "") as NSString
        let resultString = originText.replacingCharacters(in: range, with: text as String)
        price.desc = resultString
        allowAddPrice()
        
        btnClose.isHidden = (price.desc != "") ? false : true
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView)  {
        if textView.text.isEmpty {
            textView.text = "What's the price for... write it here"
            textView.textColor = UIColor.lightGray
        }
        btnClose.isHidden = true
    }
}

// UIPickerViewDataSource
extension PriceOptionViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 {
            return kDeliveryTimeItems.count
        } else {
            return 23
        }
    }
}

// UIPickerViewDelegate
extension PriceOptionViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 28.0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
            return kDeliveryTimeItems[row] + "(s)"
        } else {
            return String(format:"%d", row+1)
        }
    }
}

