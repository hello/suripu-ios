//
//  SENSense.h
//  Pods
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LGPeripheral;

@interface SENSense : NSObject

@property (nonatomic, copy, readonly) NSString* name;
@property (nonatomic, copy, readonly) NSString* deviceId;

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral;

@end
