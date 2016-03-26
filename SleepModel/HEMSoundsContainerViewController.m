//
//  HEMSoundsContainerViewController.m
//  Sense
//
//  Created by Jimmy Lu on 3/24/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSoundsContainerViewController.h"
#import "HEMSoundsTabPresenter.h"
#import "HEMSleepSoundService.h"
#import "HEMAlarmService.h"
#import "HEMDeviceService.h"
#import "HEMSoundsSubNavPresenter.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSubNavigationView.h"
#import "HEMAlarmListViewController.h"
#import "HEMSleepSoundViewController.h"
#import "HEMMainStoryboard.h"

@interface HEMSoundsContainerViewController()<HEMSoundSubNavDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet HEMSubNavigationView *subNav;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subNavHeightConstraint;

@property (nonatomic, strong) HEMSleepSoundService* sleepSoundsService;
@property (nonatomic, strong) HEMAlarmService* alarmService;
@property (nonatomic, strong) HEMDeviceService* deviceService;

@property (nonatomic, strong) HEMAlarmListViewController* alarmVC;
@property (nonatomic, strong) HEMSleepSoundViewController* sleepSoundVC;

@end

@implementation HEMSoundsContainerViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        HEMSoundsTabPresenter* tabPresenter = [HEMSoundsTabPresenter new];
        [tabPresenter bindWithTabBarItem:[self tabBarItem]];
        [self addPresenter:tabPresenter];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    [self setSleepSoundsService:[HEMSleepSoundService new]];
    [self setAlarmService:[HEMAlarmService new]];
    [self setDeviceService:[HEMDeviceService new]];
    
    HEMSoundsSubNavPresenter* subNavPresenter
        = [[HEMSoundsSubNavPresenter alloc] initWithSleepSoundService:[self sleepSoundsService]
                                                         alarmService:[self alarmService]
                                                        deviceService:[self deviceService]];
    [subNavPresenter setDelegate:self];
    [subNavPresenter bindWithActivityIndicator:[self activityIndicator]];
    [subNavPresenter bindWithSubNavigationView:[self subNav]
                          withHeightConstraint:[self subNavHeightConstraint]];
    [self addPresenter:subNavPresenter];
}

#pragma mark - Sub Nav Delegate

- (void)loadAlarms:(BOOL)hasSensePaired {
    DDLogVerbose(@"show alarms view");
    if (![self alarmVC]) {
        HEMAlarmListViewController* alarmList = [HEMMainStoryboard instantiateAlarmListViewController];
        [alarmList setHasSubNav:[[self subNav] hasControls]];
        [self setAlarmVC:alarmList];
    }
    [self showSoundViewOf:[self alarmVC]];
}

- (void)loadSleepSounds:(SENSleepSounds *)sleepSounds {
    DDLogVerbose(@"show sleep sounds view");
    if (![self sleepSoundVC]) {
        HEMSleepSoundViewController* soundVC = [HEMMainStoryboard instantiateSleepSoundViewController];
        [self setSleepSoundVC:soundVC];
    }
    [self showSoundViewOf:[self sleepSoundVC]];
}

- (void)showSoundViewOf:(UIViewController*)controller {
    UIViewController* currentVC = [[self childViewControllers] firstObject];
    if (currentVC == controller) {
        return;
    }
    
    [[self subNav] setUserInteractionEnabled:NO];
    [self addChildViewController:controller];
    
    CGRect frame = [[controller view] frame];
    frame.size = [[self containerView] bounds].size;
    [[controller view] setFrame:frame];
    [[self containerView] insertSubview:[controller view] atIndex:0];
    
    if (!currentVC) {
        [controller didMoveToParentViewController:self];
        [[self subNav] setUserInteractionEnabled:YES];
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
                        }];
    }
}

@end
