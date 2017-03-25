//
//  HEMWarningCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/8/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "Sense-Swift.h"

#import "HEMWarningCollectionViewCell.h"
#import "HEMActionButton.h"

CGFloat const HEMWarningCellBaseHeight = 170.0f;
CGFloat const HEMWarningCellMessageHorzPadding = 24.0f;

@implementation HEMWarningCollectionViewCell

+ (NSDictionary*)messageAttributes {
    UIFont* messageFont = [SenseStyle fontWithGroup:GroupWarningView
                                           property:ThemePropertyDetailFont];
    UIColor* messageColor = [SenseStyle colorWithGroup:GroupWarningView
                                              property:ThemePropertyDetailColor];
    return @{NSParagraphStyleAttributeName : DefaultBodyParagraphStyle(),
             NSForegroundColorAttributeName : messageColor,
             NSFontAttributeName : messageFont};
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self applyStyle];
}

- (void)applyStyle {
    UIColor* separatorColor = [SenseStyle colorWithGroup:GroupWarningView property:ThemePropertySeparatorColor];
    UIColor* backgroundColor = [SenseStyle colorWithGroup:GroupWarningView property:ThemePropertyBackgroundColor];
    UIColor* summaryColor = [SenseStyle colorWithGroup:GroupWarningView property:ThemePropertyTextColor];
    UIColor* messageColor = [SenseStyle colorWithGroup:GroupWarningView property:ThemePropertyDetailColor];
    UIFont* summaryFont = [SenseStyle fontWithGroup:GroupWarningView property:ThemePropertyTextFont];
    UIFont* messageFont = [SenseStyle fontWithGroup:GroupWarningView property:ThemePropertyDetailFont];
    
    [[self contentView] setBackgroundColor:backgroundColor];
    [[self warningSummaryLabel] setTextColor:summaryColor];
    [[self warningSummaryLabel] setFont:summaryFont];
    [[self warningMessageLabel] setTextColor:messageColor];
    [[self warningMessageLabel] setFont:messageFont];
    [[self separator] setBackgroundColor:separatorColor];
}

@end
