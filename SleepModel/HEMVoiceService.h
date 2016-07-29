//
//  HEMVoiceService.h
//  Sense
//
//  Created by Jimmy Lu on 7/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SENSpeechResult;

NS_ASSUME_NONNULL_BEGIN

NSString* const HEMVoiceNotification;
NSString* const HEMVoiceNotificationInfoError;
NSString* const HEMVoiceNotificationInfoResult;

@interface HEMVoiceService : NSObject

- (void)startListeningForVoiceResult;
- (void)stopListeningForVoiceResult;

@end

NS_ASSUME_NONNULL_END