//
//  HEMTrendsBubbleViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 2/1/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsBaseCell.h"

@class HEMTrendsSleepDepthView;

@interface HEMTrendsBubbleViewCell : HEMTrendsBaseCell

@property (weak, nonatomic) IBOutlet HEMTrendsSleepDepthView *mainContentView;

+ (CGFloat)height;

@end
