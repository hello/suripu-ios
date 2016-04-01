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
#import "HEMSoundsContentPresenter.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSubNavigationView.h"
#import "HEMAlarmListViewController.h"
#import "HEMSleepSoundViewController.h"
#import "HEMSensePairViewController.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBaseController+Protected.h"
#import "HEMShortcutService.h"

@interface HEMSoundsContainerViewController()<HEMSoundContentDelegate, HEMSensePairingDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet HEMSubNavigationView *subNav;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subNavHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *errorCollectionView;

@property (nonatomic, strong) HEMSleepSoundService* sleepSoundsService;
@property (nonatomic, strong) HEMAlarmService* alarmService;
@property (nonatomic, strong) HEMDeviceService* deviceService;
@property (nonatomic, weak) HEMSoundsContentPresenter* contentPresenter;

@property (nonatomic, strong) HEMAlarmListViewController* alarmVC;

@end

@implementation HEMSoundsContainerViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addAndConfigureTabPresenter];
        // must add here b/c content presenter needs shortcut notifications that
        // can come from 3D Touch, which triggers notifications on launch
        [self addContentPresenter];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureContentPresenter];
}

- (void)addAndConfigureTabPresenter {
    HEMSoundsTabPresenter* tabPresenter = [HEMSoundsTabPresenter new];
    [tabPresenter bindWithTabBarItem:[self tabBarItem]];
    [self addPresenter:tabPresenter];
}

- (void)addContentPresenter {
    [self setSleepSoundsService:[HEMSleepSoundService new]];
    [self setAlarmService:[HEMAlarmService new]];
    [self setDeviceService:[HEMDeviceService new]];
    
    HEMSoundsContentPresenter* presenter
        = [[HEMSoundsContentPresenter alloc] initWithSleepSoundService:[self sleepSoundsService]
                                                          alarmService:[self alarmService]
                                                         deviceService:[self deviceService]
                                                       shortcutService:[HEMShortcutService sharedService]];
    
    [self setContentPresenter:presenter];
    [self addPresenter:presenter];
}

- (void)configureContentPresenter {
    [[self contentPresenter] setDelegate:self];
    [[self contentPresenter] bindWithActivityIndicator:[self activityIndicator]];
    [[self contentPresenter] bindWithSubNavigationView:[self subNav]
                                  withHeightConstraint:[self subNavHeightConstraint]];
    [[self contentPresenter] bindWithErrorCollectionView:[self errorCollectionView]];
}

#pragma mark - Content Delegate

- (void)unloadContentControllersFrom:(HEMSoundsContentPresenter*)presenter {
    UIViewController* currentVC = [[self childViewControllers] firstObject];
    if (currentVC) {
        [currentVC willMoveToParentViewController:nil];
        [[currentVC view] removeFromSuperview];
        [currentVC removeFromParentViewController];
    }
}

- (void)pairWithSenseFrom:(HEMSoundsContentPresenter*)presenter {
    HEMSensePairViewController *pairVC = (id)[HEMOnboardingStoryboard instantiateSensePairViewController];
    [pairVC setDelegate:self];
    UINavigationController *nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)loadAlarmsFrom:(__unused HEMSoundsContentPresenter *)presenter thenLaunchNewAlarm:(BOOL)showNewAlarm {
    DDLogVerbose(@"show alarms view");
    if (![self alarmVC]) {
        HEMAlarmListViewController* alarmVC = [HEMMainStoryboard instantiateAlarmListViewController];
        [self setAlarmVC:alarmVC];
    }
    [self showSoundViewOf:[self alarmVC] completion:^{
        if (showNewAlarm) {
            [[self alarmVC] addNewAlarm:nil];
        }
    }];
}

- (void)loadSleepSounds:(__unused SENSleepSounds *)sleepSounds from:(__unused HEMSoundsContentPresenter *)presenter {
    DDLogVerbose(@"show sleep sounds view");
    HEMSleepSoundViewController* soundVC = [HEMMainStoryboard instantiateSleepSoundViewController];
    [soundVC setDeviceService:[self deviceService]];
    [self showSoundViewOf:soundVC completion:nil];
}

- (void)showSoundViewOf:(UIViewController*)controller completion:(void(^)(void))completion {
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
    frame.size = [[self containerView] bounds].size;
    [[controller view] setFrame:frame];
    [[self containerView] insertSubview:[controller view] atIndex:0];
    
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

#pragma mark - HEMSensePairDelegate

- (void)dismissModalAfterDelay:(BOOL)delay {
    if (delay) {
        NSTimeInterval delayInSeconds = 1.5f;
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReturnWithSenseManager:(SENSenseManager*)senseManager {
    BOOL paired = senseManager != nil;
    if (paired) {
        [[self contentPresenter] reload];
    }
    [self dismissModalAfterDelay:paired];
}

- (void)didPairSenseUsing:(SENSenseManager *)senseManager from:(UIViewController *)controller {
    [self didReturnWithSenseManager:senseManager];
}

- (void)didSetupWiFiForPairedSense:(SENSenseManager *)senseManager from:(UIViewController *)controller {
    [self didReturnWithSenseManager:senseManager];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
