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
#import <SenseKit/SENSensor.h>

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

static NSString* const HEMTutorialAlarmsKey = @"HEMTutorialAlarms";

+ (void)showTutorialForAlarmsIfNeededFrom:(UIViewController *)controller
{
    if ([self shouldShowTutorialForKey:HEMTutorialAlarmsKey]) {
        [self showTutorialForAlarmsFrom:controller];
        [self markTutorialViewed:HEMTutorialAlarmsKey];
    }
}

#pragma mark - Common

+ (BOOL)showTutorialWithContent:(NSArray*)content from:(UIViewController*)controller {
    UIImage* snapshot = [[controller view] snapshot];
    UIImage* blurredSnapshot = [snapshot blurredImageWithTint:[UIColor lightSeeThroughBackgroundColor]];
    
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

+ (void)showTutorialForAlarmsFrom:(UIViewController*)controller {
    HEMTutorialContent* tutorial =
    [[HEMTutorialContent alloc] initWithTitle:NSLocalizedString(@"tutorial.alarms.title", nil)
                                         text:NSLocalizedString(@"tutorial.alarms.message", nil)
                                        image:[UIImage imageNamed:@"welcome_dialog_alarm"]
                                    videoPath:NSLocalizedString(@"video.url.alarm", nil)];
    
    [self showTutorialWithContent:@[tutorial] from:controller];
}

+ (void)showTutorialForAlarmSmartnessFrom:(UIViewController*)controller {
    HEMTutorialContent* tutorial =
    [[HEMTutorialContent alloc] initWithTitle:NSLocalizedString(@"tutorial.alarm-smart.title", nil)
                                         text:NSLocalizedString(@"tutorial.alarm-smart.message", nil)
                                        image:[UIImage imageNamed:@"smart_alarm_dialog"]];
    
    [self showTutorialWithContent:@[tutorial] from:controller];
}

+ (void)showTutorialForPillColor {
    HEMTutorialContent* tutorial =
    [[HEMTutorialContent alloc] initWithTitle:NSLocalizedString(@"tutorial.pill-color.title", nil)
                                         text:NSLocalizedString(@"tutorial.pill-color.message", nil)
                                        image:[UIImage imageNamed:@"pill_color_dialog"]];
    [self showTutorialWithContent:@[tutorial]];
}

#pragma mark - Expansions

+ (void)showInfoForLightsExpansionFrom:(UIViewController*)controller {
    NSString* text = NSLocalizedString(@"expansion.info.lights.description", nil);
    [self showExpansionInfoWithText:text fromController:controller];
}

+ (void)showInfoForThermostatExpansionFrom:(UIViewController*)controller {
    NSString* text = NSLocalizedString(@"expansion.info.thermostat.description", nil);
    [self showExpansionInfoWithText:text fromController:controller];
}

+ (void)showInfoForAlarmThermostatSetupFrom:(UIViewController*)controller {
    NSString* text = NSLocalizedString(@"alarm.expansion.info.thermostat.description", nil);
    [self showExpansionInfoWithText:text fromController:controller];
}

+ (void)showInfoForAlarmLightsSetupFrom:(UIViewController*)controller {
    NSString* text = NSLocalizedString(@"alarm.expansion.info.lights.description", nil);
    [self showExpansionInfoWithText:text fromController:controller];
}

+ (void)showExpansionInfoWithText:(NSString*)text fromController:(UIViewController*)controller {
    HEMTutorialContent* tutorial =
    [[HEMTutorialContent alloc] initWithTitle:NSLocalizedString(@"expansion.info.title", nil)
                                         text:text
                                        image:[UIImage imageNamed:@"expInfoIllustration"]];
    [self showTutorialWithContent:@[tutorial] from:controller];
}

#pragma mark - Preferences

/**
 * TODO: remove session preference check at some distant version of the app.
 *
 * Previously it was showing per session, but now we want to show only once per
 * install of the app.  For users who have installed the app before 1.1.5, we 
 * want to still make sure they won't see the dialogs on an update to 1.1.5
 * so we must also check to see that session preference exist or not.
 *
 * For early users, if user logs out, they will see the dialogs once more and that's
 * it for the life of the app.
 */
+ (BOOL)shouldShowTutorialForKey:(NSString*)key
{
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    return ![[preferences persistentPreferenceForKey:key] boolValue]
        && ![[preferences sessionPreferenceForKey:key] boolValue];
}

+ (void)markTutorialViewed:(NSString*)key
{
    [[SENLocalPreferences sharedPreferences] setPersistentPreference:@YES forKey:key];
}

+ (void)resetTutorials {
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    [prefs setPersistentPreference:@NO forKey:HEMTutorialAlarmsKey];
}

@end
