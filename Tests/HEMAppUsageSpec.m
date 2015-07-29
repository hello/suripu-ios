//
//  HEMAppUsageSpec.m
//  Sense
//
//  Created by Jimmy Lu on 7/28/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENKeyedArchiver.h>
#import "HEMAppUsage.h"
#import "NSDate+HEMRelative.h"

@interface HEMAppUsage()

@property (nonatomic, strong) NSMutableArray* rollingCountPerDay;
@property (nonatomic, strong) NSDate* created;

- (NSUInteger)rollingCountIndex;

@end

SPEC_BEGIN(HEMAppUsageSpec)

describe(@"HEMAppUsage", ^{
    
    describe(@"+appUsageForIdentifier:completion", ^{
        
        __block HEMAppUsage* appUsage;
        
        context(@"first time retrieving app usage", ^{
            
            beforeEach(^{
                appUsage = [HEMAppUsage appUsageForIdentifier:@"firstTime"];
            });
            
            it(@"should eventually return with a newly constructed object", ^{
                [[@([[appUsage created] isOnSameDay:[NSDate date]]) should] equal:@(YES)];
            });
            
            it(@"should have initialized array of rolling counts", ^{
                [[@([[appUsage rollingCountPerDay] count]) should] beGreaterThan:@(0)];
            });
            
            it(@"should not have any usage", ^{
                [[@([appUsage usageWithin:HEMAppUsageIntervalLast7Days]) should] equal:@(0)];
            });
            
        });
        
        context(@"retrieving an already saved app usage", ^{

            __block NSUInteger currentRollingIndex;
            
            beforeEach(^{
                NSString* identifier = @"secondTime";
                appUsage = [HEMAppUsage appUsageForIdentifier:identifier];
                [appUsage increment:YES];
                appUsage = [HEMAppUsage appUsageForIdentifier:identifier];
                currentRollingIndex = [appUsage rollingCountIndex];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should have usage of 1 for today", ^{
                NSNumber* count = [appUsage rollingCountPerDay][currentRollingIndex];
                [[count should] equal:@(1)];
            });
            
        });
        
    });
    
    describe(@"-increment", ^{
        
        context(@"increments the usage multiple times in 1 day", ^{
            
            __block HEMAppUsage* appUsage;
            __block NSUInteger currentRollingIndex;
            
            beforeEach(^{
                NSString* identifier = @"app launch";
                appUsage = [HEMAppUsage appUsageForIdentifier:identifier];
                currentRollingIndex = [appUsage rollingCountIndex];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage save];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should have usage of 3 for today", ^{
                NSNumber* count = [appUsage rollingCountPerDay][currentRollingIndex];
                [[count should] equal:@(3)];
            });
            
        });
        
    });
    
    describe(@"-usageWithin:", ^{
        
        __block HEMAppUsage* appUsage;
        
        context(@"incremented 3 times on same day", ^{
            
            beforeEach(^{
                NSString* identifier = @"app launch";
                appUsage = [HEMAppUsage appUsageForIdentifier:identifier];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage save];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should return 3 in last 7 days", ^{
                NSUInteger count = [appUsage usageWithin:HEMAppUsageIntervalLast7Days];
                [[@(count) should] equal:@(3)];
            });
            
            it(@"should return 3 in last 31 days", ^{
                NSUInteger count = [appUsage usageWithin:HEMAppUsageIntervalLast31Days];
                [[@(count) should] equal:@(3)];
            });
            
        });
        
        context(@"incremented 1 time, more than 7 days ago", ^{
            
            beforeEach(^{
                NSString* identifier = @"app launch";
                NSDate* eightDaysAgo = [[NSDate date] daysFromNow:-8];
                [NSDate stub:@selector(date) andReturn:eightDaysAgo];
                appUsage = [HEMAppUsage appUsageForIdentifier:identifier];
                [appUsage increment:YES];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should return 0 in last 7 days", ^{
                [NSDate clearStubs];
                NSUInteger count = [appUsage usageWithin:HEMAppUsageIntervalLast7Days];
                [[@(count) should] equal:@(0)];
            });
            
            it(@"should return 1 in last 31 days", ^{
                [NSDate clearStubs];
                NSUInteger count = [appUsage usageWithin:HEMAppUsageIntervalLast31Days];
                [[@(count) should] equal:@(1)];
            });
            
        });
        
        context(@"incremented 1 time, more than 31 days ago", ^{
            
            beforeEach(^{
                NSString* identifier = @"app launch";
                NSDate* longTimeAgo = [[NSDate date] daysFromNow:-32];
                [NSDate stub:@selector(date) andReturn:longTimeAgo];
                appUsage = [HEMAppUsage appUsageForIdentifier:identifier];
                [appUsage increment:YES];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should return 0 in last 7 days", ^{
                [NSDate clearStubs];
                NSUInteger count = [appUsage usageWithin:HEMAppUsageIntervalLast7Days];
                [[@(count) should] equal:@(0)];
            });
            
            it(@"should return 0 in last 31 days", ^{
                [NSDate clearStubs];
                NSUInteger count = [appUsage usageWithin:HEMAppUsageIntervalLast31Days];
                [[@(count) should] equal:@(0)];
            });
            
        });
        
        context(@"incremented 1 time more than 31 days ago and again today", ^{
            
            beforeEach(^{
                NSString* identifier = @"app launch";
                NSDate* longTimeAgo = [[NSDate date] daysFromNow:-32];
                [NSDate stub:@selector(date) andReturn:longTimeAgo];
                appUsage = [HEMAppUsage appUsageForIdentifier:identifier];
                [appUsage increment:YES];
                
                [NSDate clearStubs];
                
                [appUsage increment:YES];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should return 1 in last 7 days", ^{
                NSUInteger count = [appUsage usageWithin:HEMAppUsageIntervalLast7Days];
                [[@(count) should] equal:@(1)];
            });
            
            it(@"should return 1 in last 31 days", ^{
                NSUInteger count = [appUsage usageWithin:HEMAppUsageIntervalLast31Days];
                [[@(count) should] equal:@(1)];
            });
            
        });
        
    });
    
});

SPEC_END


