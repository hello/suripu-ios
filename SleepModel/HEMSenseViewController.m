//
//  HEMSenseViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENAPITimeZone.h>
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENPillMetadata.h>
#import <SenseKit/SENSenseWiFiStatus.h>

#import "UIFont+HEMStyle.h"
#import "NSDate+HEMRelative.h"
#import "NSMutableAttributedString+HEMFormat.h"
#import "NSAttributedString+HEMUtils.h"
#import "NSDate+HEMRelative.h"
#import "NSTimeZone+HEMMapping.h"

#import "HEMSenseViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMBaseController+Protected.h"
#import "HEMAlertViewController.h"
#import "HEMWiFiConfigurationDelegate.h"
#import "HEMWifiPickerViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMDeviceActionCollectionViewCell.h"
#import "HEMActivityCoverView.h"
#import "HEMWarningCollectionViewCell.h"
#import "HEMDeviceDataSource.h"
#import "HEMActionButton.h"
#import "HEMSupportUtil.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMTimeZoneViewController.h"
#import "HEMBounceModalTransition.h"
#import "HEMActionSheetViewController.h"

static CGFloat const HEMSenseActionHeight = 62.0f;

typedef NS_ENUM(NSInteger, HEMSenseWarning) {
    HEMSenseWarningLongLastSeen = 1,
    HEMSenseWarningNoInternet = 2,
    HEMSenseWarningNotConnectedToSense = 3
};

@interface HEMSenseViewController() <UICollectionViewDataSource, UICollectionViewDelegate, HEMWiFiConfigurationDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableOrderedSet* warnings;
@property (assign, nonatomic, getter=isVisible) BOOL visible;
@property (assign, nonatomic, getter=isCheckingConnectivity) BOOL checkingConnectivity;
@property (assign, nonatomic, getter=hasCheckedConnectivity) BOOL checkedConnectivity;
@property (assign, nonatomic) BOOL updatedWiFi;
@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (assign, nonatomic) CGSize footerSize;
@property (strong, nonatomic) HEMBounceModalTransition* modalTransitionDelegate;
@property (strong, nonatomic) id disconnectObserverId;
@property (strong, nonatomic) SENSenseWiFiStatus* wiFiStatus;

@end

@implementation HEMSenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureCollectionView];
    [self checkWiFiConnectivity];
    [SENAnalytics track:kHEMAnalyticsEventSense];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setVisible:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self setVisible:NO];
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
    SENSenseMetadata* senseMetadata = [[[SENServiceDevice sharedService] devices] senseMetadata];
    NSString* format = NSLocalizedString(@"settings.sense.warning.last-seen-format", nil);
    NSString* lastSeen = [[senseMetadata lastSeenDate] timeAgo];
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

- (NSAttributedString*)attributedMessageForWarning:(HEMSenseWarning)warning {
    NSAttributedString* message = nil;
    switch (warning) {
        case HEMSenseWarningLongLastSeen:
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

- (NSString*)actionButtonTitleForWarning:(HEMSenseWarning)warning {
    NSString* title = nil;
    switch (warning) {
        case HEMSenseWarningLongLastSeen:
        case HEMSenseWarningNoInternet:
        case HEMSenseWarningNotConnectedToSense:
            title = NSLocalizedString(@"actions.troubleshoot", nil);
            break;
        default:
            break;
    }
    return [title uppercaseString];
}

- (BOOL)isWarningCellRow:(NSInteger)row {
    return row < [[self warnings] count];
}

- (void)determineWarnings {
    NSMutableOrderedSet* warnings = [NSMutableOrderedSet new];
    SENServiceDevice* deviceService = [SENServiceDevice sharedService];
    SENSenseMetadata* senseMetdata = [[deviceService devices] senseMetadata];
    BOOL connected = [deviceService pairedSenseAvailable]
                        && [[deviceService senseManager] isConnected];
    
    if ([deviceService shouldWarnAboutLastSeenForDevice:senseMetdata]) {
        [warnings addObject:@(HEMSenseWarningLongLastSeen)];
    }
    
    if (!connected) {
        [warnings addObject:@(HEMSenseWarningNotConnectedToSense)];
    } else if (![[self wiFiStatus] isConnected]) {
        [warnings addObject:@(HEMSenseWarningNoInternet)];
    }
    
    [self setWarnings:warnings];
}

- (void)checkWiFiConnectivity {
    if (![self hasCheckedConnectivity]) {
        [self setCheckingConnectivity:YES];
        
        __weak typeof(self) weakSelf = self;
        
        void (^finishChecking)(void) = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setCheckingConnectivity:NO];
            [strongSelf setCheckedConnectivity:YES];
            [strongSelf determineWarnings];
            [[strongSelf collectionView] reloadData];
        };
        
        [SENSenseManager whenBleStateAvailable:^(BOOL on) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!on) {
                finishChecking();
                return;
            }
            
            SENServiceDevice* service = [SENServiceDevice sharedService];
            [service getConfiguredWiFi:^(NSString *ssid, SENSenseWiFiStatus *status, NSError *error) {
                if (error) {
                    [SENAnalytics trackError:error];
                }
                [strongSelf setWiFiStatus:status];
                finishChecking();
            }];
            
        }];
    }
}

