//
//  HEMDevicesViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENPillMetadata.h>

#import "UIFont+HEMStyle.h"
#import "NSDate+HEMRelative.h"
#import "UIColor+HEMStyle.h"

#import "HEMDevicesViewController.h"
#import "HEMPillViewController.h"
#import "HEMSenseViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMDeviceCollectionViewCell.h"
#import "HEMNoDeviceCollectionViewCell.h"
#import "HEMActionButton.h"
#import "HEMPillPairViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMDeviceDataSource.h"
#import "HEMSensePairViewController.h"
#import "HEMSensePairDelegate.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMTextFooterCollectionReusableView.h"
#import "HEMSupportUtil.h"
#import "HEMTutorial.h"

static CGFloat const HEMDeviceInfoHeight = 184.0f;
static CGFloat const HEMNoDeviceHeight = 203.0f;
static CGFloat const HEMNoDeviceWithoutButtonHeight = 132.0f;
static CGFloat const HEMDeviceContentMargin = 18.0f;

@interface HEMDevicesViewController() <
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    HEMPillPairDelegate,
    HEMSenseControllerDelegate,
    HEMSensePairingDelegate,
    HEMPillControllerDelegate,
    HEMTextFooterDelegate
>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HEMDeviceDataSource* dataSource;
@property (assign, nonatomic) BOOL loaded;
@property (assign, nonatomic, getter=isWaitingToShowFactoryResetDialog) BOOL waitingToShowFactoryResetDialog;
@property (strong, nonatomic) SENDeviceMetadata* selectedDevice;

@end

@implementation HEMDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureCollectionView];
    [self listenForPairingChanges];
    [SENAnalytics track:kHEMAnalyticsEventDevices];
}

- (void)configureCollectionView {
    HEMDeviceDataSource* dataSource
        = [[HEMDeviceDataSource alloc] initWithCollectionView:[self collectionView]
                                            andFooterDelegate:self];
    [self setDataSource:dataSource];
    
    [[self collectionView] setDelegate:self];
    [[self collectionView] setDataSource:dataSource];
    [[self collectionView] setAlwaysBounceVertical:YES];
}

- (void)listenForPairingChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(didUpdatePairing:)
                   name:HEMOnboardingNotificationDidChangeSensePairing
                 object:nil];
    [center addObserver:self
               selector:@selector(didUpdatePairing:)
                   name:HEMOnboardingNotificationDidChangePillPairing
                 object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setSelectedDevice:nil];

    if (![self loaded]) {
        [self refreshDataSource:NO];
        [HEMTutorial showTutorialForPillColorIfNeeded];
        [self setLoaded:YES];
    }
}

- (void)reloadData {
    [[self collectionView] reloadData];
}

- (void)didUpdatePairing:(NSNotification*)notification {
    [self refreshDataSource:YES];
}

- (void)refreshDataSource:(BOOL)clearCurrentState {
    __weak typeof(self) weakSelf = self;
    
    [[self dataSource] refresh:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error != nil) {
            [strongSelf showMessageForError:error];
        }
        [strongSelf reloadData];
    }];
    
    if (clearCurrentState) {
        [self reloadData]; // clear current display state to show activity
    }
}

