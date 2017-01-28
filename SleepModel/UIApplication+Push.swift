//
//  UIApplication+Notification.swift
//  Sense
//
//  Created by Jimmy Lu on 1/27/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UIApplication {
    
    @objc func renewPushNotificationToken() {
        guard self.isRegisteredForRemoteNotifications == true else {
            return
        }
        self.registerForRemoteNotifications()
    }
    
    @objc func askForPermissionToSendPushNotifications() {
        guard self.isRegisteredForRemoteNotifications == false else {
            return self.renewPushNotificationToken()
        }
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound],
                                                  categories: nil)
        self.registerUserNotificationSettings(settings)
    }
    
    @objc func clearBadgeFromNotification() {
        self.applicationIconBadgeNumber = 1
        self.applicationIconBadgeNumber = 0
    }
    
}
