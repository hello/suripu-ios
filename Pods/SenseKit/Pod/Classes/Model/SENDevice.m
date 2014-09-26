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

@end

@implementation SENDevice

- (id)initWithDeviceId:(NSString*)deviceId
                  type:(SENDeviceType)type
                 state:(SENDeviceState)state {
    self = [super init];
    if (self) {
        [self setDeviceId:deviceId];
        [self setType:type];
        [self setState:state];
    }
    return self;
}

@end
