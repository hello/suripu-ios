//
//  HEMTrendsBarGraphCell.m
//  Sense
//
//  Created by Jimmy Lu on 2/1/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsBarGraphCell.h"

static CGFloat const HEMTrendsBarGraphBaseHeight = 224.0f;
static CGFloat const HEMTrendsBarGraphAveragesHeight = 77.0f;

@implementation HEMTrendsBarGraphCell

+ (CGFloat)heightWithAverages:(BOOL)averages {
    CGFloat height = HEMTrendsBarGraphBaseHeight;
    if (averages) {
        height += HEMTrendsBarGraphAveragesHeight;
    }
    return height;
}

@end
