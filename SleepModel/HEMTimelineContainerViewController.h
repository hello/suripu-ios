//
//  HEMTimelineContainerViewController.h
//  Sense
//
//  Created by Delisa Mason on 6/11/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMTimelineContainerViewController : UIViewController

@property (nonatomic, strong) UIViewController* timelineController;

- (void)showAlarmButton:(BOOL)isVisible;
@end
