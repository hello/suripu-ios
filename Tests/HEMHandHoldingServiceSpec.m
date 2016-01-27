//
//  HEMHandHoldingServiceSpec.m
//  Sense
//
//  Created by Jimmy Lu on 1/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/API.h>
#import <SenseKit/Model.h>
#import <SenseKit/SENLocalPreferences.h>
#import "HEMHandHoldingService.h"
#import "HEMAppUsage.h"
#import "NSDate+HEMRelative.h"

@interface HEMHandHoldingService()

@property (nonatomic, strong) NSMutableDictionary* tutorialRecordKeeper;

- (BOOL)shouldShowInsightTap;
- (BOOL)shouldShowTimelineSwipe;
- (BOOL)shouldShowTimelineZoom;
- (BOOL)isFirstAppUsage:(NSString*)usageName atLeast:(NSInteger)days;
- (BOOL)isComplete:(HEMHandHolding)tutorial;

@end

@interface HEMAppUsage()

@property (nonatomic, strong) NSDate* created;

@end

SPEC_BEGIN(HEMHandHoldingServiceSpec)

describe(@"HEMHandHoldingService", ^{
    
    describe(@"-init", ^{
        
        context(@"upgrade from older version", ^{
            
            __block HEMHandHoldingService* service = nil;
            __block BOOL savedRecords = NO;
            
            beforeEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs stub:@selector(persistentPreferenceForKey:) andReturn:nil];
                
                [prefs stub:@selector(setPersistentPreference:forKey:) withBlock:^id(NSArray *params) {
                    savedRecords = YES;
                    return nil;
                }];
                
                service = [HEMHandHoldingService new];
            });
            
            afterEach(^{
                [[SENLocalPreferences sharedPreferences] clearStubs];
                service = nil;
                savedRecords = NO;
            });
            
            it(@"should create new dictionary of records", ^{
                [[[service tutorialRecordKeeper] should] beNonNil];
            });
            
            it(@"should have set the new records in local prefs", ^{
                [[@(savedRecords) should] beYes];
            });
            
        });
        
        context(@"records already created", ^{
            
            __block HEMHandHoldingService* service = nil;
            __block BOOL savedRecords = NO;
            __block NSMutableDictionary* records = nil;
            
            beforeEach(^{
                records = [@{@"test" : @1} mutableCopy];
                
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs stub:@selector(persistentPreferenceForKey:) andReturn:records];
                
                [prefs stub:@selector(setPersistentPreference:forKey:) withBlock:^id(NSArray *params) {
                    savedRecords = YES;
                    return nil;
                }];
                
                service = [HEMHandHoldingService new];
            });
            
            afterEach(^{
                [[SENLocalPreferences sharedPreferences] clearStubs];
                service = nil;
                savedRecords = NO;
                records = nil;
            });
            
            it(@"should return saved records", ^{
                [[[service tutorialRecordKeeper] should] equal:records];
            });
            
            it(@"should not have set the records in local prefs again", ^{
                [[@(savedRecords) should] beNo];
            });
            
        });
        
    });
    
    describe(@"-isFirstAppUsage:atLeast:", ^{
        
        context(@"never seen the app usage stat before", ^{
            
            __block HEMHandHoldingService* service = nil;
            
            beforeEach(^{
                service = [HEMHandHoldingService new];
                
                HEMAppUsage* fakeUsage = [HEMAppUsage new];
                [HEMAppUsage stub:@selector(appUsageForIdentifier:) andReturn:fakeUsage];
            });
            
            afterEach(^{
                [HEMAppUsage clearStubs];
            });
            
            it(@"should return YES if 0 days passed in", ^{
                BOOL result = [service isFirstAppUsage:@"test" atLeast:0];
                [[@(result) should] beYes];
            });
            
            it(@"should return NO if 1 day passed in", ^{
                BOOL result = [service isFirstAppUsage:@"test" atLeast:1];
                [[@(result) should] beNo];
            });
            
        });
        
        context(@"app usage stat created yesterday", ^{
            
            __block HEMHandHoldingService* service = nil;
            __block HEMAppUsage* fakeUsage = nil;
            
            beforeEach(^{
                service = [HEMHandHoldingService new];
                
                fakeUsage = [HEMAppUsage new];
                [fakeUsage setCreated:[[NSDate date] previousDay]];
                [HEMAppUsage stub:@selector(appUsageForIdentifier:) andReturn:fakeUsage];
            });
            
            afterEach(^{
                fakeUsage = nil;
                service = nil;
                [HEMAppUsage clearStubs];
            });
            
            it(@"should return YES if 0 days passed in", ^{
                BOOL result = [service isFirstAppUsage:@"test" atLeast:0];
                [[@(result) should] beYes];
            });
            
            it(@"should return YES if 1 day passed in", ^{
                BOOL result = [service isFirstAppUsage:@"test" atLeast:1];
                [[@(result) should] beYes];
            });
            
        });
        
    });
    
    describe(@"-shouldShowTimelineSwipe", ^{
        
        context(@"the open timeline tutorial has not been completed, but meets reqs", ^{
            
            __block HEMHandHoldingService* service = nil;
            
            beforeEach(^{
                service = [HEMHandHoldingService new];
                [service stub:@selector(isComplete:) andReturn:[KWValue valueWithBool:NO]];
                [service stub:@selector(isFirstAppUsage:atLeast:) andReturn:[KWValue valueWithBool:YES]];
            });
            
            afterEach(^{
                [service clearStubs];
                service = nil;
            });
            
            it(@"should return NO, even if it meets requirements", ^{
                BOOL show = [service shouldShowTimelineSwipe];
                [[@(show) should] beNo];
            });
            
        });
        
        context(@"the open timeline tutorial has been completed and meets reqs", ^{
            
            __block HEMHandHoldingService* service = nil;
            
            beforeEach(^{
                service = [HEMHandHoldingService new];
                [service stub:@selector(isComplete:) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(isFirstAppUsage:atLeast:) andReturn:[KWValue valueWithBool:YES]];
            });
            
            afterEach(^{
                [service clearStubs];
                service = nil;
            });
            
            it(@"should return YES", ^{
                BOOL show = [service shouldShowTimelineSwipe];
                [[@(show) should] beYes];
            });
            
        });
        
        context(@"the open timeline tutorial has been completed, but does not meet reqs", ^{
            
            __block HEMHandHoldingService* service = nil;
            
            beforeEach(^{
                service = [HEMHandHoldingService new];
                [service stub:@selector(isComplete:) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(isFirstAppUsage:atLeast:) andReturn:[KWValue valueWithBool:NO]];
            });
            
            afterEach(^{
                [service clearStubs];
                service = nil;
            });
            
            it(@"should return NO", ^{
                BOOL show = [service shouldShowTimelineSwipe];
                [[@(show) should] beNo];
            });
            
        });
        
    });
    
    describe(@"-shouldShowTimelineZoom", ^{
        
        context(@"timeline open and swipe tutorial has not been completed", ^{
            
            __block HEMHandHoldingService* service = nil;
            
            beforeEach(^{
                service = [HEMHandHoldingService new];
                [service stub:@selector(isComplete:) andReturn:[KWValue valueWithBool:NO]];
            });
            
            afterEach(^{
                [service clearStubs];
                service = nil;
            });
            
            it(@"should return NO", ^{
                BOOL show = [service shouldShowTimelineZoom];
                [[@(show) should] beNo];
            });
            
        });
        
        context(@"pre-requites met, but not enough timelines shown yet", ^{
            
            __block HEMHandHoldingService* service = nil;
            __block HEMAppUsage* fakeUsage = nil;
            
            beforeEach(^{
                service = [HEMHandHoldingService new];
                [service stub:@selector(isComplete:) andReturn:[KWValue valueWithBool:YES]];
                
                fakeUsage = [HEMAppUsage new];
                [fakeUsage stub:@selector(usageWithin:) andReturn:[KWValue valueWithInteger:1]];
                
                [HEMAppUsage stub:@selector(appUsageForIdentifier:) andReturn:fakeUsage];
            });
            
            afterEach(^{
                [fakeUsage clearStubs];
                [service clearStubs];
                service = nil;
                fakeUsage = nil;
                [HEMAppUsage clearStubs];
            });
            
            it(@"should return NO", ^{
                BOOL show = [service shouldShowTimelineZoom];
                [[@(show) should] beNo];
            });
            
        });
        
        context(@"pre-requites met and have seen tons of timeslines", ^{
            
            __block HEMHandHoldingService* service = nil;
            __block HEMAppUsage* fakeUsage = nil;
            
            beforeEach(^{
                service = [HEMHandHoldingService new];
                [service stub:@selector(isComplete:) andReturn:[KWValue valueWithBool:YES]];
                
                fakeUsage = [HEMAppUsage new];
                [fakeUsage stub:@selector(usageWithin:) andReturn:[KWValue valueWithInteger:1000]];
                
                [HEMAppUsage stub:@selector(appUsageForIdentifier:) andReturn:fakeUsage];
            });
            
            afterEach(^{
                [fakeUsage clearStubs];
                [service clearStubs];
                service = nil;
                fakeUsage = nil;
                [HEMAppUsage clearStubs];
            });
            
            it(@"should return YES", ^{
                BOOL show = [service shouldShowTimelineZoom];
                [[@(show) should] beYes];
            });
            
        });
        
    });
    
});

SPEC_END
