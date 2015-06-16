//
//  HEMTimelineContainerViewController.h
//  Sense
//
//  Created by Delisa Mason on 6/11/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMTimelineContainerViewController : UIViewController

- (void)showBlurWithHeight:(CGFloat)blurHeight;
- (void)showBorder:(BOOL)isVisible;
- (void)showAlarmButton:(BOOL)isVisible;
- (NSString *)centerTitle;
- (void)setCenterTitleFromDate:(NSDate *)date;
- (void)prepareForCenterTitleChange;
- (void)cancelCenterTitleChange;
@end
