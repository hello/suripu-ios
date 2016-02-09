//
//  HEMTrendsCalendarView.h
//  Sense
//
//  Created by Jimmy Lu on 2/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMTrendsCalendarView : UIView

+ (CGFloat)heightWithDays:(NSInteger)days maxWidth:(CGFloat)maxWidth;

- (void)updateTitlesWith:(NSArray<NSArray<NSAttributedString*>*>*)attributedTitles;

@end
