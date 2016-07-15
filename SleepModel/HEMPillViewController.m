//
//  HEMPillViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENPillMetadata.h>
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENServiceDevice.h>

#import "NSDate+HEMRelative.h"
#import "NSMutableAttributedString+HEMFormat.h"
#import "NSAttributedString+HEMUtils.h"

#import "HEMPillViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMDeviceActionCell.h"
#import "HEMActivityCoverView.h"
#import "HEMSupportUtil.h"
#import "HEMWarningCollectionViewCell.h"
#import "HEMAlertViewController.h"
#import "HEMActionButton.h"
#import "HEMActionSheetViewController.h"
#import "HEMSleepPillDfuViewController.h"
#import "HEMStyle.h"
#import "HEMDeviceService.h"
#import "HEMSleepPillDFUDelegate.h"

static NSString* const HEMPillHeaderReuseId = @"sectionHeader";

typedef NS_ENUM(NSInteger, HEMPillWarning) {
    HEMPillWarningLongLastSeen = 1,
    HEMPillWarningLowBattery = 2
};

typedef NS_ENUM(NSInteger, HEMPillAction) {
    HEMPillActionFirmwareUpdate = 0,
    HEMPillActionReplaceBattery,
    HEMPillActionAdvanced,
    HEMPillActionRows
};

@interface HEMPillViewController() <
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    HEMSleepPillDFUDelegate
>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (strong, nonatomic) NSMutableOrderedSet* warnings;
@property (assign, nonatomic, getter=hasFirmwareUpdateAvailable) BOOL firmwareUpdateAvailable;

@end

@implementation HEMPillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self determineWarnings];
    [self determinePillUpdateAvailability];
    [self configureCollectionView];
    [SENAnalytics track:kHEMAnalyticsEventPill];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self collectionView] reloadData];
}

- (void)determineWarnings {
    NSMutableOrderedSet* warnings = [NSMutableOrderedSet new];
    SENPillMetadata* pillMetdata = [[[self deviceService] devices] pillMetadata];
    
    if ([[self deviceService] shouldWarnAboutLastSeenForDevice:pillMetdata]) {
        [warnings addObject:@(HEMPillWarningLongLastSeen)];
    }
    
    if ([pillMetdata state] == SENPillStateLowBattery) {
        [warnings addObject:@(HEMPillWarningLowBattery)];
    }
    
    [self setWarnings:warnings];
}

- (void)determinePillUpdateAvailability {
    SENPillMetadata* pillMetadata = [[[self deviceService] devices] pillMetadata];
    [self setFirmwareUpdateAvailable:[pillMetadata firmwareUpdateUrl] != nil
                                        && ![[self deviceService] shouldSuppressPillFirmwareUpdate]];
}

- (void)configureCollectionView {
    [[self collectionView] setDataSource:self];
    [[self collectionView] setDelegate:self];
    [[self collectionView] setAlwaysBounceVertical:YES];
}

- (NSAttributedString*)attributedLongLastSeenMessage {
    SENPillMetadata* pillMetadata = [[[self deviceService] devices] pillMetadata];
    NSString* format = NSLocalizedString(@"settings.pill.warning.last-seen-format", nil);
    NSString* lastSeen = [[pillMetadata lastSeenDate] timeAgo];
    lastSeen = lastSeen ?: NSLocalizedString(@"settings.device.warning.last-seen-generic", nil);
    
    NSAttributedString* attrLastSeen = [[NSAttributedString alloc] initWithString:lastSeen];
    
    NSMutableAttributedString* attrWarning =
        [[NSMutableAttributedString alloc] initWithFormat:format args:@[attrLastSeen]];
    [attrWarning addAttributes:@{NSFontAttributeName : [UIFont deviceCellWarningMessageFont]}
                         range:NSMakeRange(0, [attrWarning length])];
    
    return attrWarning;
}

- (NSAttributedString*)attributedLowBatteryMessage {
    NSString* message = NSLocalizedString(@"settings.pill.warning.low-battery", nil);
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont deviceCellWarningMessageFont]};
    return [[NSAttributedString alloc] initWithString:message attributes:attributes];
}

