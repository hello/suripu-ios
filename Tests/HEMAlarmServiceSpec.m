//
//  HEMAlarmServiceSpec.m
//  Sense
//
//  Created by Jimmy Lu on 6/21/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENAlarm.h>
#import "HEMAlarmService.h"

@interface HEMAlarmService()

- (BOOL)isTimeTooSoonWithHour:(NSUInteger)alarmHour andMinute:(NSUInteger)alarmMinute;
- (BOOL)willRingTodayWithHour:(NSUInteger)hour minute:(NSUInteger)minute repeat:(SENAlarmRepeatDays)repeat;
- (SENAlarmRepeatDays)alarmRepeatDayForDate:(NSDate*)date;

@end

SPEC_BEGIN(HEMAlarmServiceSpec)

describe(@"HEMAlarmService", ^{
    
    describe(@"-isTimeTooSoonWithHour:andMinute:", ^{
        
        const NSUInteger hour = 11;
        const NSUInteger minute = 10;
        __block NSDate *baseDate;
        __block HEMAlarmService* service;
        
        beforeEach(^{
            service = [HEMAlarmService new];
            
            NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *dateComponents = [NSDateComponents new];
            dateComponents.year = 2015;
            dateComponents.month = 11;
            dateComponents.day = 13;
            dateComponents.hour = hour;
            dateComponents.minute = minute;
            dateComponents.timeZone = [NSTimeZone defaultTimeZone];
            baseDate = [calendar dateFromComponents:dateComponents];
            [NSDate stub:@selector(date) andReturn:baseDate];
        });
        
        afterAll(^{
            [NSDate clearStubs];
        });
        
        it(@"should return true for now", ^{
            BOOL tooSoon = [service isTimeTooSoonWithHour:hour andMinute:minute];
            [[@(tooSoon) should] equal:@YES];
        });
        
        it(@"should return true for the next n minutes", ^{
            for (NSUInteger offset = 1; offset <= 2; offset++) {
                BOOL tooSoon = [service isTimeTooSoonWithHour:hour andMinute:minute + offset];
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
            dateComponents.timeZone = [NSTimeZone defaultTimeZone];
            baseDate = [calendar dateFromComponents:dateComponents];
            [NSDate stub:@selector(date) andReturn:baseDate];
            
            [[@([service isTimeTooSoonWithHour:11 andMinute:58]) should] equal:@NO];
            [[@([service isTimeTooSoonWithHour:11 andMinute:59]) should] equal:@YES];
            [[@([service isTimeTooSoonWithHour:12 andMinute:0]) should] equal:@YES];
            [[@([service isTimeTooSoonWithHour:12 andMinute:1]) should] equal:@YES];
            [[@([service isTimeTooSoonWithHour:12 andMinute:2]) should] equal:@NO];
            [[@([service isTimeTooSoonWithHour:12 andMinute:59]) should] equal:@NO];
        });
        
        it(@"should return false for times before now", ^{
            BOOL tooSoon = [service isTimeTooSoonWithHour:hour andMinute:minute - 1];
            [[@(tooSoon) should] equal:@NO];
        });
        
        it(@"should return false for times after n minutes", ^{
            NSUInteger additional = (2 + 1);
            BOOL tooSoon = [service isTimeTooSoonWithHour:hour andMinute:minute + additional];
            [[@(tooSoon) should] equal:@NO];
        });
        
    });
    
    describe(@"-localizedTextForRepeatFlags:", ^{
        
        __block HEMAlarmService* service = nil;
        
        beforeEach(^{
            service = [HEMAlarmService new];
            NSLocale* locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
            [NSLocale stub:@selector(currentLocale) andReturn:locale];
        });
        
        afterAll(^{
            [NSLocale clearStubs];
        });
        
        it(@"should return none", ^{
            NSUInteger unitFlags = 0;
            NSString *repeatText = [service localizedTextForRepeatFlags:unitFlags];
            [[repeatText should] equal:@"Not repeating"];
        });
        
        it(@"should return weekdays", ^{
            NSUInteger unitFlags = (SENAlarmRepeatMonday |
                                    SENAlarmRepeatTuesday |
                                    SENAlarmRepeatWednesday |
                                    SENAlarmRepeatThursday |
                                    SENAlarmRepeatFriday);
            NSString *repeatText = [service localizedTextForRepeatFlags:unitFlags];
            [[repeatText should] equal:@"Weekdays"];
        });
        
        it(@"should return weekends", ^{
            NSUInteger unitFlags = (SENAlarmRepeatSunday |
                                    SENAlarmRepeatSaturday);
            NSString *repeatText = [service localizedTextForRepeatFlags:unitFlags];
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
            NSString *repeatText = [service localizedTextForRepeatFlags:unitFlags];
            [[repeatText should] equal:@"Everyday"];
        });
        
        it(@"should return short day name", ^{
            [[[service localizedTextForRepeatFlags:SENAlarmRepeatSunday] should] equal:@"Sun"];
            [[[service localizedTextForRepeatFlags:SENAlarmRepeatMonday] should] equal:@"Mon"];
            [[[service localizedTextForRepeatFlags:SENAlarmRepeatTuesday] should] equal:@"Tue"];
            [[[service localizedTextForRepeatFlags:SENAlarmRepeatWednesday] should] equal:@"Wed"];
            [[[service localizedTextForRepeatFlags:SENAlarmRepeatThursday] should] equal:@"Thu"];
            [[[service localizedTextForRepeatFlags:SENAlarmRepeatFriday] should] equal:@"Fri"];
            [[[service localizedTextForRepeatFlags:SENAlarmRepeatSaturday] should] equal:@"Sat"];
        });
        
        it(@"should return day names", ^{
            NSUInteger unitFlags = (SENAlarmRepeatSunday |
                                    SENAlarmRepeatTuesday |
                                    SENAlarmRepeatThursday |
                                    SENAlarmRepeatSaturday);
            NSString *repeatText = [service localizedTextForRepeatFlags:unitFlags];
            [[repeatText should] equal:@"Sun Tue Thu Sat"];
        });
        
    });
    
    describe(@"-willRingTodayWithHour:minute:repeat:", ^{
        const NSUInteger hour = 11;
        const NSUInteger minute = 10;
        __block NSDate *baseDate;
        __block SENAlarmRepeatDays baseDateDay;
        __block HEMAlarmService* service;
        
        beforeEach(^{
            service = [HEMAlarmService new];
            NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *dateComponents = [NSDateComponents new];
            dateComponents.year = 2015;
            dateComponents.month = 11;
            dateComponents.day = 13;
            dateComponents.hour = hour;
            dateComponents.minute = minute;
            dateComponents.timeZone = [NSTimeZone defaultTimeZone];
            baseDate = [calendar dateFromComponents:dateComponents];
            baseDateDay = [service alarmRepeatDayForDate:baseDate];
            [NSDate stub:@selector(date) andReturn:baseDate];
        });
        
        afterAll(^{
            [NSDate clearStubs];
        });
        
        it(@"should return true for now with no repeat days", ^{
            BOOL willRing = [service willRingTodayWithHour:hour minute:minute repeat:0];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return true for short times after now with no repeat days", ^{
            BOOL willRing = [service willRingTodayWithHour:hour minute:minute + 10 repeat:0];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return true for long times after now with no repeat days", ^{
            BOOL willRing = [service willRingTodayWithHour:hour + 2 minute:minute repeat:0];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return false for short times before now with no repeat days", ^{
            BOOL willRing = [service willRingTodayWithHour:hour minute:minute - 10 repeat:0];
            [[@(willRing) should] equal:@NO];
        });
        
        it(@"should return false for long times before now with no repeat days", ^{
            BOOL willRing = [service willRingTodayWithHour:hour - 2 minute:minute repeat:0];
            [[@(willRing) should] equal:@NO];
        });
        
        it(@"should return false for any time when repeat doesn't contain today", ^{
            SENAlarmRepeatDays days = (SENAlarmRepeatSunday |
                                       SENAlarmRepeatMonday |
                                       SENAlarmRepeatTuesday |
                                       SENAlarmRepeatWednesday |
                                       SENAlarmRepeatThursday |
                                       SENAlarmRepeatFriday |
                                       SENAlarmRepeatSaturday);
            days &= ~baseDateDay;
            
            [[@([service willRingTodayWithHour:hour minute:minute repeat:days]) should] equal:@NO];
            [[@([service willRingTodayWithHour:hour minute:minute + 10 repeat:days]) should] equal:@NO];
            [[@([service willRingTodayWithHour:hour + 2 minute:minute repeat:days]) should] equal:@NO];
            [[@([service willRingTodayWithHour:hour minute:minute - 10 repeat:days]) should] equal:@NO];
            [[@([service willRingTodayWithHour:hour - 2 minute:minute repeat:days]) should] equal:@NO];
        });
        
        it(@"should return true for now with repeat days containing today", ^{
            BOOL willRing = [service willRingTodayWithHour:hour minute:minute repeat:baseDateDay];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return true for short times after now with repeat days containing today", ^{
            BOOL willRing = [service willRingTodayWithHour:hour minute:minute + 10 repeat:baseDateDay];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return true for long times after now with repeat days containing today", ^{
            BOOL willRing = [service willRingTodayWithHour:hour + 2 minute:minute repeat:baseDateDay];
            [[@(willRing) should] equal:@YES];
        });
        
        it(@"should return false for short times before now with repeat days containing today", ^{
            BOOL willRing = [service willRingTodayWithHour:hour minute:minute - 10 repeat:baseDateDay];
            [[@(willRing) should] equal:@NO];
        });
        
        it(@"should return false for long times before now with repeat days containing today", ^{
            BOOL willRing = [service willRingTodayWithHour:hour - 2 minute:minute repeat:baseDateDay];
            [[@(willRing) should] equal:@NO];
        });
    });
    
});

SPEC_END
