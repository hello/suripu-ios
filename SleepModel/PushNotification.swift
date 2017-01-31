//
//  PushNotification.swift
//  Sense
//
//  Created by Jimmy Lu on 1/30/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

@objc class PushNotification: NSObject {
    
    @objc enum Target: Int {
        case unknown = 0
        case sleepScore
        
        static func fromKey(targetKey: String!) -> Target {
            if targetKey == "timeline" {
                return .sleepScore
            } else {
                return .unknown
            }
        }
    }
    
    fileprivate static let keyTarget = "hlo-target"
    fileprivate static let keyDetail = "hlo-detail"
    
    /// convenience constant for objective-c code to use namespacing
    @objc public static let sleepScore: Target = .sleepScore
    
    @objc fileprivate(set) var target = Target.unknown
    @objc fileprivate(set) var detail: Any?
    
    /**
        Initializes PushNotification object using the contents of the remote
        notification userInfo.  If userInfo is empty or does not contain supported
        keys, the PushNotification object will be initialized with an unknown
     
        - Parameter info: the userInfo object from the received push notification
    */
    @objc init(info: NSDictionary!) {
        super.init()
        self.process(info: info)
    }
    
    fileprivate func process(info: NSDictionary!) {
        let target = info[PushNotification.keyTarget] as? String
        let detail = info[PushNotification.keyDetail]
        
        self.target = Target.fromKey(targetKey: target ?? "")
        
        switch self.target {
            case Target.sleepScore:
                let isoDate = detail as? String
                self.detail = Date.from(isoDateOnly: isoDate)
                break
            case Target.unknown:
                fallthrough
            default:
                break;
        }
        
    }
    
}
