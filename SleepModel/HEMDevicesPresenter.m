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
#import "HEMMainStoryboard.h"
#import "HEMTutorial.h"
#import "HEMPillCollectionViewCell.h"
#import "HEMActionButton.h"
#import "HEMUpgradeFlow.h"
#import "HEMUpgradeSensePresenter.h"
#import "HEMHaveSenseViewController.h"
#import "HEMOnboardingStoryboard.h"

static NSString* const HEMDevicesFooterReuseIdentifier = @"footer";
static CGFloat const HEMDeviceSectionMargin = 15.0f;
static CGFloat const HEMNoDeviceHeight = 203.0f;

typedef NS_ENUM(NSInteger, HEMDevicesRow) {
    HEMDevicesRowSense = 0,
    HEMDevicesRowPill,
    HEMDevicesRowCount
};

@interface HEMDevicesPresenter() <
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    HEMTextFooterDelegate
>

@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, assign, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, assign) BOOL attemptedDataLoad;
@property (nonatomic, strong) NSAttributedString* attributedFooterText;

@end

@implementation HEMDevicesPresenter

- (instancetype)initWithDeviceService:(HEMDeviceService*)deviceService {
    self = [super init];
    if (self) {
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
    
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [collectionView setAlwaysBounceVertical:YES];
    [collectionView setBackgroundColor:[UIColor backgroundColor]];
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
        UIColor* color = [UIColor textColor];
        UIFont* font = [UIFont settingsHelpFont];
        
        NSAttributedString* attrPill = [[NSAttributedString alloc] initWithString:secondPill];
        NSArray* args = @[[attrPill hyperlink:url]];
        NSMutableAttributedString* attributedText =
            [[NSMutableAttributedString alloc] initWithFormat:textFormat
                                                         args:args
                                                    baseColor:color
                                                     baseFont:font];
        NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentCenter];
        [attributedText addAttribute:NSParagraphStyleAttributeName
                               value:style
                               range:NSMakeRange(0, [attributedText length])];
        
        _attributedFooterText = [attributedText copy];
    }
    
    return _attributedFooterText;
}

- (BOOL)hasDeviceAtIndexPath:(NSIndexPath*)indexPath {
    SENPairedDevices* devices = [[self deviceService] devices];
    switch ([indexPath row]) {
        default:
        case HEMDevicesRowSense:
            return [devices hasPairedSense];
        case HEMDevicesRowPill:
            return [devices hasPairedPill];
    }
}

- (UIColor*)lastSeenTextColorFor:(SENDeviceMetadata*)deviceMetadata {
    return [[self deviceService] shouldWarnAboutLastSeenForDevice:deviceMetadata] ? [UIColor redColor] : [UIColor grey6];
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
            *color = [UIColor redColor];
            break;
        case SENWiFiConditionBad:
            *icon = [UIImage imageNamed:@"wifiIconLow"];
            *color = [UIColor orangeColor];
            break;
        case SENWiFiConditionFair:
            *icon = [UIImage imageNamed:@"wifiIconMedium"];
            *color = [UIColor grey6];
            break;
        case SENWiFiConditionGood:
            *icon = [UIImage imageNamed:@"wifiIconHigh"];
            *color = [UIColor grey6];
            break;
    }
}

- (BOOL)hasPillFirmwareUpdate {
    SENPillMetadata* pillMetadata = [[[self deviceService] devices] pillMetadata];
    return [pillMetadata firmwareUpdateUrl] != nil
        && ![[self deviceService] shouldSuppressPillFirmwareUpdate];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    // always show an option for Sense
    return [[self deviceService] shouldShowPillInfo] ? HEMDevicesRowCount : 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    BOOL hasDevice = [self hasDeviceAtIndexPath:indexPath];
    NSString* reuseId = nil;
    
    if (!hasDevice && [self attemptedDataLoad]) {
        reuseId = [HEMMainStoryboard pairReuseIdentifier];
    } else if ([indexPath row] == HEMDevicesRowPill) {
        reuseId = [HEMMainStoryboard pillReuseIdentifier];
    } else {
        reuseId = [HEMMainStoryboard senseReuseIdentifier];
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                     forIndexPath:indexPath];
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView
          viewForSupplementaryElementOfKind:(NSString*)kind
                                atIndexPath:(NSIndexPath*)indexPath {
    
    UICollectionReusableView* view = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        HEMTextFooterCollectionReusableView* footer
        = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                             withReuseIdentifier:HEMDevicesFooterReuseIdentifier
                                                    forIndexPath:indexPath];

        if ([[[self deviceService] devices] hasPairedSense]) {
            [footer setText:[self attributedFooterText]];
        } else {
            [footer setText:nil];
        }
        
        [footer setDelegate:self];
        
        view = footer;
    }
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section {
    
    CGFloat maxWidth = CGRectGetWidth([collectionView bounds]) - (HEMDeviceSectionMargin * 2);
    CGFloat textHeight = [[self attributedFooterText] sizeWithWidth:maxWidth].height;
    
    CGSize size = CGSizeZero;
    size.width = maxWidth;
    size.height = textHeight + (HEMDeviceSectionMargin * 2);
    
    return size;
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewFlowLayout *)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL hasDevice = [self hasDeviceAtIndexPath:indexPath];
    
    CGSize size = [layout itemSize];
    size.width = CGRectGetWidth([[collectionView superview] bounds]);
    
    if (hasDevice) {
        if ([indexPath row] == HEMDevicesRowPill) {
            BOOL hasUpdate = [self hasPillFirmwareUpdate];
            size.height = [HEMPillCollectionViewCell heightWithFirmwareUpdate:hasUpdate];
        } else { // is sense
            BOOL hasUpgrade = [[self deviceService] hasHardwareUpgradeForSense];
            size.height = [HEMDeviceCollectionViewCell heightOfCellActionButton:hasUpgrade];
        }
    } else {
        size.height = HEMNoDeviceHeight;
    }
    
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HEMDeviceCollectionViewCell class]]) {
        HEMDeviceCollectionViewCell* deviceCell = (id)cell;
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
    }
}

