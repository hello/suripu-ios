//
//  HEMTutorial.h
//  Sense
//
//  Created by Delisa Mason on 1/28/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMTutorial : NSObject

#pragma mark - Handholding\

/**
 * @return YES if caller should show tutorial for insight tap gesture.  No otherwise
 */
+ (BOOL)shouldShowInsightTapTutorial;

/**
 * Present the handholding UI to illustrate how to tap on an Insight card to
 * review more information if not previously shown
 *
 * @param view: the view to show the tutorial in
 * @param point: the center point for the gesture to appear at
 * @return YES if shown / needed, NO otherwise
 */
+ (BOOL)showHandholdingForInsightCardIfNeededIn:(UIView*)view atPoint:(CGPoint)point;

/**
 * Present the handholding UI to illustrate how to switch days in the Timeline,
 * if not previously shown and meets requirements
 *
 * @param view: the view to show the tutorial in
 * @return YES if shown / needed, NO otherwise
 */
+ (BOOL)showHandholdingForTimelineDaySwitchIfNeededIn:(UIView*)view;

/**
 * Present the handholding UI to illustrate how to zoom out of the timeline for
 * faster day switching
 *
 * @param view: the view to show the tutorial in
 * @param target: the location for the tap target
 * @return YES if shown / needed, NO otherwise
 */
+ (BOOL)showHandholdingForTimelineZoomIfNeededIn:(UIView*)view atTarget:(CGPoint)target;

/**
 * Present the handholding UI to illustrate how to scrub through sensor history /
 * detail values inside a sensor history view
 * 
 * @param view: the view to show the tutorial on
 * @param graphFrame: frame of the graph where the scrubbing would take place, relative
 *                    to the view that the tutorial will be presented over
 * @return YES if shown, NO otherwise
 */
+ (BOOL)showHandholdingForSensorScrubbingIfNeededIn:(UIView*)view relativeToGraphFrame:(CGRect)graphFrame;

#pragma mark - Dialogs

/**
 *  Present the timeline tutorial if not previously viewed
 */
+ (void)showTutorialForTimelineIfNeeded;

+ (BOOL)shouldShowTutorialForTimeline;

/**
 *  Present the tutorial for the sensor overview screen if not previously viewed
 */
+ (void)showTutorialForSensorsIfNeeded;

/**
 *  Show tutorial to describe what pill colors are for
 */
+ (void)showTutorialForPillColor;

/**
 *  Present the tutorial for a particular sensor if not previously viewed
 *
 *  @param sensorName name of the sensor
 *  @return YES if shown / needed.  No otherwise
 */
+ (BOOL)showTutorialIfNeededForSensorNamed:(NSString*)sensorName;

+ (void)showTutorialForSensorNamed:(NSString*)sensorName;

/**
 *  Present the tutorial for trends if not previously viewed
 */
+ (void)showTutorialForTrendsIfNeeded;

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
 * Mark all tutorials as unviewed so that they can be triggered again
 */
+ (void)resetTutorials;

@end
