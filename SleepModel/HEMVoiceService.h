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

extern NSString* const HEMVoiceNotification;
extern NSString* const HEMVoiceNotificationInfoError;
extern NSString* const HEMVoiceNotificationInfoResult;
extern NSInteger const HEMVoiceServiceMaxVolumeLevel;

typedef void(^HEMVoiceFeatureHandler)(BOOL enabled);
typedef void(^HEMVoiceInfoHandler)(id _Nullable response, NSError* _Nullable error);
typedef void(^HEVoiceInfoUpdateHandler)(BOOL updated);

@interface HEMVoiceService : SENService

- (void)startListeningForVoiceResult;
- (void)stopListeningForVoiceResult;
- (NSArray<HEMVoiceCommandGroup*>*)availableVoiceCommands;
- (BOOL)showVoiceIntro;
- (void)hideVoiceIntro;
- (void)resetVoiceIntro;
- (void)updateVoiceInfo:(SENSenseVoiceInfo*)voiceInfo
             forSenseId:(NSString*)senseId
             completion:(HEVoiceInfoUpdateHandler)completion;
- (void)getVoiceInfoForSenseId:(NSString*)senseId
                    completion:(HEMVoiceInfoHandler)completion;
- (NSInteger)volumeLevelFrom:(SENSenseVoiceInfo*)voiceInfo;
- (NSInteger)volumePercentageFromLevel:(NSInteger)volumeLevel;

@end

NS_ASSUME_NONNULL_END