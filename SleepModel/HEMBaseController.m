//
//  HEMBaseController.m
//  Sense
//
//  Created by Jimmy Lu on 8/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMBaseController.h"
#import "HEMDialogViewController.h"
#import "HEMSupportUtil.h"

CGFloat const kHEMIPhone4Height = 480.0f;
CGFloat const kHEMIPhone5Height = 568.0f;

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
    [center addObserver:self
               selector:@selector(viewDidEnterBackground)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
}

- (void)viewDidBecomeActive { /* do nothing here, meant for subclasses */ }
- (void)viewDidEnterBackground { /* do nothing here, meant for subclasses */ }

#pragma mark - Constraints / Layouts for Devices

- (BOOL)isIPhone4Family {
    CGFloat screenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    return screenHeight == kHEMIPhone4Height;
}

- (BOOL)isIPhone5Family {
    CGFloat screenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    return screenHeight == kHEMIPhone5Height;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    if (![self adjustedConstraints]) {
        if ([self isIPhone4Family]) {
            [self adjustConstraintsForIPhone4];
        } else if ([self isIPhone5Family]) {
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

#pragma mark - alerts

- (void)showMessageDialog:(NSString*)message title:(NSString*)title {
    UIView* seeThroughView = [self parentViewController] ? [[self parentViewController] view] : [self view];
    [self showMessageDialog:message title:title image:nil seeThroughView:seeThroughView withHelp:NO];
}

- (void)showMessageDialog:(NSString*)message title:(NSString*)title image:(UIImage*)image withHelp:(BOOL)help {
    UIView* seeThroughView = [self parentViewController] ? [[self parentViewController] view] : [self view];
    [self showMessageDialog:message title:title image:image seeThroughView:seeThroughView withHelp:help];
}

- (void)showMessageDialog:(NSString*)message
                    title:(NSString*)title
                    image:(UIImage*)image
           seeThroughView:(UIView*)seeThroughView
                 withHelp:(BOOL)help {
    
    HEMDialogViewController* dialogVC = [[HEMDialogViewController alloc] init];
    [dialogVC setTitle:title];
    [dialogVC setMessage:message];
    [dialogVC setShowHelp:help];
    [dialogVC setDialogImage:image];
    [dialogVC setViewToShowThrough:seeThroughView];
    
    [dialogVC showFrom:self onDone:^{
        // don't weak reference this since controller must remain until it has
        // been dismissed
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
