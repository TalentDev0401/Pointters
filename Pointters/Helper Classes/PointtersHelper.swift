//
//  PointtersHelper.swift
//  Pointters
//
//  Created by Mac on 2/10/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAnalytics

class PointtersHelper: NSObject {

    var progressHud = MBProgressHUD()

    // structor
    class var sharedInstance: PointtersHelper {
        struct Static {
            static let instance = PointtersHelper()
        }

        return Static.instance
    }

    // main window
    func mainWindow() -> UIWindow {
        let app = UIApplication.shared.delegate as? AppDelegate
        return (app?.window!)!
    }

    // check if device is iPhone_X
    func checkiPhonX() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
        }
        return false
    }

    // check if device is iPhone 5 or iPhone 5s
    func checkiPhon5() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height == 1136 {
                return true
            }
        }
        return false
    }

    // check if email is valid
    func isValidEmail(_ checkString: String) -> Bool {
        let stricterFilter: Bool = false
        let stricterFilterString: String = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
        let laxString: String = ".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*"
        let emailRegex: String = stricterFilter ? stricterFilterString : laxString
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let result: Bool = emailTest.evaluate(with: checkString)

        return result
    }

    func formatTaxId(tax: String) -> String {
        var taxStr = tax
        let indexItem = taxStr.index(taxStr.startIndex, offsetBy: 2)
        taxStr.insert("-", at: indexItem)
        return taxStr
    }

    func isValidPassword(_ checkString: String) -> Bool {
        let regex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d$@$!%*#?&]{6,}$"
        let paswordTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return paswordTest.evaluate(with: checkString)
    }

    // show the alert view
    func showAlertViewWithTitle(_ title: String?, message: String, buttonTitles: [String], viewController: UIViewController, completion: ((_ index: Int) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for buttonTitle in buttonTitles {
            let alertAction = UIAlertAction(title: buttonTitle, style: .default, handler: { (action: UIAlertAction) in
                completion?(buttonTitles.index(of: buttonTitle)!)
            })
            alertController .addAction(alertAction)
        }
        viewController .present(alertController, animated: true, completion: nil)
    }

    // show MB Progress Hud
    func startLoader(view: UIView) {
        progressHud = MBProgressHUD.showAdded(to: view, animated: true)
        progressHud.bezelView.color = UIColor(red: (255.0 / 255.0), green: (255.0 / 255.0), blue: (255.0 / 255.0), alpha: 0.8)
        progressHud .show(animated: true)
    }

    // hide MB Progress Hud
    func stopLoader() {
        progressHud .hide(animated: true)
    }
        
    // get current time
    func getCurrentDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.string(from: Date())
    }

    func generateAWSContentType(withExtension: String) -> String {
        switch withExtension {
        case "pdf":
            return "application/pdf"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "ppt":
            return "application/vnd.ms-powerpoint"
        case "pptx":
            return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "xls":
            return "application/vnd.ms-excel"
        case "xlsx":
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "zip":
            return "application/zip"
        case "jpg", "png", "jpeg":
            return "image/jpeg"
        case "avi":
            return "video/x-msvideo"
        case "mp4", "mov", "MOV":
            return "video/mp4"
        default:
            return "image/jpeg"
        }
    }

    func generateMediaType(withExtension: String) -> String {
        switch withExtension {
        case "pdf", "doc", "docx", "ppt", "pptx", "xls", "xlsx", "zip":
            return "document"
        case "jpg", "png", "jpeg":
            return "image"
        case "mp4", "mov", "avi", "MOV":
            return "video"
        default:
            return "image"
        }
    }

    // phone call
    func callByPhone(phone: String, ctrl: UIViewController) {
        if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            showAlertViewWithTitle("", message: "Invalid Phone No.", buttonTitles: ["OK"], viewController: ctrl, completion: nil)
        }
    }

    // number format
    func formatCount(value: Int) -> String {
        var str = ""

        if value >= 1000000 {
            str = String(format: "%.1f", Double(value) / 1000000.0) + "M"
        } else if value >= 1000 {
            str = String(format: "%.1f", Double(value) / 1000.0) + "K"
        } else {
            str = String(format: "%d", value)
        }

        return str
    }

    // facebook login manager
    func loginWithFacebookFromViewController(viewController: UIViewController, completetionBlock: @escaping (String?, _ error: NSError?) -> Void) {
        if (AccessToken.current != nil) {
            let fbAccessToken = AccessToken.current?.tokenString
            print(fbAccessToken!)

            completetionBlock(fbAccessToken, nil)
        } else {            
            let fbLoginManager : LoginManager = LoginManager()
//            fbLoginManager.logOut()
            fbLoginManager.logIn(permissions: ["public_profile", "email"], from: viewController, handler: { (result, error) in

                    if (error != nil) {
                        completetionBlock("", error as NSError?)
                    }
                    else if (result?.isCancelled)! {
                        completetionBlock("", nil)
                    }
                    else {
                        let fbAccessToken = AccessToken.current?.tokenString
                        print(fbAccessToken ?? "")

                        completetionBlock(fbAccessToken, nil)
                    }
            })
        }
    }

    func sendAnalyticsToFirebase(event: String) {
        Analytics.logEvent(event, parameters: [
            AnalyticsParameterItemID: UserCache.sharedInstance.getAccountData().id,
            AnalyticsParameterItemName: UserCache.sharedInstance.getAccountData().email,
            AnalyticsParameterContentType: "Event",
            "Platform": "iOS"
            ])
    }

    func markAsReadNotification(id: String) {
        ApiHandler.callMarkAsRead(id: id, withCompletionHandler: { (result, statusCode, response) in
            if result == true {
                print("Success: Mark as read notification.")
            } else {
                print(response.error ?? "")
            }
        })
    }

    func RoundEffectView(view: UIView) {
        view.backgroundColor = .cyan
        view.layer.cornerRadius = view.frame.size.height / 2
        //view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        //view.layer.shadowRadius = 5
        //view.layer.shadowOffset = .zero
        //view.layer.shadowOpacity = 1
    }
}
