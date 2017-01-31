//
//  HEMForceTouchService.h
//  Sense
//
//  Created by Jimmy Lu on 3/30/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENService.h>

typedef NS_ENUM(NSUInteger, HEMShortcutAction) {
    HEMShortcutActionUnknown = 1,
    HEMShortcutActionAlarmNew,
    HEMShortcutActionAlarmEdit,
    HEMShortcutActionRoomConditionsShow,
    HEMShortcutActionPushTimeline
};

@class PushNotification;

NS_ASSUME_NONNULL_BEGIN

@interface HEMShortcutService : SENService

+ (HEMShortcutAction)actionForType:(NSString*)type;
+ (HEMShortcutAction)actionForNotification:(PushNotification*)notification;

@end

NS_ASSUME_NONNULL_END
