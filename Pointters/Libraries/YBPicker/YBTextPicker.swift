//
//  YBTextPicker.swift
//  YBTextPicker
//
//  Created by Yahya on 01/07/18.
//  Copyright © 2018 Yahya. All rights reserved.
//

import UIKit

enum YBTextPickerAnimation:String{
    case FromBottom
    case Fade
}

enum YBTextPickerCheckMarkPosition:String{
    case Left
    case Right
}

struct YBTextPickerAppearanceManager{
    
    var pickerTitle : String?
    var titleFont : UIFont?
    var titleTextColor : UIColor?
    var titleBackground : UIColor?
    
    var chooseButtonTitle : String?
    var chooseButtonColor : UIColor?
    var chooseButtonFont : UIFont?
    
    var checkMarkPosition : YBTextPickerCheckMarkPosition?
    var itemCheckedImage : UIImage?
    var itemUncheckedImage : UIImage?
    var itemColor : UIColor?
    var itemFont : UIFont?
    var chooseIndex: Int?
}

class YBTextPicker: UIViewController {

    //MARK:- Constants
    let animationDuration = 0.3
    let shadowAmount:CGFloat = 0.6
    let shadowColor = UIColor.black
    
    //MARK:- IBOutlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chooseAnotherLocationBtn: UIButton!
    @IBOutlet weak var containerView_heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var anotherLocationBtn_heightConstraint: NSLayoutConstraint!
                
    //MARK:- Properties
    var arrAllValues = [YBTextPickerDataModel]()
    var arrValues = [YBTextPickerDataModel]()
    
    var selectedValues = [YBTextPickerDataModel]()
    
    var preSelectedValues = [String]()
    
    var allowMultipleSelection = false
    var tapToDismiss = true
    var animation = YBTextPickerAnimation.FromBottom
    var appearanceManager : YBTextPickerAppearanceManager?
    var store: Bool = false
    
    var completionHandler : ((_ selectedIndexes:[Int], _ selectedValues:[String])->Void)?
    var cancelHandler : (()->Void)?
    