- (NSAttributedString*)attributedMessageForWarning:(HEMPillWarning)warning {
    switch (warning) {
        case HEMPillWarningLongLastSeen:
            return [self attributedLongLastSeenMessage];
        case HEMPillWarningLowBattery:
            return [self attributedLowBatteryMessage];
        default:
            return nil;
    }
}

- (NSString*)warningTitleForWarning:(HEMPillWarning)warning {
    switch (warning) {
        case HEMPillWarningLongLastSeen:
            return NSLocalizedString(@"settings.pill.warning.title.last-seen", nil);
        case HEMPillWarningLowBattery:
            return NSLocalizedString(@"settings.pill.warning.title.low-battery", nil);
        default:
            return nil;
    }
}

- (NSDictionary*)dialogMessageAttributes:(BOOL)bold {
    return @{NSFontAttributeName : bold ? [UIFont dialogMessageBoldFont] : [UIFont dialogMessageFont],
             NSForegroundColorAttributeName : [UIColor blackColor]};
}

- (NSInteger)adjustedRowFor:(NSInteger)row {
    return [self hasFirmwareUpdateAvailable] ? row : row + 1;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self warnings] count] + 1; // actions always available
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSInteger rows = 1;
    if (section >= [[self warnings] count]) {
        rows = HEMPillActionRows;
        if (![self hasFirmwareUpdateAvailable]) {
            rows--;
        }
    }
    return rows;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger row = [indexPath row];
    NSInteger sec = [indexPath section];
    
    NSString* reuseId
        = sec < [[self warnings] count]
        ? [HEMMainStoryboard warningReuseIdentifier]
        : [HEMMainStoryboard actionReuseIdentifier];
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                                           forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[HEMDeviceActionCell class]]) {
        NSInteger adjustedRow = [self adjustedRowFor:row];
        HEMDeviceActionCell* actionCell = (id) cell;
        NSString* text = nil;
        UIImage* icon = nil;
        BOOL showTopSeparator = NO;
        BOOL showSeparator = YES;
        
        if (adjustedRow == HEMPillActionFirmwareUpdate) {
            icon = [UIImage imageNamed:@"settingsPairingModeIcon"];
            text = NSLocalizedString(@"settings.pill.update-firmware.title", nil) ;
            showTopSeparator = YES;
        } else if (adjustedRow == HEMPillActionReplaceBattery) {
            icon = [UIImage imageNamed:@"settingsBatteryIcon"];
            text = NSLocalizedString(@"settings.pill.replace-battery.title", nil) ;
        } else if (adjustedRow == HEMPillActionAdvanced) {
            icon = [UIImage imageNamed:@"settingsAdvanceIcon"];
            text = NSLocalizedString(@"settings.pill.advanced.option.title", nil);
            showSeparator = NO;
        }
        
        [[actionCell textLabel] setText:text];
        [[actionCell iconView] setImage:icon];
        [[actionCell separatorView] setHidden:!showSeparator];
        [[actionCell topSeparatorView] setHidden:!showTopSeparator];
        
    } else if ([cell isKindOfClass:[HEMWarningCollectionViewCell class]]) {
        HEMPillWarning warning = [[self warnings][sec] integerValue];
        HEMWarningCollectionViewCell* warningCell = (HEMWarningCollectionViewCell*)cell;
        [[warningCell warningSummaryLabel] setText:[self warningTitleForWarning:warning]];
        [[warningCell warningMessageLabel] setAttributedText:[self attributedMessageForWarning:warning]];
        [[warningCell actionButton] setTitle:[NSLocalizedString(@"actions.troubleshoot", nil) uppercaseString]
                                    forState:UIControlStateNormal];
        [[warningCell actionButton] setTag:warning];
        [[warningCell actionButton] addTarget:self
                                       action:@selector(takeWarningAction:)
                             forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind
                                atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView* view = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:HEMPillHeaderReuseId
                                                         forIndexPath:indexPath];
        [view setBackgroundColor:[UIColor backgroundColor]];
    }
    
    return view;
    
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size = [[collectionView superview] bounds].size;
    if (section == 0) {
        size.height = HEMStyleDeviceSectionTopMargin;
    } else {
        size.height = HEMStyleSectionTopMargin;
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewFlowLayout *)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [layout itemSize];
    NSInteger sec = [indexPath section];

    size.width = CGRectGetWidth([[collectionView superview] bounds]);
    
    if (sec < [[self warnings] count]) {
        CGFloat maxWidth = size.width - (2*HEMWarningCellMessageHorzPadding);
        HEMPillWarning warning = [[self warnings][sec] integerValue];
        NSAttributedString* message = [self attributedMessageForWarning:warning];
        size.height = [message sizeWithWidth:maxWidth].height + HEMWarningCellBaseHeight;
    } else {
        size.height = HEMDeviceActionCellHeight;
    }
    
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger sec = [indexPath section];
    if (sec == [[self warnings] count]) {
        NSInteger adjustedRow = [self adjustedRowFor:[indexPath row]];
        switch (adjustedRow) {
            case HEMPillActionFirmwareUpdate:
                return [self showPillDfuController];
                break;
            case HEMPillActionReplaceBattery:
                return [self replaceBattery];
            case HEMPillActionAdvanced:
                return [self showAdvancedOptions];
            default:
                return;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[self shadowView] updateVisibilityWithContentOffset:[scrollView contentOffset].y];
}

