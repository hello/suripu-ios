//
//  HelloStyleKit.h
//  Sleep Sense
//
//  Created by Delisa Mason on 10/14/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class PCGradient;

@interface HelloStyleKit : NSObject

// Colors
+ (UIColor*)darkBlueColor;
+ (UIColor*)mediumBlueColor;
+ (UIColor*)currentConditionsBackgroundColor;
+ (UIColor*)highSleepScoreColor;
+ (UIColor*)poorSleepScoreColor;
+ (UIColor*)averageSleepScoreColor;
+ (UIColor*)lightBlueColor;
+ (UIColor*)lightestBlueColor;
+ (UIColor*)alertSensorColor;
+ (UIColor*)idealSensorColor;
+ (UIColor*)warningSensorColor;
+ (UIColor*)lightSleepColor;
+ (UIColor*)intermediateSleepColor;
+ (UIColor*)deepSleepColor;
+ (UIColor*)awakeSleepColor;
+ (UIColor*)sleepQuestionBgColor;
+ (UIColor*)onboardingBlueColor;
+ (UIColor*)onboardingGrayColor;
+ (UIColor*)purple;

// Gradients
+ (PCGradient*)blueBackgroundGradient;

// Images
+ (UIImage*)alarmEnabledIcon;
+ (UIImage*)chevronIconLeft;
+ (UIImage*)alarmNoteIcon;
+ (UIImage*)questionIcon;
+ (UIImage*)bluetoothLogoImage;
+ (UIImage*)wifiLogoImage;
+ (UIImage*)humidityIcon;
+ (UIImage*)particleIcon;
+ (UIImage*)temperatureIcon;
+ (UIImage*)lightEventIcon;
+ (UIImage*)noiseEventIcon;
+ (UIImage*)sleepEventIcon;
+ (UIImage*)wakeupEventIcon;
+ (UIImage*)chevronIconRight;
+ (UIImage*)motionEventIcon;
+ (UIImage*)alarmsIcon;
+ (UIImage*)sleepInsightsIcon;
+ (UIImage*)senseIcon;
+ (UIImage*)pillIcon;
+ (UIImage*)alarmRepeatIcon;
+ (UIImage*)alarmSmartIcon;
+ (UIImage*)alarmSoundIcon;
+ (UIImage*)humidityDarkIcon;
+ (UIImage*)particleDarkIcon;
+ (UIImage*)temperatureDarkIcon;
+ (UIImage*)sense;

// Drawing Methods
+ (void)drawSleepScoreGraphWithSleepScoreLabelText: (NSString*)sleepScoreLabelText sleepScore: (CGFloat)sleepScore;
+ (void)drawMiniSleepScoreGraphWithSleepScore: (CGFloat)sleepScore;

@end



@interface PCGradient : NSObject
@property(nonatomic, readonly) CGGradientRef CGGradient;
- (CGGradientRef)CGGradient NS_RETURNS_INNER_POINTER;

+ (instancetype)gradientWithColors: (NSArray*)colors locations: (const CGFloat*)locations;
+ (instancetype)gradientWithStartingColor: (UIColor*)startingColor endingColor: (UIColor*)endingColor;

@end
