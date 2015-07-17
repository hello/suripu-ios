//
//  HEMDeviceDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 1/7/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENDevice.h>
#import <SenseKit/SENServiceDevice.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "NSDate+HEMRelative.h"
#import "NSMutableAttributedString+HEMFormat.h"
#import "NSAttributedString+HEMUtils.h"

#import "HEMDeviceDataSource.h"
#import "HEMNoDeviceCollectionViewCell.h"
#import "HEMDeviceCollectionViewCell.h"
#import "HelloStyleKit.h"
#import "HEMActionButton.h"
#import "HEMMainStoryboard.h"
#import "HEMOnboardingUtils.h"
#import "HEMTextFooterCollectionReusableView.h"
#import "HEMCardFlowLayout.h"

static NSInteger const HEMDeviceRowSense = 0;
static NSInteger const HEMDeviceRowPill = 1;
static NSString* const HEMDeviceErrorDomain = @"is.hello.sense.app.device";
static NSString* const HEMDevicesFooterReuseIdentifier = @"footer";

@interface HEMDeviceDataSource()

@property (nonatomic, weak)   UICollectionView* collectionView;
@property (nonatomic, copy)   NSAttributedString* attributedFooterText;
@property (nonatomic, copy)   NSString* configuredSSID;
@property (nonatomic, assign) SENWiFiConnectionState wifiState;
@property (nonatomic, assign, getter=isLoadingSense) BOOL loadingSense;
@property (nonatomic, assign, getter=isLoadingPill)  BOOL loadingPill;
@property (nonatomic, assign) BOOL attemptedDataLoad;
@property (nonatomic, weak)   id<HEMTextFooterDelegate> footerDelegate;
@property (nonatomic, weak)   UIActivityIndicatorView* senseActivityIndicator;
@property (nonatomic, weak)   UIActivityIndicatorView* pillActivityIndicator;

@end

@implementation HEMDeviceDataSource

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView
                     andFooterDelegate:(id<HEMTextFooterDelegate>)delegate {
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        _footerDelegate = delegate;
        
        [self configureCollectionView];
    }
    return self;
}

- (void)configureCollectionView {
    [[self collectionView] registerClass:[HEMTextFooterCollectionReusableView class]
              forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                     withReuseIdentifier:HEMDevicesFooterReuseIdentifier];
    
    HEMCardFlowLayout* layout
        = (HEMCardFlowLayout*)[[self collectionView] collectionViewLayout];
    [layout setFooterReferenceSizeFromText:[self attributedFooterText]];
}

#pragma mark - Loading Data

- (void)refreshWithUpdate:(void(^)(void))update completion:(void(^)(NSError* error))completion {
    [self setWifiState:SENWiFiConnectionStateUnknown];
    [self setConfiguredSSID:nil];
    [self setLoadingSense:YES];
    [self setLoadingPill:YES];
    
    __weak typeof(self) weakSelf = self;
    [self refereshDeviceInfo:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf setLoadingPill:NO];
        [strongSelf setAttemptedDataLoad:YES];
        
        if (error != nil) {
            [strongSelf setLoadingSense:NO];
            if (completion) completion (error);
        } else {
            if (update) update();
            
            [strongSelf refreshSenseData:^(NSError *error) {
                [strongSelf setLoadingSense:NO];
                if (completion) completion (error);
            }];
        }
    }];
}

- (void)refereshDeviceInfo:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [[SENServiceDevice sharedService] loadDeviceInfo:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSError* deviceError = error;
        
        if (error != nil) {
            
            if ([error code] == SENServiceDeviceErrorInProgress && completion) {
                [strongSelf invokeWhenInfoIsLoaded:completion];
                return;
            } else {
                // generalize error to info not loaded so that errors can be
                // properly presented based on this
                deviceError = [NSError errorWithDomain:HEMDeviceErrorDomain
                                                  code:HEMDeviceErrorDeviceInfoNotLoaded
                                              userInfo:nil];
            }
            
        }
        
        if (completion) completion (deviceError);
    }];
}

- (void)invokeWhenInfoIsLoaded:(void(^)(NSError* error))completion {
    if ([[SENServiceDevice sharedService] isLoadingInfo]) {
        [self performSelector:@selector(invokeWhenInfoIsLoaded:)
                   withObject:completion
                   afterDelay:0.1f];
        return;
    }
    completion (nil);
}

