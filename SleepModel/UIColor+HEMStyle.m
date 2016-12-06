//
//  UIColor+HEMStyle.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENTimeline.h>
#import "UIColor+HEMStyle.h"

@implementation UIColor (HEMStyle)

+ (UIColor *)colorWithHex:(uint)hexValue alpha:(float)alpha {
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0
                           green:((float)((hexValue & 0xFF00) >> 8)) / 255.0
                            blue:((float)(hexValue & 0xFF)) / 255.0
                           alpha:alpha];
}

#pragma mark - Appearance 

+ (void)applyDefaultColorAppearances {
    [[UITableView appearance] setSeparatorColor:[self grey3]];
    [[UILabel appearance] setTintColor:[self textColor]];
}

#pragma mark - Standard Hello Colors from Style Guide

#pragma mark Greys

+ (UIColor*)grey1 {
    return [UIColor colorWithHex:0xF8F8F9 alpha:1.0f];
}

+ (UIColor*)grey2 {
    return [UIColor colorWithHex:0xE8EAED alpha:1.0f];
}

+ (UIColor*)grey3 {
    return [UIColor colorWithHex:0xB9BFC8 alpha:1.0f];
}

+ (UIColor*)grey4 {
    return [UIColor colorWithHex:0x8B95A4 alpha:1.0f];
}

+ (UIColor*)grey5 {
    return [UIColor colorWithHex:0x5C6B7F alpha:1.0f];
}

+ (UIColor*)grey6 {
    return [UIColor colorWithHex:0x162B48 alpha:1.0f];
}

+ (UIColor*)grey7 {
    return [UIColor colorWithHex:0x0C1B30 alpha:1.0f];
}

#pragma mark Purple

+ (UIColor*)purple1 {
    return [UIColor colorWithHex:0xFCFAFE alpha:1.0f];
}

+ (UIColor*)purple2 {
    return [UIColor colorWithHex:0xF3EFFC alpha:1.0f];
}

+ (UIColor*)purple3 {
    return [UIColor colorWithHex:0xDBCEF6 alpha:1.0f];
}

+ (UIColor*)purple4 {
    return [UIColor colorWithHex:0xC3AEEF alpha:1.0f];
}

+ (UIColor*)purple5 {
    return [UIColor colorWithHex:0xAB8DE8 alpha:1.0f];
}

+ (UIColor*)purple6 {
    return [UIColor colorWithHex:0x865CDE alpha:1.0f];
}

+ (UIColor*)purple7 {
    return [UIColor colorWithHex:0x764EC9 alpha:1.0f];
}

#pragma mark Blue

+ (UIColor*)blue1 {
    return [UIColor colorWithHex:0xF7FCFF alpha:1.0f];
}

+ (UIColor*)blue2 {
    return [UIColor colorWithHex:0xE5F5FF alpha:1.0f];
}

+ (UIColor*)blue3 {
    return [UIColor colorWithHex:0xB2E1FF alpha:1.0f];
}

+ (UIColor*)blue4 {
    return [UIColor colorWithHex:0x7FCDFF alpha:1.0f];
}

+ (UIColor*)blue5 {
    return [UIColor colorWithHex:0x4CB9FF alpha:1.0f];
}

+ (UIColor*)blue6 {
    return [UIColor colorWithHex:0x009AFF alpha:1.0f];
}

+ (UIColor*)blue7 {
    return [UIColor colorWithHex:0x0083D9 alpha:1.0f];
}

#pragma mark Green

+ (UIColor*)green1 {
    return [UIColor colorWithHex:0xF9FEFD alpha:1.0f];
}

+ (UIColor*)green2 {
    return [UIColor colorWithHex:0xEBFCF7 alpha:1.0f];
}

+ (UIColor*)green3 {
    return [UIColor colorWithHex:0xC3F4E6 alpha:1.0f];
}

+ (UIColor*)green4 {
    return [UIColor colorWithHex:0x9BECD4 alpha:1.0f];
}

+ (UIColor*)green5 {
    return [UIColor colorWithHex:0x72E4C3 alpha:1.0f];
}

+ (UIColor*)green6 {
    return [UIColor colorWithHex:0x36D8A9 alpha:1.0f];
}

+ (UIColor*)green7 {
    return [UIColor colorWithHex:0x21BD90 alpha:1.0f];
}

#pragma mark Yellow

+ (UIColor*)yellow1 {
    return [UIColor colorWithHex:0xFFFDF8 alpha:1.0f];
}

+ (UIColor*)yellow2 {
    return [UIColor colorWithHex:0xFFF9E8 alpha:1.0f];
}

+ (UIColor*)yellow3 {
    return [UIColor colorWithHex:0xFFEBB9 alpha:1.0f];
}

+ (UIColor*)yellow4 {
    return [UIColor colorWithHex:0xFFDE8B alpha:1.0f];
}

+ (UIColor*)yellow5 {
    return [UIColor colorWithHex:0xFFD05D alpha:1.0f];
}

+ (UIColor*)yellow6 {
    return [UIColor colorWithHex:0xFFBC17 alpha:1.0f];
}

+ (UIColor*)yellow7 {
    return [UIColor colorWithHex:0xE9AD1A alpha:1.0f];
}

#pragma mark Orange

+ (UIColor*)orange1 {
    return [UIColor colorWithHex:0xFFFCFA alpha:1.0f];
}

+ (UIColor*)orange2 {
    return [UIColor colorWithHex:0xFFF5EC alpha:1.0f];
}