- (BOOL)isConnectedToSense {
    SENServiceDevice* service = [SENServiceDevice sharedService];
    return [service pairedSenseAvailable] && [[service senseManager] isConnected];
}

- (void)setupFrequentActionsCell:(HEMDeviceActionCollectionViewCell*)actionCell {
    [[actionCell action1Button] addTarget:self
                                   action:@selector(changeTimeZone:)
                         forControlEvents:UIControlEventTouchUpInside];
    [[actionCell action2Button] addTarget:self
                                   action:@selector(pairingMode:)
                         forControlEvents:UIControlEventTouchUpInside];
    [[actionCell action2Button] setEnabled:[self isConnectedToSense]];
    [[actionCell action3Button] addTarget:self
                                   action:@selector(changeWiFi:)
                         forControlEvents:UIControlEventTouchUpInside];
    [[actionCell action3Button] setEnabled:[self isConnectedToSense]];
    [[actionCell action4Button] addTarget:self
                                   action:@selector(showAdvancedOptions:)
                         forControlEvents:UIControlEventTouchUpInside];

}

- (void)setupWarningCell:(HEMWarningCollectionViewCell*)warningCell
              forWarning:(HEMSenseWarning)warning {
    [[warningCell warningMessageLabel] setAttributedText:[self attributedMessageForWarning:warning]];
    [[warningCell actionButton] setTitle:[self actionButtonTitleForWarning:warning]
                                forState:UIControlStateNormal];
    [[warningCell actionButton] setTag:warning];
    [[warningCell actionButton] addTarget:self
                                   action:@selector(takeWarningAction:)
                         forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 1 + [[self warnings] count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = [indexPath row];
    NSString* reuseId = nil;
    BOOL warningPath = [self isWarningCellRow:row];
    
    if (warningPath) {
        reuseId = [HEMMainStoryboard warningReuseIdentifier];
    } else {
        reuseId = [HEMMainStoryboard actionsReuseIdentifier];
    }
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                                           forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[HEMDeviceActionCollectionViewCell class]]) {
        HEMDeviceActionCollectionViewCell* actionCell = (id)cell;
        BOOL isBusy = [self isCheckingConnectivity] || ![self hasCheckedConnectivity];
        [actionCell showActivity:isBusy withText:NSLocalizedString(@"settings.sense.connecting", nil)];
        [self setupFrequentActionsCell:actionCell];
    } else if ([cell isKindOfClass:[HEMWarningCollectionViewCell class]]) {
        HEMSenseWarning warning = (HEMSenseWarning)[[self warnings][[indexPath row]] integerValue];
        HEMWarningCollectionViewCell* warningCell = (HEMWarningCollectionViewCell*)cell;
        [self setupWarningCell:warningCell forWarning:warning];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewFlowLayout *)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [layout itemSize];
    
    if ([self isWarningCellRow:[indexPath row]]) {
        CGFloat widthConstraint = size.width - (2*HEMWarningCellMessageHorzPadding);
        HEMSenseWarning warning = [self.warnings[indexPath.item] integerValue];
        NSAttributedString* message = [self attributedMessageForWarning:warning];
        size.height = [message sizeWithWidth:widthConstraint].height + HEMWarningCellBaseHeight;
    } else {
        size.height = HEMSenseActionHeight * 4;
    }
    
    return size;
}

#pragma mark - Actions

