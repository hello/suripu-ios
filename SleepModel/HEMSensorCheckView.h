//
//  HEMSensorCheckView.h
//  Sense
//
//  This view displays 1 sensor data as part of the "Room Check" feature, which
//  is part of Onboarding.
//
//  Created by Jimmy Lu on 12/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const HEMSensorCheckCollapsedHeight;

@interface HEMSensorCheckView : UIView

/**
 * Initialize the view with the icon that represents the sensor, a highlighted
 * version of the icon, title to display what the sensor is, a message for the
 * sensor describing it's state and the current value of the sensor along with
 * it's color of the condition of the sensor.
 *
 * @param icon:             icon of sensor
 * @param highlightedIcon:  highlighted version of the icon
 * @param title:            title for the sensor
 * @param message:          attributed message describing state of sensor
 * @param value:            the value of the sensor
 * @param color:            condition color of the sensor
 */
- (instancetype)initWithIcon:(UIImage*)icon
             highlightedIcon:(UIImage*)highlighedIcon
                       title:(NSString*)title
                     message:(NSAttributedString*)message
                       value:(NSString*)value
          withConditionColor:(UIColor*)color;

/**
 * Move the view to y origin while expanding it's height and applying additional
 * animations during the process.  This can also be thought of as expanding the
 * view, which will automatically highlight the sensor icon
 *
 * @param y:          the y origin the view should move to
 * @param height:     the expanded height of the view
 * @param animations: the animations to additional apply
 * @param completion: the block to invoke when all is done
 */
- (void)moveTo:(CGFloat)y
   andExpandTo:(CGFloat)height
whileAnimating:(void(^)(void))animations
  onCompletion:(void(^)(BOOL finished))completion;

/**
 * Collapse the view.  This is not animated
 */
- (void)collapse;

/**
 * Show the sensor value that was initialized
 */
- (void)showSensorValue;

@end
