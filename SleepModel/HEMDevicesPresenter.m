//
//  HEMDevicesPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/29/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENDeviceMetadata.h>
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENPillMetadata.h>

#import "Sense-Swift.h"

#import "NSAttributedString+HEMUtils.h"
#import "NSMutableAttributedString+HEMFormat.h"
#import "NSDate+HEMRelative.h"

#import "HEMStyle.h"
#import "HEMDevicesPresenter.h"
#import "HEMOnboardingService.h"
#import "HEMDeviceService.h"
#import "HEMDeviceCollectionViewCell.h"
#import "HEMNoDeviceCollectionViewCell.h"
#import "HEMTextFooterCollectionReusableView.h"
#import "HEMSettingsStoryboard.h"
#import "HEMTutorial.h"
#import "HEMPillCollectionViewCell.h"
#import "HEMActionButton.h"
#import "HEMUpgradeFlow.h"
#import "HEMUpgradeSensePresenter.h"
#import "HEMHaveSenseViewController.h"
#import "HEMOnboardingStoryboard.h"

static NSString* const HEMDevicesFooterReuseIdentifier = @"footer";
static CGFloat const HEMDeviceSectionMargin = 8.0f;
static CGFloat const HEMDeviceItemSpacing = 8.0f;
static CGFloat const HEMDeviceFooterTextMargin = 24.0f;
static CGFloat const HEMDeviceFooterBottomMargin = 32.0f;
static CGFloat const HEMNoDeviceHeight = 203.0f;

typedef NS_ENUM(NSInteger, HEMDevicesRow) {
    HEMDevicesRowSense = 0,
    HEMDevicesRowPill,
    HEMDevicesRowCount
};

typedef NS_ENUM(NSInteger, HEMDevicesSection) {
    HEMDevicesSectionSenseAndPill = 0,
    HEMDevicesSectionUpgrade,
    HEMDevicesSectionCount
};

@interface HEMDevicesPresenter() <
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    HEMTextFooterDelegate,
    CollapsableActionLinkDelegate
>

@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, assign, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, assign) BOOL attemptedDataLoad;
@property (nonatomic, strong) NSAttributedString* attributedFooterText;
@property (nonatomic, strong) NSAttributedString* attributedUpgradeMessage;
@property (nonatomic, assign, getter=isUpgradeCollpased) BOOL upgradeCollapsed;

@end

@implementation HEMDevicesPresenter

