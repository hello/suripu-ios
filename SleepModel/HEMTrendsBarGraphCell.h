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
@property (nonatomic, strong) UIColor* averageValueColor;
@property (nonatomic, strong) UIColor* averageTitleColor;

+ (CGFloat)heightWithAverages:(BOOL)averages;
- (void)setAverageTitles:(NSArray<NSString*>*)titles
                  values:(NSArray<NSString*>*)values;
- (void)setAttributedXAxisValues:(NSArray<NSAttributedString*>*)xValues
                      dataPoints:(NSArray<NSNumber*>*)dataPoints
          highlightDataAtIndices:(NSArray<NSNumber*>*)highlightedIndices
                         spacing:(CGFloat)spacing;

@end
