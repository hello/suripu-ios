//
//  HEMTrendsBubbleViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 2/1/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsBubbleViewCell.h"
#import "HEMTrendsSleepDepthView.h"
#import "HEMStyle.h"
#import "HEMScreenUtils.h"

static CGFloat const HEMTrendsBubbleCellHeightCoefficient = 0.369f;

@implementation HEMTrendsBubbleViewCell

+ (CGFloat)height {
    CGRect windowBounds = HEMKeyWindowBounds();
    return ceilCGFloat(CGRectGetHeight(windowBounds) * HEMTrendsBubbleCellHeightCoefficient);
}

@end