- (instancetype)initWithDeviceService:(HEMDeviceService*)deviceService {
    self = [super init];
    if (self) {
        _upgradeCollapsed = YES;
        _deviceService = deviceService;
        [self listenForPairingChanges];
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    [collectionView registerClass:[HEMTextFooterCollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
              withReuseIdentifier:HEMDevicesFooterReuseIdentifier];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(HEMDeviceSectionMargin, 0.0f, HEMDeviceSectionMargin, 0.0f);
    UICollectionViewFlowLayout* layout = (id)[collectionView collectionViewLayout];
    [layout setSectionInset:insets];
    [layout setMinimumLineSpacing:HEMDeviceItemSpacing];
    
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [collectionView setAlwaysBounceVertical:YES];
    [collectionView applyStyle];
    
    [self setCollectionView:collectionView];
    [self refresh];
}

- (void)setWaitingForFactoryReset:(BOOL)waitingForFactoryReset {
    if (_waitingForFactoryReset == waitingForFactoryReset) {
        return;
    }
    
    if (_waitingForFactoryReset && !waitingForFactoryReset) {
        NSString* title = NSLocalizedString(@"settings.sense.factory-reset.complete.title", nil);
        NSString* msg = NSLocalizedString(@"settings.sense.factory-reset.complete.confirmation", nil);
        [[self delegate] showAlertWithTitle:title message:msg from:self];
    }
    
    _waitingForFactoryReset = waitingForFactoryReset;
}

- (void)refresh {
    [self setRefreshing:YES];
    
    __weak typeof(self) weakSelf = self;
    [[self deviceService] refreshMetadata:^(SENPairedDevices * _Nullable devices, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf setAttemptedDataLoad:YES];
        [strongSelf setRefreshing:NO];
        
        if (error && [error code] != HEMDeviceErrorInProgress) {
            NSString* title = NSLocalizedString(@"settings.device.error.title", nil);
            NSString* msg = NSLocalizedString(@"settings.device.error.cannot-load-info", nil);
            [[strongSelf delegate] showAlertWithTitle:title message:msg from:self];
        } else {
            [[strongSelf collectionView] reloadData];
        }
        
    }];
}

- (void)didRelayout {
    [super didRelayout];
    UICollectionViewFlowLayout* layout = (id)[[self collectionView] collectionViewLayout];
    CGSize itemSize = [layout itemSize];
    itemSize.width = CGRectGetWidth([[[self collectionView] superview] bounds]);
    [layout setItemSize:itemSize];
}

#pragma mark - Content

- (NSAttributedString*)attributedFooterText {
    if (_attributedFooterText == nil) {
        NSString* textFormat = NSLocalizedString(@"settings.device.footer.format", nil);
        NSString* secondPill = NSLocalizedString(@"settings.device.footer.second-pill", nil);
        NSString* helpBaseUrl = NSLocalizedString(@"help.url.support", nil);
        NSString* secondPillSlug = NSLocalizedString(@"help.url.slug.pill-setup-another", nil);
        NSString* url = [helpBaseUrl stringByAppendingPathComponent:secondPillSlug];
        UIFont* font = [UIFont body];
        
        NSAttributedString* attrPill = [[NSAttributedString alloc] initWithString:secondPill];
        NSArray* args = @[[attrPill hyperlink:url font:font]];
        NSMutableAttributedString* attributedText = [[NSMutableAttributedString alloc] initWithFormat:textFormat args:args];
        
        [attributedText addAttribute:NSParagraphStyleAttributeName
                                      value:DefaultBodyParagraphStyle()
                                      range:NSMakeRange(0, [attributedText length])];
        
        _attributedFooterText = attributedText;
    }
    
    return _attributedFooterText;
}

- (BOOL)hasDeviceAtIndexPath:(NSIndexPath*)indexPath {
    if ([indexPath section] != HEMDevicesSectionSenseAndPill) {
        return NO;
    }
    
    SENPairedDevices* devices = [[self deviceService] devices];
    switch ([indexPath row]) {
        default:
        case HEMDevicesRowSense:
            return [devices hasPairedSense];
        case HEMDevicesRowPill:
            return [devices hasPairedPill];
    }
}

- (NSString*)lastSeenFor:(SENDeviceMetadata*)deviceMetadata {
    if ([deviceMetadata lastSeenDate]) {
        return [[deviceMetadata lastSeenDate] timeAgo];
    } else {
        return NSLocalizedString(@"empty-data", nil);
    }
}

- (NSString*)colorStringForDevice:(SENDeviceMetadata*)deviceMetadata {
    NSString* colorString = nil;
    
    if ([deviceMetadata isKindOfClass:[SENSenseMetadata class]]) {
        SENSenseColor senseColor = [((SENSenseMetadata*)deviceMetadata) color];
        switch (senseColor) {
            case SENSenseColorCharcoal:
                colorString = NSLocalizedString(@"color.charcoal", nil);
                break;
            case SENSenseColorCotton:
                colorString = NSLocalizedString(@"color.cotton", nil);
            default:
                break;
        }
    } else if ([deviceMetadata isKindOfClass:[SENPillMetadata class]]) {
        SENPillColor pillColor = [((SENPillMetadata*)deviceMetadata) color];
        switch (pillColor) {
            case SENPillColorBlue:
                colorString = NSLocalizedString(@"color.blue", nil);
                break;
            case SENPillColorRed:
                colorString = NSLocalizedString(@"color.red", nil);
            default:
                break;
        }
    }
    
    return colorString ?: NSLocalizedString(@"empty-data", nil);
}

- (NSString*)senseConnectedSSID {
    SENSenseMetadata* senseMetadata = [[[self deviceService] devices] senseMetadata];
    NSString* ssid = [[senseMetadata wiFi] ssid];
    return ssid ?: NSLocalizedString(@"empty-data", nil);
}

- (void)wiFiColor:(UIColor**)color icon:(UIImage**)icon {
    if (![self attemptedDataLoad]) {
        *color = [UIColor grey6];
        return;
    }
    
    SENSenseMetadata* senseMetadata = [[[self deviceService] devices] senseMetadata];
    SENWiFiCondition condition = [[senseMetadata wiFi] condition];
    
    switch (condition) {
        default:
        case SENWiFiConditionNone:
            *icon = [UIImage imageNamed:@"wifiIconNone"];
            *color = [SenseStyle colorWithCondition:SENConditionAlert defaultColor:nil];
            break;
        case SENWiFiConditionBad:
            *icon = [UIImage imageNamed:@"wifiIconLow"];
            *color = [SenseStyle colorWithCondition:SENConditionWarning defaultColor:nil];
            break;
        case SENWiFiConditionFair:
            *icon = [UIImage imageNamed:@"wifiIconMedium"];
            break;
        case SENWiFiConditionGood:
            *icon = [UIImage imageNamed:@"wifiIconHigh"];
            break;
    }
}

- (NSString*)senseTitleForMetadata:(SENSenseMetadata*)senseMetadata {
    switch ([senseMetadata hardwareVersion]) {
        case SENSenseHardwareVoice:
            return NSLocalizedString(@"settings.device.sense.voice", nil);
        default:
            return NSLocalizedString(@"settings.device.sense", nil);
    }
}

- (NSAttributedString*)attributedUpgradeMessage {
    if (!_attributedUpgradeMessage) {
        NSString* format = NSLocalizedString(@"settings.sense.upgrade.message.format", nil);
        NSString* linkText = NSLocalizedString(@"settings.sense.upgrade.learn-more.link.text", nil);
        NSString* linkUrl = NSLocalizedString(@"settings.sense.upgrade.link.url", nil);
        
        NSAttributedString* attrLink = [[NSAttributedString alloc] initWithString:linkText];
        NSArray* args = @[[attrLink hyperlink:linkUrl font:[UIFont body]]];
        NSMutableAttributedString* attributedText =
        [[NSMutableAttributedString alloc] initWithFormat:format
                                                     args:args
                                                baseColor:nil
                                                 baseFont:[UIFont body]];
        
        NSMutableParagraphStyle* style = DefaultBodyParagraphStyle();
        style.paragraphSpacing = 10.0f;
        [attributedText addAttribute:NSParagraphStyleAttributeName
                               value:style
                               range:NSMakeRange(0, [attributedText length])];
        
        _attributedUpgradeMessage = attributedText;
    }
    return _attributedUpgradeMessage;
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return HEMDevicesSectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case HEMDevicesSectionSenseAndPill:
            // always show an option for Sense
            return [[self deviceService] shouldShowPillInfo] ? HEMDevicesRowCount : 1;
        case HEMDevicesSectionUpgrade:
            return [[self deviceService] hasHardwareUpgradeForSense] ? 1 : 0;
        default:
            return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSString* reuseId = nil;
    
    switch ([indexPath section]) {
        case HEMDevicesSectionSenseAndPill: {
            BOOL hasDevice = [self hasDeviceAtIndexPath:indexPath];
            
            if (!hasDevice && [self attemptedDataLoad]) {
                reuseId = [HEMSettingsStoryboard pairReuseIdentifier];
            } else if ([indexPath row] == HEMDevicesRowPill) {
                reuseId = [HEMSettingsStoryboard pillReuseIdentifier];
            } else {
                reuseId = [HEMSettingsStoryboard senseReuseIdentifier];
            }
            
            break;
        }
        case HEMDevicesSectionUpgrade:
            reuseId = [HEMSettingsStoryboard upgradeReuseIdentifier];
            break;
        default:
            break;
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                     forIndexPath:indexPath];
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView
          viewForSupplementaryElementOfKind:(NSString*)kind
                                atIndexPath:(NSIndexPath*)indexPath {
    
    HEMTextFooterCollectionReusableView* footer
        = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                             withReuseIdentifier:HEMDevicesFooterReuseIdentifier
                                                    forIndexPath:indexPath];
    
    NSAttributedString* attributedFootnote = nil;
    switch ([indexPath section]) {
        default:
        case HEMDevicesSectionSenseAndPill:
            if ([[[self deviceService] devices] hasPairedSense]) {
                attributedFootnote = [self attributedFooterText];
            }
            break;
        case HEMDevicesSectionUpgrade:
            break;
    }
    
    [footer setText:attributedFootnote];
    [footer setDelegate:self];
    
    return footer;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section {
    
    CGSize size = CGSizeZero;
    
    switch (section) {
        case HEMDevicesSectionSenseAndPill: {
            CGFloat viewWidth = CGRectGetWidth([collectionView bounds]);
            CGFloat maxWidth = viewWidth - (HEMDeviceFooterTextMargin * 2);
            CGFloat textHeight = [[self attributedFooterText] sizeWithWidth:maxWidth].height;
            size.width = maxWidth;
            size.height = textHeight + HEMDeviceFooterBottomMargin;
            break;
        }
        default:
            break;
    }
    
    return size;
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewFlowLayout *)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [layout itemSize];
    size.width = CGRectGetWidth([[collectionView superview] bounds]);
    
    switch ([indexPath section]) {
        case HEMDevicesSectionSenseAndPill: {
            if ([self hasDeviceAtIndexPath:indexPath]) {
                if ([indexPath row] == HEMDevicesRowPill) {
                    BOOL hasUpdate = [[self deviceService] isPillFirmwareUpdateAvailable];
                    size.height = [HEMPillCollectionViewCell heightWithFirmwareUpdate:hasUpdate];
                } else { // is sense
                    size.height = [HEMDeviceCollectionViewCell heightOfCellActionButton:NO];
                }
            } else {
                size.height = HEMNoDeviceHeight;
            }
            break;
        }
        case HEMDevicesSectionUpgrade: {
            NSAttributedString* body = [self attributedUpgradeMessage];
            size.height = [CollapsableActionCell heightWithBody:body
                                                      collapsed:[self isUpgradeCollpased]
                                                      cellWidth:size.width];
            break;
        }
        default:
            break;
    }
    
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HEMDeviceCollectionViewCell class]]) {
        HEMDeviceCollectionViewCell* deviceCell = (id)cell;
        [deviceCell applyStyle];
        
        switch ([indexPath row]) {
            default:
            case HEMDevicesRowSense:
                [self updateCellForSense:deviceCell];
                break;
            case HEMDevicesRowPill:
                [self updateCellForPill:deviceCell];
                break;
        }
        [deviceCell showDataLoadingIndicator:[self isRefreshing] || ![self attemptedDataLoad]];
    } else if ([cell isKindOfClass:[HEMNoDeviceCollectionViewCell class]]) {
        HEMNoDeviceCollectionViewCell* noDeviceCell = (id)cell;
        switch ([indexPath row]) {
            default:
            case HEMDevicesRowSense:
                [noDeviceCell configureForSense];
                break;
            case HEMDevicesRowPill: {
                [noDeviceCell configureForPill];
                break;
            }
        }
    } else if ([cell isKindOfClass:[CollapsableActionCell class]]) {
        [self updateUpgradeCell:(id) cell];
    }
}

