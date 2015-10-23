//
//  HEMPillViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENPillMetadata.h>
#import <SenseKit/SENPairedDevices.h>

#import "UIFont+HEMStyle.h"
#import "NSDate+HEMRelative.h"
#import "NSMutableAttributedString+HEMFormat.h"
#import "NSAttributedString+HEMUtils.h"
#import "HEMPillViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMDeviceActionCollectionViewCell.h"
#import "HEMActivityCoverView.h"
#import "HEMSupportUtil.h"
#import "HEMWarningCollectionViewCell.h"
#import "HEMAlertViewController.h"
#import "HEMDeviceDataSource.h"
#import "HEMActionButton.h"
#import "HEMActionSheetViewController.h"

static NSInteger const HEMPillActionsCellHeight = 124.0f;

typedef NS_ENUM(NSUInteger, HEMPillWarning) {
    HEMPillWarningLongLastSeen,
    HEMPillWarningLowBattery
};

@interface HEMPillViewController() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (strong, nonatomic) NSMutableOrderedSet* warnings;

@end

@implementation HEMPillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self determineWarnings];
    [self configureCollectionView];
    [SENAnalytics track:kHEMAnalyticsEventPill];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self collectionView] reloadData];
}

- (void)determineWarnings {
    NSMutableOrderedSet* warnings = [NSMutableOrderedSet new];
    SENServiceDevice* deviceService = [SENServiceDevice sharedService];
    SENPillMetadata* pillMetdata = [[deviceService devices] pillMetadata];
    
    if ([deviceService shouldWarnAboutLastSeenForDevice:pillMetdata]) {
        [warnings addObject:@(HEMPillWarningLongLastSeen)];
    }
    
    if ([pillMetdata state] == SENPillStateLowBattery) {
        [warnings addObject:@(HEMPillWarningLowBattery)];
    }
    
    [self setWarnings:warnings];
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

- (NSAttributedString*)attributedLongLastSeenMessage {
    SENPillMetadata* pillMetadata = [[[SENServiceDevice sharedService] devices] pillMetadata];
    NSString* format = NSLocalizedString(@"settings.pill.warning.last-seen-format", nil);
    NSString* lastSeen = [[pillMetadata lastSeenDate] timeAgo];
    NSArray* args = @[[self redMessage:lastSeen ?: NSLocalizedString(@"settings.device.warning.last-seen-generic", nil)]];
    
    NSMutableAttributedString* attrWarning =
        [[NSMutableAttributedString alloc] initWithFormat:format args:args];
    [attrWarning addAttributes:@{NSFontAttributeName : [UIFont deviceCellWarningMessageFont]}
                         range:NSMakeRange(0, [attrWarning length])];
    
    return attrWarning;
}

- (NSAttributedString*)attributedLowBatteryMessage {
    NSString* format = NSLocalizedString(@"settings.pill.warning.low-battery-format", nil);
    NSString* batteryLow = NSLocalizedString(@"settings.pill.warning.battery-low", nil);
    NSArray* args = @[[self redMessage:batteryLow]];
    
    NSMutableAttributedString* attrWarning =
    [[NSMutableAttributedString alloc] initWithFormat:format args:args];
    [attrWarning addAttributes:@{NSFontAttributeName : [UIFont deviceCellWarningMessageFont]}
                         range:NSMakeRange(0, [attrWarning length])];
    
    return attrWarning;
}

- (NSAttributedString*)attributedMessageForWarning:(HEMPillWarning)warning {
    NSAttributedString* message = nil;
    switch (warning) {
        case HEMPillWarningLongLastSeen:
            message = [self attributedLongLastSeenMessage];
            break;
        case HEMPillWarningLowBattery:
            message = [self attributedLowBatteryMessage];
            break;
        default:
            break;
    }
    return message;
}

- (NSDictionary*)dialogMessageAttributes:(BOOL)bold {
    return @{NSFontAttributeName : bold ? [UIFont dialogMessageBoldFont] : [UIFont dialogMessageFont],
             NSForegroundColorAttributeName : [UIColor blackColor]};
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [[self warnings] count] + 1; // actions always available
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
        HEMDeviceActionCollectionViewCell* actionCell = (HEMDeviceActionCollectionViewCell*)cell;
        [[actionCell action1Button] addTarget:self
                                       action:@selector(replaceBattery:)
                             forControlEvents:UIControlEventTouchUpInside];
        [[actionCell action2Button] addTarget:self
                                       action:@selector(showAdvancedOptions:)
                             forControlEvents:UIControlEventTouchUpInside];
    } else if ([cell isKindOfClass:[HEMWarningCollectionViewCell class]]) {
        HEMPillWarning warning = [[self warnings][[indexPath row]] integerValue];
        HEMWarningCollectionViewCell* warningCell = (HEMWarningCollectionViewCell*)cell;
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

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewFlowLayout *)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [layout itemSize];
    if ([indexPath row] < [[self warnings] count]) {
        CGFloat maxWidth = size.width - (2*HEMWarningCellMessageHorzPadding);
        HEMPillWarning warning = [[self warnings][[indexPath row]] integerValue];
        NSAttributedString* message = [self attributedMessageForWarning:warning];
        size.height = [message sizeWithWidth:maxWidth].height + HEMWarningCellBaseHeight;
    } else if ([indexPath row] == [[self warnings] count]) {
        size.height = HEMPillActionsCellHeight;
    }
    return size;
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
            [self replaceBattery:self];
            break;
        }
        default:
            break;
    }
}

- (void)showAdvancedOptions:(id)sender {
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

- (void)replaceBattery:(id)sender {
    NSString* page = NSLocalizedString(@"help.url.slug.pill-battery", nil);
    [HEMSupportUtil openHelpToPage:page fromController:self];
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
    [dialogVC setViewToShowThrough:self.view];
    
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
