//
//  HEMTutorial.m
//  Sense
//
//  Created by Delisa Mason on 1/28/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENLocalPreferences.h>
#import <SenseKit/SENTimeline.h>

#import "UIImage+HEMBlurTint.h"
#import "NSDate+HEMRelative.h"
#import "UIColor+HEMStyle.h"
#import "HEMTutorial.h"
#import "HEMTutorialContent.h"
#import "HEMTutorialViewController.h"
#import "HEMMainStoryboard.h"
#import "UIView+HEMSnapshot.h"
#import "HEMAppUsage.h"
#import "HEMHandholdingView.h"

@implementation HEMTutorial

static NSString* const HEMTutorialHHTimelineDaySwitchCounter = @"HandholdingTimelineDaySwitchCounter";
static NSString* const HEMTutorialHHTimelineDaySwitch = @"HandholdingTimelineDaySwitch";
static NSString* const HEMTutorialHHTimelineZoom = @"HandholdingTimelineZoom";
static CGFloat const HEMTutorialHHTimelineDaysGestureY = 205.0f;
static CGFloat const HEMTutorialHHTimelineDaysGestureXStart = 45.0f;
static NSInteger const HEMTutorialHHTimelineDaysMinDaysChecked = 2;
static NSUInteger const HEMTutorialHHTimelineZoomMinTimelinesViewed = 5;

static NSString* const HEMTutorialTimelineKey = @"HEMTutorialTimeline";
static NSString* const HEMTutorialSensorKeyFormat = @"HEMTutorialSensor_%@";
static NSString* const HEMTutorialSensorsKey = @"HEMTutorialSensors";
static NSString* const HEMTutorialAlarmsKey = @"HEMTutorialAlarms";
static NSString* const HEMTutorialTrendsKey = @"HEMTutorialTrends";
static NSString* const HEMTutorialPillColorKey = @"HEMTutorialPillColor";
static CGFloat const HEMTutorialDelay = 0.5f;

#pragma mark - Handholding

+ (BOOL)showHandholdingForTimelineDaySwitchIfNeededIn:(UIView*)view {
    if ([self shouldShowHandholdingForTimelineDaySwitch]) {
        [self showHandholdingForTimelineDaySwitchIn:view];
        [self markTutorialViewed:HEMTutorialHHTimelineDaySwitch];
        return YES;
    }
    [self setHandholdingFirstChecked:HEMTutorialHHTimelineDaySwitchCounter];
    return NO;
}

+ (void)showHandholdingForTimelineDaySwitchIn:(UIView*)view {
    CGFloat constraint = CGRectGetWidth([view bounds]);
    HEMHandholdingView* handholdingView = [[HEMHandholdingView alloc] init];
    [handholdingView setGestureStartCenter:CGPointMake(HEMTutorialHHTimelineDaysGestureXStart,
                                                       HEMTutorialHHTimelineDaysGestureY)];
    [handholdingView setGestureEndCenter:CGPointMake(constraint - HEMTutorialHHTimelineDaysGestureXStart,
                                                     HEMTutorialHHTimelineDaysGestureY)];
    [handholdingView setMessage:NSLocalizedString(@"handholding.message.timeline-switch-days", nil)];
    [handholdingView setAnchor:HEMHHDialogAnchorBottom];
    
    [handholdingView showInView:view];
}

+ (BOOL)shouldShowHandholdingForTimelineDaySwitch {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    if (![self shouldShowTutorialForKey:HEMTutorialHHTimelineDaySwitch]
        || [self shouldShowTutorialForTimeline]) {
        return NO;
    }
    
    NSDate* firstCheckedDate = [preferences sessionPreferenceForKey:HEMTutorialHHTimelineDaySwitchCounter];
    return [firstCheckedDate daysElapsed] >= HEMTutorialHHTimelineDaysMinDaysChecked;
}

+ (void)setHandholdingFirstChecked:(NSString*)key {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    NSDate* date = [preferences sessionPreferenceForKey:key];
    if (!date) {
        [preferences setSessionPreference:[NSDate date] forKey:key];
    }
}

