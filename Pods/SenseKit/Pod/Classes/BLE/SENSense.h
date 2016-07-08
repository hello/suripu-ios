//
//  SENSense.h
//  Pods
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LGPeripheral;

typedef NS_ENUM(NSUInteger, SENSenseMode) {
    SENSenseModeUnknown = 0,
    SENSenseModeNormal = 1,
    SENSenseModePairing = 2
};

@interface SENSense : NSObject

@property (nonatomic, copy, readonly) NSString* name;
@property (nonatomic, copy, readonly) NSString* deviceId;
@property (nonatomic, assign, readonly) SENSenseMode mode;
@property (nonatomic, strong, readonly) LGPeripheral* peripheral;

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral;
- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral andDeviceId:(NSString*)deviceId;

@end