#pragma mark - Actions

- (void)takeWarningAction:(UIButton*)sender {
    HEMPillWarning warning = [sender tag];
    switch (warning) {
        case HEMPillWarningLongLastSeen: {
            NSString* page = NSLocalizedString(@"help.url.slug.pill-not-seen", nil);
            [HEMSupportUtil openHelpToPage:page fromController:self];
            break;
        }
        case HEMPillWarningLowBattery: {
            [self replaceBattery];
            break;
        }
        default:
            break;
    }
}

- (void)showPillDfuController {
    UINavigationController* nav = [HEMMainStoryboard instantiatePillDFUNavViewController];
    if ([[nav topViewController] isKindOfClass:[HEMSleepPillDfuViewController class]]) {
        HEMSleepPillDfuViewController* dfuVC = (id) [nav topViewController];
        [dfuVC setDelegate:self];
    }
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showAdvancedOptions {
    HEMActionSheetViewController* sheet =
        [HEMMainStoryboard instantiateActionSheetViewController];
    [sheet setTitle:NSLocalizedString(@"settings.pill.advanced.option.title", nil)];
    
    __weak typeof (self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"settings.pill.advanced.option.replace-pill", nil)
                   titleColor:nil
                  description:NSLocalizedString(@"settings.pill.advanced.option.replace-pill.desc", nil)
                    imageName:nil
                       action:^{
                           [weakSelf replacePill];
                       }];
    
    UIViewController* root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [root presentViewController:sheet animated:NO completion:nil];
}

- (void)replaceBattery {
    NSString* page = NSLocalizedString(@"help.url.slug.pill-battery", nil);
    [HEMSupportUtil openHelpToPage:page fromController:self];
}

#pragma mark - HEMSleepPillDFUDelegate

- (void)controller:(UIViewController *)dfuController didCompleteDFU:(BOOL)complete {
    if (complete) {
        [self setFirmwareUpdateAvailable:NO];
        [[self collectionView] reloadData];
    }
}

#pragma mark - Unpairing the pill

