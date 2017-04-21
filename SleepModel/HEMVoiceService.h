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
@class SENSenseVoiceSettings;
@class SENVoiceCommandGroup;

NS_ASSUME_NONNULL_BEGIN

extern NSString* const HEMVoiceNotificationSettingsUpdated;
extern NSString* const HEMVoiceNotificationInfoSettings;
extern NSString* const HEMVoiceNotification;
extern NSString* const HEMVoiceNotificationInfoError;
extern NSString* const HEMVoiceNotificationInfoResult;
extern NSInteger const HEMVoiceServiceMaxVolumeLevel;

typedef void(^HEMVoiceFeatureHandler)(BOOL enabled);
typedef void(^HEMVoiceSettingsHandler)(id _Nullable response, NSError* _Nullable error);
typedef void(^HEVoiceSettingsUpdateHandler)(SENSenseVoiceSettings* updated);
typedef void(^HEMVoiceAvailableCommandsHandler)(NSArray<SENVoiceCommandGroup*>* commandGroups);

@interface HEMVoiceService : SENService

- (void)startListeningForVoiceResult;
- (void)stopListeningForVoiceResult;
- (void)availableVoiceCommands:(HEMVoiceAvailableCommandsHandler)completion;
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
- (BOOL)isFirmwareUpdateRequiredFromError:(NSError*)error;

@end

NS_ASSUME_NONNULL_END
