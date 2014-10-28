//
//  HEMBaseController.m
//  Sense
//
//  Created by Jimmy Lu on 8/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMBaseController.h"
#import "HEMAlertController.h"

static CGFloat const kHEMIPhone4Height = 480.0f;
static CGFloat const kHEMIPhone5Height = 568.0f;

@interface HEMBaseController()

@property (nonatomic, assign) BOOL adjustedConstraints;

@end

@implementation HEMBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(viewDidBecomeActive)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
}

- (void)viewDidBecomeActive {}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    if (![self adjustedConstraints]) {
        CGFloat screenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
        if (screenHeight == kHEMIPhone4Height) {
            [self adjustConstraintsForIPhone4];
        } else if (screenHeight == kHEMIPhone5Height) {
            [self adjustConstraintsForIphone5];
        }
        [self setAdjustedConstraints:YES];
    }
}

- (void)adjustConstraintsForIphone5 { /* do nothing here, meant for subclasses */ }

- (void)adjustConstraintsForIPhone4 { /* do nothing here, meant for subclasses */ }

- (void)updateConstraint:(NSLayoutConstraint*)constraint withDiff:(CGFloat)diff {
    CGFloat constant = [constraint constant];
    [constraint setConstant:constant + diff];
}

- (void)showMessageDialog:(NSString*)message title:(NSString*)title {
    [HEMAlertController presentInfoAlertWithTitle:title message:message presentingController:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
