//
//  SENAPIDevice+Private.h
//  Pods
//
//  Created by Jimmy Lu on 9/25/14.
//
//

#import "SENAPIDevice.h"

@class SENDevice;

@interface SENAPIDevice (Private)

+ (SENDevice*)deviceFromRawResponse:(id)rawResponse;
+ (NSArray*)devicesFromRawResponse:(id)rawResponse;

@end
