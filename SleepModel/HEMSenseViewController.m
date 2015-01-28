//
//  HEMSenseViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENDevice.h>
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENServiceDevice.h>

#import "UIFont+HEMStyle.h"
#import "NSDate+HEMRelative.h"
#import "NSMutableAttributedString+HEMFormat.h"
#import "NSDate+HEMRelative.h"

#import "HEMSenseViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMBaseController+Protected.h"
#import "HEMAlertController.h"
#import "HelloStyleKit.h"
#import "HEMWiFiConfigurationDelegate.h"
#import "HEMWifiPickerViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMDeviceActionCollectionViewCell.h"
#import "HEMCardFlowLayout.h"
#import "HEMActivityCoverView.h"
#import "HEMWarningCollectionViewCell.h"
#import "HEMDeviceDataSource.h"
#import "HEMActionButton.h"
#import "HEMSupportUtil.h"
#import "HEMStyledNavigationViewController.h"

static CGFloat const HEMSenseActionsCellHeight = 248.0f;

@interface HEMSenseViewController() <UICollectionViewDataSource, UICollectionViewDelegate, HEMWiFiConfigurationDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (assign, nonatomic) BOOL updatedWiFi;
@property (strong, nonatomic) HEMAlertController* alertController;
@property (strong, nonatomic) HEMActivityCoverView* activityView;

@end

@implementation HEMSenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureCollectionView];
    [SENAnalytics track:kHEMAnalyticsEventSense];
}

- (void)configureCollectionView {
    [[self collectionView] setDataSource:self];
    [[self collectionView] setDelegate:self];
    [[self collectionView] setAlwaysBounceVertical:YES];
}

- (NSAttributedString*)redMessage:(NSString*)message {
    NSDictionary* attributes = @{NSForegroundColorAttributeName : [UIColor redColor]};
    return [[NSAttributedString alloc] initWithString:message attributes:attributes];
}

- (NSAttributedString*)attributedLastSeenWarning {
    NSString* format = NSLocalizedString(@"settings.sense.warning.last-seen-format", nil);
    NSString* lastSeen = [[[[SENServiceDevice sharedService] senseInfo] lastSeen] timeAgo];
    NSArray* args = @[[self redMessage:lastSeen ?: NSLocalizedString(@"settings.device.warning.last-seen-generic", nil)]];
    
    NSMutableAttributedString* attrWarning =
        [[NSMutableAttributedString alloc] initWithFormat:format args:args];
    [attrWarning addAttributes:@{NSFontAttributeName : [UIFont deviceCellWarningMessageFont]}
                         range:NSMakeRange(0, [attrWarning length])];
    
    return attrWarning;
}

- (NSAttributedString*)attributedWiFiWarning {
    NSString* format = NSLocalizedString(@"settings.sense.warning.wifi-format", nil);
    NSString* connectProblem = NSLocalizedString(@"settings.sense.warning.cannont-connect-wifi", nil);
    NSArray* args = @[[self redMessage:connectProblem]];
    
    NSMutableAttributedString* attrWarning =
        [[NSMutableAttributedString alloc] initWithFormat:format args:args];
    [attrWarning addAttributes:@{NSFontAttributeName : [UIFont deviceCellWarningMessageFont]}
                         range:NSMakeRange(0, [attrWarning length])];
    
    return attrWarning;
}

- (NSAttributedString*)attributedSenseNotConnectedWarning {
    NSString* message = NSLocalizedString(@"settings.sense.warning.not-connected-sense", nil);
    NSMutableAttributedString* attrWarning = [[NSMutableAttributedString alloc] initWithString:message];
    [attrWarning addAttributes:@{NSFontAttributeName : [UIFont deviceCellWarningMessageFont]}
                         range:NSMakeRange(0, [attrWarning length])];
    return attrWarning;
}

- (NSAttributedString*)attributedMessageForWarning:(HEMDeviceWarning)warning {
    NSAttributedString* message = nil;
    switch (warning) {
        case HEMDeviceWarningLongLastSeen:
            message = [self attributedLastSeenWarning];
            break;
        case HEMSenseWarningNoInternet:
            message = [self attributedWiFiWarning];
            break;
        case HEMSenseWarningNotConnectedToSense:
            message = [self attributedSenseNotConnectedWarning];
            break;
        default:
            break;
    }
    return message;
}

- (CGFloat)heightForWarning:(HEMDeviceWarning)warning withDefaultItemSize:(CGSize)size {
    NSAttributedString* message = [self attributedMessageForWarning:warning];
    CGRect bounds = [message boundingRectWithSize:CGSizeMake(size.width, MAXFLOAT)
                                          options:NSStringDrawingUsesFontLeading
                                                 |NSStringDrawingUsesLineFragmentOrigin
                                          context:nil];
    return CGRectGetHeight(bounds);
}

