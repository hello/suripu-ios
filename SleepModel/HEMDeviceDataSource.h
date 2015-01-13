//
//  HEMDeviceDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 1/7/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HEMDeviceWarning) {
    HEMDeviceWarningLongLastSeen = 1,
    HEMSenseWarningNoInternet = 2,
    HEMSenseWarningNotConnectedToSense = 3
};

@class SENDevice;

@interface HEMDeviceDataSource : NSObject <UICollectionViewDataSource>

- (void)refresh:(void(^)(NSError* error))completion;
- (NSOrderedSet*)deviceWarningsFor:(SENDevice*)device;
- (BOOL)isObtainingData;
- (BOOL)isMissingADevice;
- (SENDevice*)deviceAtIndexPath:(NSIndexPath*)indexPath;
- (SENDeviceType)deviceTypeAtIndexPath:(NSIndexPath*)indexPath;
- (void)loadDeviceInfo:(void(^)(NSError* error))completion;
- (void)updateCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;

@end