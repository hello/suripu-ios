//
//  HEMTrendsCalendarMonthView.h
//  Sense
//
//  Created by Jimmy Lu on 2/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const HEMTrendsCalMonthDaySpacing;
extern NSInteger const HEMTrendsCalMonthDaysInWeek;

@class HEMTrendsDisplayPoint;

@interface HEMTrendsCalendarMonthView : UIView

+ (CGFloat)heightForMonthInQuarter:(NSDate*)month maxWidth:(CGFloat)maxWidth;
+ (CGFloat)heightForMonthWithRows:(NSInteger)rows maxWidth:(CGFloat)maxWidth;
+ (CGFloat)sizeForEachDayInMonthWithWidth:(CGFloat)width;

- (void)showCurrentMonthWithValues:(NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)values
                            titles:(NSArray<NSAttributedString*>*)localizedTitles;
- (void)showMonthInQuarterWithValues:(NSArray<HEMTrendsDisplayPoint*>*)values
                              titles:(NSAttributedString*)localizedMonthText
                            forMonth:(NSDate*)month;

@end
