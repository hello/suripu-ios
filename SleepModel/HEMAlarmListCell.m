//
//  HEMAlarmListCell.m
//  Sense
//
//  Created by Delisa Mason on 12/17/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "Sense-Swift.h"
#import "HEMAlarmListCell.h"

@implementation HEMAlarmListCell

+ (UIFont*)detailFont {
    return [SenseStyle fontWithAClass:[self class] property:ThemePropertyDetailFont];
}

- (void)applyStyle {
    [super applyStyle];
    
    UIColor* primaryColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    UIColor* disabledColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextDisabledColor];
    UIColor* textColor = [[self enabledSwitch] isOn] ? primaryColor : disabledColor;
    
    UIColor* tintColor = [SenseStyle colorWithAClass:[UISwitch class] property:ThemePropertyTintColor];
    [[self enabledSwitch] setTintColor:tintColor];
    
    UIColor* bgColor = [SenseStyle colorWithAClass:[UISwitch class] property:ThemePropertyBackgroundColor];
    [[self enabledSwitch] setBackgroundColor:bgColor];
    
    static NSString* titleFontKey = @"sense.alarm.title.font";
    UIFont* titleFont = [SenseStyle fontWithAClass:[self class] propertyName:titleFontKey];
    [[self titleLabel] setFont:titleFont];
    [[self titleLabel] setTextColor:disabledColor];
    
    static NSString* meridienFontKey = @"sense.alarm.meridient.font";
    UIFont* meridienFont = [SenseStyle fontWithAClass:[self class] propertyName:meridienFontKey];
    [[self meridiemLabel] setFont:meridienFont];
    [[self meridiemLabel] setTextColor:textColor];
    
    static NSString* timeFontKey = @"sense.alarm.time.font";
    UIFont* timeFont = [SenseStyle fontWithAClass:[self class] propertyName:timeFontKey];
    [[self timeLabel] setFont:timeFont];
    [[self timeLabel] setTextColor:textColor];
    
    UIColor* detailColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyDetailColor];
    UIFont* detailFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyDetailFont];
    [[self detailLabel] setFont:detailFont];
    [[self detailLabel] setTextColor:detailColor];
}

@end
