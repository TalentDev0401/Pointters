//
//  Constants.swift
//  Pointters
//
//  Created by Mac on 2/10/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import Foundation

// aws credentials
struct kAWSCredentials {
    static let kAccessKey = "AKIAIGALHANVPEWURBJA"
    static let kSecretKey = "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"
    static let kS3BucketName = "pointters_dev/dev"
    static let kS3FullBucketUrl = "https://s3.amazonaws.com/pointters_dev/dev/"
}

// facebook credentials
struct kFBCredentials{
    static let kFBToken = "token"
    static let kFBAppId = "307307739927151"
}

// fcm Message Id Key
struct kFCMMessageIDKey{
    static let fcmMessageIDKey = "gcm.message_id"
    static let fcmPayloadKey = "type"
    static let fcmPayloadValue = "id"
    static let fcmPayloadBadge = "badge"
    static let fcmPayloadLikeCount = "countLikes"
    static let fcmPayloadCommentCount = "countComments"
    static let fcmPayloadShareCount = "countShares"
    static let fcmPayloadPostSubType = "subtype"

    static let fcmPayloadChatUserId = "userId"
    static let fcmPayloadChatUserPic = "profilePic"
    static let fcmPayloadChatUserFirstName = "firstName"
    static let fcmPayloadChatUserLastName = "lastName"
    static let fcmPayloadChatUserVerified = "verified"
}

//Push, redirect url key

struct kRedirectKey{
    static let serviceKey = "service"
    static let offerKey = "offer"
    static let requestKey = "request"
    static let requestOfferKey = "request-offer"
    static let liveOfferKey = "live-offer"
    static let postKey = "post"
    static let userProfileKey = "user"
    static let orderKey = "order"
    static let chatKey = "chat"
    static let resetPassword = "reset-password"
    static let signup = "signup"
}

// gms credentials
struct kGMSCredentials {
    static let kGmsApiKey = "AIzaSyD1KRgsA-9XHL_euY1OXPOB8PuT-YEH4i0"
}

// AES credentials
struct kAESCredentials {
    static let kAesKey = "bbC2H19lkVbQDfakxcrtNMQdd0FloLyw"
    static let kAesIv = "gqLOHUioQ0QjhuvI"
}

// facebook credentials
struct kBTAppCredentials {
    static let kBTAppUrl = "com.pointters.iosdevelopment.payments"
}

// Stripe credentials

struct kStripeCredentials {
    //static let apiKey = "pk_live_3cwUQESbzHtDp9xyrctmXMYF" // live mode
    static let apiKey = "pk_test_pijPot8D9iT2gvNX2RIZqTZv" // test mode
}

// Apple pay merchant id

struct kApplePayMerchantId {
    static let key = "merchant.com.pointters.iosdevelopment"
}

// API request param
struct kAPIRequest {
    static let kContentType = "Content-Type"
    static let kAuthorization = "Authorization"

    static let kTransactionHistoryFilter = "filter"//"transactionFilter"
    static let kTransactionHistoryPeriod = "period"//"statementPeriod"
    static let kLastId = "lt_id"
    static let userId = "userId"
}

// user credentials
struct kUserCredentials {
    static let kLoginType = "login_type"
    static let kAuthToken = "auth_token"
    static let kAccessToken = "access_token"
    static let kCompletedRegistration = "completed_registration"
}

// cache param
struct kCacheParam {
    static let kUserLatitude = "user_latitude"
    static let kUserLongitude = "user_longitude"
    static let kUserDetails = "userDetails"
    static let kUserLoggedInAccess = "userLoggedInAccess"
    static let kResetPasswordEmail = "resetPasswordEmail"
    static let kProfileLoginUser = "profile_loginUser"
    static let kProfileUserId = "profile_userId"
    static let kChatVerified = "chat_verified"
    static let kChatId = "chat_id"
    static let kChatUserId = "chat_userId"
    static let kChatUserName = "chat_username"
    static let kChatUserPic = "chat_userpic"
    static let kUserLoginStatus = "loginStatus"
}

// intro splash description
struct kIntroDescription {
    static let kIntroDesc00 = "Have peace of mind"
    static let kIntroDesc01 = "with trusted people..."
    static let kIntroDesc10 = "The Smarter way to"
    static let kIntroDesc11 = "Get Work Done!"
    static let kIntroDesc20 = ""
    static let kIntroDesc21 = "Bring your dream to reality"
    static let kIntroDesc30 = "The Smarter way to"
    static let kIntroDesc31 = "Get Work Done!"
}

// public search page

struct pItemType {
    static let pPopularCategory =      "popularCategory"
    static let pOnlineService =        "onlineService"
    static let pOnlineJob =           "onlineJob"
    static let pPopularService =        "popularService"
    static let pPopularJob =              "popularJob"
    static let pLocalService =            "localService"
    static let pLocalJob =                  "localJob"
}

// account items
let kAccountSectionTitles:[String] = ["BUY", "SELL", "USER SETTING", "GENERAL"]

let kAccountNotification:[String:String] = ["title": "Notifications", "icon": "icon-notification"]

let kAccountBuyItems:[[String: String]] = [["title": "Orders",             "icon":                                                             "icon-order"],
                                           ["title": "Custom Offers",      "icon": "icon-offer"],
                                           ["title": "Jobs", "icon": "icon-request"],
                                           ["title": "Watching",           "icon": "icon-watching"],
                                           ["title": "Likes",              "icon": "icon-likes"],
                                           ["title": "Location",           "icon":
                                               "icon-store"],
                                           ["title": "Transactions History",    "icon": "icon-history"]]

