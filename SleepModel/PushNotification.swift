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
    fileprivate static let typeSystem = "system"
    fileprivate static let typeNotRecognized = "not recognized"
    fileprivate static let detailPillBattery = "pill_battery"
    
    @objc enum PushType: Int {
        case unknown = 0
        case sleepScore
        case system
        
        static func fromType(type: String!) -> PushType {
            let lower = type?.lowercased()
            if lower == PushNotification.typeSleepScore {
                return .sleepScore
            } else if lower == PushNotification.typeSystem {
                return .system
            } else {
                return .unknown
            }
        }
        
        func stringValue() -> String! {
            switch self {
                case .sleepScore:
                    return PushNotification.typeSleepScore
                case .system:
                    return PushNotification.typeSystem
                case .unknown:
                    fallthrough
                default:
                    return PushNotification.typeNotRecognized
            }
        }
    }
    
    @objc enum SystemType: Int {
        case unknown = 0
        case pillBattery
        
        static func from(detail: String?) -> SystemType {
            let lower = detail?.lowercased()
            if lower == PushNotification.detailPillBattery {
                return .pillBattery
            } else {
                return .unknown
            }
        }
        
        func stringValue() -> String! {
            switch self {
                case .pillBattery:
                    return PushNotification.detailPillBattery
                default:
                    return PushNotification.typeNotRecognized
            }
        }
    }
    
    /// convenience constant for objective-c code to use namespacing
    @objc public static let sleepScore: PushType = .sleepScore
    @objc public static let system: PushType = .system
    @objc public static let systemPillBattery: SystemType = .pillBattery
    
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
    
    @objc func systemTypeStringValue() -> String! {
        guard self.type == .system else {
            return PushNotification.typeNotRecognized
        }
        
        guard let systemType = self.detail as? SystemType else {
            return PushNotification.typeNotRecognized
        }
        
        return systemType.stringValue()
    }
    
    @objc func isPillBattery() -> Bool {
        let systemType = self.detail as? SystemType
        return self.type == .system && systemType == SystemType.pillBattery
    }
    
    fileprivate func process(info: NSDictionary!) {
        let type = info[PushNotification.keyType] as? String
        self.type = PushType.fromType(type: type ?? "")
        
        switch self.type {
            case PushType.sleepScore:
                let isoDate = info[PushNotification.keyDetail] as? String
                self.detail = Date.from(isoDateOnly: isoDate)
            case PushType.system:
                let systemDetail = info[PushNotification.keyDetail] as? String
                self.detail = SystemType.from(detail: systemDetail)
            case PushType.unknown:
                fallthrough
            default:
                break;
        }
    }
    
}
