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
#import "HEMPresenter.h"

@interface HEMBaseController()

@property (nullable, nonatomic, strong) HEMNavigationShadowView* shadowView;
@property (nonatomic, assign) BOOL adjustedConstraints;
@property (nullable, nonatomic, strong) NSArray<HEMPresenter*>* presenters;

@end

@implementation HEMBaseController

#pragma mark - View Controller Lifecycle Events

- (void)viewDidLoad {
    [super viewDidLoad];
    [self listenForAppEvents];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self presenters] makeObjectsPerformSelector:@selector(willAppear)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self presenters] makeObjectsPerformSelector:@selector(didAppear)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self presenters] makeObjectsPerformSelector:@selector(willDisappear)];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[self presenters] makeObjectsPerformSelector:@selector(didDisappear)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [[self presenters] makeObjectsPerformSelector:@selector(didRelayout)];
}

#pragma mark - App Events

- (void)listenForAppEvents {
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

- (void)viewDidBecomeActive {
    [[self presenters] makeObjectsPerformSelector:@selector(didComeBackFromBackground)];
}

- (void)viewDidEnterBackground {
    [[self presenters] makeObjectsPerformSelector:@selector(didEnterBackground)];
}

#pragma mark - Shadows

- (HEMNavigationShadowView*)shadowView {
    if (!_shadowView) {
        UINavigationBar* navBar = [[self navigationController] navigationBar];
        _shadowView = [[HEMNavigationShadowView alloc] initWithNavigationBar:navBar];
        [navBar addSubview:_shadowView];
    }
    return _shadowView;
}

#pragma mark - Presenters

- (void)addPresenter:(HEMPresenter*)presenter {
    NSMutableArray* mutableList = nil;
    if ([self presenters]) {
        mutableList = [[self presenters] mutableCopy];
    } else {
        mutableList = [NSMutableArray array];
    }
    [mutableList addObject:presenter];
    [self setPresenters:mutableList];
}

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
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.ok", nil) style:HEMAlertViewButtonStyleRoundRect action:nil];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"dialog.help.title", nil)
                           style:HEMAlertViewButtonStyleBlueText
                          action:^{
            [HEMSupportUtil openHelpToPage:helpPage fromController:weakSelf];
        }];
    [dialogVC showFrom:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
