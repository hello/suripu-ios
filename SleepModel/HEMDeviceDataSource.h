//
//  HEMDeviceDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 1/7/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEMTextFooterCollectionReusableView.h"

typedef NS_ENUM(NSUInteger, HEMDeviceWarning) {
    HEMDeviceWarningLongLastSeen = 1,
    HEMSenseWarningNoInternet = 2,
    HEMSenseWarningNotConnectedToSense = 3
};

typedef NS_ENUM(NSInteger, HEMDeviceError) {
    HEMDeviceErrorNoBle = -1,
    HEMDeviceErrorDeviceInfoNotLoaded = -2,
    HEMDeviceErrorReplacedSenseInfoNotLoaded = -3
};

@class SENDevice;

@interface HEMDeviceDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, assign, readonly, getter=isLoadingSense) BOOL loadingSense;
@property (nonatomic, assign, readonly, getter=isLoadingPill)  BOOL loadingPill;

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView
                     andFooterDelegate:(id<HEMTextFooterDelegate>)delegate;

- (void)refreshWithUpdate:(void(^)(void))update completion:(void(^)(NSError* error))completion;
- (NSOrderedSet*)deviceWarningsFor:(SENDevice*)device;
- (void)updateSenseManager:(SENSenseManager*)senseManager completion:(void(^)(NSError* error))completion;
- (SENDevice*)deviceAtIndexPath:(NSIndexPath*)indexPath;
- (SENDeviceType)deviceTypeAtIndexPath:(NSIndexPath*)indexPath;
- (void)updateCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
- (NSAttributedString*)attributedFooterText;

@end
