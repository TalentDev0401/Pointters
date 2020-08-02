//
//  URLBuilder.swift
//  Pointters
//
//  Created by Dream Software on 8/13/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

// base url    
let baseURL = "https://pointters-api-dev3.pointters.com/"//"http://pointters-api-test.us-east-1.elasticbeanstalk.com:9000"// //development
//let baseURL = "http://localhost:9000/" //development

let pointterDeepLink = "pointters"

struct AppErrorInfo {
    static let Domain = "https://pointters-api-dev3.pointters.com" // error domain
    //static let Domain = "http://localhost:9000" // error domain
    static let ErrorDescriptionKey = "description" // human-readable description
    static let ErrorKey = "error" // underlying error object
}


struct URLBuilder {

    //MARK:-Push notifications
    static var urlFCMToken: String {get {return baseURL + "fcmtoken"}}
    static var urlNotifications: String {get {return baseURL + "notifications"}}
    static func urlMarkAsRead(id: String)->String{return baseURL + "notification/" + id + "/read"}


    //MARK:-User & Authentification

    static var urlSignup: String {get  {return baseURL + "user/signup"}}
    static var urlLogin: String {get  {return baseURL + "user/login"}}
    static var urlLogout: String {get {return baseURL + "user/logout"}}
    static var urlForgetPassword: String {get {return baseURL + "forgetPassword"}}
    static var urlUser: String {get {return baseURL + "user"}}
    static var urlUserOTP: String {get {return baseURL + "user/otp"}}
    static var urlUserResetPass: String {get {return baseURL + "user/reset/password"}}
    static var urlUserMenu: String {get {return baseURL + "user/menu"}}
    static func urlUserProfile(userId: String)->String {return baseURL + "user/profile?userId=" + userId}
    static func urlUserFollow(userId: String)->String{return baseURL + "user/" + userId + "/follow"}
    static var urlGetFollowers: String{get {return baseURL + "user/followers"}}
    static var urlGetFollowing: String{get {return baseURL + "user/following"}}
    static var urlFBLogin: String{get {return baseURL + "user/facebook/token"}}
    static var urlUserSetting: String{get {return baseURL + "user/setting"}}
    static var urlFeedback: String{get {return baseURL + "feedback"}}

    static var urlSendVerifyCode: String{get {return baseURL + "user/verify-email"}}
    static var urlResendVerifyCode: String{get {return baseURL + "user/resend-verify-email"}}

    //MARK:-Invite

    static var urlGetInviteSuggest: String{get {return baseURL + "users/invite-suggested"}}
    static var urlGetInviteSearch: String{get {return baseURL + "user/invite/search"}}

    //MARK:-User service

    static var urlGetUserService: String{get {return baseURL + "services"}}
    static var urlSearchLinkService: String{get {return baseURL + "services/link/search"}}
    static var urlGetSendSearchService: String{get {return baseURL + "services/search"}}

    //MARK:-Service

    static func urlGetServiceDetail(serviceId: String)->String{return baseURL+"service/" + serviceId + "/detail"}
    static var urlSendService: String{get {return baseURL + "send-service"}}
    static var urlPublicService: String{get {return baseURL + "homepage/mobile"}}
    static var urlSendOffer: String{get {return baseURL + "offer"}}
    static func urlOffer(offerId: String)->String{return baseURL + "offer/" + offerId}
    static func urlGetRelatedService(serviceId: String)->String{return baseURL + "service/" + serviceId + "/related"}
    static func urlFlagInappropriate(serviceId: String)->String{return baseURL + "service/" + serviceId + "/flag-inappropriate"}
    static func urlShareService(serviceId: String)->String{return baseURL + "service/" + serviceId + "/share"}
    static func urlLikeService(serviceId: String)->String{return baseURL + "service/" + serviceId + "/like"}
    static func urlWatchService(serviceId: String)->String{return baseURL + "service/" + serviceId + "/watch"}
    static var urlGetPosts: String{get {return baseURL + "posts"}}
    static func urlPostLike(postId: String)->String{return baseURL + "post/" + postId + "/like"}
    static func urlSendComment(postId: String)->String{return baseURL + "post/" + postId + "/comment"}
    static var urlPostService: String{get {return baseURL + "service"}}
    static func urlEditService(serviceId: String)->String{return baseURL + "service/" + serviceId}
    static var urlWatchService: String{get {return baseURL + "services/watching"}}
    static var urlLikedService: String{get {return baseURL + "services/liked"}}
    static var urlSearchTagService: String{get {return baseURL + "post/tag/search"}}
    static var urlExploreService: String{get {return baseURL + "services/explore"}}
    static var urlExploreSuggestedService: String{get {return baseURL + "services/live-offer-suggested"}}
    static func urlGetServiceReviews(serviceId: String)->String{return baseURL + "service/" + serviceId + "/reviews"}
    static func urlGetPostReview(orderId: String)->String{return baseURL + "order/" + orderId + "/review"}

