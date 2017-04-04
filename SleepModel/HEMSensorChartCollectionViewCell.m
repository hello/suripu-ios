//
//  HEMSensorChartCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "Sense-Swift.h"

#import "NSString+HEMUtils.h"

#import "HEMSensorChartCollectionViewCell.h"
#import "HEMSensorChartContainer.h"

@interface HEMSensorChartCollectionViewCell()

@property (nonatomic, assign) CGFloat usedLabelWidth;

@end

@implementation HEMSensorChartCollectionViewCell

- (void)setXAxisLabels:(NSArray<NSString*>*)labels {
    [[[self xAxisLabelContainer] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSString* label in labels) {
        [self addXAxisLabel:label];
    }
    
    [self layoutXAxis];
}

- (void)addXAxisLabel:(NSString*)label {
    UIColor* labelColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyHintColor];
    UIFont* labelFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyHintFont];
    CGFloat maxHeight = CGRectGetHeight([[self xAxisLabelContainer] bounds]);
    NSDictionary* labelAttrs = @{NSFontAttributeName : labelFont};
    CGSize labelSize = [label sizeBoundedByHeight:maxHeight attributes:labelAttrs];
    CGRect labelFrame = CGRectZero;
    labelFrame.origin.y = 0.0f;
    labelFrame.size.width = labelSize.width;
    labelFrame.size.height = maxHeight;
    
    UILabel* labelView = [[UILabel alloc] initWithFrame:labelFrame];
    [labelView setFont:labelFont];
    [labelView setTextColor:labelColor];
    [labelView setText:label];
    [labelView setBackgroundColor:[UIColor clearColor]];
    [labelView setTextAlignment:NSTextAlignmentCenter];
    
    [self setUsedLabelWidth:[self usedLabelWidth] + labelSize.width];
    [[self xAxisLabelContainer] addSubview:labelView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutXAxis];
}

- (void)layoutXAxis {
    CGFloat maxWidth = CGRectGetWidth([[self xAxisLabelContainer] bounds]);
    NSArray<UILabel*>* labels = [[self xAxisLabelContainer] subviews];
    NSInteger numberOfLabels = [labels count];
    if (numberOfLabels == 0) {
        return; // do nothing
    } else if (numberOfLabels == 1) {
        // stretch out the label
        UILabel* firstLabel = [labels firstObject];
        CGRect frame = [firstLabel frame];
        frame.size.width = maxWidth;
        frame.origin.x = 0.0f;
        [firstLabel setFrame:frame];
    } else {
        CGFloat maxWidth = CGRectGetWidth([[self xAxisLabelContainer] bounds]);
        CGFloat labelWidth = maxWidth / numberOfLabels;
        CGFloat x = 0.0f;
        NSInteger index = 0;
        
        for (UILabel* label in labels) {
            CGRect labelFrame = [label frame];
            labelFrame.origin.x = x;
            labelFrame.size.width = labelWidth;
            [label setFrame:labelFrame];
            
            x += labelWidth;
            index++;
        }
    }
}

- (void)applyStyle {
    UIColor* bgColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyBackgroundColor];
    UIFont* hintFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyHintFont];
    UIColor* hintColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyHintColor];
    UIColor* separatorColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertySeparatorColor];

    [self setBackgroundColor:bgColor];
    [[[self chartContentView] topLimitLabel] setTextColor:hintColor];
    [[[self chartContentView] botLimitLabel] setTextColor:hintColor];
    [[[self chartContentView] topLimitLine] setBackgroundColor:separatorColor];
    [[[self chartContentView] botLimitLine] setBackgroundColor:separatorColor];
    [[[self chartContentView] topLimitLabel] setFont:hintFont];
    [[[self chartContentView] botLimitLabel] setFont:hintFont];
    [[self chartContentView] setBackgroundColor:[self backgroundColor]];
    [[[self chartContentView] chartView] setBackgroundColor:[self backgroundColor]];
    [[[self chartContentView] noDataLabel] setTextColor:hintColor];
}

@end
