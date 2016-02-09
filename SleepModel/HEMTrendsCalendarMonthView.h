//
//  HEMTrendsCalendarMonthView.h
//  Sense
//
//  Created by Jimmy Lu on 2/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const HEMTrendsCalMonthDaySpacing;

@interface HEMTrendsCalendarMonthView : UIView

+ (CGFloat)heightForMonthWithRows:(NSInteger)rows maxWidth:(CGFloat)maxWidth;
+ (CGFloat)sizeForEachDayWithWidth:(CGFloat)width;
+ (NSInteger)rowsForDays:(NSInteger)days;
+ (NSInteger)monthsForRows:(NSInteger)rows;

@end
