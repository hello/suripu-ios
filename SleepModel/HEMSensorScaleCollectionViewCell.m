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

@property (nonatomic, assign) NSUInteger scalesAdded;

@end

@implementation HEMSensorScaleCollectionViewCell

+ (CGFloat)heightWithNumberOfScales:(NSUInteger)count {
    CGFloat scalesHeight = (kHEMSensorScaleHeight * count);
    return scalesHeight + kHEMSensorScaleCellBaseHeight;
}

- (void)awakeFromNib {
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
}

- (void)prepareForReuse {
    [self setScalesAdded:0];
}

- (void)addScaleWithName:(NSString*)name
                   range:(NSString*)range
          conditionColor:(UIColor*)color {
    NSArray* existingViews = [[self scaleContainerView] subviews];
    HEMSensorScaleView* scaleView = nil;
    
    if ([self scalesAdded] < [existingViews count]) {
        scaleView = existingViews[[self scalesAdded]];
    } else {
        scaleView = [HEMSensorScaleView scaleView];
        CGRect scaleFrame = CGRectZero;
        scaleFrame.size.width = CGRectGetWidth([[self scaleContainerView] bounds]);
        scaleFrame.size.height = kHEMSensorScaleHeight;
        scaleFrame.origin.y = [self scalesAdded] * kHEMSensorScaleHeight;
        [scaleView setFrame:scaleFrame];
        [scaleView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [[self scaleContainerView] addSubview:scaleView];
    }
    
    [[scaleView nameLabel] setText:name];
    [[scaleView rangeLabel] setText:range];
    [[scaleView conditionView] setBackgroundColor:color];
    [self setScalesAdded:[self scalesAdded] + 1];
}

@end
