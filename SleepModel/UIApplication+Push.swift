//
//  UIApplication+Notification.swift
//  Sense
//
//  Created by Jimmy Lu on 1/27/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UIApplication {
    
    /**
        Convenience method that simply puts a different name to the native
        registerForRemoteNotifications method, which can lead to confusion
    */
    @objc func renewPushNotificationToken() {
        self.registerForRemoteNotifications()
    }
    
    /**
        Prompt the user for permission to send push notifications.
     
        Callers should override the application delegate method to know that the
        user notification settings were registered to then call renew push notification
        to retrieve the token.
    */
    @objc func askForPermissionToSendPushNotifications() {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound],
                                                  categories: nil)
        self.registerUserNotificationSettings(settings)
    }
    
    /**
        Convenience method to clear the badge, if one was created from a push
        notification by first setting it to 1, then setting it to 0.  Without
        this, the badge may not properly clear
    */
    @objc func clearBadgeFromNotification() {
        self.applicationIconBadgeNumber = 1
        self.applicationIconBadgeNumber = 0
    }
    
    /**
        Determine if user denied notification permission
        
        - Return true if denied, false otherwise
    */
    @objc func hasDeniedNotificationPermission() -> Bool {
        guard self.isRegisteredForRemoteNotifications == false else {
            let canSend = self.canSendNotifications()
            if canSend == false {
                // because in iOS 9, if user deleted the app at one point after
                // giving permission, isRegisteredForRemoteNotifications will
                // be true, but actually we have no permissions yet
                if #available(iOS 10, *) {
                    return true
                } else {
                    return self.notificationTypesCompletelyOff() == false
                }
            } else {
                return false
            }
        }
        
        guard let settings = self.currentUserNotificationSettings else {
            return false
        }
        
        return settings.types.contains(UIUserNotificationType.alert) == false
    }
    
    @objc func notificationTypesCompletelyOff() -> Bool {
        guard let settings = self.currentUserNotificationSettings else {
            return true
        }
        return settings.types.isEmpty
    }
    
    /**
        Determine if application can be sent notifications
     
        - Return true if app can be sent notifications, false otherwise
     */
    @objc func canSendNotifications() -> Bool {
        guard let settings = self.currentUserNotificationSettings else {
            return false
        }
        
        return settings.types.contains(.alert) == true
    }
    
}
