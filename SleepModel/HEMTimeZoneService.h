//
//  HEMTimeZoneService.h
//  Sense
//
//  Created by Jimmy Lu on 11/23/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"

typedef void(^HEMCurrentTimeZoneHandler)(NSTimeZone* _Nullable timeZone);
typedef void(^HEMAllTimeZoneHandler)(NSDictionary<NSString*, NSString*>* _Nonnull tzMapping, NSArray<NSString*>* _Nonnull sortedTzNames);
typedef void(^HEMUpdateTimeZoneHandler)(NSError* _Nullable error);

@interface HEMTimeZoneService : SENService

- (void)getConfiguredTimeZone:(nonnull HEMCurrentTimeZoneHandler)completion;
- (void)getTimeZones:(nonnull HEMAllTimeZoneHandler)completion;
- (void)updateToTimeZone:(nonnull NSTimeZone*)timeZone completion:(nullable HEMUpdateTimeZoneHandler)completion;

@end
