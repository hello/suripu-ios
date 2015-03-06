//
//  HEMDevicesViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENDevice.h>

#import "UIFont+HEMStyle.h"
#import "NSDate+HEMRelative.h"

#import "HEMDevicesViewController.h"
#import "HEMPillViewController.h"
#import "HEMSenseViewController.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"
#import "HEMCardFlowLayout.h"
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

static CGFloat const HEMDeviceInfoHeight = 190.0f;
static CGFloat const HEMNoDeviceHeight = 205.0f;

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
@property (strong, nonatomic) SENDevice* selectedDevice;

@end

@implementation HEMDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureCollectionView];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setSelectedDevice:nil];

    if (![self loaded]) {
        [self refreshDataSource:NO];
        [self setLoaded:YES];
    }
    
}

- (void)reloadData {
    HEMCardFlowLayout* layout
        = (HEMCardFlowLayout*)[[self collectionView] collectionViewLayout];
    [layout clearCache];
    [[self collectionView] reloadData];
}

- (void)refreshDataSource:(BOOL)clearCurrentState {
    __weak typeof(self) weakSelf = self;
    [[self dataSource] refreshWithUpdate:^{
        [weakSelf reloadData];
    } completion:^(NSError *error) {
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
    // for now, we will show the same information since the only error that occurs
    // here is when are loading device information
    NSString* title = NSLocalizedString(@"settings.device.error.title", nil);
    NSString* msg = NSLocalizedString(@"settings.device.error.cannot-load-info", nil);
    [self showMessageDialog:msg title:title];
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HEMCardFlowLayout* layout = (HEMCardFlowLayout*)collectionViewLayout;
    SENDevice* device = [[self dataSource] deviceAtIndexPath:indexPath];
    CGSize size = [layout itemSize];
    size.height = device != nil ? HEMDeviceInfoHeight : HEMNoDeviceHeight;
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    [[self dataSource] updateCell:cell atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    SENDeviceType type = [[self dataSource] deviceTypeAtIndexPath:indexPath];
    
    switch (type) {
        case SENDeviceTypeSense: {
            if (![[self dataSource] isLoadingSense]) {
                if ([cell isKindOfClass:[HEMNoDeviceCollectionViewCell class]]) {
                    [self showSensePairingController];
                } else {
                    [self setSelectedDevice:[[self dataSource] deviceAtIndexPath:indexPath]];
                    [self performSegueWithIdentifier:[HEMMainStoryboard senseSegueIdentifier]
                                              sender:self];
                }
            }
            break;
        }
        case SENDeviceTypePill:
            if (![[self dataSource] isLoadingPill]) {
                if ([cell isKindOfClass:[HEMNoDeviceCollectionViewCell class]]) {
                    if (![[self dataSource] isLoadingSense]) { // sense is required for pill pairing
                        [self showPillPairingController];
                    }
                } else {
                    [self setSelectedDevice:[[self dataSource] deviceAtIndexPath:indexPath]];
                    [self performSegueWithIdentifier:[HEMMainStoryboard pillSegueIdentifier]
                                              sender:self];
                }
            }

            break;
        default:
            break;
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
    [self refreshDataSource:YES];
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

- (void)didUpdateWiFiFrom:(HEMSenseViewController *)viewController {
    [self refreshDataSource:YES];
}

- (void)didUnpairSenseFrom:(HEMSenseViewController *)viewController {
    [self refreshDataSource:YES];
    [[self navigationController] popViewControllerAnimated:NO];
}

- (void)didFactoryRestoreFrom:(HEMSenseViewController *)viewController {
    [self refreshDataSource:YES];
    [[self navigationController] popViewControllerAnimated:NO];
}

#pragma mark HEMSensePairDelegate

- (void)updateDataWithSenseManager:(SENSenseManager*)senseManager {
    if (senseManager != nil) {
        __weak typeof(self) weakSelf = self;
        [[self dataSource] updateSenseManager:senseManager completion:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error != nil) {
                [strongSelf showMessageForError:error];
            }
            [strongSelf reloadData];
        }];
        
        [self reloadData]; // clear current state
    }
}

- (void)didPairSenseUsing:(SENSenseManager*)senseManager from:(UIViewController *)controller {
    [self updateDataWithSenseManager:senseManager];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSetupWiFiForPairedSense:(SENSenseManager*)senseManager from:(UIViewController *)controller {
    [self updateDataWithSenseManager:senseManager];
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
        [senseVC setWarnings:[[self dataSource] deviceWarningsFor:[self selectedDevice]]];
        [senseVC setDelegate:self];
    } else if ([[segue destinationViewController] isKindOfClass:[HEMPillViewController class]]) {
        HEMPillViewController* pillVC = [segue destinationViewController];
        [pillVC setDelegate:self];
        [pillVC setWarnings:[[self dataSource] deviceWarningsFor:[self selectedDevice]]];
    }
}

#pragma mark - Cleanup

- (void)dealloc {
    [_collectionView setDelegate:nil];
    [_collectionView setDataSource:nil];
}

@end
