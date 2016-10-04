//
//  HEMTutorial.h
//  Sense
//
//  Created by Delisa Mason on 1/28/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMTutorial : NSObject

#pragma mark - Dialogs

+ (void)showTutorialForSleepSoundsIfNeeded;

/**
 *  Present the timeline tutorial if not previously viewed
 */
+ (void)showTutorialForTimelineIfNeeded;

+ (BOOL)shouldShowTutorialForTimeline;

/**
 *  Show tutorial to describe what pill colors are for
 */
+ (void)showTutorialForPillColor;

/**
 * Present the tutorial for alarms if not previously viewed
 * @param controller: the alarm controller to show tutorial on top of
 */
+ (void)showTutorialForAlarmsIfNeededFrom:(UIViewController*)controller;

/**
 * Present the tutorial for alarms
 * @param controller: the alarm controller to show tutorial on top of
 */
+ (void)showTutorialForAlarmsFrom:(UIViewController*)controller;

/**
 *  Show a dialog about making alarms smart
 */
+ (void)showTutorialForAlarmSmartnessFrom:(UIViewController*)controller;

/**
 *  Show a dialog to display information about enabling expansions
 */
+ (void)showInfoForExpansionFrom:(UIViewController*)controller;

/**
 * Mark all tutorials as unviewed so that they can be triggered again
 */
+ (void)resetTutorials;

@end
