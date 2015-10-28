//
//  HEMDeviceDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 1/7/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENPillMetadata.h>

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
#import "HEMTextFooterCollectionReusableView.h"
#import "HEMOnboardingService.h"

NSString* const HEMDeviceErrorDomain = @"is.hello.sense.app.device";
NSInteger const HEMDeviceRowSense = 0;
NSInteger const HEMDeviceRowPill = 1;

static NSString* const HEMDevicesFooterReuseIdentifier = @"footer";

@interface HEMDeviceDataSource()

@property (nonatomic, weak)   UICollectionView* collectionView;
@property (nonatomic, copy)   NSAttributedString* attributedFooterText;

@property (nonatomic, assign) BOOL attemptedDataLoad;
@property (nonatomic, weak)   id<HEMTextFooterDelegate> footerDelegate;
@property (nonatomic, weak)   UIActivityIndicatorView* senseActivityIndicator;
@property (nonatomic, weak)   UIActivityIndicatorView* pillActivityIndicator;

@property (nonatomic, strong) SENPairedDevices* pairedDevices;
@property (nonatomic, assign, getter=isRefreshing) BOOL refreshing;

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
    
    UICollectionViewFlowLayout* layout = (id)[[self collectionView] collectionViewLayout];
    UIEdgeInsets insets = [layout sectionInset];
    CGSize size = [[self attributedFooterText] sizeWithWidth:layout.itemSize.width];
    size.height += insets.top + insets.bottom;
    layout.footerReferenceSize = size;
}

#pragma mark - Loading Data

- (void)refresh:(void(^)(NSError* error))completion {
    [self setRefreshing:YES];
    
    __weak typeof(self) weakSelf = self;
    [[SENServiceDevice sharedService] loadDeviceInfo:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf setAttemptedDataLoad:YES];
        
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
    
        [strongSelf setRefreshing:NO];
        
        if (completion) {
            completion (deviceError);
        }
    }];
}

- (void)invokeWhenInfoIsLoaded:(void(^)(NSError* error))completion {
    if ([[SENServiceDevice sharedService] isLoadingInfo]) {
        [self performSelector:@selector(invokeWhenInfoIsLoaded:)
                   withObject:completion
                   afterDelay:0.1f];
        return;
    }
    
    [self setRefreshing:NO];
    completion (nil);
}

- (BOOL)canPairPill {
    return [[[SENServiceDevice sharedService] devices] hasPairedSense];
}

#pragma mark - Convenience Methods

- (NSString*)lastSeen:(SENDeviceMetadata*)deviceMetadata {
    NSDate* lastSeenDate = [deviceMetadata lastSeenDate];
    NSString* desc = nil;
    
    if (lastSeenDate != nil) {
        NSString* lastSeen = NSLocalizedString(@"settings.device.last-seen", nil);
        desc = [NSString stringWithFormat:@"%@ %@", lastSeen, [lastSeenDate timeAgo]];
    } else {
        desc = NSLocalizedString(@"empty-data", nil);
    }
    
    return desc;
}

- (UIColor*)lastSeenTextColorFor:(SENDeviceMetadata*)deviceMetadata {
    SENServiceDevice* service = [SENServiceDevice sharedService];
    return [service shouldWarnAboutLastSeenForDevice:deviceMetadata]
         ? [UIColor redColor]
         : [UIColor blackColor];
}

- (SENDeviceMetadata*)deviceAtIndexPath:(NSIndexPath*)indexPath {
    SENServiceDevice* service = [SENServiceDevice sharedService];
    SENDeviceMetadata* deviceMetadata = nil;
    switch ([indexPath row]) {
        case HEMDeviceRowSense:
            deviceMetadata = [[service devices] senseMetadata];
            break;
        case HEMDeviceRowPill:
            deviceMetadata = [[service devices] pillMetadata];
            break;
        default:
            break;
    }
    return deviceMetadata;
}

- (NSString*)wifiValue {
    SENServiceDevice* service = [SENServiceDevice sharedService];
    SENSenseMetadata* senseMetadata = [[service devices] senseMetadata];
    NSString* ssid = [[senseMetadata wiFi] ssid];
    return ssid ?: NSLocalizedString(@"empty-data", nil);
}