- (void)takeWarningAction:(UIButton*)sender {
    HEMSenseWarning warning = [sender tag];
    NSString* helpPage = nil;
    
    switch (warning) {
        case HEMSenseWarningNotConnectedToSense:
            helpPage = NSLocalizedString(@"help.url.slug.sense-not-connected", nil);
            break;
        case HEMSenseWarningLongLastSeen:
            helpPage = NSLocalizedString(@"help.url.slug.sense-not-seen", nil);
            break;
        case HEMSenseWarningNoInternet:
            helpPage = NSLocalizedString(@"help.url.slug.sense-no-internet", nil);
            break;
        default:
            break;
    }
    
    // if no help page, will open to complete guide
    [HEMSupportUtil openHelpToPage:helpPage fromController:self];
}

- (NSDictionary*)dialogMessageAttributes:(BOOL)bold {
    return @{NSFontAttributeName : bold ? [UIFont dialogMessageBoldFont] : [UIFont dialogMessageFont],
             NSForegroundColorAttributeName : [UIColor blackColor]};
}

- (void)showConfirmation:(NSString*)title message:(NSAttributedString*)message action:(void(^)(void))action {
    HEMAlertViewController* dialogVC = [HEMAlertViewController new];
    [dialogVC setTitle:title];
    [dialogVC setAttributedMessage:message];
    [dialogVC setViewToShowThrough:self.view];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.no", nil) style:HEMAlertViewButtonStyleRoundRect action:nil];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.yes", nil) style:HEMAlertViewButtonStyleBlueText action:^{
        if (action) {
            action();
        }
    }];
    
    __weak typeof(self) weakSelf = self;
    [dialogVC onLinkTapOf:NSLocalizedString(@"help.url.support.hyperlink-text", nil) takeAction:^(NSURL *link) {
        [HEMSupportUtil openHelpFrom:weakSelf];
    }];
    
    [dialogVC showFrom:self];
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
    [[self activityView] dismissWithResultText:done showSuccessMark:YES remove:YES completion:^{
        if ([[self delegate] respondsToSelector:@selector(didDismissActivityFrom:)]) {
            [[self delegate] didDismissActivityFrom:self];
        }
        if (completion) {
            completion ();
        }
    }];
}

- (void)dismissActivity:(void(^)(void))completion {
    [[self activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:completion];
}

#pragma mark Advanced Options

- (void)showAdvancedOptions:(id)sender {
    HEMActionSheetViewController* sheet =
        [HEMMainStoryboard instantiateActionSheetViewController];
    [sheet setTitle:NSLocalizedString(@"settings.sense.advanced.option.title", nil)];
    
    __weak typeof (self) weakSelf = self;
    
    [sheet addOptionWithTitle:NSLocalizedString(@"settings.sense.advanced.option.replace-sense", nil)
                   titleColor:nil
                  description:NSLocalizedString(@"settings.sense.advanced.option.replace-sense.desc", nil)
                    imageName:nil
                       action:^{
                           [weakSelf replaceSense];
                       }];
    
    if ([self isConnectedToSense]) {
        [sheet addOptionWithTitle:NSLocalizedString(@"settings.sense.advanced.option.factory-reset", nil)
                       titleColor:[UIColor redColor]
                      description:NSLocalizedString(@"settings.sense.advanced.option.factory-reset.desc", nil)
                        imageName:nil
                           action:^{
                               [weakSelf factoryReset];
                           }];
    }
    
    UIViewController* root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [root presentViewController:sheet animated:NO completion:nil];
}

#pragma mark Unpair Sense

- (void)showUnpairError {
    NSString* title = NSLocalizedString(@"settings.sense.dialog.pair-failed-title", nil);
    NSString* message = NSLocalizedString(@"settings.sense.unpair.failed-message", nil);
    [self showMessageDialog:message title:title];
}

- (void)unlinkSense {
    if ([[self delegate] respondsToSelector:@selector(willUnpairSenseFrom:)]) {
        [[self delegate] willUnpairSenseFrom:self];
    }
    
    SENSenseMetadata* senseMetadata = [[[SENServiceDevice sharedService] devices] senseMetadata];
    NSString* senseId = [senseMetadata uniqueId];
    [SENAnalytics track:kHEMAnalyticsEventDeviceAction
             properties:@{kHEMAnalyticsEventPropAction : kHEMAnalyticsEventDeviceActionUnpairSense,
                          kHEMAnalyticsEventPropSenseId : senseId ?: @"unknown"}];
    
    NSString* message = NSLocalizedString(@"settings.sense.unpairing-message", nil);
    [self showActivityText:message completion:^{
        __weak typeof(self) weakSelf = self;
        [[SENServiceDevice sharedService] unlinkSenseFromAccount:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error != nil) {
                [SENAnalytics trackError:error];
                [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                    [strongSelf showUnpairError];
                }];
            } else {
                if ([[strongSelf delegate] respondsToSelector:@selector(didUnpairSenseFrom:)]) {
                    [[strongSelf delegate] didUnpairSenseFrom:strongSelf];
                }
                [strongSelf dismissActivityWithSuccess:nil];
            }
        }];
    }];
}

