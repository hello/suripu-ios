//
//  SENDevice.h
//  Pods
//
//  This is a wrapper around the Device Resource for the API.
//
//  Created by Jimmy Lu on 9/19/14.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SENDeviceType) {
    SENDeviceTypePill = 0,
    SENDeviceTypeSense = 1
};

typedef NS_ENUM(NSUInteger, SENDeviceState) {
    SENDeviceStateNormal = 0,
    SENDeviceStateLowBattery = 1,
    SENDeviceStateFirmwareUpdate = 2,
    SENDeviceStateUnknown = 3
};

@interface SENDevice : NSObject

/*
 * @property deviceId: the id provided by the device itself
 */
@property (nonatomic, copy,   readonly) NSString* deviceId;

/**
 * @property type: the type of device
 */
@property (nonatomic, assign, readonly) SENDeviceType type;

/**
 * @property state: the current "primary" state the device is in
 */
@property (nonatomic, assign, readonly) SENDeviceState state;

/**
 * @property firmwareVersion: specifies the current firmware version of the device
 */
@property (nonatomic, copy, readonly)   NSString* firmwareVersion;

/**
 * @property lastSeen: specifies date in which the device last "phoned home"
 */
@property (nonatomic, strong, readonly) NSDate* lastSeen;

/**
 * Initialize with the name, uuid, type, and state of the device
 * @param deviceId: @see @property deviceId
 * @param type:     @see @property type
 * @param state:    @see @property state
 * @param version:  @see @property version
 * @param lastSeen: @see @property lastSeen
 */
- (id)initWithDeviceId:(NSString*)deviceId
                  type:(SENDeviceType)type
                 state:(SENDeviceState)state
       firmwareVersion:(NSString*)version
              lastSeen:(NSDate*)lastSeen;

@end