- (void)updateSenseManager:(SENSenseManager*)senseManager completion:(void(^)(NSError* error))completion {
    [self setLoadingSense:YES];
    
    __weak typeof(self) weakSelf = self;
    SENServiceDevice* service = [SENServiceDevice sharedService];
    [service clearCache];
    [service replaceWithNewlyPairedSenseManager:senseManager completion:^(NSError *error) {
        [weakSelf setLoadingSense:NO];
        
        NSError* opError = nil;
        if (error) {
            opError = [NSError errorWithDomain:HEMDeviceErrorDomain
                                          code:HEMDeviceErrorReplacedSenseInfoNotLoaded
                                      userInfo:nil];
        }
        if (completion) completion (opError);
    }];
}

- (void)refreshSenseData:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    
    [SENSenseManager whenBleStateAvailable:^(BOOL on) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!on) {
            if (completion) completion ([NSError errorWithDomain:HEMDeviceErrorDomain
                                                            code:HEMDeviceErrorNoBle
                                                        userInfo:nil]);
            return;
        }
        
        [[SENServiceDevice sharedService] getConfiguredWiFi:^(NSString *ssid, SENWiFiConnectionState state, NSError *error) {
            if ([[error domain] isEqualToString:SENServiceDeviceErrorDomain]
                && [error code] == SENServiceDeviceErrorInProgress) {
                [strongSelf performSelector:@selector(refreshSenseData:)
                                 withObject:completion
                                 afterDelay:0.2f];
                return;
            }
            NSString* wifiSSID = [ssid length] == 0 ? nil : ssid;
            [strongSelf setConfiguredSSID:wifiSSID];
            [strongSelf setWifiState:state];
            
            [HEMOnboardingUtils saveConfiguredSSID:wifiSSID];
            
            if (completion) completion (error);
        }];
    }];
}

#pragma mark - Warnings

- (BOOL)lostInternetConnection:(SENDevice*)device {
    return [device type] == SENDeviceTypeSense
            && ([self wifiState] == SENWiFiConnectionStateNoInternet
                || [self wifiState] == SENWifiConnectionStateDisconnected);
}

- (NSOrderedSet*)deviceWarningsFor:(SENDevice*)device {
    NSMutableOrderedSet* set = [[NSMutableOrderedSet alloc] init];
    if ([device type] == SENDeviceTypePill
        && [device state] == SENDeviceStateLowBattery) {
        [set addObject:@(HEMPillWarningHasLowBattery)];
    }
    if ([[SENServiceDevice sharedService] shouldWarnAboutLastSeenForDevice:device]) {
        [set addObject:@(HEMDeviceWarningLongLastSeen)];
    }
    if ([self lostInternetConnection:device]) {
        [set addObject:@(HEMSenseWarningNoInternet)];
    }
    if ([device type] == SENDeviceTypeSense
        && (![[SENServiceDevice sharedService] pairedSenseAvailable]
         || ![[[SENServiceDevice sharedService] senseManager] isConnected])) {
        [set addObject:@(HEMSenseWarningNotConnectedToSense)];
    }
    return set;
}

#pragma mark - Convenience Methods

- (NSString*)lastSeen:(SENDevice*)device {
    NSString* desc = nil;
    if ([device lastSeen] != nil && [device state] != SENDeviceStateUnknown) {
        NSString* lastSeen = NSLocalizedString(@"settings.device.last-seen", nil);
        desc = [NSString stringWithFormat:@"%@ %@", lastSeen, [[device lastSeen] timeAgo]];
    } else {
        desc = NSLocalizedString(@"empty-data", nil);
    }
    return desc;
}

- (UIColor*)lastSeenTextColorFor:(SENDevice*)device {
    return [[SENServiceDevice sharedService] shouldWarnAboutLastSeenForDevice:device]
            ? [UIColor redColor] : [UIColor blackColor];
}

- (SENDevice*)deviceAtIndexPath:(NSIndexPath*)indexPath {
    SENServiceDevice* service = [SENServiceDevice sharedService];
    SENDevice* device = nil;
    switch ([indexPath row]) {
        case HEMDeviceRowSense:
            device = [service senseInfo];
            break;
        case HEMDeviceRowPill:
            device = [service pillInfo];
            break;
        default:
            break;
    }
    return device;
}

