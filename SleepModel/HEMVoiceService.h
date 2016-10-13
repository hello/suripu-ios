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

- (void)startListeningForVoiceResult;
- (void)stopListeningForVoiceResult;
- (NSArray<HEMVoiceCommand*>*)availableVoiceCommands;
- (BOOL)showVoiceIntro;
- (void)hideVoiceIntro;
- (void)resetVoiceIntro;

@end

NS_ASSUME_NONNULL_END