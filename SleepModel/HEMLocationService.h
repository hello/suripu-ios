//
//  HEMLocationService.h
//  Sense
//
//  Created by Jimmy Lu on 6/7/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString* const HEMLocationErrorDomain;

typedef NS_ENUM(NSInteger, HEMLocationErrorCode) {
    HEMLocationErrorCodeNone = 0,
    HEMLocationErrorCodeNotEnabled = -1,
    HEMLocationErrorCodeDenied = -2
};

typedef NS_ENUM(NSUInteger, HEMLocationAuthStatus) {
    HEMLocationAuthStatusUnknown = 1,
    HEMLocationAuthStatusNotEnabled,
    HEMLocationAuthStatusAuthorized,
    HEMLocationAuthStatusDenied
};

@interface HEMLocation : NSObject

@property (nonatomic, assign, readonly) CGFloat lat;
@property (nonatomic, assign, readonly) CGFloat lon;
@property (nonatomic, assign, readonly) CGFloat horizontalAccuracy;
@property (nonatomic, assign, readonly) CGFloat verticalAccuracy;

@end

typedef void(^HEMLocationAuthorizationHandler)(HEMLocationAuthStatus status);
typedef void(^HEMLocationHandler)(HEMLocation* _Nullable mostRecentLocation, NSError* _Nullable error);

@interface HEMLocationActivity : NSObject

@end

@interface HEMLocationService : SENService

- (HEMLocationAuthStatus)authorizationStatus;
- (void)requestPermission:(HEMLocationAuthorizationHandler)authHandler;
- (nullable HEMLocationActivity*)startLocationActivity:(HEMLocationHandler)update
                                                 error:(NSError**)error;
- (void)stopLocationActivity:(HEMLocationActivity*)activity;

@end

NS_ASSUME_NONNULL_END
