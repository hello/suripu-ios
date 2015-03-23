//
//  HEMTimeZoneViewController.h
//  Sense
//
//  Created by Jimmy Lu on 3/17/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMBaseController.h"

@class HEMTimeZoneViewController;

@protocol HEMTimeZoneConrollerDelegate <NSObject>

- (void)willCancelTimeZoneUpdateFrom:(HEMTimeZoneViewController*)tzViewController;
- (void)didUpdateTimeZoneTo:(NSTimeZone*)timeZone from:(HEMTimeZoneViewController*)tzViewController;

@end

@interface HEMTimeZoneViewController : HEMBaseController

@property (weak, nonatomic) id<HEMTimeZoneConrollerDelegate> delegate;

@end