- (SENDeviceType)deviceTypeAtIndexPath:(NSIndexPath*)indexPath {
    return [indexPath row] == HEMDeviceRowSense ? SENDeviceTypeSense : SENDeviceTypePill;
}

- (NSString*)wifiValue {
    NSString* value = [self configuredSSID] ?: [HEMOnboardingUtils lastConfiguredSSID];
    if ([value length] == 0 && [self wifiState] == SENWifiConnectionStateDisconnected) {
        value = NSLocalizedString(@"settings.device.network.disconnected", nil);
    } else if ([value length] == 0) {
        value = NSLocalizedString(@"empty-data", nil);
    }
    return value;
}

- (UIColor*)wifiValueColor {
    UIColor* color = [UIColor blackColor];
    if ([self wifiState] == SENWifiConnectionStateDisconnected
        || [self wifiState] == SENWiFiConnectionStateNoInternet) {
        color = [UIColor redColor];
    }
    return color;
}

- (NSString*)colorStringForDevice:(SENDevice*)device {
    switch ([device color]) {
        case SENDeviceColorBlack:
            return NSLocalizedString(@"color.black", nil);
        case SENDeviceColorWhite:
            return NSLocalizedString(@"color.white", nil);
        case SENDeviceColorBlue:
            return NSLocalizedString(@"color.blue", nil);
        case SENDeviceColorRed:
            return NSLocalizedString(@"color.red", nil);
        case SENDeviceColorUnknown:
        default:
            return NSLocalizedString(@"empty-data", nil);
    }
}

#pragma mark - Cell Appearance

- (void)updateCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    if ([cell isKindOfClass:[HEMDeviceCollectionViewCell class]]) {
        [self updateDeviceInfoForCell:(HEMDeviceCollectionViewCell*)cell atIndexPath:indexPath];
    } else if ([cell isKindOfClass:[HEMNoDeviceCollectionViewCell class]]) {
        [self updateMissingDeviceForCell:(HEMNoDeviceCollectionViewCell*)cell atIndexPath:indexPath];
    }
}

- (void)updateMissingDeviceForCell:(HEMNoDeviceCollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    UIColor* actionButtonColor = [UIColor senseBlueColor];
    
    switch ([indexPath row]) {
        case HEMDeviceRowSense:
            [cell configureForSense];
            break;
        case HEMDeviceRowPill:
            [cell configureForPill];
            if ([self isLoadingSense] || ![self attemptedDataLoad]) {
                actionButtonColor = [UIColor actionButtonDisabledColor];
            }
            break;
        default:
            break;
    }
    [[cell actionButton] setUserInteractionEnabled:NO]; // let the entire cell be actionable
    [[cell actionButton] setBackgroundColor:actionButtonColor];
}

- (void)updateSenseInfo:(SENDevice*)senseInfo forCell:(HEMDeviceCollectionViewCell*)cell {
    NSString* lastSeen
        = [senseInfo lastSeen] != nil
        ? [[senseInfo lastSeen] timeAgo]
        : NSLocalizedString(@"empty-data", nil);
    
    UIColor* lastSeenColor = [self lastSeenTextColorFor:senseInfo];
    UIImage* icon = [HelloStyleKit senseIcon];
    NSString* name = NSLocalizedString(@"settings.device.sense", nil);
    NSString* property1Name = NSLocalizedString(@"settings.sense.wifi", nil);
    NSString* property1Value = [self wifiValue];
    UIColor* property1ValueColor = [self wifiValueColor];
    NSString* property2Name = NSLocalizedString(@"settings.device.firmware-version", nil);
    NSString* property2Value = [senseInfo firmwareVersion] ?: NSLocalizedString(@"empty-data", nil);
    
    [[cell iconImageView] setImage:icon];
    [[cell nameLabel] setText:name];
    [[cell lastSeenValueLabel] setText:lastSeen];
    [[cell lastSeenValueLabel] setTextColor:lastSeenColor];
    [[cell property1Label] setText:property1Name];
    [[cell property1ValueLabel] setText:property1Value];
    [[cell property1ValueLabel] setTextColor:property1ValueColor];
    [[cell property2Label] setText:property2Name];
    [[cell property2ValueLabel] setText:property2Value];
}

