//
//  HEMBaseController.m
//  Sense
//
//  Created by Jimmy Lu on 8/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMBaseController.h"
#import "HEMAlertViewController.h"
#import "HEMSupportUtil.h"
#import "HEMScreenUtils.h"

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

- (void)updateViewConstraints {
    [super updateViewConstraints];
    if (![self adjustedConstraints]) {
        if (HEMIsIPhone4Family()) {
            [self adjustConstraintsForIPhone4];
        } else if (HEMIsIPhone5Family()) {
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
    [self showMessageDialog:message title:title image:nil seeThroughView:seeThroughView withHelpPage:nil];
}

- (void)showMessageDialog:(NSString*)message
                    title:(NSString*)title
                    image:(UIImage*)image
             withHelpPage:(NSString*)helpPage {
    
    UIView* seeThroughView = [self parentViewController] ? [[self parentViewController] view] : [self view];
    [self showMessageDialog:message title:title image:image seeThroughView:seeThroughView withHelpPage:helpPage];
}

- (void)showMessageDialog:(NSString*)message
                    title:(NSString*)title
                    image:(UIImage*)image
           seeThroughView:(UIView*)seeThroughView
             withHelpPage:(NSString*)helpPage {
    
    HEMAlertViewController* dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
    [dialogVC setDialogImage:image];
    [dialogVC setViewToShowThrough:seeThroughView];
    __weak typeof(self) weakSelf = self;
    [dialogVC addAction:NSLocalizedString(@"dialog.help.title", nil)
                primary:NO
            actionBlock:^{
            [HEMSupportUtil openHelpToPage:helpPage fromController:weakSelf];
        }];
    [dialogVC showFrom:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
