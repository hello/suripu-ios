//
//  HEMTrendsCalendarViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMTrendsBaseCell.h"

@interface HEMTrendsCalendarViewCell : HEMTrendsBaseCell

+ (CGFloat)heightForNumberOfDays:(NSInteger)days withAverages:(BOOL)showAverages;

@end
