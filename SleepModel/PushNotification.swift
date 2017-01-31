//
//  PushNotification.swift
//  Sense
//
//  Created by Jimmy Lu on 1/30/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

@objc class PushNotification: NSObject {
    
    fileprivate static let keyType = "hlo-type"
    fileprivate static let keyDetail = "hlo-detail"
    fileprivate static let typeSleepScore = "sleep_score"
    
    @objc enum InfoType: Int {
        case unknown = 0
        case sleepScore
        
        static func fromType(type: String!) -> InfoType {
            let lower = type?.lowercased()
            if lower == PushNotification.typeSleepScore {
                return .sleepScore
            } else {
                return .unknown
            }
        }
    }
    
    /// convenience constant for objective-c code to use namespacing
    @objc public static let sleepScore: InfoType = .sleepScore
    
    @objc fileprivate(set) var type = InfoType.unknown
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
        let type = info[PushNotification.keyType] as? String
        let detail = info[PushNotification.keyDetail]
        
        self.type = InfoType.fromType(type: type ?? "")
        
        switch self.type {
            case InfoType.sleepScore:
                let isoDate = detail as? String
                self.detail = Date.from(isoDateOnly: isoDate)
                break
            case InfoType.unknown:
                fallthrough
            default:
                break;
        }
        
    }
    
}
