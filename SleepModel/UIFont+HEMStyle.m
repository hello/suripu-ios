//
//  UIFont+HEMStyle.m
//  Sense
//
//  Created by Delisa Mason on 11/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"
#import "HEMScreenUtils.h"

@implementation UIFont (HEMStyle)

#pragma mark - Style guide

+ (UIFont*)h1 {
    return [UIFont systemFontOfSize:64.0f weight:UIFontWeightThin];
}

+ (UIFont*)h2 {
    return [UIFont systemFontOfSize:40.0f weight:UIFontWeightThin];
}

+ (UIFont*)h3 {
    return [UIFont systemFontOfSize:32.0f weight:UIFontWeightLight];
}

+ (UIFont*)h4 {
    return [UIFont systemFontOfSize:24.0f weight:UIFontWeightLight];
}

+ (UIFont*)h5 {
    return [UIFont systemFontOfSize:20.0f weight:UIFontWeightRegular];
}

+ (UIFont*)h6 {
    return [UIFont systemFontOfSize:18.0f weight:UIFontWeightRegular];
}

+ (UIFont*)h6Bold {
    return [UIFont systemFontOfSize:18.0f weight:UIFontWeightMedium];
}

+ (UIFont*)h7 {
    return [UIFont systemFontOfSize:12.0f weight:UIFontWeightRegular];
}

+ (UIFont*)h7Bold {
    return [UIFont systemFontOfSize:12.0f weight:UIFontWeightMedium];
}

+ (UIFont*)h8 {
    return [UIFont systemFontOfSize:10.0f weight:UIFontWeightMedium];
}

+ (UIFont*)body {
    return [UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular];
}

+ (UIFont*)bodyBold {
    return [UIFont systemFontOfSize:15.0f weight:UIFontWeightMedium];
}

+ (UIFont*)bodySmall {
    return [UIFont systemFontOfSize:14.0f weight:UIFontWeightRegular];
}

+ (UIFont*)bodySmallBold {
    return [UIFont systemFontOfSize:14.0f weight:UIFontWeightMedium];
}

+ (UIFont*)buttonLarge {
    return [UIFont systemFontOfSize:24.0f weight:UIFontWeightRegular];
}

+ (UIFont*)button {
    return [UIFont systemFontOfSize:14.0f weight:UIFontWeightMedium];
}

+ (UIFont*)buttonSmall {
    return [UIFont systemFontOfSize:13.0f weight:UIFontWeightMedium];
}

#pragma mark - Common fonts

+ (UIFont*)settingsTableCellFont {
    return [self body];
}

+ (UIFont*)settingsTableCellDetailFont {
    return [self body];
}

+ (UIFont*)settingsHelpFont {
    return [self h7];
}

#pragma mark - Special custom font sizes

#pragma mark Alarms

+ (UIFont*)alarmMeridiemFont {
    return [UIFont systemFontOfSize:16.0f weight:UIFontWeightRegular];
}

+ (UIFont*)alarmNumberFont {
    return [UIFont systemFontOfSize:28.0f weight:UIFontWeightThin];
}

+ (UIFont*)alarmSelectedNumberFont {
    return [UIFont systemFontOfSize:56.0f weight:UIFontWeightThin];
}

+ (UIFont*)alarmButtonFont {
    return [UIFont systemFontOfSize:14.0f weight:UIFontWeightMedium];
}

#pragma mark - Sensor

+ (UIFont*)sensorUnitFontForUnit:(SENSensorUnit)unit {
    switch (unit) {
        case SENSensorUnitMGCM:
            return [UIFont systemFontOfSize:22.0f weight:UIFontWeightLight];
        default:
            return [self h3];
    }
}

#pragma mark - Timeline

+ (UIFont*)timelineBreakdownTitleFont {
    return [UIFont systemFontOfSize:11.0f weight:UIFontWeightMedium];
}

+ (UIFont*)timelineBreakdownMessageFont {
    return [UIFont systemFontOfSize:14.0f weight:UIFontWeightLight];
}

+ (UIFont*)timelineBreakdownMessageBoldFont {
    return [UIFont systemFontOfSize:14.0f weight:UIFontWeightMedium];
}

+ (UIFont*)timelineEventMessageFont {
    return [UIFont systemFontOfSize:14.0f weight:UIFontWeightLight];
}

#pragma mark - Trends

+ (UIFont*)trendAverageValueFont {
    return [UIFont systemFontOfSize:28.0f weight:UIFontWeightLight];
}

+ (UIFont*)trendSleepDepthValueFontWithSize:(CGFloat)size {
    return [UIFont systemFontOfSize:size weight:UIFontWeightLight];
}

@end
