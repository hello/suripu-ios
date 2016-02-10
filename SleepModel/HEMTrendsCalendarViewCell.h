//
//  HEMTrendsCalendarViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMTrendsBaseCell.h"
#import "HEMTrendsCalendarView.h"

NS_ASSUME_NONNULL_BEGIN

@class HEMTrendsDisplayPoint;

@interface HEMTrendsCalendarViewCell : HEMTrendsBaseCell

@property (nonatomic, assign) HEMTrendsCalendarType type;

+ (CGFloat)heightWithNumberOfSections:(NSInteger)sections
                              forType:(HEMTrendsCalendarType)type
                         withAverages:(BOOL)averages
                                width:(CGFloat)width;

- (void)setSectionTitles:(NSArray<NSAttributedString*>*)sectionTitles
                  scores:(NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)scores;

@end

NS_ASSUME_NONNULL_END