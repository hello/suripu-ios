//
//  HEMVoiceService.h
//  Sense
//
//  Created by Jimmy Lu on 7/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SenseKit/SENService.h>

@class SENSpeechResult;
@class HEMVoiceCommand;

NS_ASSUME_NONNULL_BEGIN

NSString* const HEMVoiceNotification;
NSString* const HEMVoiceNotificationInfoError;
NSString* const HEMVoiceNotificationInfoResult;

typedef void(^HEMVoiceFeatureHandler)(BOOL enabled);

@interface HEMVoiceService : SENService

@property (nonatomic, assign, readonly, getter=isVoiceEnabled) BOOL voiceEnabled;

- (void)startListeningForVoiceResult;
- (void)stopListeningForVoiceResult;
- (void)updateVoiceAvailability:(nullable HEMVoiceFeatureHandler)completion;
- (NSArray<HEMVoiceCommand*>*)availableVoiceCommands;

@end

NS_ASSUME_NONNULL_END