//
//  HEMAppReviewSpec.m
//  Sense
//
//  Created by Jimmy Lu on 7/31/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Kiwi/Kiwi.h>
#import <SenseKit/SENKeyedArchiver.h>
#import <SenseKit/SENLocalPreferences.h>
#import "NSDate+HEMRelative.h"
#import "HEMAppReview.h"
#import "HEMConfig.h"
#import "HEMAppUsage.h"

@interface HEMAppReview()

+ (void)hasSenseAndPillPaired:(void(^)(BOOL hasPairedDevices))completion;
+ (BOOL)hasAppReviewURL;
+ (BOOL)isWithinAppReviewThreshold;
+ (BOOL)meetsMinimumRequiredTimelineViews;
+ (BOOL)meetsMinimumRequiredAppLaunches;
+ (BOOL)isWithinSystemAlertThreshold;
+ (BOOL)hasStatedToStopAsking;
+ (BOOL)hasNotYetReviewedThisVersion;
+ (NSString*)appVersion;

@end

SPEC_BEGIN(HEMAppReviewSpec)

describe(@"HEMAppReview", ^{
    
    describe(@"+hasAppReviewURL", ^{
        
        it(@"should return YES if url in config", ^{
            [HEMConfig stub:@selector(stringForConfig:) andReturn:@"url"];
            BOOL yes = [HEMAppReview hasAppReviewURL];
            [[@(yes) should] beYes];
        });
        
        it(@"should return NO if url not in config", ^{
            [HEMConfig stub:@selector(stringForConfig:) andReturn:nil];
            BOOL no = [HEMAppReview hasAppReviewURL];
            [[@(no) should] beNo];
        });
        
    });
    
    describe(@"+isWithinAppReviewThreshold", ^{
        
        context(@"app prompt was never been completed", ^{
            
            beforeEach(^{
                HEMAppUsage* usage = [[HEMAppUsage alloc] init];
                [HEMAppUsage stub:@selector(appUsageForIdentifier:) andReturn:usage];
            });
            
            afterEach(^{
                [HEMAppUsage clearStubs];
            });

            it(@"should return yes", ^{
                BOOL yes = [HEMAppReview isWithinAppReviewThreshold];
                [[@(yes) should] beYes];
            });
            
        });
        
        context(@"app prompt was completed 30 days ago", ^{
            
            beforeEach(^{
                NSDate* daysAgo = [[NSDate date] daysFromNow:-30];
                [NSDate stub:@selector(date) andReturn:daysAgo];
                [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageAppReviewPromptCompleted];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should return NO", ^{
                BOOL no = [HEMAppReview isWithinAppReviewThreshold];
                [[@(no) should] beNo];
            });
            
        });
        
        context(@"app prompt was completed 60 days ago", ^{
            
            beforeEach(^{
                NSDate* daysAgo = [[NSDate date] daysFromNow:-60];
                [NSDate stub:@selector(date) andReturn:daysAgo];
                [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageAppReviewPromptCompleted];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should return NO", ^{
                BOOL no = [HEMAppReview isWithinAppReviewThreshold];
                [[@(no) should] beNo];
            });
            
        });
        
        context(@"app prompt was completed 61 days ago", ^{
            
            beforeEach(^{
                NSDate* daysAgo = [[NSDate date] daysFromNow:-61];
                [NSDate stub:@selector(date) andReturn:daysAgo];
                [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageAppReviewPromptCompleted];
                [NSDate clearStubs];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should return YES", ^{
                BOOL yes = [HEMAppReview isWithinAppReviewThreshold];
                [[@(yes) should] beYes];
            });
            
        });

    });
    
    describe(@"+meetsMinimumRequiredTimelineViews", ^{
        
        __block NSString* identifier = nil;
        
        beforeEach(^{
            identifier = HEMAppUsageTimelineShownWithData;
        });
        
        it(@"should return no if usage indicate no timeline with data seen before", ^{
            BOOL no = [HEMAppReview meetsMinimumRequiredTimelineViews];
            [[@(no) should] beNo];
        });
        
        context(@"has seen 4 timelines with data", ^{
            
            beforeEach(^{
                HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:identifier];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage save];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should return NO", ^{
                BOOL no = [HEMAppReview meetsMinimumRequiredTimelineViews];
                [[@(no) should] beNo];
            });
            
        });
        
        context(@"has seen 10 timelines with data", ^{
            
            beforeEach(^{
                HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:identifier];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage save];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should return YES", ^{
                BOOL yes = [HEMAppReview meetsMinimumRequiredTimelineViews];
                [[@(yes) should] beYes];
            });
            
        });
        
    });
    
    describe(@"+meetsMinimumRequiredAppLaunches", ^{
        
        __block NSString* identifier = nil;
        
        beforeEach(^{
            identifier = HEMAppUsageAppLaunched;
        });
        
        it(@"should return no if usage indicate no app launches", ^{
            BOOL no = [HEMAppReview meetsMinimumRequiredAppLaunches];
            [[@(no) should] beNo];
        });
        
        context(@"has launched 2 times", ^{
            
            beforeEach(^{
                HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:identifier];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage save];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should return NO", ^{
                BOOL no = [HEMAppReview meetsMinimumRequiredAppLaunches];
                [[@(no) should] beNo];
            });
            
        });
        
        context(@"has launched 4 times in last 7 days", ^{
            
            beforeEach(^{
                HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:identifier];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage increment:NO];
                [appUsage save];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should return YES", ^{
                BOOL yes = [HEMAppReview meetsMinimumRequiredAppLaunches];
                [[@(yes) should] beYes];
            });
            
        });
        
    });
    
    describe(@"+isWithinSystemAlertThreshold", ^{
        
        __block NSString* identifier = nil;
        
        beforeEach(^{
            identifier = HEMAppUsageSystemAlertShown;
        });
        
        it(@"should return yes if usage indicate no system alert ever seen", ^{
            BOOL yes = [HEMAppReview isWithinSystemAlertThreshold];
            [[@(yes) should] beYes];
        });
        
        context(@"has seen alert today", ^{
            
            beforeEach(^{
                [HEMAppUsage incrementUsageForIdentifier:identifier];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should return no", ^{
                BOOL no = [HEMAppReview isWithinSystemAlertThreshold];
                [[@(no) should] beNo];
            });
            
        });
        
        context(@"saw a system alert 31 days ago", ^{
            
            beforeEach(^{
                NSDate* daysAgo = [[NSDate date] daysFromNow:-31];
                [NSDate stub:@selector(date) andReturn:daysAgo];
                [HEMAppUsage incrementUsageForIdentifier:identifier];
                [NSDate clearStubs];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
            });
            
            it(@"should return YES", ^{
                BOOL yes = [HEMAppReview isWithinSystemAlertThreshold];
                [[@(yes) should] beYes];
            });
            
        });
        
    });
    
    describe(@"+hasStatedToStopAsking", ^{
        
        __block NSString* key = nil;
        
        beforeEach(^{
            key = @"stop.asking.to.rate.app";
        });
        
        it(@"should return no if never stated that", ^{
            SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
            [localPrefs setPersistentPreference:nil forKey:key];
            
            BOOL no = [HEMAppReview hasStatedToStopAsking];
            [[@(no) should] beNo];
        });
        
        it(@"should return yes if stated to stop asking", ^{
            SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
            [localPrefs setPersistentPreference:@(YES) forKey:key];
            
            BOOL yes = [HEMAppReview hasStatedToStopAsking];
            [[@(yes) should] beYes];
        });
        
    });
    
    describe(@"+hasNotYetReviewedThisVersion", ^{
        
        it(@"should return yes if never attempted to rate app before", ^{
            BOOL yes = [HEMAppReview hasNotYetReviewedThisVersion];
            [[@(yes) should] beYes];
        });
        
        context(@"has rated the app before for this version", ^{
            
            __block NSString* appVersion = nil;
            
            beforeEach(^{
                appVersion = @"1.1.1";
                [HEMAppUsage incrementUsageForIdentifier:appVersion];
                [HEMAppReview stub:@selector(appVersion) andReturn:appVersion];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
                [HEMAppReview clearStubs];
            });

            it(@"should return no", ^{
                BOOL no = [HEMAppReview hasNotYetReviewedThisVersion];
                [[@(no) should] beNo];
            });
            
        });
        
        context(@"has rated the app for a previous version before", ^{
            
            beforeEach(^{
                [HEMAppUsage incrementUsageForIdentifier:@"1.1.1"];
                [HEMAppReview stub:@selector(appVersion) andReturn:@"1.1.2"];
            });
            
            afterEach(^{
                [SENKeyedArchiver removeAllObjects];
                [HEMAppReview clearStubs];
            });
            
            it(@"should return yes", ^{
                BOOL yes = [HEMAppReview hasNotYetReviewedThisVersion];
                [[@(yes) should] beYes];
            });
            
        });
        
    });

    
});

SPEC_END
