//
//  AlarmInterfaceController.h
//  Sense
//
//  Created by Delisa Mason on 1/18/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

@import WatchKit;

@class SENAlarm;

@interface AlarmInterfaceController : WKInterfaceController

@property (nonatomic, strong) SENAlarm *alarm;
@end
