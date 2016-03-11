//
//  SENSleepSounds.h
//  Pods
//
//  Created by Jimmy Lu on 3/9/16.
//
//

#import <Foundation/Foundation.h>

@interface SENSleepSound : NSObject

@property (nonatomic, strong, readonly) NSNumber* identifier;
@property (nonatomic, copy, readonly) NSString* previewURL;
@property (nonatomic, copy, readonly) NSString* localizedName;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

@interface SENSleepSounds : NSObject

@property (nonatomic, strong, readonly) NSArray<SENSleepSound*>* sounds;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