- (void)replaceSense {
    UIColor* baseColor = [UIColor blackColor];
    
    NSString* title = NSLocalizedString(@"settings.sense.unpair.title", nil);
    NSString* questionFormat = NSLocalizedString(@"settings.sense.unpair.confirmation.format", nil);
    NSString* guideLink = NSLocalizedString(@"help.url.support.hyperlink-text", nil);
    
    NSArray* args = @[[[NSAttributedString alloc] initWithString:guideLink
                                                      attributes:[self dialogMessageAttributes:YES]]];
    
    NSAttributedString* message =
        [[NSMutableAttributedString alloc] initWithFormat:questionFormat
                                                     args:args
                                                baseColor:baseColor
                                                 baseFont:[UIFont dialogMessageFont]];
    
    [self showConfirmation:title message:message action:^{
        [self unlinkSense];
    }];
}

#pragma mark Time Zone

- (void)changeTimeZone:(id)sender {
    NSString* title = NSLocalizedString(@"alerts.timezone.title", nil);
    NSString* messageFormat = NSLocalizedString(@"timezone.alert.message.use-local.format", nil);
    NSArray* args = @[[[NSAttributedString alloc] initWithString:[NSTimeZone localTimeZoneMappedName]
                                                      attributes:[self dialogMessageAttributes:YES]]];
    
    NSAttributedString* message =
    [[NSMutableAttributedString alloc] initWithFormat:messageFormat
                                                 args:args
                                            baseColor:[UIColor blackColor]
                                             baseFont:[UIFont dialogMessageFont]];
    
    HEMAlertViewController* dialogVC = [HEMAlertViewController new];
    [dialogVC setTitle:title];
    [dialogVC setAttributedMessage:message];
    [dialogVC setViewToShowThrough:self.view];
    
    __weak typeof(self) weakSelf = self;
    [dialogVC addButtonWithTitle:NSLocalizedString(@"timezone.action.use-local", nil) style:HEMAlertViewButtonStyleRoundRect action:^{
        [weakSelf updateToLocalTimeZone];
    }];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"timezone.action.select-manually", nil) style:HEMAlertViewButtonStyleBlueText action:^{
        [weakSelf performSegueWithIdentifier:[HEMMainStoryboard timezoneSegueIdentifier] sender:weakSelf];
    }];
    [dialogVC showFrom:self];
}

- (void)updateToLocalTimeZone {
    NSString* progressMessage = NSLocalizedString(@"timezone.activity.message", nil);
    [self showActivityText:progressMessage completion:^{
        __weak typeof(self) weakSelf = self;
        NSTimeZone* timeZone = [NSTimeZone localTimeZone];
        [SENAPITimeZone setTimeZone:timeZone completion:^(id data, NSError *error) {
            __strong typeof(weakSelf) strongSelf = self;
            if (!error) {
                NSString* tz = [timeZone name] ?: @"unknown";
                [SENAnalytics track:HEMAnalyticsEventTimeZoneChanged
                         properties:@{HEMAnalyticsEventPropTZ : tz}];

                [strongSelf dismissActivityWithSuccess:nil];
            } else {
                [SENAnalytics trackError:error];
                [strongSelf dismissActivity:^{
                    [strongSelf showMessageDialog:NSLocalizedString(@"timezone.error.message", nil)
                                            title:NSLocalizedString(@"timezone.error.title", nil)];
                }];
            }
        }];
    }];
}

#pragma mark Enable Pairing Mode

