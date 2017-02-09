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
    
    // this is a work around for the fact
    static var receivedToken: Bool = false
    
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
    
    @objc func updateSettings(settings: [SENNotificationSetting]!, completion: @escaping (Error?) -> Void) {
        SENAPINotification.update(settings) { (data, error: Error?) in
            if error != nil {
                SENAnalytics.trackError(error!)
            }
            completion(error)
        }
    }
    
    @objc func enableAllSettings(completion: ((Error?) -> Void)?) {
        func done(error: Error?) {
            if completion != nil {
                completion!(error)
            }
        }
        
        self.getSettings { [weak self] (data: [SENNotificationSetting]?, error: Error?) in
            guard error == nil else {
                return done(error: error)
            }
            
            guard let settings = data else {
                return done(error: nil)
            }
            
            let enabledSettings = settings.map { (setting) -> SENNotificationSetting in
                setting.isEnabled = true
                return setting
            }

            self?.updateSettings(settings: enabledSettings, completion:done)
        }
    }
    
}
