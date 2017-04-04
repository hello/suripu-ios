//
//  HEMSensorScaleCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 9/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "Sense-Swift.h"
#import "HEMSensorScaleCollectionViewCell.h"
#import "HEMSensorScaleView.h"

static CGFloat const kHEMSensorScaleCellBaseHeight = 42.0f;

@interface HEMSensorScaleCollectionViewCell()

@property (nonatomic, assign) NSUInteger nextScaleIndex;

@end

@implementation HEMSensorScaleCollectionViewCell

+ (CGFloat)heightWithNumberOfScales:(NSUInteger)count {
    CGFloat scalesHeight = (kHEMSensorScaleHeight * count);
    return scalesHeight + kHEMSensorScaleCellBaseHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self applyStyle];
    [[self scaleContainerView] setClipsToBounds:NO];
}

- (void)setNumberOfScales:(NSUInteger)numberOfScales {
    if (_numberOfScales != numberOfScales) {
        _numberOfScales = numberOfScales;
        NSArray* scaleViews = [[self scaleContainerView] subviews];
        [scaleViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    // would normally put the below line in prepareForReuse, but iOS 10 appears
    // to call this a different times now ...
    [self setNextScaleIndex:0];
}

- (void)addScaleWithName:(NSString*)name
                   range:(NSString*)range
          conditionColor:(UIColor*)color {
    NSArray* existingViews = [[self scaleContainerView] subviews];
    HEMSensorScaleView* scaleView = nil;
    
    if ([self nextScaleIndex] < [existingViews count]) {
        scaleView = existingViews[[self nextScaleIndex]];
    } else {
        UIColor* titleColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
        UIFont* detailFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyDetailFont];
        UIColor* detailColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyDetailColor];
        
        scaleView = [HEMSensorScaleView scaleView];
        CGRect scaleFrame = CGRectZero;
        scaleFrame.size.width = CGRectGetWidth([[self scaleContainerView] bounds]);
        scaleFrame.size.height = kHEMSensorScaleHeight;
        scaleFrame.origin.y = [self nextScaleIndex] * kHEMSensorScaleHeight;
        [scaleView setFrame:scaleFrame];
        [scaleView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [[scaleView separatorView] applySeparatorStyle];
        [[scaleView nameLabel] setFont:detailFont];
        [[scaleView nameLabel] setTextColor:titleColor];
        [[scaleView rangeLabel] setFont:detailFont];
        [[scaleView rangeLabel] setTextColor:detailColor];
        [[self scaleContainerView] addSubview:scaleView];
    }
    
    [[scaleView nameLabel] setText:name];
    [[scaleView rangeLabel] setText:range];
    [[scaleView conditionView] setBackgroundColor:color];
    [self setNextScaleIndex:[self nextScaleIndex] + 1];
}

- (void)applyStyle {
    UIColor* bgColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyBackgroundColor];
    UIColor* titleColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    UIFont* titleFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    UIColor* hintColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyHintColor];
    UIFont* hintFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyHintFont];
    
    [[self titleLabel] setFont:titleFont];
    [[self titleLabel] setTextColor:titleColor];
    [self setBackgroundColor:bgColor];
    [[self scaleContainerView] setBackgroundColor:bgColor];
    [[self measurementLabel] setFont:hintFont];
    [[self measurementLabel] setTextColor:hintColor];
}

@end
