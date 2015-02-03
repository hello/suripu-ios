//
//  HEMTutorial.m
//  Sense
//
//  Created by Delisa Mason on 1/28/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAuthorizationService.h>
#import "HEMTutorial.h"
#import "HEMFullscreenDialogView.h"

@implementation HEMTutorial

static NSString* const HEMTutorialTimelineKey = @"HEMTutorialTimeline";
static NSString* const HEMTutorialSensorKeyFormat = @"HEMTutorialSensor_%@";
static NSString* const HEMTutorialSensorsKey = @"HEMTutorialSensors";
static NSString* const HEMTutorialAlarmsKey = @"HEMTutorialAlarms";
static NSString* const HEMTutorialTrendsKey = @"HEMTutorialTrends";
static CGFloat const HEMTutorialDelay = 0.5f;

+ (void)showTutorialForTimelineIfNeeded
{
    if ([self shouldShowTutorialForKey:HEMTutorialTimelineKey]) {
        [self showTutorialForTimeline];
        [self markTutorialViewed:HEMTutorialTimelineKey];
    }
}

+ (void)showTutorialForSensorsIfNeeded
{
    if ([self shouldShowTutorialForKey:HEMTutorialSensorsKey]) {
        [self delayBlock:^{
            [self showTutorialForSensors];
            [self markTutorialViewed:HEMTutorialSensorsKey];
        }];
    }
}

+ (void)delayBlock:(void(^)())block
{
    int64_t delta = (int64_t)(HEMTutorialDelay * NSEC_PER_SEC);
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, delta);
    dispatch_after(after, dispatch_get_main_queue(), block);
}

+ (void)showTutorialIfNeededForSensorNamed:(NSString *)sensorName
{
    NSString* key = [NSString stringWithFormat:HEMTutorialSensorKeyFormat, sensorName];
    if ([self shouldShowTutorialForKey:key]) {
        [self delayBlock:^{
            [self showTutorialForSensorNamed:sensorName];
            [self markTutorialViewed:key];
        }];
    }
}

+ (void)showTutorialForAlarmsIfNeeded
{
    if ([self shouldShowTutorialForKey:HEMTutorialAlarmsKey]) {
        [self delayBlock:^{
            [self showTutorialForAlarms];
            [self markTutorialViewed:HEMTutorialAlarmsKey];
        }];
    }
}

+ (void)showTutorialForTrendsIfNeeded
{
    if ([self shouldShowTutorialForKey:HEMTutorialTrendsKey]) {
        [self delayBlock:^{
            [self showTutorialForTrends];
            [self markTutorialViewed:HEMTutorialTrendsKey];
        }];
    }
}

+ (void)showTutorialForTimeline
{
    HEMDialogContent* content1 = [HEMDialogContent new];
    content1.title = NSLocalizedString(@"tutorial.timeline.title1", nil);
    content1.content = NSLocalizedString(@"tutorial.timeline.message1", nil);
    content1.image = [UIImage imageNamed:@"timeline_explain_sleep"];
    HEMDialogContent* content2 = [HEMDialogContent new];
    content2.content = NSLocalizedString(@"tutorial.timeline.message2", nil);
    content2.image = [UIImage imageNamed:@"timeline_explain_score"];
    HEMDialogContent* content3 = [HEMDialogContent new];
    content3.content = NSLocalizedString(@"tutorial.timeline.message3", nil);
    content3.image = [UIImage imageNamed:@"timeline_explain_before"];
    HEMDialogContent* content4 = [HEMDialogContent new];
    content4.content = NSLocalizedString(@"tutorial.timeline.message4", nil);
    content4.image = [UIImage imageNamed:@"timeline_explain_graph"];
    [HEMFullscreenDialogView showDialogsWithContent:@[content1, content2, content3, content4]];
}

+ (void)showTutorialForSensors
{
    HEMDialogContent* content = [HEMDialogContent new];
    content.title = NSLocalizedString(@"tutorial.sensors.title", nil);
    content.content = NSLocalizedString(@"tutorial.sensors.message", nil);
    content.image = [UIImage imageNamed:@"welcome_dialog_sensors"];
    [HEMFullscreenDialogView showDialogsWithContent:@[content]];
}

+ (void)showTutorialForSensorNamed:(NSString*)sensorName
{
    static NSString* const nameFormat = @"welcome_dialog_%@";
    static NSString* const titleFormat = @"tutorial.sensor.%@.title";
    static NSString* const messageFormat = @"tutorial.sensor.%@.message";
    UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:nameFormat, sensorName]];
    if (!image)
        return;

    NSString* localizedTitleKey = [NSString stringWithFormat:titleFormat, sensorName];
    NSString* localizedMessageKey = [NSString stringWithFormat:messageFormat, sensorName];
    HEMDialogContent* content = [HEMDialogContent new];
    content.title = NSLocalizedString(localizedTitleKey, nil);
    content.content = NSLocalizedString(localizedMessageKey, nil);
    content.image = image;
    [HEMFullscreenDialogView showDialogsWithContent:@[content]];
}

+ (void)showTutorialForAlarms
{
    HEMDialogContent* content = [HEMDialogContent new];
    content.title = NSLocalizedString(@"tutorial.alarms.title", nil);
    content.content = NSLocalizedString(@"tutorial.alarms.message", nil);
    content.image = [UIImage imageNamed:@"welcome_dialog_alarm"];
    [HEMFullscreenDialogView showDialogsWithContent:@[content]];
}

+ (void)showTutorialForTrends
{
    HEMDialogContent* content = [HEMDialogContent new];
    content.title = NSLocalizedString(@"tutorial.trends.title", nil);
    content.content = NSLocalizedString(@"tutorial.trends.message", nil);
    content.image = [UIImage imageNamed:@"welcome_dialog_trends"];
    [HEMFullscreenDialogView showDialogsWithContent:@[content]];
}

+ (BOOL)shouldShowTutorialForKey:(NSString*)key
{
    if (![SENAuthorizationService isAuthorized])
        return NO;
    BOOL hasBeenViewed = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    return !hasBeenViewed;
}

+ (void)markTutorialViewed:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
}

@end
