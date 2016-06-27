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
+ (NSDictionary*)amazonReviewLinks;
+ (NSString*)amazonReviewLink;
+ (NSString*)appVersion;

@end

SPEC_BEGIN(HEMAppReviewSpec)

describe(@"HEMAppReview", ^{

    __block NSString* databasePath = nil;

    void (^incrementUsage)(NSString*, int) = ^(NSString *identifier, int times) {
        HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:identifier];
        for(int i = 0; i < times; i++) {
            [appUsage increment:NO];
        }
        [appUsage save];
    };

    beforeEach(^{
        databasePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpAppReviewSpec"];
        [SENKeyedArchiver stub:@selector(datastorePath) andReturn:databasePath];
    });

    afterEach(^{
        [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
    });
    
    describe(@"+amazonReviewLinks", ^{
        
        it(@"should return US and UK sites", ^{
            NSDictionary* links = [HEMAppReview amazonReviewLinks];
            [[[links valueForKey:@"US"] should] beNonNil];
            [[[links valueForKey:@"GB"] should] beNonNil];
        });
        
        it(@"should return a link to the uk site if country code is GB", ^{
            NSLocale* locale = [NSLocale localeWithLocaleIdentifier:@"en_GB"];
            [NSLocale stub:@selector(currentLocale) andReturn:locale];
            NSString* link = [HEMAppReview amazonReviewLink];
            [[link should] equal:@"https://www.amazon.co.uk/review/create-review?asin=B016XBL2RE"];
        });
    });

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

        __block HEMAppUsage* usage = nil;

        beforeEach(^{
            usage = [HEMAppUsage new];
            [HEMAppUsage stub:@selector(appUsageForIdentifier:) andReturn:usage];
        });

        afterEach(^{
            usage = nil;
        });

        context(@"app prompt was never been completed", ^{

            it(@"should return yes", ^{
                BOOL yes = [HEMAppReview isWithinAppReviewThreshold];
                [[@(yes) should] beYes];
            });

        });

        context(@"app prompt was completed 30 days ago", ^{
            
            beforeEach(^{
                NSDate* daysAgo = [[NSDate date] daysFromNow:-30];
                [usage stub:@selector(updated) andReturn:daysAgo];
            });
            
            it(@"should return NO", ^{
                BOOL no = [HEMAppReview isWithinAppReviewThreshold];
                [[@(no) should] beNo];
            });
            
        });
        
        context(@"app prompt was completed 60 days ago", ^{
            
            beforeEach(^{
                NSDate* daysAgo = [[NSDate date] daysFromNow:-60];
                [usage stub:@selector(updated) andReturn:daysAgo];
            });
            
            it(@"should return NO", ^{
                BOOL no = [HEMAppReview isWithinAppReviewThreshold];
                [[@(no) should] beNo];
            });
            
        });
        
        context(@"app prompt was completed 61 days ago", ^{
            
            beforeEach(^{
                NSDate* daysAgo = [[NSDate date] daysFromNow:-61];
                [usage stub:@selector(updated) andReturn:daysAgo];
            });
            
            it(@"should return YES", ^{
                BOOL yes = [HEMAppReview isWithinAppReviewThreshold];
                [[@(yes) should] beYes];
            });
            
        });

    });
    
    describe(@"+meetsMinimumRequiredTimelineViews", ^{
        
        NSString* identifier = HEMAppUsageTimelineShownWithData;
        
        it(@"should return no if usage indicate no timeline with data seen before", ^{
            BOOL no = [HEMAppReview meetsMinimumRequiredTimelineViews];
            [[@(no) should] beNo];
        });
        
        context(@"has seen 4 timelines with data", ^{
            
            beforeEach(^{
                incrementUsage(identifier, 4);
            });
            
            it(@"should return NO", ^{
                BOOL no = [HEMAppReview meetsMinimumRequiredTimelineViews];
                [[@(no) should] beNo];
            });
            
        });
        
        context(@"has seen 6 timelines with data", ^{
            
            beforeEach(^{
                incrementUsage(identifier, 6);
            });
            
            it(@"should return YES", ^{
                BOOL yes = [HEMAppReview meetsMinimumRequiredTimelineViews];
                [[@(yes) should] beYes];
            });
            
        });
        
    });
    
    describe(@"+meetsMinimumRequiredAppLaunches", ^{
        
        NSString* identifier = HEMAppUsageAppLaunched;
        
        it(@"should return no if usage indicate no app launches", ^{
            BOOL no = [HEMAppReview meetsMinimumRequiredAppLaunches];
            [[@(no) should] beNo];
        });
        
        context(@"has launched 2 times", ^{
            
            beforeEach(^{
                incrementUsage(identifier, 2);
            });
            
            it(@"should return NO", ^{
                BOOL no = [HEMAppReview meetsMinimumRequiredAppLaunches];
                [[@(no) should] beNo];
            });
            
        });
        
        context(@"has launched 4 times in last 7 days", ^{
            
            beforeEach(^{
                incrementUsage(identifier, 4);
            });
            
            it(@"should return YES", ^{
                [[@([HEMAppReview meetsMinimumRequiredAppLaunches]) should] beYes];
            });
            
        });
        
    });

    describe(@"+incrementAppUsageForIdentifier:", ^{

        NSString* identifier = @"stuff done";

        it(@"increases usage by 1", ^{
            [HEMAppUsage incrementUsageForIdentifier:identifier];
            HEMAppUsage* usage = [HEMAppUsage appUsageForIdentifier:identifier];
            [[@([usage usageWithin:HEMAppUsageIntervalLast7Days]) should] equal:@1];
        });
    });
    
    describe(@"+isWithinSystemAlertThreshold", ^{
        
        NSString* identifier = HEMAppUsageSystemAlertShown;
        
        it(@"should return yes if usage indicate no system alert ever seen", ^{
            BOOL yes = [HEMAppReview isWithinSystemAlertThreshold];
            [[@(yes) should] beYes];
        });
        
        context(@"has seen alert today", ^{
            
            beforeEach(^{
                [HEMAppUsage incrementUsageForIdentifier:identifier];
            });
            
            it(@"should return no", ^{
                [[@([HEMAppReview isWithinSystemAlertThreshold]) should] beNo];
            });
            
        });
        
        context(@"saw a system alert 16 days ago", ^{

            beforeEach(^{
                HEMAppUsage* usage = [HEMAppUsage new];
                [HEMAppUsage stub:@selector(appUsageForIdentifier:) andReturn:usage];
                NSDate* daysAgo = [[NSDate date] daysFromNow:-16];
                [usage stub:@selector(updated) andReturn:daysAgo];
            });
            
            it(@"should return YES", ^{
                BOOL yes = [HEMAppReview isWithinSystemAlertThreshold];
                [[@(yes) should] beYes];
            });
            
        });
        
    });
    
    describe(@"+hasStatedToStopAsking", ^{
        
        NSString* key = @"stop.asking.to.rate.app";

        context(@"never stated", ^{

            beforeEach(^{
                SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
                [localPrefs setPersistentPreference:nil forKey:key];
            });

            it(@"returns no", ^{
                BOOL no = [HEMAppReview hasStatedToStopAsking];
                [[@(no) should] beNo];
            });
        });

        context(@"stated", ^{

            beforeEach(^{
                SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
                [localPrefs setPersistentPreference:@(YES) forKey:key];
            });

            it(@"returns yes", ^{
                BOOL yes = [HEMAppReview hasStatedToStopAsking];
                [[@(yes) should] beYes];
            });
        });
    });
    
    describe(@"+hasNotYetReviewedThisVersion", ^{
        
        it(@"should return yes if never attempted to rate app before", ^{
            BOOL yes = [HEMAppReview hasNotYetReviewedThisVersion];
            [[@(yes) should] beYes];
        });
        
        context(@"has rated the app before for this version", ^{
            
            beforeEach(^{
                NSString* appVersion = @"1.1.1";
                [HEMAppUsage incrementUsageForIdentifier:appVersion];
                [HEMAppReview stub:@selector(appVersion) andReturn:appVersion];
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
            
            it(@"should return yes", ^{
                BOOL yes = [HEMAppReview hasNotYetReviewedThisVersion];
                [[@(yes) should] beYes];
            });
            
        });
        
    });

});

SPEC_END
