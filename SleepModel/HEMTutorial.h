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

/**
 *  Show tutorial to describe what pill colors are for
 */
+ (void)showTutorialForPillColor;

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
 *  Show info about why enabling access to Lights expansion is a good idea.
 */
+ (void)showInfoForLightsExpansionFrom:(UIViewController*)controller;

/**
 *  Show info about why enabling access to thermostat expansion is a good idea.
 */
+ (void)showInfoForThermostatExpansionFrom:(UIViewController*)controller;

/**
 *  Show info about what happens if you enable thermostat for alarms.
 */
+ (void)showInfoForAlarmThermostatSetupFrom:(UIViewController*)controller;

/**
 *  Show info about what happens if you enable lights for alarms.
 */
+ (void)showInfoForAlarmLightsSetupFrom:(UIViewController*)controller;

@end
