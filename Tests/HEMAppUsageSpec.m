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

SPEC_BEGIN(HEMAppUsageSpec)

describe(@"HEMAppUsage", ^{

    __block HEMAppUsage* appUsage;
    __block NSString* databasePath = nil;

    beforeEach(^{
        databasePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpAppUsageSpec"];
        [SENKeyedArchiver stub:@selector(datastorePath) andReturn:databasePath];
    });

    afterEach(^{
        [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
    });
    describe(@"+appUsageForIdentifier:completion", ^{
        
        context(@"first time retrieving app usage", ^{
            
            beforeEach(^{
                appUsage = [HEMAppUsage appUsageForIdentifier:@"firstTime"];
            });
            
            it(@"should not have any usage", ^{
                [[@([appUsage usageWithin:HEMAppUsageIntervalLast7Days]) should] equal:@(0)];
            });
            
        });
        
        context(@"retrieving an already saved app usage", ^{
            
            beforeEach(^{
                NSString* identifier = @"secondTime";
                appUsage = [HEMAppUsage appUsageForIdentifier:identifier];
                [appUsage increment:YES];
                appUsage = [HEMAppUsage appUsageForIdentifier:identifier];
            });
            
            it(@"should have usage of 1 for today", ^{
                [[@([appUsage usageWithin:HEMAppUsageIntervalLast7Days]) should] equal:@(1)];
            });
            
        });
        
    });
    
    describe(@"-increment", ^{
        
        context(@"increments the usage multiple times in 1 day", ^{
            
            beforeEach(^{
                appUsage = [HEMAppUsage appUsageForIdentifier:@"app launch"];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage save];
            });
            
            it(@"should have usage of 3 for today", ^{
                [[@([appUsage usageWithin:HEMAppUsageIntervalLast7Days]) should] equal:@(3)];
            });
            
        });
        
    });
    
    describe(@"-usageWithin:", ^{
        
        context(@"incremented 3 times on same day", ^{
            
            beforeEach(^{
                appUsage = [HEMAppUsage appUsageForIdentifier:@"app launch"];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage save];
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
                
                [NSDate clearStubs]; // clear it after calling appUsageForIdentifier:
            });
            
            it(@"should return 0 in last 7 days", ^{
                NSUInteger count = [appUsage usageWithin:HEMAppUsageIntervalLast7Days];
                [[@(count) should] equal:@(0)];
            });
            
            it(@"should return 1 in last 31 days", ^{
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
                
                [NSDate clearStubs]; // clear it after calling appUsageForIdentifier:
            });
            
            it(@"should return 0 in last 7 days", ^{
                NSUInteger count = [appUsage usageWithin:HEMAppUsageIntervalLast7Days];
                [[@(count) should] equal:@(0)];
            });
            
            it(@"should return 0 in last 31 days", ^{
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


