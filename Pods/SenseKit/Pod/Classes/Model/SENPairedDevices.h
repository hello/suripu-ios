//
//  SENDevices.h
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//

#import <Foundation/Foundation.h>
#import "SENSerializable.h"

@class SENSenseMetadata;
@class SENPillMetadata;

@interface SENPairedDevices : NSObject <SENSerializable>

- (nullable SENSenseMetadata*)senseMetadata;
- (nullable SENPillMetadata*)pillMetadata;
- (BOOL)hasPairedSense;
- (BOOL)hasPairedPill;
- (void)removePairedPill;
- (void)removePairedSense;

@end
