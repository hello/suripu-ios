//
//  HEMDevicesViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMDevicesViewController.h"
#import "HEMPillViewController.h"
#import "HEMSenseViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMPillPairViewController.h"
#import "HEMSensePairViewController.h"
#import "HEMSensePairDelegate.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMRootViewController.h"
#import "HEMSupportUtil.h"
#import "HEMDeviceService.h"
#import "HEMDevicesPresenter.h"

@interface HEMDevicesViewController() <
    HEMPillPairDelegate,
    HEMSenseControllerDelegate,
    HEMSensePairingDelegate,
    HEMPillControllerDelegate,
    HEMDevicesPresenterDelegate
>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HEMDeviceService* deviceService;
@property (weak, nonatomic) HEMDevicesPresenter* devicesPresenter;

@end

@implementation HEMDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
    [SENAnalytics track:kHEMAnalyticsEventDevices];
}

- (void)configurePresenter {
    HEMDeviceService* service = [HEMDeviceService new];
    HEMDevicesPresenter* presenter = [[HEMDevicesPresenter alloc] initWithDeviceService:service];
    [presenter setDelegate:self];
    [presenter bindWithCollectionView:[self collectionView]];
    [presenter bindWithShadowView:[self shadowView]];
    [self addPresenter:presenter];
    [self setDeviceService:service];
    [self setDevicesPresenter:presenter];
}

- (void)presentPairingViewController:(UIViewController*)pairingVC {
    UINavigationController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairingVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - HEMDeviceDelegate

- (void)showAlertWithTitle:(NSString*)title
                   message:(NSString*)message
                      from:(HEMDevicesPresenter*)presenter {
    [self showMessageDialog:message title:title];
}

- (void)openSupportURL:(NSString*)url from:(HEMDevicesPresenter*)presenter {
    [HEMSupportUtil openURL:url from:self];
}

- (void)pairSenseFrom:(HEMDevicesPresenter*)presenter {
    HEMSensePairViewController* pairVC = (id) [HEMOnboardingStoryboard instantiateSensePairViewController];
    [pairVC setDelegate:self];
    [self presentPairingViewController:pairVC];
}

- (void)showSenseSettingsFrom:(HEMDevicesPresenter*)presenter {
    [self performSegueWithIdentifier:[HEMMainStoryboard senseSegueIdentifier]
                              sender:self];
}

- (void)showPillSettingsFrom:(HEMDevicesPresenter*)presenter {
    [self performSegueWithIdentifier:[HEMMainStoryboard pillSegueIdentifier]
                              sender:self];
}

- (void)pairPillFrom:(HEMDevicesPresenter*)presenter {
    HEMPillPairViewController* pairVC = (id) [HEMOnboardingStoryboard instantiatePillPairViewController];
    [pairVC setDelegate:self];
    [self presentPairingViewController:pairVC];
}

#pragma mark - HEMPillPairDelegate

- (void)didPairWithPillFrom:(HEMPillPairViewController *)controller {
    [[self devicesPresenter] refresh];
    NSTimeInterval delayInSeconds = 1.25f;
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)didCancelPairing:(HEMPillPairViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HEMPillControllerDelegate

- (void)didUnpairPillFrom:(HEMPillViewController *)viewController {
    [[self devicesPresenter] refresh];
    [[self navigationController] popViewControllerAnimated:NO];
}

#pragma mark - HEMSenseControllerDelegate

- (void)didEnterPairingModeFrom:(HEMSenseViewController *)viewController {
    // no need to refresh data source since nothing changed.
    [[self navigationController] popViewControllerAnimated:NO];
}

- (void)didUpdateWiFiFrom:(HEMSenseViewController *)viewController {
    [[self devicesPresenter] refresh];
}

- (void)didUnpairSenseFrom:(HEMSenseViewController *)viewController {
    [[self devicesPresenter] refresh];
    [[self navigationController] popViewControllerAnimated:NO];
}

- (void)didFactoryRestoreFrom:(HEMSenseViewController *)viewController {
    [[self devicesPresenter] refresh];
    [[self devicesPresenter] setWaitingForFactoryReset:YES];
    [[self navigationController] popViewControllerAnimated:NO];
}

- (void)didDismissActivityFrom:(HEMSenseViewController *)viewController {
    [[self devicesPresenter] setWaitingForFactoryReset:NO];
}

#pragma mark HEMSensePairDelegate

- (void)didPairSenseUsing:(SENSenseManager*)senseManager from:(UIViewController *)controller {
    [[self devicesPresenter] refresh];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSetupWiFiForPairedSense:(SENSenseManager*)senseManager from:(UIViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[HEMSenseViewController class]]) {
        HEMSenseViewController* senseVC = [segue destinationViewController];
        [senseVC setDelegate:self];
    } else if ([[segue destinationViewController] isKindOfClass:[HEMPillViewController class]]) {
        HEMPillViewController* pillVC = [segue destinationViewController];
        [pillVC setDelegate:self];
    }
}

@end
