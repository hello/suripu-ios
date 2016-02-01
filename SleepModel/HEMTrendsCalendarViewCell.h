//
//  HEMTrendsCalendarViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMTrendsBaseCell.h"

typedef NS_ENUM(NSInteger, HEMTrendsCalendarType) {
    HEMTrendsCalendarTypeMonth = 0,
    HEMTrendsCalendarTypeQuarter
};

@interface HEMTrendsCalendarViewCell : HEMTrendsBaseCell

@property (nonatomic, assign, getter=showAverages) BOOL averages;
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, assign) HEMTrendsCalendarType type;

+ (CGFloat)heightForMonthWithNumberOfRows:(NSInteger)rows showAverages:(BOOL)averages;
+ (CGFloat)heightForMultiMonthWithAverages:(BOOL)averages;

@end
