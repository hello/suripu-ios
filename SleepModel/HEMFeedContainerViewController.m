//
//  HEMFeedContainerViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMFeedContainerViewController.h"
#import "HEMSubNavigationView.h"
#import "HEMActivityIndicatorView.h"
#import "HEMFeedNavigationPresenter.h"
#import "HEMVoiceService.h"
#import "HEMUnreadAlertService.h"
#import "HEMInsightFeedViewController.h"
#import "HEMVoiceFeedViewController.h"
#import "HEMMainStoryboard.h"

@interface HEMFeedContainerViewController () <HEMFeedNavigationDelegate>

@property (weak, nonatomic) IBOutlet HEMSubNavigationView *subNav;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subNavHeightConstraint;

@property (strong, nonatomic) HEMFeedNavigationPresenter* navPresenter;
@property (strong, nonatomic) HEMVoiceService* voiceService;
@property (strong, nonatomic) HEMUnreadAlertService* unreadService;

@end

@implementation HEMFeedContainerViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _voiceService = [HEMVoiceService new];
        _unreadService = [HEMUnreadAlertService new];

        HEMFeedNavigationPresenter* navPresenter =
            [[HEMFeedNavigationPresenter alloc] initWithVoiceService:_voiceService
                                                       unreadService:_unreadService];
        [navPresenter bindWithTabBarItem:[self tabBarItem]];
        _navPresenter = navPresenter;
        [self addPresenter:navPresenter];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navPresenter] bindWithSubNavigationBar:[self subNav]
                             withHeightConstraint:[self subNavHeightConstraint]];
    [[self navPresenter] setNavDelegate:self];
}

#pragma mark - HEMFeedNavigationDelegate

- (void)showInsightsFrom:(HEMFeedNavigationPresenter *)presenter {
    HEMInsightFeedViewController* insightVC = [HEMMainStoryboard instantiateInsightsFeedViewController];
    [insightVC setUnreadService:[self unreadService]];
    [insightVC setSubNavBar:[self subNav]];
    [self showViewOf:insightVC completion:nil];
}

- (void)showVoiceFrom:(HEMFeedNavigationPresenter*)presenter {
    HEMVoiceFeedViewController* voiceVC = [HEMMainStoryboard instantiateVoiceViewController];
    [voiceVC setVoiceService:[self voiceService]];
    [voiceVC setSubNavBar:[self subNav]];
    [self showViewOf:voiceVC completion:nil];
}

- (void)showViewOf:(UIViewController*)controller completion:(void(^)(void))completion {
    UIViewController* currentVC = [[self childViewControllers] firstObject];
    if (currentVC == controller) {
        if (completion) {
            completion ();
        }
        return;
    }
    
    [[self subNav] setUserInteractionEnabled:NO];
    [self addChildViewController:controller];
    
    CGRect frame = [[controller view] frame];
    frame.size = [[self contentView] bounds].size;
    [[controller view] setFrame:frame];
    
    [[self contentView] insertSubview:[controller view] atIndex:0];
    
    if (!currentVC) {
        [controller didMoveToParentViewController:self];
        [[self subNav] setUserInteractionEnabled:YES];
        if (completion) {
            completion ();
        }
    } else {
        [currentVC willMoveToParentViewController:nil];
        [UIView transitionFromView:[currentVC view]
                            toView:[controller view]
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        completion:^(BOOL finished) {
                            [[currentVC view] removeFromSuperview];
                            [currentVC removeFromParentViewController];
                            [controller didMoveToParentViewController:self];
                            [[self subNav] setUserInteractionEnabled:YES];
                            if (completion) {
                                completion ();
                            }
                        }];
    }
}

@end
