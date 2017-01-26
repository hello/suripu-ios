//
//  HEMTimeZoneService.h
//  Sense
//
//  Created by Jimmy Lu on 11/23/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMCurrentTimeZoneHandler)(NSTimeZone* _Nullable timeZone);
typedef void(^HEMAllTimeZoneHandler)(NSDictionary<NSString*, NSString*>* tzMapping);
typedef void(^HEMUpdateTimeZoneHandler)(NSError* _Nullable error);

@interface HEMTimeZoneService : SENService

- (void)getConfiguredTimeZone:(HEMCurrentTimeZoneHandler)completion;
- (void)getTimeZones:(HEMAllTimeZoneHandler)completion;
- (void)updateToTimeZone:(NSTimeZone*)timeZone completion:(nullable HEMUpdateTimeZoneHandler)completion;
- (nullable NSString*)cityForTimeZone:(NSTimeZone*)timeZone
                          fromMapping:(NSDictionary<NSString*, NSString*>*)timeZoneMapping;
- (NSArray<NSString*>*)sortedCityNamesWithout:(NSTimeZone*)timeZone
                                                 from:(NSDictionary<NSString*, NSString*>*)timeZoneMapping
                                     matchingCityName:(NSString *_Nonnull *_Nonnull)matchingCityName;

@end

NS_ASSUME_NONNULL_END