- (void)replacePill {
    NSString* title = NSLocalizedString(@"settings.pill.dialog.unpair-title", nil);
    NSString* messageFormat = NSLocalizedString(@"settings.pill.dialog.unpair-message.format", nil);
    NSString* helpLink = NSLocalizedString(@"help.url.support.hyperlink-text", nil);
    
    NSArray* args = @[[[NSAttributedString alloc] initWithString:helpLink
                                                      attributes:[self dialogMessageAttributes:YES]]];
    
    NSAttributedString* confirmation =
    [[NSMutableAttributedString alloc] initWithFormat:messageFormat
                                                 args:args
                                            baseColor:[UIColor blackColor]
                                             baseFont:[UIFont dialogMessageFont]];
    
    HEMAlertViewController* dialogVC = [HEMAlertViewController new];
    [dialogVC setTitle:title];
    [dialogVC setAttributedMessage:confirmation];
    [dialogVC setViewToShowThrough:[self backgroundViewForAlerts]];
    
    __weak typeof(self) weakSelf = self;
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.no", nil) style:HEMAlertViewButtonStyleRoundRect action:nil];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.yes", nil) style:HEMAlertViewButtonStyleBlueText action:^{
        [weakSelf unpair];
    }];
    [dialogVC onLinkTapOf:helpLink takeAction:^(NSURL *link) {
        [HEMSupportUtil openHelpFrom:weakSelf];
    }];
    
    [dialogVC showFrom:self];
}

- (void)showUnpairMessageForError:(NSError*)error {
    NSString* message = nil;
    switch ([error code]) {
        case SENServiceDeviceErrorSenseUnavailable:
            message = NSLocalizedString(@"settings.pill.unpair-no-sense-found", nil);
            break;
        case SENServiceDeviceErrorSenseNotPaired:
            message = NSLocalizedString(@"settings.pill.dialog.no-paired-sense-message", nil);
            break;
        case SENServiceDeviceErrorUnpairPillFromSense:
            message = NSLocalizedString(@"settings.pill.dialog.unable-to-unpair-from-sense", nil);
            break;
        case SENServiceDeviceErrorUnlinkPillFromAccount:
            message = NSLocalizedString(@"settings.pill.dialog.unable-to-unlink-from-account", nil);
            break;
        default:
            message = NSLocalizedString(@"settings.pill.dialog.unable-to-unpair", nil);
            break;
    }

    NSString* title = NSLocalizedString(@"settings.pill.unpair-error-title", nil);
    [HEMAlertViewController showInfoDialogWithTitle:title message:message controller:self];
}

- (void)unpair {
    if ([self activityView] == nil) {
        [self setActivityView:[[HEMActivityCoverView alloc] init]];
    }
    
    if ([[self delegate] respondsToSelector:@selector(willUnpairPillFrom:)]) {
        [[self delegate] willUnpairPillFrom:self];
    }
    
    SENPillMetadata* pillMetadata = [[[SENServiceDevice sharedService] devices] pillMetadata];
    NSString* pillId = [pillMetadata uniqueId];
    [SENAnalytics track:kHEMAnalyticsEventDeviceAction
             properties:@{kHEMAnalyticsEventPropAction : kHEMAnalyticsEventDeviceActionUnpairPill,
                          kHEMAnalyticsEventPropPillId : pillId ?: @"unknown"}];
    
    id<UIApplicationDelegate> delegate = (id)[UIApplication sharedApplication].delegate;
    UIViewController* root = (id)delegate.window.rootViewController;
    
    NSString* message = NSLocalizedString(@"settings.pill.unpairing-message", nil);
    [[self activityView] showInView:[root view] withText:message activity:YES completion:^{
        __weak typeof(self) weakSelf = self;
        // TODO: remove depedency to SENServiceDevice so we can remove that class
        // completely and use HEMDeviceService
        [[SENServiceDevice sharedService] unpairSleepPill:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error != nil) {
                [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                    [strongSelf showUnpairMessageForError:error];
                }];
            } else {
                if ([[strongSelf delegate] respondsToSelector:@selector(didUnpairPillFrom:)]) {
                    [[strongSelf delegate] didUnpairPillFrom:strongSelf];
                }
                NSString* success = NSLocalizedString(@"settings.pill.unpaired-message", nil);
                [[strongSelf activityView] dismissWithResultText:success showSuccessMark:YES remove:YES completion:nil];
            }
        }];
    }];

}

@end
