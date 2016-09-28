//
//  HEMExpansionService.m
//  Sense
//
//  Created by Jimmy Lu on 9/27/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENSenseMetadata.h>

#import "HEMExpansionService.h"

@implementation HEMExpansionService

- (BOOL)isEnabledForHardware:(SENSenseHardware)hardware {
    return hardware == SENSenseHardwareVoice;
}

@end
