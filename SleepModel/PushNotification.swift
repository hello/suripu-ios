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
    fileprivate static let typeLowBattery = "pill_battery"
    fileprivate static let typeNotRecognized = "not recognized"
    
    @objc enum PushType: Int {
        case unknown = 0
        case sleepScore
        case lowBattery
        
        static func fromType(type: String!) -> PushType {
            let lower = type?.lowercased()
            if lower == PushNotification.typeSleepScore {
                return .sleepScore
            } else if lower == PushNotification.typeLowBattery {
                return .lowBattery
            } else {
                return .unknown
            }
        }
        
        func stringValue() -> String! {
            switch self {
                case .sleepScore:
                    return PushNotification.typeSleepScore
                case .lowBattery:
                    return PushNotification.typeLowBattery
                case .unknown:
                    fallthrough
                default:
                    return PushNotification.typeNotRecognized
            }
        }
    }
    
    /// convenience constant for objective-c code to use namespacing
    @objc public static let sleepScore: PushType = .sleepScore
    @objc public static let lowBattery: PushType = .lowBattery
    
    @objc fileprivate(set) var type = PushType.unknown
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

    /**
        Convenience method for objective c to retrieve the string value for
        the type of this instance
        
        - Return the string value for the type enum
    */
    @objc func typeStringValue() -> String! {
        return self.type.stringValue()
    }
    
    fileprivate func process(info: NSDictionary!) {
        let type = info[PushNotification.keyType] as? String
        self.type = PushType.fromType(type: type ?? "")
        
        switch self.type {
            case PushType.sleepScore:
                let isoDate = info[PushNotification.keyDetail] as? String
                self.detail = Date.from(isoDateOnly: isoDate)
                break
            case PushType.lowBattery:
                fallthrough // detail is not used
            case PushType.unknown:
                fallthrough
            default:
                break;
        }
        
    }
    
}
