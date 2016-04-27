//
//  HEMAlarmRepeatDaysPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 4/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENAlarm.h>

#import "HEMListPresenter.h"
#import "HEMAlarmCache.h"
#import "HEMAlarmService.h"

@interface HEMAlarmRepeatDaysPresenter : HEMListPresenter

@property (nonatomic, assign, readonly) SENAlarmRepeatDays selectedDays;

- (instancetype)initWithNavTitle:(NSString*)title
                        subtitle:(NSString*)subtitle
                      alarmCache:(HEMAlarmCache*)cache
                         basedOn:(SENAlarm*)alarm
                     withService:(HEMAlarmService*)service;

@end
