//
//  NotificationService.swift
//  Sense
//
//  Created by Jimmy Lu on 1/27/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import SenseKit

@objc class PushNotificationService: SENService {
    
    @objc func canRegisterForPushNotifications() -> Bool {
        return SENAuthorizationService.isAuthorized()
    }

    /**
        Upload the push token
     */
    @objc func uploadPushToken(data: Data!) {
        SENAPINotification.registerForRemoteNotifications(withTokenData: data) { (error: Error?) in
            if error != nil {
                SENAnalytics.trackError(error!, withEventName: kHEMAnalyticsEventWarning)
            }
        }
    }
    
    @objc func getSettings(completion: @escaping ([SENNotificationSetting]?, Error?) -> Void) {
        SENAPINotification.getSettings { (data, error: Error?) in
            if error != nil {
                SENAnalytics.trackError(error!)
            }
            completion (data as? [SENNotificationSetting], error)
        }
    }
    
    @objc func updateSettings(settings: [SENNotificationSetting]!,
                              completion: @escaping ([SENNotificationSetting]?, Error?) -> Void) {
        SENAPINotification.update(settings) { (data, error: Error?) in
            if error != nil {
                SENAnalytics.trackError(error!)
            }
            completion(data as? [SENNotificationSetting], error)
        }
    }
    
}
