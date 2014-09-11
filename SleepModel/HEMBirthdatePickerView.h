//
//  HEMBirthdatePickerView.h
//  Sense
//
//  Created by Jimmy Lu on 9/8/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kHEMBirthdateValueHeight;

@interface HEMBirthdatePickerView : UIView

/**
 * Set the picker to the specified date in month, day, and years from this year.
 * @param month:     1 - 12, where 1 is January
 * @param day:       1 - 31, where max depends on which month is passed
 * @param yearsPast: 0 - 120
 */
- (void)setMonth:(NSInteger)month day:(NSInteger)day yearsPast:(NSInteger)yearPast;

/**
 * @return month currently selected in the picker
 */
- (NSInteger)selectedMonth;

/**
 * @return day currently selected in the picker
 */
- (NSInteger)selectedDay;

/**
 * @return year currently selected in the picker.  
           The year will be in the form 'yyyy'
 */
- (NSInteger)selectedYear;

@end