let kAccountSellItems:[[String:String]] = [["title": "Start Selling",           "icon": ""],
                                           ["title": "Orders", "icon":          "icon-order"],
                                           ["title": "Become a Seller",         "icon": "icon-seller"],
                                           ["title": "Offers Sent", "icon":     "icon-offersent"],
                                           ["title": "Job Opportunities",       "icon": "icon-job"],
                                           ["title": "Edit Store Locations",    "icon": "icon-store"],
                                           ["title": "Transactions History",    "icon": "icon-history"]]
//["title": "Business Verification",   "icon": "icon-business"], ["title": "Background Check",        "icon": "icon-background"],

let kAccountSettingItems:[[String:String]] = [["title": "Edit Profile",           "icon": "icon-profile"],
                                              ["title": "Edit User Settings",     "icon": "icon-usersettings"],
                                              ["title": "Notification Settings",  "icon": "icon-notesettings"]]
//["title": "Shipping Address",        "icon": "icon-ship-home"]
//["title": "Payment Methods",        "icon": "icon-payment"], ["title": "Premium Membership",      "icon": "icon-membership"],
let kAccountGeneralItems:[[String:String]] = [["title": "Following",            "icon": "icon-following"],
                                              ["title": "Followers",            "icon": "icon-followers"],
                                              ["title": "Invite Friends",       "icon": "icon-invite"],
                                              ["title": "Leave Feedback",       "icon": "icon-feedback"],
                                              ["title": "Terms & Conditions",   "icon": "icon-terms"],
                                              ["title": "Privacy Policy",       "icon": "icon-privacy"],
                                              ["title": "Logout",               "icon": ""]]

// background items
let kBackgroundSectionTitles:[String] = ["SOCIAL SECURITY NUMBER",
                                         "DRIVER LICENSE NUMBER",
                                         "DRIVER LICENSE STATE"]

let kBackgroundLabelNames:[String] = ["First Name", "Middle Name", "Last Name"]
let kBackgroundLabelInfos:[String] = ["Email", "Phone", "Date of Birth"]
let kBackgroundLabelAddress:[String] = ["Postal Code"]

// user settings
struct kUserSettingsItems {
    static let kUserPublic = "Public"
    static let kUserFollowers = "Followers"
    static let kUserOnlyMe = "Only Me"
}

let kUserSettingsTitles:[[String]] = [["Location Settings", "Who can view my location"],
                                      ["Phone Number", "Who can view my phone number"]]

// user edit items
let kUserProfileItems:[String] = ["First Name", "Last Name", "About Me", "Company", "Education", "Licence", "Insurance", "Awards", "Phone"]

// notification settings
struct kNotificationItems {
    static let kNotificationPush = "Push"
    static let kNotificationEmail = "Email"
    static let kNotificationNone = "None"
    static let kNotificationAll = "All"
}

// summary email settings
struct kSummaryEmailItems {
    static let kSummaryEmailDaily = "Daily"
    static let kSummaryEmailWeekly = "Weekly"
    static let kSummaryEmailNone = "None"
    static let kSummaryEmailAll = "All"
}

// Action button label & Status on fulfillment

struct kOrderActions {
    static let kPaid_Buyer =                 "Propose schedule and location"
    static let kComplete_Buyer =         "Review Order"
    static let kReview_Acceptance =     ""
    static let kCancel_Buyer =             "Request cancellation"

    static let kCancel_Seller =             "Review Cancellation"
    static let kPaid_Seller =                 "Accept schedule and location"
    static let kScheduled_Seller =        "Start Service"
    static let kStart_Seller =                "Complete Service"
    static let kMake_payment =            "Make Payment"

}

struct kOrderStatus {
    static let kOrderCanceled =            "Order Cancelled"
    static let kOrderAccept =  "Accept"
    static let kOrderProposeSchedule = "Propose Schedule"
    static let kOrderProposeLocation = "Propose Location"
}

let kNotificationDescriptions:[String] = ["points, likes, comments, follows",
                                          "orders, updates, custom offers",
                                          "live request",
                                          ""]

// card details
let kCardDetailItems:[String] = ["Name", "Card Number", "Expiration Date", "Security Code"]

// bank card info
let kBankCardItems:[String] = ["Cardholder", "Number", "Expires", "Nic Name"]

// new address info
let kNewAddressItems:[String] = ["Name", "Type to search location", "Apt., Suite, Bldg. (Optional)",
                                 "City", "State", "Postal Code", "Country"]

let kChangeAddressItems:[String] = ["Street", "Apt., Suite, Bldg. (Optional)",
                                 "City", "State", "ZIP", "Country"]

// shipping address info
let kShippingAddressItems:[String] = ["Street", "Apt., Suite, Bldg. (Optional)",
                                 "City", "State", "ZIP", "Country"]

// shipping measurement info
let kShippingMeasurementItems:[String] = ["Weight", "Height", "Length", "Width"]

// orders items
let kChooseMenuItems:[String] = ["Buy", "Sell", "Transaction History"]

// buy/sell subItems
let kBuySellSubItems:[[String]] = [["Orders", "Offers", "Jobs"], ["Orders", "Offers", "Jobs"]]

// delivery method items
let kDeliveryMethodItems:[String] = ["Online", "Shipment", "Local", "Store"]

// delivery time items
let kDeliveryTimeItems:[String] = ["Hour", "Day", "Week"]

let kMonthItems: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

// shipping info
let kShippingInfoItems:[String] = ["Package shipped on", "Courier", "Tracking", "Expected Arrival"]
