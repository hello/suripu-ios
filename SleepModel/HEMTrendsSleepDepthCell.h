//
//  HEMTrendsSleepDepthCell.h
//  Sense
//
//  Created by Jimmy Lu on 2/16/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsBaseCell.h"

@class HEMTrendsBubbleView;

@interface HEMTrendsSleepDepthCell : HEMTrendsBaseCell

@property (weak, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet HEMTrendsBubbleView *lightBubbleView;
@property (weak, nonatomic) IBOutlet HEMTrendsBubbleView *deepBubbleView;
@property (weak, nonatomic) IBOutlet HEMTrendsBubbleView *mediumBubbleView;

+ (CGFloat)height;
- (void)updateLightPercentage:(CGFloat)lightPercentage
             mediumPercentage:(CGFloat)mediumPercentage
               deepPercentage:(CGFloat)deepPercentage;

@end
