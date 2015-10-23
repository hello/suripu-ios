//
//  HEMDeviceDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 1/7/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEMTextFooterCollectionReusableView.h"

extern NSString* const HEMDeviceErrorDomain;
extern NSInteger const HEMDeviceRowSense;
extern NSInteger const HEMDeviceRowPill;

typedef NS_ENUM(NSInteger, HEMDeviceError) {
    HEMDeviceErrorNoBle = -1,
    HEMDeviceErrorDeviceInfoNotLoaded = -2,
    HEMDeviceErrorReplacedSenseInfoNotLoaded = -3
};

@class SENDeviceMetadata;

@interface HEMDeviceDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, assign, readonly, getter=isRefreshing) BOOL refreshing;

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView
                     andFooterDelegate:(id<HEMTextFooterDelegate>)delegate;

- (void)refresh:(void(^)(NSError* error))completion;
- (SENDeviceMetadata*)deviceAtIndexPath:(NSIndexPath*)indexPath;
- (void)updateCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
- (NSAttributedString*)attributedFooterText;
- (BOOL)canPairPill;

@end
