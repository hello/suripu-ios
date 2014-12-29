//
//  HEMUpdateEmailViewController.h
//  Sense
//
//  Created by Jimmy Lu on 12/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMUpdateEmailViewController;

@protocol HEMUpdateEmailDelegate <NSObject>

- (void)didUpdateEmail:(BOOL)updated from:(HEMUpdateEmailViewController*)controller;

@end

@interface HEMUpdateEmailViewController : UIViewController

@property (nonatomic, weak) id<HEMUpdateEmailDelegate> delegate;

@end
