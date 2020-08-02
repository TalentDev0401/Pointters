//
//  Extensions.swift
//  Pointters
//
//  Created by Mac on 2/15/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import Foundation
import UIKit
import CryptoSwift
import SystemConfiguration
import NVActivityIndicatorView

let appDelegate = UIApplication.shared.delegate as! AppDelegate

func changeDays(date: Date, component: Calendar.Component, by days: Int) -> Date? {
    return Calendar.current.date(byAdding: .day, value: days, to: date)!
}

extension URL {

    func value(for paramater: String) -> String? {

        let queryItems = URLComponents(string: self.absoluteString)?.queryItems
        let queryItem = queryItems?.filter({$0.name == paramater}).first
        let value = queryItem?.value

        return value
    }

}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {

        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }

        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }

        return self
    }
}


extension Date {

    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {

        let currentCalendar = Calendar.current

        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }

        return end - start
    }
}

// UIColor
extension UIColor {
    static func getCustomBlueColor() -> UIColor {
        return UIColor(red:0.0/255.0, green: 180.0/255.0, blue: 241.0/255.0, alpha: 1.0)
    }

    static func getCustomLightBlueColor() -> UIColor {
        return UIColor(red:0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }

    static func getCustomGrayTextColor() -> UIColor {
        return UIColor(red:142.0/255.0, green: 142.0/255.0, blue: 147.0/255.0, alpha: 1.0)
    }

    static func getCustomGrayColor() -> UIColor {
        return UIColor(red:235.0/255.0, green: 235.0/255.0, blue: 241.0/255.0, alpha: 1.0)
    }

    public convenience init(hex: UInt32) {
        let mask = 0x000000FF

        let r = Int(hex >> 16) & mask
        let g = Int(hex >> 8) & mask
        let b = Int(hex) & mask

        let red   = CGFloat(r) / 255
        let green = CGFloat(g) / 255
        let blue  = CGFloat(b) / 255

        self.init(red:red, green:green, blue:blue, alpha:1)
    }
}

// UIColor(hex color)
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

public extension UIColor {
    class func color(_ hexString: String) -> UIColor? {
        if (hexString.count > 7 || hexString.count < 7) {
            return nil
        } else {
            let hexInt = Int(String(hexString[hexString.index(hexString.startIndex, offsetBy: 1)...]), radix: 16)
            if let hex = hexInt {
                let components = (
                    R: CGFloat((hex >> 16) & 0xff) / 255,
                    G: CGFloat((hex >> 08) & 0xff) / 255,
                    B: CGFloat((hex >> 00) & 0xff) / 255
                )
                return UIColor(red: components.R, green: components.G, blue: components.B, alpha: 1)
            } else {
                return nil
            }
        }
    }
}

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)

        return ceil(boundingBox.width)
    }
}

// String
extension String {
    func aesEncrypt(key: String, iv: String) throws -> String {
        let data = self.data(using: .utf8)!
        let gcm = GCM(iv: iv.bytes, mode: .combined)
        let encrypted = try! AES(key: key.bytes, blockMode: gcm, padding: .pkcs7).encrypt([UInt8](data))
        let encryptedData = Data(encrypted)
        return encryptedData.base64EncodedString()
    }

    func aesDecrypt(key: String, iv: String) throws -> String {
        let data = Data(base64Encoded: self)!
        let gcm = GCM(iv: iv.bytes, mode: .combined)
        let decrypted = try! AES(key: key.bytes, blockMode: gcm, padding: .pkcs7).decrypt([UInt8](data))
        let decryptedData = Data(decrypted)
        return String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Could not decrypt"
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }

    mutating func insert(string:String,ind:Int) {
        self.insert(contentsOf: string, at:string.index(string.startIndex, offsetBy: ind) )
    }

    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}

// Date
extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offsetOmit(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))Y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
    /// Returns the a custom time interval description from another date
    func offsetFull(from date: Date) -> String {
        if years(from: date)   > 0 { return (years(from: date) == 1)   ?  "\(years(from: date)) Year"   :  "\(years(from: date)) Years"   }
        if months(from: date)  > 0 { return (months(from: date) == 1)  ?  "\(months(from: date)) Month" :  "\(months(from: date)) Months" }
        if weeks(from: date)   > 0 { return (weeks(from: date) == 1)   ?  "\(weeks(from: date)) week"   :  "\(weeks(from: date)) weeks"   }
        if days(from: date)    > 0 { return (days(from: date) == 1)    ?  "\(days(from: date)) day"     :  "\(days(from: date)) days"     }
        if hours(from: date)   > 0 { return (hours(from: date) == 1)   ?  "\(hours(from: date)) hour"   :  "\(hours(from: date)) hours"   }
        if minutes(from: date) > 0 { return (minutes(from: date) == 1) ?  "\(minutes(from: date)) min"  :  "\(minutes(from: date)) mins"  }
        if seconds(from: date) > 0 { return (seconds(from: date) == 1) ?  "\(seconds(from: date)) sec"  :  "\(seconds(from: date)) secs"  }
        return ""
    }
}

extension NSDictionary {
    func getSortedKeys() -> [String] {
        return self.allKeys.sorted { (d1, d2) -> Bool in
            return d2 as! String > d1 as! String
        } as! [String]
    }

    func getSortedKeysDesc() -> [String] {
        return self.allKeys.sorted { (d1, d2) -> Bool in
            return d1 as! String > d2 as! String
            } as! [String]
    }
}

extension Int {
    static func formatedTimeString(number: Int) -> String{
        if number < 10 {
            return "0\(number)"
        } else {
            return "\(number)"
        }
    }
}

extension UITextView{

    func setPlaceholder(placeholder: String) {

        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholder
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (self.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 222
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !self.text.isEmpty

        self.addSubview(placeholderLabel)
    }

    func checkPlaceholder() {
        let placeholderLabel = self.viewWithTag(222) as! UILabel
        placeholderLabel.isHidden = !self.text.isEmpty
    }

}

extension UIImage {
    class func imageWithColor(_ color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
    var userInfo: [String: Any] { return (self as NSError).userInfo }
}

extension UISearchBar {

    var textField : UITextField? {
        if #available(iOS 13.0, *) {
            return self.searchTextField
        } else {
            // Fallback on earlier versions
            return value(forKey: "_searchField") as? UITextField
        }
        return nil
    }
}

extension UIViewController: NVActivityIndicatorViewable {
    //MARK: Show Loading view
    func startLoader() {
        
        // - Starting loading view
        let size = CGSize(width: 70, height: 70)
        startAnimating(size, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader, fadeInAnimation: nil)
    }
    
    //MARK: Dismiss loading view
    func stopLoader() {
        
        // - Dismiss loading view
        self.stopAnimating(nil)
    }
}
