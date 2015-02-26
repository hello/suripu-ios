//
//  HEMUpdateNameViewController.h
//  Sense
//
//  Created by Delisa Mason on 2/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMUpdateNameViewController;

@protocol HEMUpdateNameDelegate <NSObject>

- (void)didUpdateName:(BOOL)updated from:(HEMUpdateNameViewController*)controller;
@end

@interface HEMUpdateNameViewController : UIViewController

@property (nonatomic, weak) id<HEMUpdateNameDelegate> delegate;
@end