    init (
        with items : [String],
        appearance : YBTextPickerAppearanceManager?, store: Bool,
        onCompletion : @escaping (_ selectedIndexes:[Int], _ selectedValues:[String]) -> Void,
        onCancel : @escaping () -> Void
        ){
        
        super.init(nibName: "YBTextPicker", bundle: nil)
        
        for (index,textItem) in items.enumerated(){
            let dataModel = YBTextPickerDataModel.init(textItem, index)
            arrAllValues.append(dataModel)
        }
        
        self.arrValues = arrAllValues.map{$0}
        
        self.appearanceManager = appearance
        self.store = store
        
        self.completionHandler = onCompletion
        self.cancelHandler = onCancel
        
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(withAnimation animationType:YBTextPickerAnimation){
        self.animation = animationType
        if let topController = UIApplication.topViewController() {
            var shouldAnimate = false
            if animation == .FromBottom{
                shouldAnimate = true
            }
            topController.present(self, animated: shouldAnimate, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: animationDuration, animations: {
            self.shadowView.backgroundColor = self.shadowColor.withAlphaComponent(self.shadowAmount)
            
            if self.animation == .Fade {
                self.containerView.alpha = 1
            }
            
        })
    }
    
    func setupLayout(){
        tableView.register(UINib.init(nibName: "YBTextPickerCell", bundle: nil), forCellReuseIdentifier: "YBTextPickerCell")
        
        if animation == .Fade{
            containerView.alpha = 0
        }
        
        if store {
            self.chooseAnotherLocationBtn.isHidden = true
            anotherLocationBtn_heightConstraint.constant = 0
            containerView_heightConstraint.constant = CGFloat(self.arrValues.count * 50 + 50)
        } else {
            self.chooseAnotherLocationBtn.isHidden = false
            containerView_heightConstraint.constant = CGFloat(self.arrValues.count * 50 + 100)
        }
        
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 5
        
        selectedValues = arrAllValues.filter{
            preSelectedValues.contains($0.title)
        }
        if let appearance = self.appearanceManager {
            if let index = appearance.chooseIndex {
                let dataModel = arrValues[index]
                selectedValues.append(dataModel)
            }
        }
        
        if let appearance = self.appearanceManager{
            if let pTitle = appearance.pickerTitle{
                titleLabel.text = pTitle
            }
            
            if let tFont = appearance.titleFont{
                titleLabel.font = tFont
            }
            
            if let tBGColor = appearance.titleBackground{
                titleLabel.backgroundColor = tBGColor
            }
            
            if let tColor = appearance.titleTextColor{
                titleLabel.textColor = tColor
            }
                        
            if let dBtnTitle = appearance.chooseButtonTitle{
                chooseAnotherLocationBtn.setTitle(dBtnTitle, for: .normal)
            }
            
            if let dBtnColor = appearance.chooseButtonColor{
                chooseAnotherLocationBtn.setTitleColor(dBtnColor, for: .normal)
            }
            
            if let dBtnFont = appearance.chooseButtonFont{
                chooseAnotherLocationBtn.titleLabel?.font = dBtnFont
            }
        }
        
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        
        switch (deviceIdiom) {
        case .pad:
            print("iPad style UI")
        case .phone:
            print("iPhone style UI")
        case .tv:
            print("tvOS style UI")
        default:
            print("Unspecified UI idiom")
        }
    }
    
    //MARK:- Button Clicks
        
    @IBAction func ChooseAnotherLocationAction(_ sender: Any) {
        
        cancelHandler?()
        closePicker()
    }
    
    func closePicker(){
        UIView.animate(withDuration: animationDuration, animations: {
            self.shadowView.backgroundColor = .clear
            
            if self.animation == .Fade{
                self.containerView.alpha = 0
            }
            
        }) { (completed) in
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

}

extension YBTextPicker : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YBTextPickerCell", for: indexPath) as! YBTextPickerCell
        
        let dataModel = arrValues[indexPath.row]
        
        
        cell.lblItem.text = dataModel.title
        
        var chkImage:UIImage? = nil
        
        if selectedValues.contains(dataModel)
        {
            chkImage = #imageLiteral(resourceName: "YBTextPicker_checked.png")
        }else{
            chkImage = #imageLiteral(resourceName: "YBTextPicker_unchecked.png")
        }
        
        cell.widthOfImgTrailingCheck.constant = 0.0
        
        if let appearance = self.appearanceManager{
            if let itFont = appearance.itemFont{
                cell.lblItem.font = itFont
            }
            if let itColor = appearance.itemColor{
                cell.lblItem.textColor = itColor
            }
            
            if let itCheckedImage = appearance.itemCheckedImage{
                if selectedValues.contains(dataModel)
                {
                    chkImage = itCheckedImage
                }
            }
            if let itUncheckedImage = appearance.itemUncheckedImage{
                if selectedValues.contains(dataModel) == false
                {
                    chkImage = itUncheckedImage
                }
            }
            if let checkMarkPosition = appearance.checkMarkPosition{
                let checkMarkWidth:CGFloat = 26.0
                if checkMarkPosition == .Right{
                    cell.widthOfImgTrailingCheck.constant = checkMarkWidth
                    cell.widthOfImgLeadingCheck.constant = 0
                }else{
                    cell.widthOfImgLeadingCheck.constant = checkMarkWidth
                    cell.widthOfImgTrailingCheck.constant = 0
                }
            }
        }
        
        cell.imgTrailingCheck.image = chkImage
        cell.imgLeadingCheck.image = chkImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrValues.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if allowMultipleSelection == false {
            selectedValues = [YBTextPickerDataModel]()
        }

        let dataModel = arrValues[indexPath.row]
        if selectedValues.contains(dataModel){
            selectedValues.removeAll{ $0 == dataModel }
        }else{
            selectedValues.append(dataModel)
        }
        
        var cellsToReload = [IndexPath]()
        if allowMultipleSelection == false {
            cellsToReload = tableView.indexPathsForVisibleRows!
            //RELOAD ALL VISIBLE CELLS SO THAT PREVIOUSLY SELECTED CELL GETS DE-SELECTED
        }else{
            cellsToReload = [indexPath]
            //SELECT OR DE-SELECT CURRENT CELL (NO NEED TO RELOAD OTHER CELLS)
        }
        tableView.reloadRows(at: cellsToReload, with: .fade)
        let indexes = selectedValues.map{$0.identity!}
        let values = selectedValues.map{$0.title!}
        completionHandler?(indexes, values)
        
        closePicker()
    }
    
}

//extension UIApplication {
//    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
//        if let navigationController = controller as? UINavigationController {
//            return topViewController(controller: navigationController.visibleViewController)
//        }
//        if let tabController = controller as? UITabBarController {
//            if let selected = tabController.selectedViewController {
//                return topViewController(controller: selected)
//            }
//        }
//        if let presented = controller?.presentedViewController {
//            return topViewController(controller: presented)
//        }
//        return controller
//    }
//}
