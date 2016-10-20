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
@class SENSenseVoiceSettings;

NS_ASSUME_NONNULL_BEGIN

extern NSString* const HEMVoiceNotification;
extern NSString* const HEMVoiceNotificationInfoError;
extern NSString* const HEMVoiceNotificationInfoResult;
extern NSInteger const HEMVoiceServiceMaxVolumeLevel;

typedef void(^HEMVoiceFeatureHandler)(BOOL enabled);
typedef void(^HEMVoiceSettingsHandler)(id _Nullable response, NSError* _Nullable error);
typedef void(^HEVoiceSettingsUpdateHandler)(BOOL updated);

@interface HEMVoiceService : SENService

- (void)startListeningForVoiceResult;
- (void)stopListeningForVoiceResult;
- (NSArray<HEMVoiceCommandGroup*>*)availableVoiceCommands;
- (BOOL)showVoiceIntro;
- (void)hideVoiceIntro;
- (void)resetVoiceIntro;
- (void)updateVoiceSettings:(SENSenseVoiceSettings*)voiceSettings
                 forSenseId:(NSString*)senseId
                 completion:(HEVoiceSettingsUpdateHandler)completion;
- (void)getVoiceSettingsForSenseId:(NSString*)senseId
                        completion:(HEMVoiceSettingsHandler)completion;
- (NSInteger)volumeLevelFrom:(SENSenseVoiceSettings*)voiceSettings;
- (NSInteger)volumePercentageFromLevel:(NSInteger)volumeLevel;

@end

NS_ASSUME_NONNULL_END