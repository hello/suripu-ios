//
//  HEMAlarmService.h
//  Sense
//
//  Created by Jimmy Lu on 12/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"

@class SENSound;
@class HEMAlarmCache;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMAlarmSoundHandler)(NSArray<SENSound*>* _Nullable sounds, NSError* _Nullable error);
typedef void(^HEMAlarmUpdateHandler)(NSError* _Nullable error);
typedef void(^HEMAlarmsHandler)(NSArray<SENAlarm*>* _Nullable alarms, NSError* _Nullable error);

@interface HEMAlarmService : SENService

/**
 * @discussion
 * Load avaiable alarm sounds
 *
 * @param completion: the block to call upon response from retrieving available
 *                    alarm sounds that can be used when setting an alarm
 */
- (void)loadAvailableAlarmSounds:(HEMAlarmSoundHandler)completion;
- (void)refreshAlarms:(HEMAlarmsHandler)completion;
- (void)updateAlarms:(NSArray<SENAlarm*>*)alarms completion:(HEMAlarmUpdateHandler)completion;
- (BOOL)isTimeTooSoon:(HEMAlarmCache*)cache;
- (BOOL)willRingToday:(HEMAlarmCache*)cache;
- (NSString*)localizedTextForRepeatFlags:(NSUInteger)alarmRepeatFlags;
- (void)copyCache:(HEMAlarmCache*)cache to:(SENAlarm*)alarm;

@end

NS_ASSUME_NONNULL_END