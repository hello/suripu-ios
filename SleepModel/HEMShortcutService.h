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
    HEMShortcutActionAlarmEdit
};

NS_ASSUME_NONNULL_BEGIN

extern NSString* const HEMShortcutNotification;
extern NSString* const HEMShortcutNoteInfoAction;

@interface HEMShortcutService : SENService

+ (instancetype)sharedService;
- (instancetype)init NS_UNAVAILABLE;
- (BOOL)canHandle3DTouchType:(NSString*)type;
- (void)notifyOfAction:(HEMShortcutAction)action;

@end

NS_ASSUME_NONNULL_END