- (void)updatePillInfo:(SENDevice*)pillInfo forCell:(HEMDeviceCollectionViewCell*)cell {
    NSString* lastSeen
        = [pillInfo lastSeen] != nil
        ? [[pillInfo lastSeen] timeAgo]
        : NSLocalizedString(@"empty-data", nil);
    
    UIColor* lastSeenColor = [self lastSeenTextColorFor:pillInfo];
    UIImage* icon = [HelloStyleKit pillIcon];
    NSString* name = NSLocalizedString(@"settings.device.pill", nil);
    NSString* property1Name = NSLocalizedString(@"settings.device.battery", nil);
    NSString* property1Value = nil;
    UIColor* property1ValueColor =nil;
    NSString* property2Name = NSLocalizedString(@"settings.device.color", nil);
    NSString* property2Value = [self colorStringForDevice:pillInfo];
    
    if ([pillInfo state] == SENDeviceStateLowBattery) {
        property1Value = NSLocalizedString(@"settings.device.battery.low", nil);
        property1ValueColor = [UIColor redColor];
    } else if ([pillInfo state] == SENDeviceStateNormal) {
        property1Value = NSLocalizedString(@"settings.device.battery.good", nil);
    } else {
        property1Value = NSLocalizedString(@"empty-data", nil);
    }
    
    [[cell iconImageView] setImage:icon];
    [[cell nameLabel] setText:name];
    [[cell lastSeenValueLabel] setText:lastSeen];
    [[cell lastSeenValueLabel] setTextColor:lastSeenColor];
    [[cell property1Label] setText:property1Name];
    [[cell property1ValueLabel] setText:property1Value];
    [[cell property1ValueLabel] setTextColor:property1ValueColor];
    [[cell property2Label] setText:property2Name];
    [[cell property2ValueLabel] setText:property2Value];
}

- (void)updateDeviceInfoForCell:(HEMDeviceCollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    SENDevice* device = [self deviceAtIndexPath:indexPath];
    SENDeviceType type = [self deviceTypeAtIndexPath:indexPath]; // device may be nil
    BOOL loading = NO;
    
    if (type == SENDeviceTypeSense) {
        [self updateSenseInfo:device forCell:cell];
        loading = [self isLoadingSense];
    } else if (type == SENDeviceTypePill) {
        [self updatePillInfo:device forCell:cell];
        loading = [self isLoadingPill];
    }
    
    [cell showDataLoadingIndicator:loading || ![self attemptedDataLoad]];
}

- (NSAttributedString*)attributedFooterText {
    
    if (_attributedFooterText == nil) {
        NSString* textFormat = NSLocalizedString(@"settings.device.footer.format", nil);
        NSString* secondPill = NSLocalizedString(@"settings.device.footer.second-pill", nil);
        NSString* helpBaseUrl = NSLocalizedString(@"help.url.support", nil);
        NSString* secondPillSlug = NSLocalizedString(@"help.url.slug.pill-setup-another", nil);
        NSString* url = [helpBaseUrl stringByAppendingPathComponent:secondPillSlug];
        UIColor* color = [UIColor backViewTextColor];
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 2; // always 1 sense and 1 pill, even if we are trying to pair one
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SENDevice* device = [self deviceAtIndexPath:indexPath];
    NSString* reuseId
        = [[SENServiceDevice sharedService] isInfoLoaded] && device == nil
        ? [HEMMainStoryboard pairReuseIdentifier]
        : [HEMMainStoryboard deviceReuseIdentifier];
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                                           forIndexPath:indexPath];
    
    // if the cell does not respond to this selector, then that means the collection view
    // also will never call the delegate's willDisplayCell:atIndexPath, which means we
    // need to do it here.
    if (![cell respondsToSelector:@selector(preferredLayoutAttributesFittingAttributes:)]) {
        [self updateCell:cell atIndexPath:indexPath];
    }
    
    return cell;
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
        
        [footer setText:[self attributedFooterText]];
        [footer setDelegate:[self footerDelegate]];
        
        view = footer;
    }
    return view;
}

- (void)dealloc {
    [SENSenseManager stopScan];
}

@end
