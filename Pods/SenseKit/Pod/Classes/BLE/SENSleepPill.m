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

@interface SENSleepPill()

@property (nonatomic, strong) LGPeripheral* peripheral;

@end

@implementation SENSleepPill

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
    }
    return self;
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
