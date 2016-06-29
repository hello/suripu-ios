//
//  NSDateHEMRelativeSpec.c
//  Sense
//
//  Created by Jimmy Lu on 6/4/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "NSDate+HEMRelative.h"

SPEC_BEGIN(NSDateHEMRelativeSpec)

describe(@"NSDateHEMRelative", ^{
    
    __block NSCalendar* calendar = nil;
    
    beforeAll(^{
        calendar = [NSCalendar autoupdatingCurrentCalendar];
    });
    
    describe(@"-elapsed", ^{
        
        it(@"should be today", ^{
            
            NSString* elapsed = [[NSDate date] elapsed];
            NSString* todayElapsed = NSLocalizedString(@"date.elapsed.today", nil);
            [[elapsed should] equal:todayElapsed];
            
        });
        
        it(@"should be yesterday", ^{
            
            NSDate* today = [NSDate date];
            NSInteger daysDiff = 1;
            
            NSDateComponents* diff = [NSDateComponents new];
            [diff setDay:-daysDiff];
            
            NSDate* oneDayAgo = [calendar dateByAddingComponents:diff toDate:today options:0];
            NSString* elapsed = [oneDayAgo elapsed];
            
            NSString* yesterday = NSLocalizedString(@"date.elapsed.yesterday", nil);
            [[elapsed should] equal:yesterday];
            
        });
        
        it(@"should be days ago, plural", ^{
            
            NSDate* today = [NSDate date];
            NSInteger daysDiff = 4;
            
            NSDateComponents* diff = [NSDateComponents new];
            [diff setDay:-daysDiff];
            
            NSDate* fourDaysAgo = [calendar dateByAddingComponents:diff toDate:today options:0];
            NSString* elapsed = [fourDaysAgo elapsed];
            
            NSString* format = NSLocalizedString(@"date.elapsed.days.format", nil);
            [[elapsed should] equal:[NSString stringWithFormat:format, daysDiff]];
            
        });
        
        it(@"should be 1 week ago", ^{
            
            NSDate* today = [NSDate date];
            
            NSDateComponents* diff = [NSDateComponents new];
            [diff setDay:-7];
            
            NSDate* sevenDaysAgo = [calendar dateByAddingComponents:diff toDate:today options:0];
            NSString* elapsed = [sevenDaysAgo elapsed];
            
            NSString* format = NSLocalizedString(@"date.elapsed.week.format", nil);
            [[elapsed should] equal:[NSString stringWithFormat:format, 1]];
            
        });
        
        it(@"should be 1 month ago", ^{
            
            NSDate* today = [NSDate date];
            
            NSDateComponents* diff = [NSDateComponents new];
            [diff setDay:-20];
            
            NSDate* twentyDaysAgo = [calendar dateByAddingComponents:diff toDate:today options:0];
            NSString* elapsed = [twentyDaysAgo elapsed];
            
            NSString* format = NSLocalizedString(@"date.elapsed.month.format", nil);
            [[elapsed should] equal:[NSString stringWithFormat:format, 1]];
            
        });
        
        it(@"should be 1 year ago", ^{
            
            NSDate* today = [NSDate date];
            
            NSDateComponents* diff = [NSDateComponents new];
            [diff setDay:-365];
            
            NSDate* oneYearAgo = [calendar dateByAddingComponents:diff toDate:today options:0];
            NSString* elapsed = [oneYearAgo elapsed];
            
            NSString* format = NSLocalizedString(@"date.elapsed.year.format", nil);
            [[elapsed should] equal:[NSString stringWithFormat:format, 1]];
            
        });
        
        it(@"should be years ago, plural", ^{
            
            NSDate* today = [NSDate date];
            
            NSDateComponents* diff = [NSDateComponents new];
            [diff setDay:-380];
            
            NSDate* overOneYearAgo = [calendar dateByAddingComponents:diff toDate:today options:0];
            NSString* elapsed = [overOneYearAgo elapsed];
            
            NSString* format = NSLocalizedString(@"date.elapsed.years.format", nil);
            [[elapsed should] equal:[NSString stringWithFormat:format, 2]];
            
        });
        
    });
    
});

SPEC_END
