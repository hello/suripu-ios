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

@property (nonatomic, assign, getter=isPrimaryUser) BOOL primaryUser;
@property (nonatomic, assign, getter=isMuted) BOOL muted;
@property (nonatomic, strong, nullable) NSNumber* volume;

- (NSDictionary*)dictionaryValue;

@end

NS_ASSUME_NONNULL_END