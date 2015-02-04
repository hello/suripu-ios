//
//  SENDevice.m
//  Pods
//
//  Created by Jimmy Lu on 9/19/14.
//
//

#import "SENDevice.h"

@interface SENDevice()

@property (nonatomic, copy,   readwrite) NSString* deviceId;
@property (nonatomic, assign, readwrite) SENDeviceType type;
@property (nonatomic, assign, readwrite) SENDeviceState state;
@property (nonatomic, copy,   readwrite) NSString* firmwareVersion;
@property (nonatomic, strong, readwrite) NSDate* lastSeen;

@end

@implementation SENDevice

- (instancetype)initWithDeviceId:(NSString*)deviceId
                  type:(SENDeviceType)type
                 state:(SENDeviceState)state
       firmwareVersion:(NSString*)version
              lastSeen:(NSDate*)lastSeen {
    
    self = [super init];
    if (self) {
        [self setDeviceId:deviceId];
        [self setType:type];
        [self setState:state];
        [self setFirmwareVersion:version];
        [self setLastSeen:lastSeen];
    }
    return self;
}

@end

@interface SENDeviceMetadata()

@property (nonatomic, copy, readwrite) NSString* deviceId;
@property (nonatomic, copy, readwrite) NSNumber* pairedAccounts;

@end

@implementation SENDeviceMetadata

static NSString* const SENDeviceMetadataPropSenseId = @"sense_id";
static NSString* const SENDeviceMetadataPropPairedAccounts = @"paired_accounts";

- (instancetype)initWithDictionary:(NSDictionary*)dictionary withType:(SENDeviceType)type {
    self = [super init];
    if (self) {
        if (type == SENDeviceTypeSense) {
            _deviceId = dictionary[SENDeviceMetadataPropSenseId];
        }
        _pairedAccounts = dictionary[SENDeviceMetadataPropPairedAccounts];
    }
    return self;
}

@end
