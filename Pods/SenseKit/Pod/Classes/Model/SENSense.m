//
//  SENSense.m
//  Pods
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "LGPeripheral.h"

#import "SENSense+Protected.h"

@interface SENSense()

@property (nonatomic, strong) LGPeripheral* peripheral;

@end

@implementation SENSense

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral {
    self = [super init];
    if (self) {
        [self setPeripheral:peripheral];
    }
    return self;
}

- (NSString*)name {
    return [[self peripheral] name];
}

- (NSString*)uuid {
    return [[self peripheral] UUIDString];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Sense: %@, uuid: %@", [self name], [self uuid]];
}

@end
