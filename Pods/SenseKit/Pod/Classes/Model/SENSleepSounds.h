//
//  SENSleepSounds.h
//  Pods
//
//  Created by Jimmy Lu on 3/9/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SENSleepSoundsFeatureState) {
    SENSleepSoundsFeatureStateOK = 1,
    SENSleepSoundsFeatureStateNoSounds,
    SENSleepSoundsFeatureStateFWRequired,
    SENSleepSoundsFeatureStateDisabled
};

@interface SENSleepSound : NSObject

@property (nonatomic, strong, readonly) NSNumber* identifier;
@property (nonatomic, copy, readonly) NSString* previewURL;
@property (nonatomic, copy, readonly) NSString* localizedName;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

@interface SENSleepSounds : NSObject

@property (nonatomic, strong, readonly) NSArray<SENSleepSound*>* sounds;
@property (nonatomic, assign, readonly) SENSleepSoundsFeatureState state;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
