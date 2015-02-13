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
#import "NSDate+HEMRelative.h"

#import "HEMDeviceDataSource.h"
#import "HEMNoDeviceCollectionViewCell.h"
#import "HEMDeviceCollectionViewCell.h"
#import "HelloStyleKit.h"
#import "HEMActionButton.h"
#import "HEMMainStoryboard.h"
#import "HEMOnboardingUtils.h"

static NSInteger const HEMDeviceRowSense = 0;
static NSInteger const HEMDeviceRowPill = 1;
static NSString* const HEMDeviceErrorDomain = @"is.hello.sense.app.device";

@interface HEMDeviceDataSource()

@property (nonatomic, copy)   NSString* configuredSSID;
@property (nonatomic, assign) SENWiFiConnectionState wifiState;
@property (nonatomic, assign, getter=isObtainingData) BOOL obtainingData;
@property (nonatomic, assign) BOOL attemptedDataLoad;

@end

@implementation HEMDeviceDataSource

#pragma mark - Loading Data

- (void)refresh:(void(^)(NSError* error))completion {
    [self setWifiState:SENWiFiConnectionStateUnknown];
    [self setConfiguredSSID:nil];
    [self setObtainingData:NO];
    [self setAttemptedDataLoad:NO];
    
    [[SENServiceDevice sharedService] clearCache];
    
    [self loadDeviceInfo:completion];
}

- (void)loadDeviceInfo:(void(^)(NSError* error))completion {
    [self setObtainingData:YES];
    __weak typeof(self) weakSelf = self;
    [[SENServiceDevice sharedService] loadDeviceInfo:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error != nil) {
            if ([error code] == SENServiceDeviceErrorInProgress && completion) {
                [strongSelf invokeWhenInfoIsLoaded:completion];
            } else if (completion) {
                [strongSelf setObtainingData:NO];
                [strongSelf setAttemptedDataLoad:YES];
                completion ([NSError errorWithDomain:HEMDeviceErrorDomain
                                                code:HEMDeviceErrorDeviceInfoNotLoaded
                                            userInfo:nil]);
            }

            return;
        }
        
        [strongSelf refreshSenseData:completion];
    }];
}

- (void)invokeWhenInfoIsLoaded:(void(^)(NSError* error))completion {
    if ([[SENServiceDevice sharedService] isLoadingInfo]) {
        [self performSelector:@selector(invokeWhenInfoIsLoaded:)
                   withObject:completion
                   afterDelay:0.1f];
        return;
    }
    
    [self refreshSenseData:completion];
}

- (void)updateSenseManager:(SENSenseManager*)senseManager completion:(void(^)(NSError* error))completion {
    SENServiceDevice* service = [SENServiceDevice sharedService];
    [service replaceWithNewlyPairedSenseManager:senseManager completion:completion];
}

- (void)refreshSenseData:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    
    [SENSenseManager whenBleStateAvailable:^(BOOL on) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!on) {
            [strongSelf setObtainingData:NO];
            [strongSelf setAttemptedDataLoad:YES];
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
            [strongSelf setObtainingData:NO];
            [strongSelf setAttemptedDataLoad:YES];
            
            [HEMOnboardingUtils saveConfiguredSSID:wifiSSID];
            
            if (completion) completion (error);
        }];
    }];
}

#pragma mark - Warnings

- (BOOL)hasBeenAwhile:(SENDevice*)device {
    NSDate* badThresholdDate = [[NSDate date] previousDay];
    return [[device lastSeen] compare:badThresholdDate] == NSOrderedAscending;
}

- (BOOL)lostInternetConnection:(SENDevice*)device {
    return [device type] == SENDeviceTypeSense
            && ([self wifiState] == SENWiFiConnectionStateNoInternet
                || [self wifiState] == SENWifiConnectionStateDisconnected);
}

- (NSOrderedSet*)deviceWarningsFor:(SENDevice*)device {
    NSMutableOrderedSet* set = [[NSMutableOrderedSet alloc] init];
    if ([self hasBeenAwhile:device]) {
        [set addObject:@(HEMDeviceWarningLongLastSeen)];
    }
    if ([self lostInternetConnection:device]) {
        [set addObject:@(HEMSenseWarningNoInternet)];
    }
    if (![[SENServiceDevice sharedService] pairedSenseAvailable]
        && [device type] == SENDeviceTypeSense) {
        [set addObject:@(HEMSenseWarningNotConnectedToSense)];
    }
    return set;
}

#pragma mark - Convenience Methods

- (BOOL)isMissingADevice {
    SENServiceDevice* service = [SENServiceDevice sharedService];
    return ([service senseInfo] == nil || [service pillInfo] == nil) && [service isInfoLoaded];
}

- (NSString*)lastSeen:(SENDevice*)device {
    NSString* desc = nil;
    if ([device lastSeen] != nil) {
        NSString* lastSeen = NSLocalizedString(@"settings.device.last-seen", nil);
        desc = [NSString stringWithFormat:@"%@ %@", lastSeen, [[device lastSeen] timeAgo]];
    } else {
        desc = NSLocalizedString(@"settings.device.never-seen", nil);
    }
    return desc;
}

- (UIColor*)lastSeenTextColorFor:(SENDevice*)device {
    return [self hasBeenAwhile:device] ? [UIColor redColor] : [UIColor blackColor];
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
    UIImage* icon = nil;
    NSString* name = nil;
    NSString* message = nil;
    NSString* buttonTitle = nil;
    
    switch ([indexPath row]) {
        case HEMDeviceRowSense:
            icon = [HelloStyleKit senseIcon];
            name = NSLocalizedString(@"settings.device.sense", nil);
            message = NSLocalizedString(@"settings.device.no-sense", nil);
            buttonTitle = NSLocalizedString(@"settings.device.button.title.pair-sense", nil);
            break;
        case HEMDeviceRowPill:
            icon = [HelloStyleKit pillIcon];
            name = NSLocalizedString(@"settings.device.pill", nil);
            message = NSLocalizedString(@"settings.device.no-pill", nil);
            buttonTitle = NSLocalizedString(@"settings.device.button.title.pair-pill", nil);
            break;
        default:
            break;
    }
    
    [[cell iconImageView] setImage:icon];
    [[cell nameLabel] setText:name];
    [[cell messageLabel] setText:message];
    [[cell actionButton] setTitle:buttonTitle forState:UIControlStateNormal];
    [[cell actionButton] setUserInteractionEnabled:NO]; // let the entire cell be actionable
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
    
    if (type == SENDeviceTypeSense) {
        [self updateSenseInfo:device forCell:cell];
    } else if (type == SENDeviceTypePill) {
        [self updatePillInfo:device forCell:cell];
    }
    
    [cell showDataLoadingIndicator:[self isObtainingData] || ![self attemptedDataLoad]];
}

#pragma mark - UICollectionViewDataSource

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

@end
