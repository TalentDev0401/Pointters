//
//  AppDelegate.swift
//  Pointters
//
//  Created by Mac on 2/10/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Fabric
import Crashlytics
import GooglePlaces
import CoreLocation
import Stripe
import Firebase
import FirebaseMessaging
import UserNotifications
import IQKeyboardManagerSwift
import Paystack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()
    var webservice: PushWebservice!
    var logout: Bool = false
    
    /**
     * Explore public page
     */
    var arrBanner : [[String:Any]]?
    var popularCategories : [[String:Any]]?
    var popularServices : [[String:Any]]?
    var popularJobs : [[String:Any]]?
    var localServices : [[String:Any]]?
    var localJobs : [[String:Any]]?
    var bestSellers : [[String:Any]]?
    var onlineServices : [[String:Any]]?
    var onlineJobs : [[String:Any]]?
    
    /**
     * Updates page
     */
    var arrPosts : [Update]?
    
    /**
     * Chat page
     */
    var conversationsList : [[String:Any]]?
    
    /**
     * User Account page
     */
    var userProfile : Profile?
    var userDetails : UserMenu?
    var badgeNumbers : [String:Any]?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // PayPal initialize
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction:PaypalKeyManager.Production ,PayPalEnvironmentSandbox:PaypalKeyManager.Sandbox])
        
        // Paystack initialize
        Paystack.setDefaultPublicKey(PaystackManager.test)
        
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        IQKeyboardManager.shared.enable = true
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        STPPaymentConfiguration.shared().publishableKey = kStripeCredentials.apiKey
        STPPaymentConfiguration.shared().appleMerchantIdentifier = kApplePayMerchantId.key
        GMSPlacesClient.provideAPIKey(kGMSCredentials.kGmsApiKey)
        setupLocationManager()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        self.webservice = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        application.registerForRemoteNotifications()
        
        if let userDict = UserCache.sharedInstance.getUserCredentials() {
            if let val = userDict[kUserCredentials.kLoginType] as? String {
                if val == "E" || val == "F" {
                    if let registered = userDict[kUserCredentials.kCompletedRegistration] as? Bool, registered == true {
                        openServicesScreen(selectedTabIndex: 0)
                    } else {
                        openSplashScreen()
                    }
                } else {
                    openSplashScreen()
                }
            }
        } else {
            if UserDefaults.standard.value(forKey: "isOpen") == nil {
                UserDefaults.standard.setValue(true, forKeyPath: "isOpen")
            } else {
                openServicesScreen(selectedTabIndex: 0)
            }
        }
        
        if let option = launchOptions {
            let info = option[UIApplicationLaunchOptionsKey.remoteNotification]
            if (info != nil) {
                managePushNotification(state: application.applicationState, userInfo:info as! [AnyHashable : Any])
            }
        }
        
        if UserCache.sharedInstance.getUserAuthToken() == nil {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        return true
    }
    
    func setNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = self
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        print("latitude: \(userLocation.coordinate.latitude), longitude: \(userLocation.coordinate.longitude)")
        UserCache.sharedInstance.setUserLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        getAddressFromLatLon(pdblLatitude: userLocation.coordinate.latitude, withLongitude: userLocation.coordinate.longitude)
        locationManager.stopUpdatingLocation()
    }
    
    func openServicesScreen(selectedTabIndex: Int) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let containerNavVC = storyBoard.instantiateViewController(withIdentifier: "ContainerTabsNavVC") as! UINavigationController
        let containerVC = storyBoard.instantiateViewController(withIdentifier: "ContainerTabVC") as! ContainerTabViewController
        containerNavVC.viewControllers = [containerVC]
        containerVC.selectedExplorerTabIndex = selectedTabIndex
        let window: UIWindow = PointtersHelper.sharedInstance.mainWindow()
        window.rootViewController = containerNavVC
        window.makeKeyAndVisible()
    }
    
    func openSplashScreen() {
        let storyBoard = UIStoryboard(name: "Auth", bundle: nil)
        let introNavVC = storyBoard.instantiateViewController(withIdentifier: "IntroNavVC") as! UINavigationController
        let introVC = storyBoard.instantiateViewController(withIdentifier: "IntroSplashVC") as! IntroSplashViewController
        introNavVC.viewControllers = [introVC]
        
        let window: UIWindow = PointtersHelper.sharedInstance.mainWindow()
        window.rootViewController = introNavVC
        window.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
         if url.scheme != nil && url.scheme!.hasPrefix("fb\(kFBCredentials.kFBAppId)") && url.host ==  "authorize"{
            return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        if url.scheme!.hasPrefix(pointterDeepLink) {
            if let type = url.value(for: "type") {
                var id = ""
                if let _ = url.value(for: "id") {
                    id = url.value(for: "id")!
                }
                if UserCache.sharedInstance.getUserAuthToken() == nil && type != kRedirectKey.resetPassword && type != kRedirectKey.signup{
                    return false
                }
                switch type{
                case kRedirectKey.serviceKey:
                    self.gotoServiceDetailPage(serviceId: id)
                case kRedirectKey.offerKey:
                    self.gotoOfferDetailPage(offerId: id)
                case kRedirectKey.requestKey:
                    self.gotoRequestDetailPage(requestId: id)
                case kRedirectKey.requestOfferKey:
                    self.gotoRequestOfferPage(offerId: id)
                case kRedirectKey.postKey:
                    let likeCount: Int = Int(url.value(for: kFCMMessageIDKey.fcmPayloadLikeCount) ?? "0")!
                    let commentCount: Int = Int(url.value(for: kFCMMessageIDKey.fcmPayloadCommentCount) ?? "0")!
                    let shareCount: Int  = Int(url.value(for: kFCMMessageIDKey.fcmPayloadShareCount) ?? "0")!
                    let subType: String = url.value(for: kFCMMessageIDKey.fcmPayloadPostSubType)!
                    self.gotoPostPage(postId: id, likeCount: likeCount, commentCount: commentCount, shareCount: shareCount, subType: subType)
                case kRedirectKey.userProfileKey:
                    self.gotoUserProfilePage(userId: id)
                case kRedirectKey.orderKey:
                    self.gotoOrderPage(orderId: id)
                case kRedirectKey.resetPassword:
                    if let verifyCode = url.value(for: "verifyCode"), let email = url.value(for: "email") {
                        self.gotoResetPassword(email: email, passcode: verifyCode)
                    }
                case kRedirectKey.signup:
                    if let verifyCode = url.value(for: "verifyCode") {
                        self.gotoPasscode(passcode: verifyCode)
                    }
                default: break
                }
                return true
            }
        }
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme != nil && url.scheme!.hasPrefix("fb\(kFBCredentials.kFBAppId)") && url.host ==  "authorize" {
            let fbLogin = ApplicationDelegate.shared.application(app, open: url, options: options)
            return fbLogin
        }
        if url.scheme != nil && url.scheme!.hasPrefix(pointterDeepLink) && url.host == "app" {
            return self.application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.sourceApplication] as Any)
        }
        return false
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        completionHandler(UIBackgroundFetchResult.newData)
    
    }
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }

    func managePushNotification(state: UIApplicationState, userInfo: [AnyHashable: Any]){
        if UserCache.sharedInstance.getUserAuthToken() == nil {
            return
        }
        if let notificationId = userInfo["notificationId"] as? String  {
            PointtersHelper.sharedInstance.markAsReadNotification(id: notificationId)
        }
        if let aps = userInfo["aps"] as? NSDictionary  {
            if let alert = aps["alert"] as? NSDictionary {
                if let _ = alert["body"] as? String, let _ = alert["title"] as? String {
                    var payload_id = ""
                    if let id = userInfo[kFCMMessageIDKey.fcmPayloadValue] as? String {
                        payload_id = id
                    }
                    var payload_key = ""
                    if let key = userInfo[kFCMMessageIDKey.fcmPayloadKey] as? String {
                        payload_key = key
                    }
                    if let payload_badge = userInfo[kFCMMessageIDKey.fcmPayloadBadge]{
                        UIApplication.shared.applicationIconBadgeNumber = Int(payload_badge as! String)!
                    }
                                                            
                    switch payload_key{
                    case kRedirectKey.serviceKey:
                        self.gotoServiceDetailPage(serviceId: payload_id)
                    case kRedirectKey.offerKey:
                        self.gotoOfferDetailPage(offerId: payload_id)
                    case kRedirectKey.requestKey:
                        self.gotoRequestDetailPage(requestId: payload_id)
                    case kRedirectKey.requestOfferKey:
                        self.gotoRequestOfferPage(offerId: payload_id)
                    case kRedirectKey.liveOfferKey:
                        self.openServicesScreen(selectedTabIndex: 1)
                    case kRedirectKey.postKey:
                        let likeCount = Int(userInfo[kFCMMessageIDKey.fcmPayloadLikeCount] as! String)
                        let commentsCount = Int(userInfo[kFCMMessageIDKey.fcmPayloadCommentCount] as! String)
                        let shareCount = Int(userInfo[kFCMMessageIDKey.fcmPayloadShareCount] as! String)
                        let subType = userInfo[kFCMMessageIDKey.fcmPayloadPostSubType] as! String
                        self.gotoPostPage(postId: payload_id, likeCount: likeCount!, commentCount: commentsCount!, shareCount: shareCount!, subType: subType)
                    case kRedirectKey.userProfileKey:
                        self.gotoUserProfilePage(userId: payload_id)
                    case kRedirectKey.orderKey:
                        self.gotoOrderPage(orderId: payload_id)
                    case kRedirectKey.chatKey:
                        let userId = userInfo[kFCMMessageIDKey.fcmPayloadChatUserId] as! String
                        let firstName = userInfo[kFCMMessageIDKey.fcmPayloadChatUserFirstName] as! String
                        let lastName = userInfo[kFCMMessageIDKey.fcmPayloadChatUserLastName] as! String
                        let profilePic = userInfo[kFCMMessageIDKey.fcmPayloadChatUserPic] as! String
                        let verified = (userInfo[kFCMMessageIDKey.fcmPayloadChatUserVerified] as! NSString).boolValue
                        self.gotoChatpage(chatId: payload_id, userId: userId, firstName: firstName, lastName: lastName, profilePic: profilePic, verified: verified)
                    default: break

                    }
                    
                }
            } else if let alert = aps["alert"] as? NSString {
                print(alert)
            }
        }
    }
    
    func gotoServiceDetailPage(serviceId: String){
        let topMostViewController = UIApplication.shared.topMostViewController()
        let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
        let serviceDetailVC = storyboard.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailViewController
        serviceDetailVC.serviceId = serviceId
        topMostViewController?.navigationController?.pushViewController(serviceDetailVC, animated: true)
    }
    
    func gotoOfferDetailPage(offerId: String){
        let topMostViewController = UIApplication.shared.topMostViewController()
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let offerDetailVC = storyboard.instantiateViewController(withIdentifier: "OfferDetailVC") as! OfferDetailViewController
        offerDetailVC.offerId = offerId
        offerDetailVC.offerFlag = 1
        topMostViewController?.navigationController?.pushViewController(offerDetailVC, animated: true)
    }
    
    func gotoRequestDetailPage(requestId: String){
        let topMostViewController = UIApplication.shared.topMostViewController()
        let storyboard = UIStoryboard.init(name: "Explore", bundle: nil)
        let requestDetailVC = storyboard.instantiateViewController(withIdentifier: "RequestDetailVC") as! RequestDetailViewController
        requestDetailVC.pageFlag = 0
        requestDetailVC.requestId = requestId
        topMostViewController?.navigationController?.pushViewController(requestDetailVC, animated: true)
    }
    
    func gotoRequestOfferPage(offerId: String){
        let topMostViewController = UIApplication.shared.topMostViewController()
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let offerDetailVC = storyboard.instantiateViewController(withIdentifier: "OfferDetailVC") as! OfferDetailViewController
        offerDetailVC.offerId = offerId
        offerDetailVC.offerFlag = 1
        topMostViewController?.navigationController?.pushViewController(offerDetailVC, animated: true)
    }
    
    func gotoPostPage(postId: String, likeCount: Int, commentCount: Int, shareCount: Int, subType: String){
        let topMostViewController = UIApplication.shared.topMostViewController()
        let storyboard = UIStoryboard.init(name: "Updates", bundle: nil)
        let postCommentsVC = storyboard.instantiateViewController(withIdentifier: "PostCommentsVC") as! PostCommentsViewController
        if subType == "like" {
            postCommentsVC.tabSelectIndex = 0
        } else if subType == "comment" {
            postCommentsVC.tabSelectIndex = 1
        } else {
            postCommentsVC.tabSelectIndex = 2
        }
        postCommentsVC.postId = postId
        postCommentsVC.countLikes = likeCount
        postCommentsVC.countComments = commentCount
        postCommentsVC.countShares = shareCount
        topMostViewController?.navigationController?.pushViewController(postCommentsVC, animated: true)
    }
    
    func gotoUserProfilePage(userId: String){
        let topMostViewController = UIApplication.shared.topMostViewController()
        let storyboard = UIStoryboard.init(name: "Account", bundle: nil)
        let strOtherId = userId
        if strOtherId == UserCache.sharedInstance.getAccountData().id {
            UserCache.sharedInstance.setProfileUser(loginUser: true, userId: "")
        } else {
            UserCache.sharedInstance.setProfileUser(loginUser: false, userId: strOtherId)
        }
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
        topMostViewController?.navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func gotoOrderPage(orderId: String){
        let topMostViewController = UIApplication.shared.topMostViewController()
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let fulfillmentVC = storyboard.instantiateViewController(withIdentifier: "FulfillmentVC") as! FulfillmentViewController
        fulfillmentVC.orderId = orderId
        topMostViewController?.navigationController?.pushViewController(fulfillmentVC, animated: true)
    }
    
    func gotoChatpage(chatId: String, userId: String, firstName: String, lastName: String, profilePic: String, verified: Bool) {
        UserCache.sharedInstance.setChatCredentials(id: chatId, userId: userId, name: "\(firstName) \(lastName)", pic: profilePic, verified: verified)
        let topMostViewController = UIApplication.shared.topMostViewController()
        let storyboard = UIStoryboard.init(name: "Chats", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PrivateChatVC") as! PrivateChatViewController
        vc.conversationId = chatId
        vc.otherUserId = userId
        vc.otherUserPic = profilePic
        vc.otherUsername = "\(firstName) \(lastName)"
        topMostViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoResetPassword(email: String, passcode: String){
        let topMostViewController = UIApplication.shared.topMostViewController()
        let storyboard = UIStoryboard.init(name: "Auth", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordViewController
        vc.txtEmail = email
        vc.txtCode = passcode
        topMostViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoPasscode(passcode: String){
        let topMostViewController = UIApplication.shared.topMostViewController()
        let storyboard = UIStoryboard.init(name: "Auth", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PasscodeVC") as! PasscodeViewController
        vc.textPasscode = passcode
        topMostViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[kFCMMessageIDKey.fcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
                
        completionHandler([.alert, .badge, .sound])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        managePushNotification(state: UIApplicationState.inactive, userInfo: userInfo)
        // Print message ID.
        if let messageID = userInfo[kFCMMessageIDKey.fcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        let fcmTokenOld = UserCache.sharedInstance.getFCMToken()
        var alreadyHaveFcmToken = false
        if fcmTokenOld != nil {
            alreadyHaveFcmToken = true
        }
        UserCache.sharedInstance.setFCMToken(token: fcmToken)
        let token = UserCache.sharedInstance.getUserAuthToken()
        if token != nil && !alreadyHaveFcmToken{
            self.webservice.sendToken()
        }
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}

extension AppDelegate: PushWebservice {
    func webServiceGetError(receivedError: String) {
        
    }
    
    func webServiceGetResponse() {
        
    }
}
