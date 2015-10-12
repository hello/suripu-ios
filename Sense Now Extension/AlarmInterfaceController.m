//
//  AlarmInterfaceController.m
//  Sense
//
//  Created by Delisa Mason on 1/18/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENAPIAlarms.h>
#import "AlarmInterfaceController.h"
#import "ModelCache.h"

@interface AlarmInterfaceController ()

@property (weak, nonatomic) IBOutlet WKInterfaceSwitch *enabledSwitch;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;
@property (nonatomic) struct SENAlarmTime time;
@property (nonatomic, getter=isAlarmOn) BOOL on;
@end

@implementation AlarmInterfaceController

static NSInteger const AlarmHourMaxValue = 23;
static NSInteger const AlarmHourMinValue = 0;
static NSInteger const AlarmHourIncrementValue = 1;
static NSInteger const AlarmMinuteMaxValue = 55;
static NSInteger const AlarmMinuteMinValue = 0;
static NSInteger const AlarmMinuteIncrementValue = 5;

- (void)awakeWithContext:(SENAlarm *)context {
    [super awakeWithContext:context];
    self.alarm = context;
    self.time = (struct SENAlarmTime){.hour = self.alarm.hour, .minute = self.alarm.minute };
    self.on = [self.alarm isOn];
}

- (void)willActivate {
    [super willActivate];
    [self updateControls];
}

- (void)didDeactivate {
    [super didDeactivate];
    [self saveChanges];
}

- (void)updateControls {
    [self.enabledSwitch setOn:[self isAlarmOn]];
    [self.timeLabel setText:[SENAlarm localizedValueForTime:self.time]];
}

- (void)saveChanges {
    self.alarm.on = [self isAlarmOn];
    self.alarm.hour = self.time.hour;
    self.alarm.minute = self.time.minute;
    [self.alarm save];
    [SENAPIAlarms updateAlarms:[ModelCache alarms]
                    completion:^(id data, NSError *error) {
                      if (!error)
                          [ModelCache refreshCache];
                    }];
}

- (IBAction)incrementHour {
    NSInteger hour = self.time.hour + AlarmHourIncrementValue;
    if (hour > AlarmHourMaxValue)
        hour = AlarmHourMinValue;
    self.time = (struct SENAlarmTime){.hour = hour, .minute = self.time.minute };
    [self updateControls];
}

- (IBAction)incrementMinute {
    NSInteger minute = self.time.minute + AlarmMinuteIncrementValue;
    if (minute > AlarmMinuteMaxValue)
        minute = AlarmMinuteMinValue;
    self.time = (struct SENAlarmTime){.hour = self.time.hour, .minute = minute };
    [self updateControls];
}

- (IBAction)decrementHour {
    NSInteger hour = self.time.hour - AlarmHourIncrementValue;
    if (hour < AlarmHourMinValue)
        hour = AlarmHourMaxValue;
    self.time = (struct SENAlarmTime){.hour = hour, .minute = self.time.minute };
    [self updateControls];
}

- (IBAction)decrementMinute {
    NSInteger minute = self.time.minute - AlarmMinuteIncrementValue;
    if (minute < AlarmMinuteMinValue)
        minute = AlarmMinuteMaxValue;
    self.time = (struct SENAlarmTime){.hour = self.time.hour, .minute = minute };
    [self updateControls];
}

- (IBAction)updateEnabled:(BOOL)on {
    self.on = on;
    [self updateControls];
}

@end
