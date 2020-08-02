//
//  SocketHelper.swift
//  Pointters
//
//  Created by Mac on 2/10/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import SocketIO

class SocketHelper: NSObject {
    
    var socket: SocketIOClient?
    var socketManager: SocketManager?
    
    class var sharedInstance : SocketHelper {
        struct Static {
            static let instance = SocketHelper()
        }
        
        return Static.instance
    }
    
    func connectSocket() {
        if self.socket == nil, let token = UserCache.sharedInstance.getUserAuthToken() {
            let urlStr = "https://pointters-api-dev3.pointters.com"
            self.socketManager = SocketManager(socketURL: URL(string: urlStr)!, config: [.log(false), .connectParams(["token": token])])
            socket = self.socketManager?.defaultSocket
            
            socket?.on(clientEvent: .connect) {data, ack in
                print("socket connected")
            }
            
            socket?.on(clientEvent: .error) {data, ack in
                print(data)
                print("socket error")
            }
            
            socket?.connect()
        }
    }
    
    func disconnectSocket() {
        socket?.off("start_conversation")
        socket?.off("message")
        socket?.off("message_error")
        socket?.disconnect()
        self.socket = nil
    }
    
    func setStartConversation(convId:String, users:[String]) {
        var data:[String:Any] = [:]
        if convId != "" {
            data["conversationId"] = convId
        }
        data["users"] = users
        
        socket?.emit("start_conversation", data)
    }
    
    func getStartConversation(completionHandler: @escaping (_ result:[String:Any]) -> Void) {
        socket?.on("start_conversation") { (result, ack) -> Void in
            completionHandler(result[0] as! [String: Any])
        }
    }
    
    func sendMessage(data:[String:Any]) {
        socket?.emit("message", data)
    }
    
    func receiveMessage(completionHandler: @escaping (_ result:[String:Any], _ error:[String:Any]) -> Void) {
        socket?.on("message") { (result, ack) -> Void in
            completionHandler(result[0] as! [String: Any], [:])
        }
        socket?.on("message_error") { (error, ack) -> Void in
            completionHandler([:], error[0] as! [String: Any])
        }
    }
    
    func sendJoinLiveOffer(requestId: String) {
        socket?.emit("join_live_offer_room", ["requestId" : requestId])
    }
    
    func getEventLiveOffers(completionHandler: @escaping (_ result:[String:Any], _ error:String) -> Void) {
        socket?.on("join_live_offer_room") { (result, ack) -> Void in
            completionHandler(result[0] as! [String: Any], "")
        }
        socket?.on("error") { (error, ack) -> Void in
            completionHandler([:], error[0] as! String)
        }
    }
    
    func sendLiveOffers(offerId: String) {
        var params = [String: Any]()
        params["_id"] = offerId
        socket?.emit("live_offer", params)
    }
    
    func receiveLiveOffers(completionHandler: @escaping (_ result:[String:Any], _ error:String) -> Void) {
        socket?.on("live_offer") { (result, ack) -> Void in
            completionHandler(result[0] as! [String: Any], "")
        }
        socket?.on("error") { (error, ack) -> Void in
            completionHandler([:], error[0] as! String)
        }
    }
}