- (UIColor*)wifiValueColor {
    SENServiceDevice* service = [SENServiceDevice sharedService];
    SENSenseMetadata* senseMetadata = [[service devices] senseMetadata];
    SENWiFiCondition condition = [[senseMetadata wiFi] condition];
    
    switch (condition) {
        case SENWiFiConditionNone:
            return [UIColor redColor];
        case SENWiFiConditionBad:
            return [UIColor orangeColor];
        case SENWiFiConditionFair:
        case SENWiFiConditionGood:
        default:
            return [UIColor blackColor];
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

#pragma mark - Cell Appearance

- (void)updateCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    if ([cell isKindOfClass:[HEMDeviceCollectionViewCell class]]) {
        [self updateDeviceInfoForCell:(HEMDeviceCollectionViewCell*)cell atIndexPath:indexPath];
    } else if ([cell isKindOfClass:[HEMNoDeviceCollectionViewCell class]]) {
        [self updateMissingDeviceForCell:(HEMNoDeviceCollectionViewCell*)cell atIndexPath:indexPath];
    }
}

- (void)updateMissingDeviceForCell:(HEMNoDeviceCollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    switch ([indexPath row]) {
        case HEMDeviceRowSense:
            [cell configureForSense];
            break;
        case HEMDeviceRowPill: {
            [cell configureForPill:[self canPairPill]];
            break;
        }
        default:
            break;
    }
}

- (void)updateSenseInfo:(SENSenseMetadata*)senseMetadata forCell:(HEMDeviceCollectionViewCell*)cell {
    NSString* lastSeen
        = [senseMetadata lastSeenDate] != nil
        ? [[senseMetadata lastSeenDate] timeAgo]
        : NSLocalizedString(@"empty-data", nil);
    
    UIColor* lastSeenColor = [self lastSeenTextColorFor:senseMetadata];
    UIImage* icon = [HelloStyleKit senseIcon];
    NSString* name = NSLocalizedString(@"settings.device.sense", nil);
    NSString* property1Name = NSLocalizedString(@"settings.sense.wifi", nil);
    NSString* property1Value = [self wifiValue];
    UIColor* property1ValueColor = [self wifiValueColor];
    NSString* property2Name = NSLocalizedString(@"settings.device.firmware-version", nil);
    NSString* property2Value = [senseMetadata firmwareVersion] ?: NSLocalizedString(@"empty-data", nil);
    
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

- (void)updatePillInfo:(SENPillMetadata*)pillMetadata forCell:(HEMDeviceCollectionViewCell*)cell {
    NSString* lastSeen
        = [pillMetadata lastSeenDate] != nil
        ? [[pillMetadata lastSeenDate] timeAgo]
        : NSLocalizedString(@"empty-data", nil);
    
    UIColor* lastSeenColor = [self lastSeenTextColorFor:pillMetadata];
    UIImage* icon = [HelloStyleKit pillIcon];
    NSString* name = NSLocalizedString(@"settings.device.pill", nil);
    NSString* property1Name = NSLocalizedString(@"settings.device.battery", nil);
    NSString* property1Value = nil;
    UIColor* property1ValueColor =nil;
    NSString* property2Name = NSLocalizedString(@"settings.device.color", nil);
    NSString* property2Value = [self colorStringForDevice:pillMetadata];
    
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
    SENDeviceMetadata* deviceMetadata = [self deviceAtIndexPath:indexPath];
    if ([deviceMetadata isKindOfClass:[SENSenseMetadata class]]) {
        [self updateSenseInfo:(id)deviceMetadata forCell:cell];
    } else if ([deviceMetadata isKindOfClass:[SENPillMetadata class]]) {
        [self updatePillInfo:(id)deviceMetadata forCell:cell];
    }
    [cell showDataLoadingIndicator:[self isRefreshing] || ![self attemptedDataLoad]];
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
    SENServiceDevice* service = [SENServiceDevice sharedService];
    return [service isInfoLoaded] ? 2 : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SENDeviceMetadata* deviceMetadata = [self deviceAtIndexPath:indexPath];
    NSString* reuseId
        = [[SENServiceDevice sharedService] isInfoLoaded] && deviceMetadata == nil
        ? [HEMMainStoryboard pairReuseIdentifier]
        : [HEMMainStoryboard deviceReuseIdentifier];
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
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
        
        NSInteger numberOfItems = [collectionView numberOfItemsInSection:0];
        if (numberOfItems > 0) {
            [footer setText:[self attributedFooterText]];
        } else {
            [footer setText:nil];
        }
        
        [footer setDelegate:[self footerDelegate]];
        
        view = footer;
    }
    return view;
}

- (void)dealloc {
    [SENSenseManager stopScan];
}

@end