+ (BOOL)showHandholdingForTimelineZoomIfNeededIn:(UIView*)view atTarget:(CGPoint)target {
    if ([self shouldShowHandholdingForTimelineZoom]) {
        [self showHandholdingForTimelineZoomIn:view atTarget:target];
        [self markTutorialViewed:HEMTutorialHHTimelineZoom];
        return YES;
    }
    return NO;
}

+ (BOOL)shouldShowHandholdingForTimelineZoom {
    if (![self shouldShowTutorialForKey:HEMTutorialHHTimelineZoom]) {
        return NO;
    }
    
    HEMAppUsage* timelineUsage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageTimelineShownWithData];
    return [timelineUsage usageWithin:HEMAppUsageIntervalLast31Days] >= HEMTutorialHHTimelineZoomMinTimelinesViewed;
}

+ (void)showHandholdingForTimelineZoomIn:(UIView*)view atTarget:(CGPoint)target {
    HEMHandholdingView* handholdingView = [[HEMHandholdingView alloc] init];
    [handholdingView setGestureStartCenter:target];
    [handholdingView setGestureEndCenter:target];
    
    [handholdingView setMessage:NSLocalizedString(@"handholding.message.timeline-zoom", nil)];
    [handholdingView setAnchor:HEMHHDialogAnchorBottom];
    
    [handholdingView showInView:view];
}

#pragma mark - Dialogs

+ (void)showTutorialForTimelineIfNeeded
{
    if ([self shouldShowTutorialForTimeline]) {
        if ([self showTutorialForTimeline]) {
            [self markTutorialViewed:HEMTutorialTimelineKey];
        }
    }
}

+ (BOOL)shouldShowTutorialForTimeline
{
    return [self shouldShowTutorialForKey:HEMTutorialTimelineKey];
}

