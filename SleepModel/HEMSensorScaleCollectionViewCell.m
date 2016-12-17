//
//  HEMSensorScaleCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 9/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSensorScaleCollectionViewCell.h"
#import "HEMSensorScaleView.h"
#import "HEMStyle.h"

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
    [[self titleLabel] setFont:[UIFont h6Bold]];
    [[self titleLabel] setTextColor:[UIColor grey6]];
    [[self measurementLabel] setFont:[UIFont h7]];
    [[self measurementLabel] setTextColor:[UIColor grey3]];
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
        scaleView = [HEMSensorScaleView scaleView];
        CGRect scaleFrame = CGRectZero;
        scaleFrame.size.width = CGRectGetWidth([[self scaleContainerView] bounds]);
        scaleFrame.size.height = kHEMSensorScaleHeight;
        scaleFrame.origin.y = [self nextScaleIndex] * kHEMSensorScaleHeight;
        [scaleView setFrame:scaleFrame];
        [scaleView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [[self scaleContainerView] addSubview:scaleView];
    }
    
    [[scaleView nameLabel] setText:name];
    [[scaleView rangeLabel] setText:range];
    [[scaleView conditionView] setBackgroundColor:color];
    [self setNextScaleIndex:[self nextScaleIndex] + 1];
}

@end
