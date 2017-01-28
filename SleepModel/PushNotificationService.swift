//
//  NotificationService.swift
//  Sense
//
//  Created by Jimmy Lu on 1/27/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import SenseKit

/**
    Typically, services should not have any dependencies to UIKit, but because
    this particular service should have knowledge of what type of notifications
    we should want, which is part of the UIKit, we will make an exception.
 */
@objc class PushNotificationService: SENService {
    
    @objc func canRegisterForPushNotifications() -> Bool {
        return SENAuthorizationService.isAuthorized()
    }
    
    @objc func uploadPushToken(data: Data!) {
        SENAPINotification.registerForRemoteNotifications(withTokenData: data) { (error: Error?) in
            if error != nil {
                SENAnalytics.trackError(error!, withEventName: kHEMAnalyticsEventWarning)
            }
        }
    }
    
}