    //MARK:-Category

    static var urlCategories: String{get {return baseURL + "categories"}}

    //MARK:-Request
    static var urlCreateJobRequest: String{get {return baseURL + "request"}}
    static func urlRequestDetail(requestId: String)->String{return baseURL + "request/" + requestId}
    static func urlRequestOffer(offerId: String)->String{return baseURL + "request/offer/" + offerId}
    static func urlCreateJobOffer(jobId: String)->String{return baseURL + "request/" + jobId + "/offer"}

    //MARK:-Order

    static var urlBuyOrder: String{get {return baseURL + "orders/buy"}}
    static var urlSellOrder: String {get {return baseURL + "orders/sell"}}
    static func urlOrderFulfillment(orderId: String)->String{return baseURL + "order/" + orderId}

    //MARK:-Offer

    static func urlExploreOffersRequest(requestId: String)->String{return baseURL + "request/" + requestId + "/offers"}
    static func urlJobRequest(requestId: String)->String{return baseURL + "request/" + requestId}
    static var urlOfferReceived: String{get {return baseURL + "offers/received"}}
    static var urlOfferSent: String{get {return baseURL + "offers/sent"}}

    //MARK:-Buy request

    static var urlLiveOfferRequest: String{get {return baseURL + "requests"}}

    //MARK:-Job

    static var urlExploreJob: String{get {return baseURL + "explore/jobs"}}
    static var urlSellJob: String{get {return baseURL + "jobs"}}

    //MARK:-Post

    static func urlPostLikes(postId: String)->String{return baseURL + "post/" + postId + "/likes"}
    static func urlPostComments(postId: String)->String{return baseURL + "post/" + postId + "/comments"}
    static func urlPostShares(postId: String)->String{return baseURL + "post/" + postId + "/shares"}

    static func urlPostShare(postId: String)->String{return baseURL + "post/" + postId + "/share"}

    //MARK:-TransactionHistory

    static var urlTransactionHistory: String{get {return baseURL + "transaction-history"}}

    //MARK:-ShippingAddress

    static var urlShippingAddress: String{get {return baseURL + "shipment-addresses"}}
    static func urlShippingAddress(addressId: String)->String{return baseURL + "shipment-address/" + addressId}

    //MARK:-Store

    static var urlGetStoreLocation: String{get {return baseURL + "stores"}}
    static var urlSetStoreLocation: String{get {return baseURL + "store"}}
    static func urlStoreLocation(addressId: String)->String{return baseURL + "store/" + addressId}

    //MARK:-Conversations

    static var urlConversations: String{get {return baseURL + "conversations"}}
    static var urlConversationSearch: String{get {return baseURL + "conversations/search"}}
    static func urlGetMessage(conversationId: String)->String{return baseURL + "conversation/" + conversationId + "/messages"}

    //MARK:-SellerEligability

    static var urlSellerEligability: String{get {return baseURL + "user/seller-eligibility"}}

    //MARK:-BackgroundCheck

    static var urlBackgroundCheck: String{get {return baseURL + "background-check"}}

    //MARK:-Post

    static var urlPostUpdate: String{get {return baseURL + "post"}}
    
    //MARK:-User
    static var urlUserUpdate: String{get {return baseURL + "user"}}

    //MARK:-BrainTree & PaymentMethod

    static var urlBraintreeClientToken: String{get {return baseURL + "braintree/client-token"}}
    static var urlGetPaymentMethod: String {get {return baseURL + "braintree/payment-method"}}
    static func urlPaymentMethod(methodToken: String)->String{return baseURL + "braintree/payment-method/" + methodToken}

    static var urlBraintreeWithdraw: String{get {return baseURL + "braintree/merchant-account"}}

    //MARK: Stripe & PaymentMethod

    static var urlStripeGetPaymentMethods: String {get {return baseURL + "payment/payment-methods?limit=10"}}
    static var urlStripeGetDefaultPaymentMethod: String {get {return baseURL + "payment/payment-method/default"}}
    static var urlStripeSetDefaultPaymentMethod: String {get {return baseURL + "payment/payment-method/customer"}}
    static func urlStripePaymentMethod(token: String)->String{return baseURL + "payment/payment-method/" + token}

    static var urlStripeWithdraw: String{get {return baseURL + "payment/account"}}
    static var urlPayStackListBanks: String{get {return baseURL + "paystack/list-banks"}}
}
