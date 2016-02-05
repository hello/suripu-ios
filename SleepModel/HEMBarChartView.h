//
//  HEMBarChartView.h
//  Sense
//
//  Created by Jimmy Lu on 2/4/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMBarChartView : UIView

@property (nonatomic, strong) UIColor* normalBarColor;
@property (nonatomic, strong) UIColor* highlightedBarColor;
@property (nonatomic, assign) CGFloat barSpacing;
@property (nonatomic, assign) CGFloat barWidth;
@property (nonatomic, assign) CGFloat maxValue;

- (void)updateBarChartWith:(NSArray<NSNumber*>*)values
        highlightedIndices:(NSArray<NSNumber*>*)highlightedIndices;

@end