- (void)pairingMode:(id)sender {
    NSString* title = NSLocalizedString(@"settings.sense.dialog.enable-pair-mode-title", nil);
    NSString* msgFormat = NSLocalizedString(@"settings.sense.dialog.enable-pair-mode-message.format", nil);
    NSString* guideLink = NSLocalizedString(@"help.url.support.hyperlink-text", nil);
    
    NSArray* args = @[[[NSAttributedString alloc] initWithString:guideLink
                                                      attributes:[self dialogMessageAttributes:YES]]];
    
    NSAttributedString* message =
        [[NSMutableAttributedString alloc] initWithFormat:msgFormat
                                                     args:args
                                                baseColor:[UIColor blackColor]
                                                 baseFont:[UIFont dialogMessageFont]];
    
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
             properties:@{kHEMAnalyticsEventPropAction : kHEMAnalyticsEventDeviceActionPairingMode}];
    
    [self listenForDisconnects];
    
    NSString* message = NSLocalizedString(@"settings.sense.enabling-pairing-mode", nil);
    [self showActivityText:message completion:^{
        __weak typeof(self) weakSelf = self;
        [[SENServiceDevice sharedService] putSenseIntoPairingMode:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error != nil) {
                [SENAnalytics trackError:error];
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

- (void)factoryReset {
    NSString* title = NSLocalizedString(@"settings.device.dialog.factory-restore-title", nil);
    NSString* message = NSLocalizedString(@"settings.device.dialog.factory-restore-message", nil);
    NSAttributedString* attributedMessage =
        [[NSAttributedString alloc] initWithString:message attributes:[self dialogMessageAttributes:NO]];
    
    __weak typeof(self) weakSelf = self;
    [self showConfirmation:title message:attributedMessage action:^{
        [weakSelf restore];
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
    [SENAnalytics trackError:error];
}

- (void)listenForDisconnects {
    SENSenseManager* manager = [[SENServiceDevice sharedService] senseManager];

    if ([self disconnectObserverId] == nil && manager != nil) {
        __weak typeof(self) weakSelf = self;
        self.disconnectObserverId =
        [manager observeUnexpectedDisconnect:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if ([strongSelf isVisible]) {
                if ([strongSelf activityView] != nil) {
                    [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                        NSString* title = NSLocalizedString(@"settings.sense.operation-failed.title", nil);
                        NSString* message = NSLocalizedString(@"settings.sense.operation-failed.unexpected-disconnect", nil);
                        [strongSelf showMessageDialog:message title:title];
                        [SENAnalytics trackError:error];
                    }];
                }
            }
        }];
    }
}

- (void)restore {
    
    SENServiceDevice* deviceService = [SENServiceDevice sharedService];
    SENDeviceMetadata* senseMetadata = [[deviceService devices] senseMetadata];
    SENDeviceMetadata* pillMetdata = [[deviceService devices] pillMetadata];
    NSString* senseId = [senseMetadata uniqueId];
    NSString* pillId = [pillMetdata uniqueId];
    [SENAnalytics track:kHEMAnalyticsEventDeviceAction
             properties:@{kHEMAnalyticsEventPropAction : kHEMAnalyticsEventDeviceActionFactoryRestore,
                          kHEMAnalyticsEventPropSenseId : senseId ?: @"unknown",
                          kHEMAnalyticsEventPropPillId : pillId ?: @"unknown"}];

    [self listenForDisconnects];
    
    NSString* message = NSLocalizedString(@"settings.device.restoring-factory-settings", nil);
    [self showActivityText:message completion:^{
        __weak typeof(self) weakSelf = self;
        [deviceService restoreFactorySettings:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error != nil) {
                [SENAnalytics trackError:error];
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
    if (ssid && [[self warnings] count] > 0) {
        [[self warnings] removeObject:@(HEMSenseWarningNotConnectedToSense)];
        [[self warnings] removeObject:@(HEMSenseWarningNoInternet)];
        [[self collectionView] reloadData];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = [segue destinationViewController];
        UIViewController* root = [nav topViewController];
        // only apply the transition to timezone
        if ([root isKindOfClass:[HEMTimeZoneViewController class]]) {
            [self setModalTransitionDelegate:[[HEMBounceModalTransition alloc] init]];
            [nav setTransitioningDelegate:[self modalTransitionDelegate]];
            [nav setModalPresentationStyle:UIModalPresentationCustom];
        }
    }
}

#pragma mark - Clean up

- (void)dealloc {
    [[[SENServiceDevice sharedService] senseManager] disconnectFromSense];
}

@end
