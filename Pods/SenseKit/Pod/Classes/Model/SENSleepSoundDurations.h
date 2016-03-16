//
//  SENSleepSoundDurations.h
//  Pods
//
//  Created by Jimmy Lu on 3/9/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SENSleepSoundDuration : NSObject

@property (nonatomic, strong, readonly) NSNumber* identifier;
@property (nonatomic, copy, readonly) NSString* localizedName;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

@interface SENSleepSoundDurations : NSObject

@property (nonatomic, strong, readonly) NSArray<SENSleepSoundDuration*>* durations;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

NS_ASSUME_NONNULL_END