- (void)updateCellForSense:(HEMDeviceCollectionViewCell*)cell {
    SENSenseMetadata* senseMetadata = [[[self deviceService] devices] senseMetadata];
    
    UIImage* wiFiIcon = nil;
    UIColor* wiFiColor = nil;
    [self wiFiColor:&wiFiColor icon:&wiFiIcon];
    
    BOOL hasUpgrade = [[self deviceService] hasHardwareUpgradeForSense];
    NSString* lastSeen = [self lastSeenFor:senseMetadata];
    UIColor* lastSeenColor = [self lastSeenTextColorFor:senseMetadata];
    NSString* name = NSLocalizedString(@"settings.device.sense", nil);
    NSString* property1Name = NSLocalizedString(@"settings.sense.wifi", nil);
    NSString* property1Value = [self senseConnectedSSID];
    UIColor* property1ValueColor = wiFiColor;
    NSString* property2Name = NSLocalizedString(@"settings.device.firmware-version", nil);
    NSString* property2Value = [senseMetadata firmwareVersion] ?: NSLocalizedString(@"empty-data", nil);
    NSString* actionButtonText = hasUpgrade ? [NSLocalizedString(@"upgrade.button.title", nil) uppercaseString] : nil;
    
    [[cell nameLabel] setText:name];
    [[cell lastSeenValueLabel] setText:lastSeen];
    [[cell lastSeenValueLabel] setTextColor:lastSeenColor];
    [[cell property1Label] setText:property1Name];
    [[cell property1ValueLabel] setText:property1Value];
    [[cell property1IconView] setImage:wiFiIcon];
    [[cell property1ValueLabel] setTextColor:property1ValueColor];
    [[cell property2Label] setText:property2Name];
    [[cell property2ValueLabel] setText:property2Value];
    [[cell property2InfoButton] setHidden:YES];
    [[cell actionButton] setHidden:!hasUpgrade];
    [[cell actionButton] setTitle:actionButtonText forState:UIControlStateNormal];
    [[cell actionButton] addTarget:self
                            action:@selector(upgradeSense)
                  forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateCellForPill:(HEMDeviceCollectionViewCell*)cell {
    HEMPillCollectionViewCell* pillCell = (id)cell;
    SENPillMetadata* pillMetadata = [[[self deviceService] devices] pillMetadata];
    
    BOOL hasUpdate = [self hasPillFirmwareUpdate];
    NSString* lastSeen = [self lastSeenFor:pillMetadata];
    UIColor* lastSeenColor = [self lastSeenTextColorFor:pillMetadata];
    NSString* name = NSLocalizedString(@"settings.device.pill", nil);
    NSString* property1Name = NSLocalizedString(@"settings.device.battery", nil);
    NSString* property1Value = nil;
    UIColor* property1ValueColor =nil;
    NSString* property2Name = NSLocalizedString(@"settings.device.color", nil);
    NSString* property2Value = [self colorStringForDevice:pillMetadata];
    NSString* firmwareName = NSLocalizedString(@"settings.device.firmware-version", nil);
    NSString* firmwareVers = [pillMetadata firmwareVersion];
    UIColor* firmwareColor = hasUpdate ? [UIColor redColor] : [UIColor grey6];
    NSString* updateButtonText = nil;
    
    if (hasUpdate) {
        updateButtonText = [NSLocalizedString(@"actions.update", nil) uppercaseString];
    }
    
    switch ([pillMetadata state]) {
        case SENPillStateLowBattery:
            property1Value = NSLocalizedString(@"settings.device.battery.low", nil);
            property1ValueColor = [UIColor redColor];
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
    [[cell lastSeenValueLabel] setTextColor:lastSeenColor];
    [[cell property1Label] setText:property1Name];
    [[cell property1ValueLabel] setText:property1Value];
    [[cell property1ValueLabel] setTextColor:property1ValueColor];
    [[cell property2Label] setText:property2Name];
    [[cell property2ValueLabel] setText:property2Value];
    [[cell property2InfoButton] setHidden:NO];
    [[cell property2InfoButton] addTarget:self
                                   action:@selector(showPillColorTutorial)
                         forControlEvents:UIControlEventTouchUpInside];
    [[pillCell firmwareLabel] setText:firmwareName];
    [[pillCell firmwareValueLabel] setText:firmwareVers];
    [[pillCell firmwareValueLabel] setTextColor:firmwareColor];
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
    
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    switch ([indexPath row]) {
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Actions

- (void)upgradeSense {
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

#pragma mark - HEMTextFooterDelegate

- (void)didTapOnLink:(NSURL *)url from:(HEMTextFooterCollectionReusableView *)view {
    NSString* lowerScheme = [url scheme];
    if ([lowerScheme hasPrefix:@"http"]) {
        [[self delegate] openSupportURL:[url absoluteString] from:self];
    }
}

#pragma mark - Pairing Notifications

// TODO: try and remove this completely and use presenter events + service
// to handle updates as needed
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
