//
//  HEMExpansionService.h
//  Sense
//
//  Created by Jimmy Lu on 9/27/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SenseKit.h>

@interface HEMExpansionService : SENService

- (BOOL)isEnabledForHardware:(SENSenseHardware)hardware;

@end
