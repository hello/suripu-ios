//
//  NotificationSettingsPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 2/2/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

@objc class NotificationSettingsPresenter: HEMPresenter {
    
    fileprivate weak var service: PushNotificationService!
    
    init(service: PushNotificationService!) {
        super.init()
        self.service = service
    }
    
    
    
}
