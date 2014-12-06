//
//  HEMUpdatePasswordViewController.h
//  Sense
//
//  Created by Jimmy Lu on 12/5/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMUpdatePasswordViewController;

@protocol HEMUpdatePasswordDelegate <NSObject>

- (void)didUpdatePassword:(BOOL)updated from:(HEMUpdatePasswordViewController*)controller;

@end

@interface HEMUpdatePasswordViewController : HEMBaseController

@property (nonatomic, weak) id<HEMUpdatePasswordDelegate> delegate;

@end