- (void)showMessageForError:(NSError*)error {
    NSString* title = nil;
    NSString* msg = nil;
    
    // there are other errors that can occur, but are more like warnings.  We
    // should only display an error for codes that matter here, which is when
    // device info could not be loaded
    switch ([error code]) {
        case HEMDeviceErrorDeviceInfoNotLoaded:
        case HEMDeviceErrorReplacedSenseInfoNotLoaded:
            title = NSLocalizedString(@"settings.device.error.title", nil);
            msg = NSLocalizedString(@"settings.device.error.cannot-load-info", nil);
            break;
        default:
            break;
    }
    
    if (msg) { // title is optional
        [self showMessageDialog:msg title:title];
        // only log an error / warning if an error is displayed to the user
        if ([[error domain] isEqualToString:HEMDeviceErrorDomain] && [error code] == HEMDeviceErrorNoBle) {
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventWarning];
        } else {
            [SENAnalytics trackError:error];
        }

    }
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewFlowLayout *)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    SENDeviceMetadata* device = [[self dataSource] deviceAtIndexPath:indexPath];
    
    CGSize size = [layout itemSize];
    size.width = CGRectGetWidth([collectionView bounds]);
    
    if (device) {
        size.height = HEMDeviceInfoHeight;
    } else if ([indexPath row] == HEMDeviceRowPill && ![[self dataSource] canPairPill]) {
        size.height = HEMNoDeviceWithoutButtonHeight;
    } else {
        size.height = HEMNoDeviceHeight;
    }
    
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    [[self dataSource] updateCell:cell atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self dataSource] isRefreshing]) {
        return;
    }
    
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([indexPath row] == HEMDeviceRowSense) {
        if ([cell isKindOfClass:[HEMNoDeviceCollectionViewCell class]]) {
            [self showSensePairingController];
        } else {
            [self setSelectedDevice:[[self dataSource] deviceAtIndexPath:indexPath]];
            [self performSegueWithIdentifier:[HEMMainStoryboard senseSegueIdentifier]
                                      sender:self];
        }
    } else if ([indexPath row] == HEMDeviceRowPill) {
        if ([cell isKindOfClass:[HEMNoDeviceCollectionViewCell class]]) {
            // cell interaction will be disabled if not ready to pair
            [self showPillPairingController];
        } else {
            [self setSelectedDevice:[[self dataSource] deviceAtIndexPath:indexPath]];
            [self performSegueWithIdentifier:[HEMMainStoryboard pillSegueIdentifier]
                                      sender:self];
        }
    }
}

#pragma mark - Pill

- (void)showPillPairingController {
    HEMPillPairViewController* pairVC =
        (HEMPillPairViewController*) [HEMOnboardingStoryboard instantiatePillPairViewController];
    [pairVC setDelegate:self];
    UINavigationController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark HEMPillPairDelegate

- (void)didPairWithPillFrom:(HEMPillPairViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelPairing:(HEMPillPairViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark HEMPillControllerDelegate

- (void)didUnpairPillFrom:(HEMPillViewController *)viewController {
    [self refreshDataSource:YES];
    [[self navigationController] popViewControllerAnimated:NO];
}

#pragma mark - Sense

- (void)showSensePairingController {
    HEMSensePairViewController* pairVC =
        (HEMSensePairViewController*) [HEMOnboardingStoryboard instantiateSensePairViewController];
    [pairVC setDelegate:self];
    UINavigationController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark HEMSenseControllerDelegate

- (void)didEnterPairingModeFrom:(HEMSenseViewController *)viewController {
    // no need to refresh data source since nothing changed.
    [[self navigationController] popViewControllerAnimated:NO];
}

- (void)didUpdateWiFiFrom:(HEMSenseViewController *)viewController {
    [self refreshDataSource:YES];
}

- (void)didUnpairSenseFrom:(HEMSenseViewController *)viewController {
    [self refreshDataSource:YES];
    [[self navigationController] popViewControllerAnimated:NO];
}

- (void)didFactoryRestoreFrom:(HEMSenseViewController *)viewController {
    [self refreshDataSource:YES];
    [self setWaitingToShowFactoryResetDialog:YES];
    [[self navigationController] popViewControllerAnimated:NO];
}

- (void)didDismissActivityFrom:(HEMSenseViewController *)viewController {
    if ([self isWaitingToShowFactoryResetDialog]) {
        NSString* title = NSLocalizedString(@"settings.sense.factory-reset.complete.title", nil);
        NSString* msg = NSLocalizedString(@"settings.sense.factory-reset.complete.confirmation", nil);
        [self showMessageDialog:msg title:title];
        [self setWaitingToShowFactoryResetDialog:NO];
    }
}

#pragma mark HEMSensePairDelegate

- (void)didPairSenseUsing:(SENSenseManager*)senseManager from:(UIViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSetupWiFiForPairedSense:(SENSenseManager*)senseManager from:(UIViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HEMTextFooterDelegate

- (void)didTapOnLink:(NSURL *)url from:(HEMTextFooterCollectionReusableView *)view {
    NSString* lowerScheme = [url scheme];
    if ([lowerScheme hasPrefix:@"http"]) {
        [HEMSupportUtil openURL:[url absoluteString] from:self];
    }
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

#pragma mark - Cleanup

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_collectionView setDelegate:nil];
    [_collectionView setDataSource:nil];
}

@end
