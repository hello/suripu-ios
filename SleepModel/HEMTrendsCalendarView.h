//
//  HEMTrendsCalendarView.h
//  Sense
//
//  Created by Jimmy Lu on 2/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMTrendsDisplayPoint;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HEMTrendsCalendarType) {
    HEMTrendsCalendarTypeWeek = 1,
    HEMTrendsCalendarTypeMonth,
    HEMTrendsCalendarTypeQuarter
};

@interface HEMTrendsCalendarView : UIView

@property (nonatomic, assign) HEMTrendsCalendarType type;

+ (CGFloat)heightWithSections:(NSInteger)sections
                      forType:(HEMTrendsCalendarType)type
                     maxWidth:(CGFloat)maxWidth;

- (void)updateWithValues:(NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)values
                  titles:(NSArray<NSAttributedString*>*)attributedTitles;

@end

NS_ASSUME_NONNULL_END