//
//  HEMTutorial.m
//  Sense
//
//  Created by Delisa Mason on 1/28/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENLocalPreferences.h>
#import "HEMTutorial.h"
#import "HEMFullscreenDialogView.h"
#import "HEMTutorialContent.h"
#import "HEMTutorialViewController.h"
#import "HEMMainStoryboard.h"
#import "UIView+HEMSnapshot.h"

@implementation HEMTutorial

static NSString* const HEMTutorialTimelineKey = @"HEMTutorialTimeline";
static NSString* const HEMTutorialSensorKeyFormat = @"HEMTutorialSensor_%@";
static NSString* const HEMTutorialSensorsKey = @"HEMTutorialSensors";
static NSString* const HEMTutorialAlarmsKey = @"HEMTutorialAlarms";
static NSString* const HEMTutorialTrendsKey = @"HEMTutorialTrends";
static CGFloat const HEMTutorialDelay = 0.5f;

+ (void)showTutorialForTimelineIfNeeded
{
//    if ([self shouldShowTutorialForTimeline]) {
//        [self showTutorialForTimeline];
//        [self markTutorialViewed:HEMTutorialTimelineKey];
//    }
    [self showTutorialForTimeline];
}

+ (BOOL)shouldShowTutorialForTimeline
{
    return YES;
//    return [self shouldShowTutorialForKey:HEMTutorialTimelineKey];
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
    HEMTutorialContent* tutorial1 =
    [[HEMTutorialContent alloc] initWithTitle:NSLocalizedString(@"tutorial.timeline.title1", nil)
                                         text:NSLocalizedString(@"tutorial.timeline.message1", nil)
                                        image:[UIImage imageNamed:@"timeline_explain_sleep"]];
    HEMTutorialContent* tutorial2 =
    [[HEMTutorialContent alloc] initWithTitle:NSLocalizedString(@"tutorial.timeline.title2", nil)
                                         text:NSLocalizedString(@"tutorial.timeline.message2", nil)
                                        image:[UIImage imageNamed:@"timeline_explain_score"]];
    HEMTutorialContent* tutorial3 =
    [[HEMTutorialContent alloc] initWithTitle:NSLocalizedString(@"tutorial.timeline.title3", nil)
                                         text:NSLocalizedString(@"tutorial.timeline.message3", nil)
                                        image:[UIImage imageNamed:@"timeline_explain_before"]];
    HEMTutorialContent* tutorial4 =
    [[HEMTutorialContent alloc] initWithTitle:NSLocalizedString(@"tutorial.timeline.title4", nil)
                                         text:NSLocalizedString(@"tutorial.timeline.message4", nil)
                                        image:[UIImage imageNamed:@"timeline_explain_graph"]];
    
    UIViewController* rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UIImage* snapshot = [[rootVC view] blurredSnapshotWithTint:[UIColor colorWithWhite:0.0f alpha:0.3f]];

    HEMTutorialViewController* tutorialVC = [HEMMainStoryboard instantiateTutorialViewController];
    [tutorialVC setTutorials:@[tutorial1, tutorial2, tutorial3, tutorial4]];
    [tutorialVC setBackgroundImage:snapshot];
    
    [rootVC presentViewController:tutorialVC animated:YES completion:nil];
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

+ (void)showTutorialForAlarmSmartness
{
    HEMDialogContent* content = [HEMDialogContent new];
    content.title = NSLocalizedString(@"tutorial.alarm-smart.title", nil);
    content.content = NSLocalizedString(@"tutorial.alarm-smart.message", nil);
    content.image = [UIImage imageNamed:@"smart_alarm_dialog"];
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
    return ![[[SENLocalPreferences sharedPreferences] sessionPreferenceForKey:key] boolValue];
}

+ (void)markTutorialViewed:(NSString*)key
{
    [[SENLocalPreferences sharedPreferences] setSessionPreference:@YES forKey:key];
}

@end
