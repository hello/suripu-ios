//
//  HEMTrendsBarGraphCell.h
//  Sense
//
//  Created by Jimmy Lu on 2/1/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsBaseCell.h"

@class  HEMTrendsDisplayPoint;

@interface HEMTrendsBarGraphCell : HEMTrendsBaseCell

@property (nonatomic, strong) UIColor* highlightedBarColor;
@property (nonatomic, strong) UIColor* normalBarColor;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, copy)   NSString* highlightLabelTextFormat;
@property (nonatomic, strong) UIFont* highlightTextFont;
@property (nonatomic, strong) UIColor* dashLineColor;

+ (CGFloat)heightWithAverages:(BOOL)averages;
- (void)setAverageTitles:(NSArray<NSString*>*)titles
                  values:(NSArray<NSString*>*)values;
- (void)updateGraphWithTitles:(NSArray<NSAttributedString*>*)titles
                displayPoints:(NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)displayPoints
                      spacing:(CGFloat)spacing;

@end
