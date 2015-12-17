//
//  HEMPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/2/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAPIClient.h>
#import <SenseKit/SENAuthorizationService.h>

#import "HEMPresenter.h"
#import "HEMNavigationShadowView.h"

@interface HEMPresenter()

@property (nullable, nonatomic, weak) HEMNavigationShadowView* shadowView;

@end

@implementation HEMPresenter

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        [self listenForNetworkChanges];
        [self listenForAuthChanges];
    }
    return self;
}

- (void)listenForNetworkChanges {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGainConnectivity)
                                                 name:SENAPIReachableNotification
                                               object:nil];
}

- (void)listenForAuthChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(userDidSignOut)
                   name:SENAuthorizationServiceDidDeauthorizeNotification
                 object:nil];
}

- (void)bindWithShadowView:(HEMNavigationShadowView*)shadowView {
    [self setShadowView:shadowView];
}

- (void)didScrollContentIn:(UIScrollView*)scrollView {
    [[self shadowView] updateVisibilityWithContentOffset:[scrollView contentOffset].y];
}

- (void)willAppear {}
- (void)didAppear {}

- (void)willDisappear {}
- (void)didDisappear {}

- (void)didRelayout {}

- (void)didEnterBackground {}
- (void)didComeBackFromBackground {}

- (void)didGainConnectivity {}

- (void)userDidSignOut {}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
