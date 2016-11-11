//
//  SENSleepPill.m
//  Pods
//
//  Created by Jimmy Lu on 6/29/16.
//
//
#import <CoreBluetooth/CoreBluetooth.h>
#import <LGBluetooth/LGBluetooth.h>
#import "LGPeripheral.h"

#import "SENSleepPill.h"

static unsigned char const kSENSleepPillOneFiveByte = 0x12;
static NSInteger const kSENSleepPillOneFiveHwVersionLoc = 2;

@interface SENSleepPill()

@property (nonatomic, strong) LGPeripheral* peripheral;

@end

@implementation SENSleepPill

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        [self processAdvertisementData:[peripheral advertisingData]];
    }
    return self;
}

- (void)processAdvertisementData:(NSDictionary*)data {
    NSData* manufacturerData = data[CBAdvertisementDataManufacturerDataKey];
    if ([manufacturerData length] >= kSENSleepPillOneFiveHwVersionLoc + 1) {
        const unsigned char* bytes = (const unsigned char*)[manufacturerData bytes];
        unsigned char hwByte = bytes[kSENSleepPillOneFiveHwVersionLoc];
        if (hwByte == kSENSleepPillOneFiveByte) {
            _version = SENSleepPillAdvertisedVersionOneFive;
        }
    }
}

- (NSString*)name {
    return [[self peripheral] name];
}

- (BOOL)isEqual:(id)object {
    if (!object || ![object isKindOfClass:[self class]]) return NO;
    
    SENSleepPill* other = object;
    return [other identifier] != nil
        && [[self identifier] isEqualToString:[other identifier]];
}

- (NSUInteger)hash {
    return [[[self peripheral] UUIDString] hash];
}

- (NSInteger)rssi {
    return [[self peripheral] RSSI];
}

- (NSString*)identifier {
    return [[self peripheral] UUIDString];
}

@end
