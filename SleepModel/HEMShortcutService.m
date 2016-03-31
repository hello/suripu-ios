//
//  HEMShortcutService.m
//  Sense
//
//  Created by Jimmy Lu on 3/30/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENAuthorizationService.h>

#import "HEMShortcutService.h"

NSString* const HEMShortcutNotification = @"HEMShortcutNotification";
NSString* const HEMShortcutNoteInfoAction = @"action";

static NSString* const HEMShortcut3DTouchTypeAlarmNew = @"is.hello.sense.shortcut.addalarm";
static NSString* const HEMShortcut3DTouchTypeAlarmEdit = @"is.hello.sense.shortcut.editalarms";

@implementation HEMShortcutService

+ (instancetype)sharedService {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    return instance;
}

- (BOOL)canHandle3DTouchType:(NSString*)type {
    BOOL handled = NO;
    if ([SENAuthorizationService isAuthorized]) {
        if ([type isEqualToString:HEMShortcut3DTouchTypeAlarmNew]) {
            [self notifyOfAction:HEMShortcutActionAlarmNew];
            [SENAnalytics track:HEMAnalyticsEventShortcutAlarmNew];
            handled = YES;
        } else if ([type isEqualToString:HEMShortcut3DTouchTypeAlarmEdit]) {
            [self notifyOfAction:HEMShortcutActionAlarmEdit];
            [SENAnalytics track:HEMAnalyticsEventShortcutAlarmEdit];
            handled = YES;
        }
    }
    return handled;
}

- (void)notifyOfAction:(HEMShortcutAction)action {
    NSDictionary* info = @{HEMShortcutNoteInfoAction : @(action)};
    NSNotification* note = [NSNotification notificationWithName:HEMShortcutNotification
                                                         object:self
                                                       userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

@end
