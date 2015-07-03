//
//  HEMTimelineContainerViewController.h
//  Sense
//
//  Created by Delisa Mason on 6/11/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMTimelineContainerViewController : UIViewController

- (void)showAlarmButton:(BOOL)isVisible;
- (NSString *)centerTitle;
- (void)setCenterTitleFromDate:(NSDate *)date;
- (void)setCenterTitleFromDate:(NSDate *)date scrolledToTop:(BOOL)atTop;
- (void)prepareForCenterTitleChange;
- (void)cancelCenterTitleChange;
- (void)setBlurEnabled:(BOOL)enabled;
@end
