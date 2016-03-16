//
//  SENSense+Protected.h
//  Pods
//
//  Created by Jimmy Lu on 8/25/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "SENSense.h"

@class LGPeripheral;

typedef enum {
    SENSenseCommandEnterPairMode = 0x06,
    SENSenseCommandExitPairMode = 0x07,
} SENSenseCommand;

@interface SENSense (Protected)

- (LGPeripheral*)peripheral;

@end
