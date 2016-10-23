//
//  SENSenseVoiceSettings.h
//  Pods
//
//  Created by Jimmy Lu on 10/19/16.
//
//

#import <Foundation/Foundation.h>
#import "SENSerializable.h"

NS_ASSUME_NONNULL_BEGIN

@interface SENSenseVoiceSettings : NSObject <SENSerializable>

@property (nonatomic, strong, nullable) NSNumber* primaryUser;
@property (nonatomic, assign, nullable) NSNumber* muted;
@property (nonatomic, strong, nullable) NSNumber* volume;

- (NSDictionary*)dictionaryValue;
- (BOOL)isPrimaryUser;
- (BOOL)isMuted;

@end

NS_ASSUME_NONNULL_END