- (NSString*)actionButtonTitleForWarning:(HEMDeviceWarning)warning {
    NSString* title = nil;
    switch (warning) {
        case HEMDeviceWarningLongLastSeen:
        case HEMSenseWarningNotConnectedToSense:
            title = NSLocalizedString(@"actions.troubleshoot", nil);
            break;
        case HEMSenseWarningNoInternet:
            title = NSLocalizedString(@"actions.edit.wifi", nil);
            break;
        default:
            break;
    }
    return [title uppercaseString];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 1 + [[self warnings] count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* reuseId
        = [indexPath row] < [[self warnings] count]
        ? [HEMMainStoryboard warningReuseIdentifier]
        : [HEMMainStoryboard actionsReuseIdentifier];
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                                           forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[HEMDeviceActionCollectionViewCell class]]) {
        BOOL senseAvailable = [[SENServiceDevice sharedService] pairedSenseAvailable];
        HEMDeviceActionCollectionViewCell* actionCell = (HEMDeviceActionCollectionViewCell*)cell;
        [[actionCell action1Button] addTarget:self
                                       action:@selector(replaceSense:)
                             forControlEvents:UIControlEventTouchUpInside];
        [[actionCell action2Button] addTarget:self
                                       action:@selector(pairingMode:)
                             forControlEvents:UIControlEventTouchUpInside];
        [[actionCell action2Button] setEnabled:senseAvailable];
        [[actionCell action3Button] addTarget:self
                                       action:@selector(factoryReset:)
                             forControlEvents:UIControlEventTouchUpInside];
        [[actionCell action3Button] setEnabled:senseAvailable];
        [[actionCell action4Button] addTarget:self
                                       action:@selector(changeWiFi:)
                             forControlEvents:UIControlEventTouchUpInside];
        [[actionCell action4Button] setEnabled:senseAvailable];
    } else if ([cell isKindOfClass:[HEMWarningCollectionViewCell class]]) {
        HEMDeviceWarning warning = (HEMDeviceWarning)[[self warnings][[indexPath row]] integerValue];
        HEMWarningCollectionViewCell* warningCell = (HEMWarningCollectionViewCell*)cell;
        [[warningCell warningMessageLabel] setAttributedText:[self attributedMessageForWarning:warning]];
        [[warningCell actionButton] setTitle:[self actionButtonTitleForWarning:warning]
                                    forState:UIControlStateNormal];
        [[warningCell actionButton] setTag:warning];
        [[warningCell actionButton] addTarget:self
                                       action:@selector(takeWarningAction:)
                             forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HEMCardFlowLayout* layout = (HEMCardFlowLayout*)collectionViewLayout;
    CGSize size = [layout itemSize];
    
    if ([indexPath row] < [[self warnings] count]) {
        size.height = [self heightForWarning:[[self warnings][[indexPath row]] integerValue]
                         withDefaultItemSize:size] + HEMWarningCellBaseHeight;
    } else if ([indexPath row] == [[self warnings] count]) {
        size.height = HEMSenseActionsCellHeight;
    }
    
    return size;
}

#pragma mark - Actions

- (void)takeWarningAction:(UIButton*)sender {
    HEMDeviceWarning warning = [sender tag];
    switch (warning) {
        case HEMSenseWarningNotConnectedToSense:
        case HEMDeviceWarningLongLastSeen:
            [HEMSupportUtil openHelpFrom:self];
            break;
        case HEMSenseWarningNoInternet:
            [self changeWiFi:self];
            break;
        default:
            break;
    }
}

- (void)showConfirmation:(NSString*)title message:(NSString*)message action:(void(^)(void))action {
    HEMAlertController* alert = [[HEMAlertController alloc] initWithTitle:title
                                                                  message:message
                                                                    style:HEMAlertControllerStyleAlert
                                                     presentingController:self];
    
    [alert addActionWithText:NSLocalizedString(@"actions.no", nil) block:nil];
    [alert addActionWithText:NSLocalizedString(@"actions.yes", nil) block:action];
    
    [self setAlertController:alert];
    [[self alertController] show];
}

- (void)showActivityText:(NSString*)text completion:(void(^)(void))completion {
    if ([self activityView] == nil) {
        [self setActivityView:[[HEMActivityCoverView alloc] init]];
    }
    
    id<UIApplicationDelegate> delegate = (id)[UIApplication sharedApplication].delegate;
    UIViewController* root = (id)delegate.window.rootViewController;
    
    [[self activityView] showInView:[root view] withText:text activity:YES completion:completion];
}

- (void)dismissActivityWithSuccess:(void(^)(void))completion {
    NSString* done = NSLocalizedString(@"status.success", nil);
    [[self activityView] dismissWithResultText:done showSuccessMark:YES remove:YES completion:completion];
}

#pragma mark Unpair Sense

- (void)showUnpairError {
    NSString* title = NSLocalizedString(@"settings.sense.dialog.pair-failed-title", nil);
    NSString* message = NSLocalizedString(@"settings.sense.unpair.failed-message", nil);
    [self showMessageDialog:message title:title];
}

- (void)unlinkSense {
    NSString* message = NSLocalizedString(@"settings.sense.unpairing-message", nil);
    [self showActivityText:message completion:^{
        __weak typeof(self) weakSelf = self;
        [[SENServiceDevice sharedService] unlinkSenseFromAccount:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error != nil) {
                [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
                [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                    [strongSelf showUnpairError];
                }];
            } else {
                [strongSelf dismissActivityWithSuccess:nil];
            }
        }];
    }];
}

