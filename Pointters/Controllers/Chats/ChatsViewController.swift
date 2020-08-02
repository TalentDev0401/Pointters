//
//  ChatsViewController.swift
//  Pointters
//
//  Created by Mac on 2/14/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class ChatsViewController: UIViewController {
    
    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var conversationsList = [[String:Any]]()
    
    var currentPage = 1
    var totalPages = 0
    var lastDocId = ""
    
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
            consNavBarHeight.constant = 137.0
        } else {
            consNavBarHeight.constant = 116.0
        }
        searchBar.textField?.clearButtonMode = .always
        
        guard let conversations = appDelegate.conversationsList else {
            callConversationsAPI(inited: true, lastId: self.lastDocId)
            return
        }
        self.conversationsList = conversations
    }
    
    @objc func hideKeyBoard(sender: UITapGestureRecognizer? = nil) {
        if conversationsList.count == 0 {
            view.endEditing(true)
        }else{
            view.removeGestureRecognizer(sender!)
        }
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnCreateTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        let sendServicesVC = storyboard.instantiateViewController(withIdentifier: "SendServicesVC") as! SendServicesViewController
        navigationController?.pushViewController(sendServicesVC, animated: true)
    }
    
    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    func callConversationsAPI(inited: Bool, lastId: String) {
        if inited {
            PointtersHelper.sharedInstance.startLoader(view: view)
            self.lastDocId = ""
        }
        ApiHandler.callConversations(lastId: self.lastDocId, withCompletionHandler: { (result,statusCode,response) in
            if inited {
                PointtersHelper.sharedInstance.stopLoader()
                self.conversationsList.removeAll()
            }
            self.view.endEditing(true)
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.currentPage = responseDict["page"] as! Int + 1
                    self.totalPages = responseDict["pages"] as! Int
                    self.lastDocId = responseDict["lastDocId"] as! String
                    if let arr = responseDict["docs"] as? [[String : Any]] {
                        for conversation in arr {
                            self.conversationsList.append(conversation)
                        }
                    }
                    appDelegate.conversationsList = self.conversationsList
                    self.tableView.reloadData()
                    if self.conversationsList.count == 0 {
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyBoard))
                        self.view.addGestureRecognizer(tap)
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                print(response.error ?? "")
            }
        })
    }
    
    func callConversationsSearchAPI(filterString:String) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callConversationsSearch(query: filterString, withCompletionHandler: { (result,statusCode,response,error) in
            PointtersHelper.sharedInstance.stopLoader()
            self.view.endEditing(true)
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    let hits = responseDict["hits"] as! [String:Any]
                    self.conversationsList = hits["hits"] as! [[String:Any]]
                    self.tableView.reloadData()
                    if self.conversationsList.count == 0 {
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyBoard))
                        self.view.addGestureRecognizer(tap)
                    }
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        })
    }
    
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITableViewDataSource
extension ChatsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversationsList.count
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell") as! ConversationCell
        cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height/2
        cell.imgUser.layer.masksToBounds = true
        if conversationsList.count > 0{
            let itemConversation : [String:Any] = self.conversationsList[indexPath.row]
            var item = [String:Any]()
            if itemConversation.keys.contains("_source"){
                item = itemConversation["_source"] as! [String : Any]
            }else{
                item = itemConversation
            }
            let itemUsers : [[String : Any]] = item["users"] as! [[String:Any]]
            let itemUser = itemUsers[0]
            if itemUser.keys.contains("profilePic"){
                let profilePic = itemUser["profilePic"] as! String
                cell.imgUser.sd_imageTransition = .fade
                cell.imgUser.sd_setImage(with: URL(string: profilePic), placeholderImage: UIImage(named:"user_avatar_placeholder"))
            } else {
                cell.imgUser.image = UIImage(named:"user_avatar_placeholder")
            }
            if itemUser.keys.contains("firstName") && itemUser.keys.contains("lastName"){
                cell.lblName.text = "\(itemUser["firstName"] as! String) \(itemUser["lastName"] as! String)"
            }
            if item.keys.contains("countNewMessages") {
                let countNewMessages = item["countNewMessages"] as! Int
                cell.imgOnline.isHidden = !(countNewMessages > 0)
            }
            if item.keys.contains("lastMessage") {
                let lastMessage : [String:Any] = item["lastMessage"] as! [String:Any]
                let lastName : String = lastMessage["lastName"] as! String
                cell.lblMessage.text = "\(lastMessage["firstName"] as! String) \(lastName.substring(to: lastName.index(lastName.startIndex, offsetBy:1))). : \(lastMessage["message"] as! String)"
                let messageTimeString = lastMessage["time"] as! String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                let messageTime = dateFormatter.date(from:messageTimeString)!
                let calendar = Calendar.current
                if calendar.isDateInToday(messageTime){
                    cell.lblTime.text = "\(calendar.component(.hour, from: messageTime)):\(calendar.component(.minute, from: messageTime))"
                }else{
                    cell.lblTime.text = "\(calendar.component(.month, from: messageTime))/\(calendar.component(.day, from: messageTime))"
                }
            }
        }
        return cell
    }
}

// UITableViewDelegate
extension ChatsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == conversationsList.count - 1) && (self.currentPage - 1 < self.totalPages) {
            callConversationsAPI(inited: false, lastId: self.lastDocId)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchBar.resignFirstResponder()
        let privateChatVC = storyboard?.instantiateViewController(withIdentifier: "PrivateChatVC") as! PrivateChatViewController
        if self.conversationsList.count > 0 {
            let itemConversation : [String:Any] = self.conversationsList[indexPath.row]
            privateChatVC.conversationId = itemConversation["_id"] as! String
            var item = [String:Any]()
            if itemConversation.keys.contains("_source"){
                item = itemConversation["_source"] as! [String : Any]
            }else{
                item = itemConversation
            }
            let itemUsers : [[String : Any]] = item["users"] as! [[String:Any]]
            let itemUser = itemUsers[0]
            if itemUser.keys.contains("profilePic"){
                let profilePic = itemUser["profilePic"] as! String
                privateChatVC.otherUserPic = profilePic
            } else {
                privateChatVC.otherUserPic = ""
            }
            if itemUser.keys.contains("firstName") && itemUser.keys.contains("lastName"){
                privateChatVC.otherUsername = "\(itemUser["firstName"] as! String) \(itemUser["lastName"] as! String)"
            } else {
                privateChatVC.otherUsername = ""
            }
            if let _ = itemUser["userId"]{
                privateChatVC.otherUserId = itemUser["userId"] as! String
                navigationController?.pushViewController(privateChatVC, animated: true)
            }else{
                PointtersHelper.sharedInstance.showAlertViewWithTitle("Warning", message: "User doesn't exist.", buttonTitles: ["OK"], viewController: self, completion: nil)
            }
            
        }
    }
}

extension ChatsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            self.callConversationsAPI(inited: true, lastId: self.lastDocId)
        }else{
            self.callConversationsSearchAPI(filterString:searchBar.text!)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0
        {
            self.lastDocId = ""
            callConversationsAPI(inited: true, lastId: self.lastDocId)
        }
    }
    
}

//extension ChatsViewController: UITextFieldDelegate {
//    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        self.lastDocId = ""
//        callConversationsAPI(inited: true, lastId: self.lastDocId)
//        return textField.resignFirstResponder()
//    }
//}

//extension UISearchBar {
//    var textField : UITextField {
//        return self.value(forKey: "_searchField") as! UITextField
//    }
//}

