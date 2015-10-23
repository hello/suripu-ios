//
//  SENDevices.h
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//

#import <Foundation/Foundation.h>

@class SENSenseMetadata;
@class SENPillMetadata;

@interface SENPairedDevices : NSObject

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary*)dict;
- (nullable SENSenseMetadata*)senseMetadata;
- (nullable SENPillMetadata*)pillMetadata;
- (BOOL)hasPairedSense;
- (BOOL)hasPairedPill;
- (void)removePairedPill;
- (void)removePairedSense;

@end