- (void)replaceSense:(id)sender {
    NSString* title = NSLocalizedString(@"settings.sense.unpair.title", nil);
    NSString* question = NSLocalizedString(@"settings.sense.unpair.confirmation", nil);
    [self showConfirmation:title message:question action:^{
        [self unlinkSense];
    }];
}

#pragma mark Enable Pairing Mode

- (void)pairingMode:(id)sender {
    NSString* title = NSLocalizedString(@"settings.sense.dialog.enable-pair-mode-title", nil);
    NSString* message = NSLocalizedString(@"settings.sense.dialog.enable-pair-mode-message", nil);
    
    __weak typeof(self) weakSelf = self;
    [self showConfirmation:title message:message action:^{
        [weakSelf enablePairingMode];
    }];
}

- (void)showFailureToEnablePairingModeAlert {
    NSString* title = NSLocalizedString(@"settings.sense.dialog.pair-failed-title", nil);
    NSString* message = NSLocalizedString(@"settings.sense.dialog.pair-failed-message", nil);
    [self showMessageDialog:message title:title];
}

- (void)enablePairingMode {
    [SENAnalytics track:kHEMAnalyticsEventDeviceAction
             properties:@{kHEMAnalyticsEventPropAction : kHEMAnalyticsEventDevicePairingMode}];
    
    NSString* message = NSLocalizedString(@"settings.sense.enabling-pairing-mode", nil);
    [self showActivityText:message completion:^{
        __weak typeof(self) weakSelf = self;
        [[SENServiceDevice sharedService] putSenseIntoPairingMode:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error != nil) {
                [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
                [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                    [strongSelf showFailureToEnablePairingModeAlert];
                }];
            } else {
                [strongSelf dismissActivityWithSuccess:nil];
            }
        }];
    }];
}

#pragma mark Factory Reset

- (void)factoryReset:(id)sender {
    NSString* title = NSLocalizedString(@"settings.device.dialog.factory-restore-title", nil);
    NSString* message = NSLocalizedString(@"settings.device.dialog.factory-restore-message", nil);
    
    __weak typeof(self) weakSelf = self;
    [self showConfirmation:title message:message action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf restore];
        }
    }];
}

- (void)showFactoryRestoreErrorMessage:(NSError*)error {
    NSString* title = NSLocalizedString(@"settings.factory-restore.error.title", nil);
    NSString* message = nil;
    
    switch ([error code]) {
        case SENServiceDeviceErrorUnlinkPillFromAccount:
            message = NSLocalizedString(@"settings.factory-restore.error.unlink-pill", nil);
            break;
        case SENServiceDeviceErrorUnlinkSenseFromAccount:
            message = NSLocalizedString(@"settings.factory-restore.error.unlink-sense", nil);
            break;
        case SENServiceDeviceErrorInProgress:
        case SENServiceDeviceErrorSenseUnavailable: {
            title = NSLocalizedString(@"settings.sense.not-found-title", nil);
            message = NSLocalizedString(@"settings.sense.no-sense-message", nil);
            break;
        }
        default:
            break;
    }
    
    [self showMessageDialog:message title:title];
}


- (void)restore {
    [SENAnalytics track:kHEMAnalyticsEventDeviceAction
             properties:@{kHEMAnalyticsEventPropAction : kHEMAnalyticsEventDeviceFactoryRestore}];

    NSString* message = NSLocalizedString(@"settings.device.restoring-factory-settings", nil);
    [self showActivityText:message completion:^{
        __weak typeof(self) weakSelf = self;
        [[SENServiceDevice sharedService] restoreFactorySettings:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error != nil) {
                [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
                // if there's no error, notification of factory restore will fire,
                // which will trigger app to be put back at checkpoint
                [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                    [strongSelf showFactoryRestoreErrorMessage:error];
                }];
            } else {
                if ([[strongSelf delegate] respondsToSelector:@selector(didFactoryRestoreFrom:)]) {
                    [[strongSelf delegate] didFactoryRestoreFrom:strongSelf];
                }
                [strongSelf dismissActivityWithSuccess:nil];
            }
        }];
    }];

}


#pragma mark Change WiFi

- (void)changeWiFi:(id)sender {
    HEMWifiPickerViewController* picker =
        (HEMWifiPickerViewController*) [HEMOnboardingStoryboard instantiateWifiPickerViewController];
    [picker setDelegate:self];
    
    UINavigationController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:picker];
    [self presentViewController:nav animated:YES completion:nil];

}

#pragma mark - HEMWifiConfigurationDelegate

- (void)didCancelWiFiConfigurationFrom:(id)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didConfigureWiFiTo:(NSString *)ssid from:(id)controller {
    if ([[self delegate] respondsToSelector:@selector(didUpdateWiFiFrom:)]) {
        [[self delegate] didUpdateWiFiFrom:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