+ (UIColor*)orange3 {
    return [UIColor colorWithHex:0xFFE0C6 alpha:1.0f];
}

+ (UIColor*)orange4 {
    return [UIColor colorWithHex:0xFFCBA1 alpha:1.0f];
}

+ (UIColor*)orange5 {
    return [UIColor colorWithHex:0xFFB67B alpha:1.0f];
}

+ (UIColor*)orange6 {
    return [UIColor colorWithHex:0xFF9742 alpha:1.0f];
}

+ (UIColor*)orange7 {
    return [UIColor colorWithHex:0xE88A3D alpha:1.0f];
}

#pragma mark Red

+ (UIColor*)red1 {
    return [UIColor colorWithHex:0xFFFCFB alpha:1.0f];
}

+ (UIColor*)red2 {
    return [UIColor colorWithHex:0xFFF4F2 alpha:1.0f];
}

+ (UIColor*)red3 {
    return [UIColor colorWithHex:0xFFC8BB alpha:1.0f];
}

+ (UIColor*)red4 {
    return [UIColor colorWithHex:0xFFB2A0 alpha:1.0f];
}

+ (UIColor*)red5 {
    return [UIColor colorWithHex:0xFF9177 alpha:1.0f];
}

+ (UIColor*)red6 {
    return [UIColor colorWithHex:0xFF6B47 alpha:1.0f];
}

+ (UIColor*)red7 {
    return [UIColor colorWithHex:0xE35533 alpha:1.0f];
}

#pragma mark - Timeline colors

// The below timeline utility color functions should ideally reside in a presenter

+ (UIColor *)colorForCondition:(SENCondition)condition {
    switch (condition) {
        case SENConditionAlert:
            return [self red6];
        case SENConditionWarning:
            return [self yellow6];
        case SENConditionIdeal:
            return [self green6];
        default:
            return [self grey3];
    }
}

+ (UIColor *)colorForSleepState:(SENTimelineSegmentSleepState)state {
    switch (state) {
        case SENTimelineSegmentSleepStateLight:
            return [self blue4];
        case SENTimelineSegmentSleepStateMedium:
            return [self blue5];
        case SENTimelineSegmentSleepStateSound:
            return [self blue6];
        case SENTimelineSegmentSleepStateAwake:
        default:
            return [self clearColor];
    }
}

+ (UIColor *)colorForSleepScore:(NSInteger)score {
    if (score == 0) {
        return [self colorForCondition:SENConditionUnknown];
    } else if (score < 50) {
        return [self colorForCondition:SENConditionAlert];
    } else if (score < 80) {
        return [self colorForCondition:SENConditionWarning];
    } else {
        return [self colorForCondition:SENConditionIdeal];
    }
}

+ (UIColor *)timelineBackgroundColor {
    return [self blue2];
}

+ (NSArray *)timelineSelectedGradientColorRefs {
    // if you change the values, you should check the references to ensure the
    // locations matches the colors
    return @[(id)[UIColor colorWithHex:0xF5F7FA alpha:1.f].CGColor,
             (id)[UIColor colorWithHex:0xF5F7FA alpha:0.f].CGColor];
}

#pragma mark - Background colors

+ (UIColor *)backgroundColor {
    return [UIColor colorWithHex:0xEBEDF0 alpha:1.f];
}

+ (UIColor *)lightBackgroundColor {
    return [self grey1];
}

+ (UIColor *)seeThroughBackgroundColor {
    return [UIColor colorWithHex:0x596980 alpha:0.9];
}

+ (UIColor *)lightSeeThroughBackgroundColor {
    return [[self grey6] colorWithAlphaComponent:0.6f];
}

#pragma mark - Text colors

+ (UIColor *)settingsTextColor {
    return [self grey6];
}
+ (UIColor *)settingsDetailTextColor {
    return [self grey3];
}
+ (UIColor *)boldTextColor {
    return [self grey7];
}
+ (UIColor *)textColor {
    return [self grey6];
}
+ (UIColor *)detailTextColor {
    return [self grey4];
}
+ (UIColor *)lowImportanceTextColor {
    return [self grey3];
}

#pragma mark - Navigation bar color

+ (UIColor *)navigationBarColor {
    return [UIColor whiteColor];
}

+ (UIColor *)subNavActiveTitleColor {
    return [self grey6];
}
+ (UIColor *)subNavInactiveTitleColor {
    return [self grey3];
}

#pragma mark - Card colors

+ (UIColor *)cardBorderColor {
    return [self colorWithHex:0xE5E5E5 alpha:1.f];
}
+ (UIColor *)cardTitleColor {
    return [self grey6];
}

#pragma mark - Separators / Lines

+ (UIColor *)separatorColor {
    return [self grey2];
}

#pragma mark - Common colors

+ (UIColor *)tintColor {
    return [self blue6];
}
+ (UIColor *)disabledColor {
    return [self grey4];
}
+ (UIColor *)borderColor {
    return [self grey2];
}
+ (UIColor *)touchIndicatorColor {
    return [self grey1];
}
+ (NSArray*)loadingIndicatorColorRefs {
    return @[(id)[[UIColor clearColor] CGColor],
             (id)[[UIColor colorWithWhite:0.0f alpha:0.25f] CGColor],
             (id)[[UIColor colorWithWhite:0.0f alpha:0.5f] CGColor],
             (id)[[UIColor colorWithWhite:0.0f alpha:0.25f] CGColor],
             (id)[[UIColor clearColor] CGColor]];
}


@end
