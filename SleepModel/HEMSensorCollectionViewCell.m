//
//  HEMSensorCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 9/1/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "Sense-Swift.h"

#import "NSString+HEMUtils.h"

#import "HEMSensorCollectionViewCell.h"
#import "HEMSensorChartContainer.h"

static CGFloat const HEMSensorCellPadding = 24.0f;
static CGFloat const HEMSensorCellNameHeight = 24.0f;
static CGFloat const HEMSensorCellGraphHeight = 112.0f;
static CGFloat const HEMSensorCellTextWidthRatio = 0.75f;

@implementation HEMSensorCollectionViewCell

+ (CGFloat)heightWithDescription:(NSString*)description cellWidth:(CGFloat)cellWidth {
    UIFont* descFont = [SenseStyle fontWithGroup:GroupSensorCard property:ThemePropertyDetailFont];
    CGFloat widthMinusPadding = cellWidth - (HEMSensorCellPadding * 2);
    CGFloat maxTextWidth = widthMinusPadding * HEMSensorCellTextWidthRatio;
    CGFloat totalHeight = HEMSensorCellPadding;
    totalHeight += HEMSensorCellNameHeight;
    totalHeight += [description heightBoundedByWidth:maxTextWidth usingFont:descFont];
    totalHeight += HEMSensorCellPadding;
    totalHeight += HEMSensorCellGraphHeight;
    return totalHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self applyDefaultStyle];
}

- (void)prepareForReuse {
    [[self valueLabel] setText:nil];
    [[self valueLabel] setAttributedText:nil];
}

- (void)applyDefaultStyle {
    static NSString* valueFontKey = @"sense.sensor.value.font";
    UIFont* nameFont = [SenseStyle fontWithGroup:GroupSensorCard property:ThemePropertyTextFont];
    UIFont* descFont = [SenseStyle fontWithGroup:GroupSensorCard property:ThemePropertyDetailFont];
    UIFont* valueFont = [SenseStyle fontWithGroup:GroupSensorCard propertyName:valueFontKey];
    UIFont* hintFont = [SenseStyle fontWithGroup:GroupSensorCard property:ThemePropertyHintFont];
    [[self nameLabel] setFont:nameFont];
    [[self descriptionLabel] setFont:descFont];
    [[self descriptionLabel] setNumberOfLines:0];
    [[self valueLabel] setFont:valueFont];
    [[self unitLabel] setFont:hintFont];
    [[[self graphContainerView] topLimitLabel] setFont:hintFont];
    [[[self graphContainerView] botLimitLabel] setFont:hintFont];
}

- (void)applyStyle {
    [super applyStyle];
    [[self graphContainerView] setBackgroundColor:[self backgroundColor]];
    [[[self graphContainerView] chartView] setBackgroundColor:[self backgroundColor]];
 
    UIColor* nameColor = [SenseStyle colorWithGroup:GroupSensorCard property:ThemePropertyTextColor];
    UIColor* descColor = [SenseStyle colorWithGroup:GroupSensorCard property:ThemePropertyDetailColor];
    UIColor* hintColor = [SenseStyle colorWithGroup:GroupSensorCard property:ThemePropertyHintColor];
    UIColor* separatorColor = [SenseStyle colorWithGroup:GroupSensorCard property:ThemePropertySeparatorColor];
    [[self nameLabel] setTextColor:nameColor];
    [[self descriptionLabel] setTextColor:descColor];
    [[self unitLabel] setTextColor:hintColor];
    [[[self graphContainerView] topLimitLabel] setTextColor:hintColor];
    [[[self graphContainerView] botLimitLabel] setTextColor:hintColor];
    [[[self graphContainerView] topLimitLine] setBackgroundColor:separatorColor];
    [[[self graphContainerView] botLimitLine] setBackgroundColor:separatorColor];
    [[[self graphContainerView] noDataLabel] setTextColor:hintColor];
}

@end
