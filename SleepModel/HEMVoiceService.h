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
@class HEMVoiceCommandGroup;
@class SENSenseVoiceInfo;

NS_ASSUME_NONNULL_BEGIN

NSString* const HEMVoiceNotification;
NSString* const HEMVoiceNotificationInfoError;
NSString* const HEMVoiceNotificationInfoResult;

typedef void(^HEMVoiceFeatureHandler)(BOOL enabled);
typedef void(^HEMVoiceControlUpdateHandler)(id _Nullable response, NSError* _Nullable error);

@interface HEMVoiceService : SENService

- (void)startListeningForVoiceResult;
- (void)stopListeningForVoiceResult;
- (NSArray<HEMVoiceCommandGroup*>*)availableVoiceCommands;
- (BOOL)showVoiceIntro;
- (void)hideVoiceIntro;
- (void)resetVoiceIntro;
- (void)updateVoiceInfo:(SENSenseVoiceInfo*)voiceInfo
             forSenseId:(NSString*)senseId
             completion:(HEMVoiceControlUpdateHandler)completion;

@end

NS_ASSUME_NONNULL_END