- (void)updateUpgradeCell:(CollapsableActionCell*)cell {
    [cell setWithBody:[self attributedUpgradeMessage]];
    [cell setLinkDelegate:self];
    [[cell titleLabel] setText:NSLocalizedString(@"settings.device.sense.voice", nil)];
    [[cell actionButton] setTitle:NSLocalizedString(@"upgrade.button.title", nil)
                         forState:UIControlStateNormal];
    [[cell actionButton] addTarget:self
                            action:@selector(upgradeSense)
                  forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateCellForSense:(HEMDeviceCollectionViewCell*)cell {
    SENSenseMetadata* senseMetadata = [[[self deviceService] devices] senseMetadata];
    
    UIImage* wiFiIcon = nil;
    UIColor* wiFiColor = nil;
    [self wiFiColor:&wiFiColor icon:&wiFiIcon];
    
    NSString* lastSeen = [self lastSeenFor:senseMetadata];
    NSString* name = [self senseTitleForMetadata:senseMetadata];
    NSString* property1Name = NSLocalizedString(@"settings.sense.wifi", nil);
    NSString* property1Value = [self senseConnectedSSID];
    NSString* property2Name = NSLocalizedString(@"settings.device.firmware-version", nil);
    NSString* property2Value = [senseMetadata firmwareVersion] ?: NSLocalizedString(@"empty-data", nil);
    
    [[cell nameLabel] setText:name];
    [[cell lastSeenValueLabel] setText:lastSeen];
    if ([[self deviceService] shouldWarnAboutLastSeenForDevice:senseMetadata]) {
        UIColor* alertColor = [SenseStyle colorWithCondition:SENConditionAlert defaultColor:nil];
        [[cell lastSeenValueLabel] setTextColor:alertColor];
    }
    [[cell property1Label] setText:property1Name];
    [[cell property1ValueLabel] setText:property1Value];
    [[cell property1IconView] setImage:wiFiIcon];
    if (wiFiColor) {
        [[cell property1ValueLabel] setTextColor:wiFiColor];
    }
    [[cell property2Label] setText:property2Name];
    [[cell property2ValueLabel] setText:property2Value];
    [[cell property2InfoButton] setHidden:YES];
    [[cell actionButton] setHidden:YES];
}

- (void)updateCellForPill:(HEMDeviceCollectionViewCell*)cell {
    HEMPillCollectionViewCell* pillCell = (id)cell;
    SENPillMetadata* pillMetadata = [[[self deviceService] devices] pillMetadata];
    
    BOOL hasUpdate = [[self deviceService] isPillFirmwareUpdateAvailable];
    NSString* lastSeen = [self lastSeenFor:pillMetadata];
    NSString* name = NSLocalizedString(@"settings.device.pill", nil);
    NSString* property1Name = NSLocalizedString(@"settings.device.battery", nil);
    NSString* property1Value = nil;
    UIColor* property1ValueColor = nil;
    NSString* property2Name = NSLocalizedString(@"settings.device.color", nil);
    NSString* property2Value = [self colorStringForDevice:pillMetadata];
    NSString* firmwareName = NSLocalizedString(@"settings.device.firmware-version", nil);
    NSString* firmwareVers = [pillMetadata firmwareVersion];
    NSString* updateButtonText = nil;
    
    if (hasUpdate) {
        updateButtonText = [NSLocalizedString(@"actions.update", nil) uppercaseString];
    }
    
    switch ([pillMetadata state]) {
        case SENPillStateLowBattery:
            property1Value = NSLocalizedString(@"settings.device.battery.low", nil);
            property1ValueColor = [SenseStyle colorWithCondition:SENConditionAlert defaultColor:nil];
            break;
        case SENPillStateNormal:
            property1Value = NSLocalizedString(@"settings.device.battery.good", nil);
            break;
        case SENPillStateUnknown:
        default:
            property1Value = NSLocalizedString(@"empty-data", nil);
            break;
    }
    
    [[cell nameLabel] setText:name];
    [[cell lastSeenValueLabel] setText:lastSeen];
    if ([[self deviceService] shouldWarnAboutLastSeenForDevice:pillMetadata]) {
        UIColor* alertColor = [SenseStyle colorWithCondition:SENConditionAlert defaultColor:nil];
        [[cell lastSeenValueLabel] setTextColor:alertColor];
    }
    [[cell property1Label] setText:property1Name];
    [[cell property1ValueLabel] setText:property1Value];
    if (property1ValueColor) {
        [[cell property1ValueLabel] setTextColor:property1ValueColor];
    }
    [[cell property2Label] setText:property2Name];
    [[cell property2ValueLabel] setText:property2Value];
    [[cell property2InfoButton] setHidden:NO];
    [[cell property2InfoButton] addTarget:self
                                   action:@selector(showPillColorTutorial)
                         forControlEvents:UIControlEventTouchUpInside];
    [[pillCell firmwareLabel] setText:firmwareName];
    [[pillCell firmwareValueLabel] setText:firmwareVers];
    if (hasUpdate) {
        UIColor* alertColor = [SenseStyle colorWithCondition:SENConditionAlert defaultColor:nil];
        [[pillCell firmwareValueLabel] setTextColor:alertColor];
    }
    [[pillCell updateButton] setHidden:!hasUpdate];
    [[pillCell updateButton] setUserInteractionEnabled:hasUpdate];
    [[pillCell updateButton] addTarget:self
                                action:@selector(updateFirmware)
                      forControlEvents:UIControlEventTouchUpInside];
    [[pillCell updateButton] setTitle:updateButtonText forState:UIControlStateNormal];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isRefreshing]) {
        return;
    }
    
    switch ([indexPath section]) {
        default:
        case HEMDevicesSectionSenseAndPill: {
            return [self handleSenseOrPillSelectionAtPath:indexPath];
        }
        case HEMDevicesSectionUpgrade:
            return [self handleUpgradeCellSelectionAtIndexPath:indexPath];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

- (void)handleUpgradeCellSelectionAtIndexPath:(NSIndexPath*)path {
    [[[self collectionView] collectionViewLayout] invalidateLayout];
    [[self collectionView] performBatchUpdates:^{
        [self setUpgradeCollapsed:![self isUpgradeCollpased]];
        
        CollapsableActionCell* cell = (id) [[self collectionView] cellForItemAtIndexPath:path];
        ViewState state = [self isUpgradeCollpased] ? ViewStateCollapse : ViewStateExpand;
        [UIView animateWithDuration:0.33f animations:^{
            [cell setWithState:state];
        }];
    } completion:nil];
    
    [[self collectionView] scrollToItemAtIndexPath:path
                                  atScrollPosition:UICollectionViewScrollPositionTop
                                          animated:YES];
}

- (void)handleSenseOrPillSelectionAtPath:(NSIndexPath*)path {
    UICollectionViewCell* cell = [[self collectionView] cellForItemAtIndexPath:path];
    switch ([path row]) {
        default:
        case HEMDevicesRowSense: {
            if ([cell isKindOfClass:[HEMNoDeviceCollectionViewCell class]]) {
                [[self delegate] pairSenseFrom:self];
            } else {
                [[self delegate] showSenseSettingsFrom:self];
            }
            break;
        }
        case HEMDevicesRowPill: {
            if ([cell isKindOfClass:[HEMNoDeviceCollectionViewCell class]]) {
                [[self delegate] pairPillFrom:self];
            } else {
                [[self delegate] showPillSettingsFrom:self];
            }
            break;
        }
    }
}

#pragma mark - Actions

- (void)upgradeSense {
    // in case it was started before upgrading.  for example: user taps in to
    // sense settings, backs out, and tries to upgrade
    [[self deviceService] stopScanningForSense];
    
    NSString* currentSenseId = [[[[self deviceService] devices] senseMetadata] uniqueId];
    UIViewController* upgradeVC = [HEMUpgradeFlow rootViewControllerForFlowWithCurrentSenseId:currentSenseId];
    [[self delegate] showModalController:upgradeVC from:self];
}

- (void)showPillColorTutorial {
    [HEMTutorial showTutorialForPillColor];
}

- (void)updateFirmware {
    [[self delegate] showFirmwareUpdateFrom:self];
}

#pragma mark - Links

- (void)openInAppBrowserIfPossibleTo:(NSURL*)url {
    NSString* lowerScheme = [url scheme];
    if ([lowerScheme hasPrefix:@"http"]) {
        [[self delegate] openSupportURL:[url absoluteString] from:self];
    }
}

#pragma mark CollapsableLinkDelegate

- (void)showLinkWithUrl:(NSURL *)url from:(CollapsableActionCell *)cell {
    [self openInAppBrowserIfPossibleTo:url];
}

#pragma mark HEMTextFooterDelegate

- (void)didTapOnLink:(NSURL *)url from:(HEMTextFooterCollectionReusableView *)view {
    [self openInAppBrowserIfPossibleTo:url];
}

#pragma mark - Pairing Notifications

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

- (void)didUpdatePairing:(NSNotification*)notification {
    [self refresh];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_collectionView setDataSource:nil];
    [_collectionView setDelegate:nil];
}

@end
