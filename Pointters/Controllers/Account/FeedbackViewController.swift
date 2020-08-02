//
//  FeedbackViewController.swift
//  Pointters
//
//  Created by dreams on 11/27/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import iOSDropDown

class FeedbackViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titletxt: UITextField!
    @IBOutlet weak var category_dropDown : DropDown!
    @IBOutlet weak var select_dropDown : DropDown!
    let placeHolderText = "Please leave your feedback here."
    var feedback = ""
    var selectArray = [[String:Any]]()
    var categoryArray = [String]()
    var isShowCategory = false
    var isShowSelect = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = placeHolderText
        textView.textColor = UIColor.lightGray
        textView.layer.cornerRadius = 3
        textView.clipsToBounds = true
        textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        textView.layer.borderWidth = 1
                
        self.categoryArray = ["Order", "Service", "Job", "Offer", "Job Offer", "Customer Support", "Technical Issue", "Other"]
        category_dropDown.optionArray = self.categoryArray
        category_dropDown.selectedRowColor = UIColor.white
        
        select_dropDown.selectedRowColor = UIColor.white
        var titles = [String]()
        for item in self.selectArray {
            let title = item["title"] as! String
            titles.append(title)
        }
        select_dropDown.optionArray = titles
        
        category_dropDown.didSelect{(selectedText , index ,id) in
            self.category_dropDown.text = self.categoryArray[index]
            self.isShowCategory = false
            //order, service, offer, request-offer
            let selectCategory = self.categoryArray[index]
            if self.categoryArray[index] == "Order" || self.categoryArray[index] == "Job" || self.categoryArray[index] == "Service" || self.categoryArray[index] == "Offer" || self.categoryArray[index] == "Job Offer" {
                if selectCategory == "Order" {
                    DispatchQueue.main.async {
                        self.getDetailCategory(category: "order")
                    }
                    return
                }
                if selectCategory == "Service" {
                    DispatchQueue.main.async {
                        self.getDetailCategory(category: "service")
                    }
                    return
                }
                if selectCategory == "Offer" {
                    DispatchQueue.main.async {
                        self.getDetailCategory(category: "offer")
                    }
                    return
                }
                if selectCategory == "Job" {
                    DispatchQueue.main.async {
                        self.getDetailCategory(category: "job")
                    }
                    return
                }
                if selectCategory == "Job Offer" {
                    DispatchQueue.main.async {
                        self.getDetailCategory(category: "request-offer")
                    }
                    return
                }
            }
        }
        
        select_dropDown.didSelect{(selectedText , index ,id) in
            self.isShowSelect = false
            self.select_dropDown.text = self.selectArray[index]["title"] as? String
        }
        
    }
    
    func getDetailCategory(category: String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callDetailCategory(category: category, withCompletionHandler: { (result, statusCode, response_result, response, error) -> Void in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {                
                print(response?.value as! [[String:Any]])
                
                self.selectArray = response?.value as! [[String:Any]]
                var titles = [String]()
                for item in self.selectArray {
                    let title = item["title"] as! String
                    titles.append(title)
                }
                self.select_dropDown.optionArray = titles
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("Sorry", message: "Failed to send feedback at the moment, Please try again later.", buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        })
    }
    
    func postFeedback(feedback: String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callFeedback(feedback: feedback, withCompletionHandler:{ (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            if result == true {
                if statusCode == 200 {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Successfully sent your feedback. Thanks.", buttonTitles: ["OK"], viewController: self, completion: { (type) in
                        self.dismiss(animated: true, completion: nil)
                    })
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("Sorry", message: "Failed to send feedback at the moment, Please try again later.", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            }
            else {
                PointtersHelper.sharedInstance.stopLoader()
            }
        })
    }
    
    //MARK:- IBActions
    
    @IBAction func onClickAgree(_ sender: Any) {
        self.feedback = self.textView.text
        if self.textView.text == "" || self.textView.text == self.placeHolderText {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Please leave your feedback to send.", buttonTitles: ["OK"], viewController: self, completion: nil)
            return
        }else {
            self.postFeedback(feedback: self.feedback)
        }
        
        
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FeedbackViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = self.placeHolderText
            textView.textColor = UIColor.lightGray
            self.feedback = ""
        }
    }
}

extension FeedbackViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.category_dropDown {
            if isShowCategory {
                self.isShowCategory = false
                self.category_dropDown.hideList()
            } else {
                self.isShowCategory = true
                self.category_dropDown.showList()
            }
            return false
        } else if textField == self.select_dropDown {
            if isShowSelect {
                self.isShowSelect = false
                self.select_dropDown.hideList()
            } else {
                self.isShowSelect = true
                self.select_dropDown.showList()
            }
            return false
        } else {
            return true
        }
    }
}
