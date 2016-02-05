//
//  HEMTrendsBarGraphCell.h
//  Sense
//
//  Created by Jimmy Lu on 2/1/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsBaseCell.h"

@interface HEMTrendsBarGraphCell : HEMTrendsBaseCell

@property (nonatomic, strong) UIColor* highlightedBarColor;
@property (nonatomic, strong) UIColor* normalBarColor;
@property (nonatomic, assign) CGFloat maxValue;

+ (CGFloat)heightWithAverages:(BOOL)averages;
- (void)setAttributedXAxisValues:(NSArray<NSAttributedString*>*)xValues
                      dataPoints:(NSArray<NSNumber*>*)dataPoints
          highlightDataAtIndices:(NSArray<NSNumber*>*)highlightedIndices
                         spacing:(CGFloat)spacing;

@end
