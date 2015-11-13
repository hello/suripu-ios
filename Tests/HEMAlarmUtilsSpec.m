//
//  HEMAlarmUtilsSpec.m
//  Sense
//
//  Created by Kevin MacWhinnie on 11/13/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENAlarm.h>
#import "HEMAlarmUtils.h"

SPEC_BEGIN(HEMAlarmUtilsSpec)

describe(@"HEMAlarmUtils", ^{
    
    describe(@"+timeIsTooSoonByHour:minute:", ^{
        const NSUInteger hour = 11;
        const NSUInteger minute = 10;
        __block NSDate *baseDate;
        
        beforeEach(^{
            NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *dateComponents = [NSDateComponents new];
            dateComponents.year = 2015;
            dateComponents.month = 11;
            dateComponents.day = 13;
            dateComponents.hour = hour;
            dateComponents.minute = minute;
            baseDate = [calendar dateFromComponents:dateComponents];
            [NSDate stub:@selector(date) andReturn:baseDate];
        });
        
        it(@"should return true for now", ^{
            BOOL tooSoon = [HEMAlarmUtils timeIsTooSoonByHour:hour minute:minute];
            [[@(tooSoon) should] equal:@YES];
        });
        
        it(@"should return true for the next n minutes", ^{
            for (NSUInteger offset = 1; offset <= HEMAlarmTooSoonMinuteLimit; offset++) {
                BOOL tooSoon = [HEMAlarmUtils timeIsTooSoonByHour:hour minute:minute + offset];
                [[@(tooSoon) should] equal:@YES];
            }
        });
        
        it(@"should return true for next n minutes at hour boundary", ^{
            NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *dateComponents = [NSDateComponents new];
            dateComponents.year = 2015;
            dateComponents.month = 11;
            dateComponents.day = 13;
            dateComponents.hour = 11;
            dateComponents.minute = 59;
            baseDate = [calendar dateFromComponents:dateComponents];
            [NSDate stub:@selector(date) andReturn:baseDate];
            
            [[@([HEMAlarmUtils timeIsTooSoonByHour:11 minute:59]) should] equal:@YES];
            [[@([HEMAlarmUtils timeIsTooSoonByHour:12 minute:0]) should] equal:@YES];
            [[@([HEMAlarmUtils timeIsTooSoonByHour:12 minute:1]) should] equal:@YES];
        });
        
        it(@"should return false for times before now", ^{
            BOOL tooSoon = [HEMAlarmUtils timeIsTooSoonByHour:hour minute:minute - 1];
            [[@(tooSoon) should] equal:@NO];
        });
        
        it(@"should return false for times after n minutes", ^{
            NSUInteger additional = (HEMAlarmTooSoonMinuteLimit + 1);
            BOOL tooSoon = [HEMAlarmUtils timeIsTooSoonByHour:hour minute:minute + additional];
            [[@(tooSoon) should] equal:@NO];
        });
    });
    
    describe(@"+repeatTextForUnitFlags:", ^{
        beforeEach(^{
            NSLocale* locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
            [NSLocale stub:@selector(currentLocale) andReturn:locale];
        });
        
        it(@"should return none", ^{
            NSUInteger unitFlags = 0;
            NSString *repeatText = [HEMAlarmUtils repeatTextForUnitFlags:unitFlags];
            [[repeatText should] equal:@"Not repeating"];
        });
        
        it(@"should return weekdays", ^{
            NSUInteger unitFlags = (SENAlarmRepeatMonday |
                                    SENAlarmRepeatTuesday |
                                    SENAlarmRepeatWednesday |
                                    SENAlarmRepeatThursday |
                                    SENAlarmRepeatFriday);
            NSString *repeatText = [HEMAlarmUtils repeatTextForUnitFlags:unitFlags];
            [[repeatText should] equal:@"Weekdays"];
        });
        
        it(@"should return weekends", ^{
            NSUInteger unitFlags = (SENAlarmRepeatSunday |
                                    SENAlarmRepeatSaturday);
            NSString *repeatText = [HEMAlarmUtils repeatTextForUnitFlags:unitFlags];
            [[repeatText should] equal:@"Weekends"];
        });
        
        it(@"should return everyday", ^{
            NSUInteger unitFlags = (SENAlarmRepeatSunday |
                                    SENAlarmRepeatMonday |
                                    SENAlarmRepeatTuesday |
                                    SENAlarmRepeatWednesday |
                                    SENAlarmRepeatThursday |
                                    SENAlarmRepeatFriday |
                                    SENAlarmRepeatSaturday);
            NSString *repeatText = [HEMAlarmUtils repeatTextForUnitFlags:unitFlags];
            [[repeatText should] equal:@"Everyday"];
        });
        
        it(@"should return short day name", ^{
            [[[HEMAlarmUtils repeatTextForUnitFlags:SENAlarmRepeatSunday] should] equal:@"Sun"];
            [[[HEMAlarmUtils repeatTextForUnitFlags:SENAlarmRepeatMonday] should] equal:@"Mon"];
            [[[HEMAlarmUtils repeatTextForUnitFlags:SENAlarmRepeatTuesday] should] equal:@"Tue"];
            [[[HEMAlarmUtils repeatTextForUnitFlags:SENAlarmRepeatWednesday] should] equal:@"Wed"];
            [[[HEMAlarmUtils repeatTextForUnitFlags:SENAlarmRepeatThursday] should] equal:@"Thu"];
            [[[HEMAlarmUtils repeatTextForUnitFlags:SENAlarmRepeatFriday] should] equal:@"Fri"];
            [[[HEMAlarmUtils repeatTextForUnitFlags:SENAlarmRepeatSaturday] should] equal:@"Sat"];
        });
        
        it(@"should return day names", ^{
            NSUInteger unitFlags = (SENAlarmRepeatSunday |
                                    SENAlarmRepeatTuesday |
                                    SENAlarmRepeatThursday |
                                    SENAlarmRepeatSaturday);
            NSString *repeatText = [HEMAlarmUtils repeatTextForUnitFlags:unitFlags];
            [[repeatText should] equal:@"Sun Tue Thu Sat"];
        });
    });
    
    describe(@"+willRingTodayWithHour:minute:repeatDays:", ^{
        const NSUInteger hour = 11;
        const NSUInteger minute = 10;
        __block NSDate *baseDate;
        __block SENAlarmRepeatDays baseDateDay;
        
        beforeEach(^{
            NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *dateComponents = [NSDateComponents new];
            dateComponents.year = 2015;
            dateComponents.month = 11;
            dateComponents.day = 13;
            dateComponents.hour = hour;
            dateComponents.minute = minute;
            baseDate = [calendar dateFromComponents:dateComponents];
            baseDateDay = [HEMAlarmUtils alarmRepeatDayForDate:baseDate];
            [NSDate stub:@selector(date) andReturn:baseDate];
        });
        
        it(@"should return true for now with no repeat days", ^{
            BOOL willRing = [HEMAlarmUtils willRingTodayWithHour:hour minute:minute repeatDays:0];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return true for short times after now with no repeat days", ^{
            BOOL willRing = [HEMAlarmUtils willRingTodayWithHour:hour minute:minute + 10 repeatDays:0];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return true for long times after now with no repeat days", ^{
            BOOL willRing = [HEMAlarmUtils willRingTodayWithHour:hour + 2 minute:minute repeatDays:0];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return false for short times before now with no repeat days", ^{
            BOOL willRing = [HEMAlarmUtils willRingTodayWithHour:hour minute:minute - 10 repeatDays:0];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return false for long times before now with no repeat days", ^{
            BOOL willRing = [HEMAlarmUtils willRingTodayWithHour:hour - 2 minute:minute repeatDays:0];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return false for any time when repeat doesn't contain today", ^{
            SENAlarmRepeatDays days = (SENAlarmRepeatSunday |
                                       SENAlarmRepeatMonday |
                                       SENAlarmRepeatTuesday |
                                       SENAlarmRepeatWednesday |
                                       SENAlarmRepeatThursday |
                                       SENAlarmRepeatFriday |
                                       SENAlarmRepeatSaturday);
            days |= ~baseDateDay;
            
            [[@([HEMAlarmUtils willRingTodayWithHour:hour minute:minute repeatDays:days]) should] equal:@NO];
            [[@([HEMAlarmUtils willRingTodayWithHour:hour minute:minute + 10 repeatDays:days]) should] equal:@NO];
            [[@([HEMAlarmUtils willRingTodayWithHour:hour + 2 minute:minute repeatDays:days]) should] equal:@NO];
            [[@([HEMAlarmUtils willRingTodayWithHour:hour minute:minute - 10 repeatDays:days]) should] equal:@NO];
            [[@([HEMAlarmUtils willRingTodayWithHour:hour - 2 minute:minute repeatDays:days]) should] equal:@NO];
        });
        
        it(@"should return true for now with repeat days containing today", ^{
            BOOL willRing = [HEMAlarmUtils willRingTodayWithHour:hour minute:minute repeatDays:baseDateDay];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return true for short times after now with repeat days containing today", ^{
            BOOL willRing = [HEMAlarmUtils willRingTodayWithHour:hour minute:minute + 10 repeatDays:baseDateDay];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return true for long times after now with repeat days containing today", ^{
            BOOL willRing = [HEMAlarmUtils willRingTodayWithHour:hour + 2 minute:minute repeatDays:baseDateDay];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return false for short times before now with repeat days containing today", ^{
            BOOL willRing = [HEMAlarmUtils willRingTodayWithHour:hour minute:minute - 10 repeatDays:baseDateDay];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return false for long times before now with repeat days containing today", ^{
            BOOL willRing = [HEMAlarmUtils willRingTodayWithHour:hour - 2 minute:minute repeatDays:baseDateDay];
            [[@(willRing) should] equal:@YES];
        });
    });
});

SPEC_END