+ (void)showTutorialForSensorsIfNeeded
{
    if ([self shouldShowTutorialForKey:HEMTutorialSensorsKey]) {
        [self delayBlock:^{
            if ([self showTutorialForSensors]) {
                [self markTutorialViewed:HEMTutorialSensorsKey];
            }
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

+ (void)showTutorialForAlarmsIfNeededFrom:(UIViewController *)controller
{
    if ([self shouldShowTutorialForKey:HEMTutorialAlarmsKey]) {
        [self delayBlock:^{
            [self showTutorialForAlarmsFrom:controller];
            [self markTutorialViewed:HEMTutorialAlarmsKey];
        }];
    }
}

+ (void)showTutorialForTrendsIfNeeded
{
    if ([self shouldShowTutorialForKey:HEMTutorialTrendsKey]) {
        [self delayBlock:^{
            if ([self showTutorialForTrends]) {
                [self markTutorialViewed:HEMTutorialTrendsKey];
            }
            
        }];
    }
}

+ (void)showTutorialForPillColorIfNeeded
{
    if ([self shouldShowTutorialForKey:HEMTutorialPillColorKey]) {
        [self delayBlock:^{
            if ([self showTutorialForPillColor]) {
                [self markTutorialViewed:HEMTutorialPillColorKey];
            }
        }];
    }
}

+ (BOOL)showTutorialWithContent:(NSArray*)content from:(UIViewController*)controller {
    UIImage* snapshot = [[controller view] snapshot];
    UIImage* blurredSnapshot = [snapshot blurredImageWithTint:[UIColor tutorialBackgroundColor]];
    
    HEMTutorialViewController* tutorialVC = [HEMMainStoryboard instantiateTutorialViewController];
    [tutorialVC setTutorials:content];
    [tutorialVC setBackgroundImage:blurredSnapshot];
    [tutorialVC setUnblurredBackgroundImage:snapshot];

    BOOL presented = NO;
    if (![controller presentedViewController]) {
        [controller presentViewController:tutorialVC animated:NO completion:nil];
        presented = YES;
    }
    return presented;
}

+ (BOOL)showTutorialWithContent:(NSArray*)content {
    UIViewController* rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    return [self showTutorialWithContent:content from:rootVC];
}

+ (BOOL)showTutorialForTimeline
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
    
    return [self showTutorialWithContent:@[tutorial1, tutorial2, tutorial3, tutorial4]];
}

+ (BOOL)showTutorialForSensors
{
    HEMTutorialContent* tutorial =
        [[HEMTutorialContent alloc] initWithTitle:NSLocalizedString(@"tutorial.sensors.title", nil)
                                             text:NSLocalizedString(@"tutorial.sensors.message", nil)
                                            image:[UIImage imageNamed:@"welcome_dialog_sensors"]];
    
    return [self showTutorialWithContent:@[tutorial]];
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
    
    HEMTutorialContent* tutorial =
    [[HEMTutorialContent alloc] initWithTitle:NSLocalizedString(localizedTitleKey, nil)
                                         text:NSLocalizedString(localizedMessageKey, nil)
                                        image:image];
    
    [self showTutorialWithContent:@[tutorial]];
}

+ (void)showTutorialForAlarmsFrom:(UIViewController*)controller
{
    HEMTutorialContent* tutorial =
    [[HEMTutorialContent alloc] initWithTitle:NSLocalizedString(@"tutorial.alarms.title", nil)
                                         text:NSLocalizedString(@"tutorial.alarms.message", nil)
                                        image:[UIImage imageNamed:@"welcome_dialog_alarm"]
                                    videoPath:NSLocalizedString(@"video.url.alarm", nil)];
    
    [self showTutorialWithContent:@[tutorial] from:controller];
}

+ (void)showTutorialForAlarmSmartnessFrom:(UIViewController*)controller
{
    HEMTutorialContent* tutorial =
    [[HEMTutorialContent alloc] initWithTitle:NSLocalizedString(@"tutorial.alarm-smart.title", nil)
                                         text:NSLocalizedString(@"tutorial.alarm-smart.message", nil)
                                        image:[UIImage imageNamed:@"smart_alarm_dialog"]];
    
    [self showTutorialWithContent:@[tutorial] from:controller];
}

+ (BOOL)showTutorialForTrends
{
    HEMTutorialContent* tutorial =
    [[HEMTutorialContent alloc] initWithTitle:NSLocalizedString(@"tutorial.trends.title", nil)
                                         text:NSLocalizedString(@"tutorial.trends.message", nil)
                                        image:[UIImage imageNamed:@"welcome_dialog_trends"]];
    return [self showTutorialWithContent:@[tutorial]];
}

+ (BOOL)showTutorialForPillColor
{
    HEMTutorialContent* tutorial =
    [[HEMTutorialContent alloc] initWithTitle:NSLocalizedString(@"tutorial.pill-color.title", nil)
                                         text:NSLocalizedString(@"tutorial.pill-color.message", nil)
                                        image:[UIImage imageNamed:@"pill_color_dialog"]];
    return [self showTutorialWithContent:@[tutorial]];
}

#pragma mark - Session Preferences

+ (BOOL)shouldShowTutorialForKey:(NSString*)key
{
    return ![[[SENLocalPreferences sharedPreferences] sessionPreferenceForKey:key] boolValue];
}

+ (void)markTutorialViewed:(NSString*)key
{
    [[SENLocalPreferences sharedPreferences] setSessionPreference:@YES forKey:key];
}

+ (void)resetTutorials {
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    [prefs setSessionPreference:@NO forKey:HEMTutorialTimelineKey];
    [prefs setSessionPreference:@NO forKey:HEMTutorialSensorsKey];
    [prefs setSessionPreference:@NO forKey:HEMTutorialAlarmsKey];
    [prefs setSessionPreference:@NO forKey:HEMTutorialTrendsKey];
    [prefs setSessionPreference:@NO forKey:HEMTutorialHHTimelineDaySwitch];
    [prefs setSessionPreference:@NO forKey:HEMTutorialPillColorKey];
    [prefs setSessionPreference:@NO forKey:HEMTutorialHHTimelineZoom];
}

@end
