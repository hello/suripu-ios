//
//  SENSleepSoundRequest.h
//  Pods
//
//  Created by Jimmy Lu on 3/9/16.
//
//

#import <Foundation/Foundation.h>

@interface SENSleepSoundRequest : NSObject

@property (nonatomic, strong, readonly) NSNumber* order;

- (NSDictionary*)dictionaryValue;

@end

@interface SENSleepSoundRequestStop : SENSleepSoundRequest

@end

@interface SENSleepSoundRequestPlay : SENSleepSoundRequest

@property (nonatomic, strong, readonly) NSNumber* soundId;
@property (nonatomic, strong, readonly) NSNumber* durationId;
@property (nonatomic, strong, readonly) NSNumber* volume; // between 0 - 100

- (instancetype)initWithSoundId:(NSNumber*)soundId
                     durationId:(NSNumber*)durationId
                         volume:(NSNumber*)volume;

@end
