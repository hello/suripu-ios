//
//  HEMHealthKitServiceSpec.m
//  Sense
//
//  Created by Jimmy Lu on 1/19/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <HealthKit/HealthKit.h>
#import <SenseKit/SENTimeline.h>
#import <SenseKit/SENAPITimeline.h>
#import "HEMHealthKitService.h"

@interface HEMHealthKitService()

@property (nonatomic, strong) HKHealthStore* hkStore;

- (NSArray*)sleepDataPointsForSleepResult:(SENTimeline*)sleepResult;
- (BOOL)isHealthKitEnabled;
- (BOOL)timelineHasSufficientData:(SENTimeline*)timeline;
- (void)syncRecentMissingDays:(void(^)(NSError* error))completion;
- (NSDate*)lastSyncDate;
- (void)syncTimelineDataFrom:(NSDate*)startDate
                       until:(NSDate*)endDate
                withCalendar:(NSCalendar*)calendar
                  completion:(void(^)(NSArray* timelines, NSError* error))completion;
- (void)timelineForDate:(NSDate*)date
             completion:(void(^)(SENTimeline* timeline, NSError* error))completion;
- (void)syncTimelinesToHealthKit:(NSArray*)timelines completion:(void(^)(NSError* error))completion;
- (HKSample*)sleepSampleFromTimeline:(SENTimeline*)timeline;

@end

SPEC_BEGIN(HEMHealthKitServiceSpec)

describe(@"HEMHealthKitService", ^{
    
    describe(@"-isSupported", ^{
        
        afterEach(^{
            HEMHealthKitService* service = [HEMHealthKitService new];
            [service clearStubs];
        });
        
        it(@"should return NO if healthstore is unavailable", ^{
            
            HEMHealthKitService* service = [HEMHealthKitService new];
            [service setHkStore:nil];
            BOOL supported = [service isSupported];
            [[@(supported) should] beNo];
            
        });
        
        it(@"should return YES if healthstore is available", ^{
            
            HEMHealthKitService* service = [HEMHealthKitService new];
            [service setHkStore:[[HKHealthStore alloc] init]];
            BOOL supported = [service isSupported];
            [[@(supported) should] beYes];
            
        });
        
    });
    
    describe(@"-canWriteSleepAnalysis", ^{
        
        it(@"should return NO if hk store returns not authorized", ^{
            [HKHealthStore stub:@selector(isHealthDataAvailable) andReturn:@(YES)];
            HEMHealthKitService* service = [HEMHealthKitService new];
            [service setHkStore:[[HKHealthStore alloc] init]];
            [[service hkStore] stub:@selector(authorizationStatusForType:)
                          andReturn:[KWValue valueWithInteger:HKAuthorizationStatusNotDetermined]];
            BOOL canWrite = [service canWriteSleepAnalysis];
            [[@(canWrite) should] beNo];
            
        });
        
        it(@"should return YES, if authorization is provided", ^{
            
            HEMHealthKitService* service = [HEMHealthKitService new];
            HKHealthStore* store = [[HKHealthStore alloc] init];
            [store stub:@selector(authorizationStatusForType:) withBlock:^id(NSArray *params) {
                return theValue(HKAuthorizationStatusSharingAuthorized);
            }];
            [service setHkStore:store];
            
            BOOL canWrite = [service canWriteSleepAnalysis];
            [[@(canWrite) should] beYes];
            
        });
        
    });
    
    describe(@"-sync:", ^{
        
        __block HEMHealthKitService* service = nil;
        __block NSError* syncError = nil;
        __block BOOL syncCompleted = NO;
        
        beforeEach(^{
            service = [HEMHealthKitService new];
        });
        
        context(@"healthkit is not not enabled as a preference", ^{
            
            beforeEach(^{
                [service stub:@selector(isHealthKitEnabled) andReturn:[KWValue valueWithBool:NO]];
                [service stub:@selector(isSupported) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(canWriteSleepAnalysis) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(syncRecentMissingDays:) withBlock:^id(NSArray *params) {
                    void(^cb)(NSError* error) = [params lastObject];
                    syncCompleted = YES;
                    cb (nil);
                    return nil;
                }];
                [service sync:^(NSError *error) {
                    syncError = error;
                }];
            });
            
            afterEach(^{
                syncCompleted = NO;
                syncError = nil;
                [service clearStubs];
            });
            
            it(@"should return with not enabled error", ^{
                [[syncError shouldNot] beNil];
                [[@([syncError code]) should] equal:@(HEMHKServiceErrorNotEnabled)];
            });
            
            it(@"should not have completed a sync to get the error", ^{
                [[@(syncCompleted) shouldNot] beYes];
            });
            
        });
        
        context(@"device / iOS does not support HealthKit", ^{
            
            beforeEach(^{
                [service stub:@selector(isHealthKitEnabled) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(isSupported) andReturn:[KWValue valueWithBool:NO]];
                [service stub:@selector(canWriteSleepAnalysis) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(syncRecentMissingDays:) withBlock:^id(NSArray *params) {
                    void(^cb)(NSError* error) = [params lastObject];
                    syncCompleted = YES;
                    cb (nil);
                    return nil;
                }];
                [service sync:^(NSError *error) {
                    syncError = error;
                }];
            });
            
            afterEach(^{
                syncCompleted = NO;
                syncError = nil;
                [service clearStubs];
            });
            
            it(@"should return error saying not supported", ^{
                [[syncError shouldNot] beNil];
                [[@([syncError code]) should] equal:@(HEMHKServiceErrorNotSupported)];
            });
            
            it(@"should not have completed a sync to get the error", ^{
                [[@(syncCompleted) shouldNot] beYes];
            });
            
        });
        
        context(@"user did not give permissions for Sense to access health data", ^{
            
            beforeEach(^{
                [service stub:@selector(isHealthKitEnabled) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(isSupported) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(canWriteSleepAnalysis) andReturn:[KWValue valueWithBool:NO]];
                [service stub:@selector(syncRecentMissingDays:) withBlock:^id(NSArray *params) {
                    void(^cb)(NSError* error) = [params lastObject];
                    syncCompleted = YES;
                    cb (nil);
                    return nil;
                }];
                [service sync:^(NSError *error) {
                    syncError = error;
                }];
            });
            
            afterEach(^{
                syncCompleted = NO;
                syncError = nil;
                [service clearStubs];
            });
            
            it(@"should return error stating not authorized", ^{
                [[syncError shouldNot] beNil];
                [[@([syncError code]) should] equal:@(HEMHKServiceErrorNotAuthorized)];
            });
            
            it(@"should not have completed a sync to get the error", ^{
                [[@(syncCompleted) shouldNot] beYes];
            });
            
        });
        
        context(@"HealthKit is supported, enabled, and authorized", ^{
            
            beforeEach(^{
                [service stub:@selector(isHealthKitEnabled) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(isSupported) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(canWriteSleepAnalysis) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(syncRecentMissingDays:) withBlock:^id(NSArray *params) {
                    void(^cb)(NSError* error) = [params lastObject];
                    syncCompleted = YES;
                    cb (nil);
                    return nil;
                }];
                [service sync:^(NSError *error) {
                    syncError = error;
                }];
            });
            
            afterEach(^{
                syncCompleted = NO;
                syncError = nil;
                [service clearStubs];
            });
            
            it(@"should not return an error", ^{
                [[syncError should] beNil];
            });
            
            it(@"should have completed a sync, since it's stubbed", ^{
                [[@(syncCompleted) should] beYes];
            });
            
        });
        
    });
    
    describe(@"-syncRecentMissingDays:", ^{
        
        __block HEMHealthKitService* service = nil;
        __block NSDate* startSyncDate = nil;
        __block NSDate* endSyncDate = nil;
        __block NSDate* lastNight = nil;
        __block BOOL calledBack = NO;
        __block NSError* syncError = nil;
        __block NSCalendar* calendar = nil;
        
        beforeEach(^{
            calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSCalendarUnit unitsWeCareAbout = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
            NSDateComponents* todayComponents = [calendar components:unitsWeCareAbout fromDate:[NSDate date]];
            NSDate* today = [calendar dateFromComponents:todayComponents];
            
            NSDateComponents* lastNightComponents = [[NSDateComponents alloc] init];
            [lastNightComponents setDay:-1];
            lastNight = [calendar dateByAddingComponents:lastNightComponents toDate:today options:0];
            
            service = [HEMHealthKitService new];
        });
        
        afterEach(^{
            service = nil;
            startSyncDate = nil;
            endSyncDate = nil;
            lastNight = nil;
            calledBack = NO;
            syncError = nil;
            calendar = nil;
        });
        
        context(@"never sync'ed successfully before", ^{
            
            beforeEach(^{
                [service stub:@selector(lastSyncDate) andReturn:nil];
                [service stub:@selector(syncTimelineDataFrom:until:withCalendar:completion:)
                    withBlock:^id(NSArray *params) {
                        startSyncDate = [params firstObject];
                        endSyncDate = params[1];
                        void(^cb)(NSArray* timelines, NSError* error) = [params lastObject];
                        cb (@[[SENTimeline new]], nil);
                        return nil;
                    }];
                
                [service syncRecentMissingDays:^(NSError *error) {
                    calledBack = YES;
                    syncError = error;
                }];
            });
            
            afterEach(^{
                [service clearStubs];
                calledBack = NO;
                startSyncDate = nil;
                endSyncDate = nil;
                syncError = nil;
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have encountered error", ^{
                [[syncError should] beNil];
            });
            
            it(@"should try and sync with last night as the start date", ^{
                [[startSyncDate should] equal:lastNight];
            });
            
            it(@"should have end syc date equal to last night", ^{
                [[endSyncDate should] equal:lastNight];
            });
            
        });
        
        context(@"sync'ed data from 2 nights ago", ^{
            
            __block NSDate* lastWrittenDate = nil;
            
            beforeEach(^{
                // last sync date is the date of sleep that was last sync'ed, which
                // if means if it sync'ed yesterday, it it's two nights ago
                NSDateComponents* backFillComps = [[NSDateComponents alloc] init];
                [backFillComps setDay:-1];
                lastWrittenDate = [calendar dateByAddingComponents:backFillComps toDate:lastNight options:0];
                
                [service stub:@selector(lastSyncDate) andReturn:lastWrittenDate];
                [service stub:@selector(syncTimelineDataFrom:until:withCalendar:completion:)
                    withBlock:^id(NSArray *params) {
                        startSyncDate = [params firstObject];
                        endSyncDate = params[1];
                        void(^cb)(NSArray* timelines, NSError* error) = [params lastObject];
                        cb (@[[SENTimeline new]], nil);
                        return nil;
                    }];
                
                [service syncRecentMissingDays:^(NSError *error) {
                    calledBack = YES;
                    syncError = error;
                }];
            });
            
            afterEach(^{
                [service clearStubs];
                calledBack = NO;
                startSyncDate = nil;
                endSyncDate = nil;
                syncError = nil;
            });
            
            it(@"should sync just last night", ^{
                [[startSyncDate should] equal:lastNight];
            });
            
            it(@"should set end sync date to be last night", ^{
                [[endSyncDate should] equal:lastNight];
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have returned an error", ^{
                [[syncError should] beNil];
            });
            
        });
        
        context(@"sync'ed data from 3 nights ago", ^{
            
            __block NSDate* lastWrittenDate = nil;
            
            beforeEach(^{
                NSDateComponents* backFillComps = [[NSDateComponents alloc] init];
                [backFillComps setDay:-2];
                lastWrittenDate = [calendar dateByAddingComponents:backFillComps
                                                            toDate:lastNight
                                                           options:0];
                
                [service stub:@selector(lastSyncDate) andReturn:lastWrittenDate];
                [service stub:@selector(syncTimelineDataFrom:until:withCalendar:completion:)
                    withBlock:^id(NSArray *params) {
                        startSyncDate = [params firstObject];
                        endSyncDate = params[1];
                        void(^cb)(NSArray* timeine, NSError* error) = [params lastObject];
                        cb (@[[SENTimeline new], [SENTimeline new], [SENTimeline new]], nil);
                        return nil;
                    }];
                
                [service syncRecentMissingDays:^(NSError *error) {
                    calledBack = YES;
                    syncError = error;
                }];
            });
            
            afterEach(^{
                [service clearStubs];
                calledBack = NO;
                startSyncDate = nil;
                endSyncDate = nil;
                syncError = nil;
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have encountered error", ^{
                [[syncError should] beNil];
            });
            
            it(@"should try and sync from the day after last sync'ed", ^{
                NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                                           fromDate:lastWrittenDate
                                                             toDate:startSyncDate
                                                            options:0];
                [[@([difference day]) should] equal:@1];
            });
            
            it(@"should sync until last night", ^{
                [[endSyncDate should] equal:lastNight];
            });
            
        });
        
        context(@"sync'ed before, 4 days before last night", ^{
            
            __block NSDate* lastWrittenDate = nil;
            
            beforeEach(^{
                NSDateComponents* backFillComps = [[NSDateComponents alloc] init];
                [backFillComps setDay:-4];
                lastWrittenDate = [calendar dateByAddingComponents:backFillComps toDate:lastNight options:0];
                
                [service stub:@selector(lastSyncDate) andReturn:lastWrittenDate];
                [service stub:@selector(syncTimelineDataFrom:until:withCalendar:completion:)
                    withBlock:^id(NSArray *params) {
                        startSyncDate = [params firstObject];
                        endSyncDate = params[1];
                        void(^cb)(NSArray* timelines, NSError* error) = [params lastObject];
                        cb (@[[SENTimeline new], [SENTimeline new], [SENTimeline new], [SENTimeline new], [SENTimeline new]], nil);
                        return nil;
                    }];
                
                [service syncRecentMissingDays:^(NSError *error) {
                    calledBack = YES;
                    syncError = error;
                }];
            });
            
            afterEach(^{
                [service clearStubs];
                calledBack = NO;
                startSyncDate = nil;
                endSyncDate = nil;
                syncError = nil;
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have encountered error", ^{
                [[syncError should] beNil];
            });
            
            it(@"should sync from the limit of 3 nights, last night plus 2 more", ^{
                NSDateComponents* backFillComps = [[NSDateComponents alloc] init];
                [backFillComps setDay:-2];
                NSDate* startDate = [calendar dateByAddingComponents:backFillComps
                                                              toDate:lastNight
                                                             options:0];
                [[startSyncDate should] equal:startDate];
            });
            
            it(@"should sync until last night", ^{
                [[endSyncDate should] equal:lastNight];
            });
            
        });
        
    });
    
    describe(@"-timelineForDate:completion:", ^{
        
        __block HEMHealthKitService* service = nil;
        __block BOOL apiCalled = NO;
        __block BOOL calledBack = NO;
        __block NSError* timelineError = nil;
        
        beforeEach(^{
            service = [HEMHealthKitService new];
        });
        
        afterEach(^{
            [SENAPITimeline clearStubs];
        });
        
        context(@"device has local timeline data", ^{
            
            beforeEach(^{
                SENTimeline* timeline = [[SENTimeline alloc] init];
                [timeline setScoreCondition:SENConditionIdeal];
                [timeline setMetrics:@[[SENTimelineMetric new]]];
                [SENTimeline stub:@selector(timelineForDate:) andReturn:timeline];
                [SENAPITimeline stub:@selector(timelineForDate:completion:) withBlock:^id(NSArray *params) {
                    void(^cb)(SENTimeline* timeline, NSError* error) = [params lastObject];
                    cb([SENTimeline new], nil);
                    apiCalled = YES;
                    return nil;
                }];
                [service timelineForDate:[NSDate date] completion:^(SENTimeline *timeline, NSError *error) {
                    calledBack = YES;
                    timelineError = error;
                }];
            });
            
            afterEach(^{
                [SENTimeline clearStubs];
                [SENAPITimeline clearStubs];
                apiCalled = NO;
                calledBack = NO;
                timelineError = nil;
            });
            
            it(@"should call back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return error", ^{
                [[timelineError should] beNil];
            });
            
            it(@"should not call api", ^{
                [[@(apiCalled) should] beNo];
            });
            
        });
        
        context(@"device does not have local timeline data, api returns timeline", ^{
            
            beforeEach(^{
                [SENTimeline stub:@selector(timelineForDate:) andReturn:nil];
                [SENAPITimeline stub:@selector(timelineForDate:completion:) withBlock:^id(NSArray *params) {
                    void(^cb)(SENTimeline* timeline, NSError* error) = [params lastObject];
                    cb([SENTimeline new], nil);
                    apiCalled = YES;
                    return nil;
                }];
                [service timelineForDate:[NSDate date] completion:^(SENTimeline *timeline, NSError *error) {
                    calledBack = YES;
                    timelineError = error;
                }];
            });
            
            afterEach(^{
                [SENTimeline clearStubs];
                [SENAPITimeline clearStubs];
                apiCalled = NO;
                calledBack = NO;
                timelineError = nil;
            });
            
            it(@"should call back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return error", ^{
                [[timelineError should] beNil];
            });
            
            it(@"should call api", ^{
                [[@(apiCalled) should] beYes];
            });
            
        });
        
        context(@"device does not have local timeline data, api returns junk", ^{
            
            beforeEach(^{
                [SENTimeline stub:@selector(timelineForDate:) andReturn:nil];
                [SENAPITimeline stub:@selector(timelineForDate:completion:) withBlock:^id(NSArray *params) {
                    void(^cb)(id data, NSError* error) = [params lastObject];
                    cb([NSArray array], nil);
                    apiCalled = YES;
                    return nil;
                }];
                [service timelineForDate:[NSDate date] completion:^(SENTimeline *timeline, NSError *error) {
                    calledBack = YES;
                    timelineError = error;
                }];
            });
            
            afterEach(^{
                [SENTimeline clearStubs];
                [SENAPITimeline clearStubs];
                apiCalled = NO;
                calledBack = NO;
                timelineError = nil;
            });
            
            it(@"should call back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should return unexpected api response error", ^{
                [[timelineError shouldNot] beNil];
                [[@([timelineError code]) should] equal:@(HEMHKServiceErrorUnexpectedAPIResponse)];
            });
            
            it(@"should call api", ^{
                [[@(apiCalled) should] beYes];
            });
            
        });
        
    });
    
    describe(@"-syncTimelineDataFrom:until:withCalendar:completion", ^{
        
        __block HEMHealthKitService* service = nil;
        __block NSCalendar* calendar = nil;
        __block NSDate* lastNight = nil;
        __block NSDate* today = nil;
        
        beforeEach(^{
            calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSCalendarUnit unitsWeCareAbout = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
            NSDateComponents* todayComponents = [calendar components:unitsWeCareAbout fromDate:[NSDate date]];
            today = [calendar dateFromComponents:todayComponents];
            
            NSDateComponents* lastNightComponents = [[NSDateComponents alloc] init];
            [lastNightComponents setDay:-1];
            lastNight = [calendar dateByAddingComponents:lastNightComponents toDate:today options:0];
            
            service = [HEMHealthKitService new];
            [service stub:@selector(timelineForDate:completion:) withBlock:^id(NSArray *params) {
                void(^cb)(SENTimeline *timeline, NSError *error) = [params lastObject];
                cb ([[SENTimeline alloc] init], nil);
                return nil;
            }];
            
            [service stub:@selector(syncTimelinesToHealthKit:completion:) withBlock:^id(NSArray *params) {
                void(^cb)(NSError* error) = [params lastObject];
                cb (nil);
                return nil;
            }];
        });
        
        afterEach(^{
            [service clearStubs];
        });
        
        context(@"up to date in syncing, except last night", ^{
            
            __block BOOL syncCallback = NO;
            __block NSError* syncError = nil;
            __block NSUInteger numberOfTimelinesToSync = 0;
            
            beforeAll(^{
                [service syncTimelineDataFrom:lastNight until:lastNight withCalendar:calendar completion:^(NSArray* timelines, NSError *error) {
                    numberOfTimelinesToSync = [timelines count];
                    syncCallback = YES;
                    syncError = error;
                }];
            });
            
            afterAll(^{
                numberOfTimelinesToSync = 0;
                syncCallback = NO;
                syncError = nil;
                [service clearStubs];
            });
            
            it(@"should attempt to sync 1 timelines", ^{
                [[expectFutureValue(@(numberOfTimelinesToSync)) shouldEventually] equal:@1];
            });
            
            it(@"should call back", ^{
                [[expectFutureValue(@(syncCallback)) shouldEventually] beYes];
            });
            
            it(@"should not return an error", ^{
                [[expectFutureValue(syncError) shouldEventually] beNil];
            });
            
        });
        
        context(@"starts from today (day after last night)", ^{
            
            __block BOOL syncCallback = NO;
            __block NSError* syncError = nil;
            __block NSUInteger numberOfTimelinesToSync = 0;
            
            beforeAll(^{
                [service syncTimelineDataFrom:[NSDate date] until:lastNight withCalendar:calendar completion:^(NSArray* timelines, NSError *error) {
                    numberOfTimelinesToSync = [timelines count];
                    syncCallback = YES;
                    syncError = error;
                }];
            });
            
            afterAll(^{
                numberOfTimelinesToSync = 0;
                syncCallback = NO;
                syncError = nil;
                [service clearStubs];
            });
            
            it(@"should not return any timelines to sync", ^{
                [[expectFutureValue(@(numberOfTimelinesToSync)) shouldEventually] equal:@0];
            });
            
            it(@"should call back", ^{
                [[expectFutureValue(@(syncCallback)) shouldEventually] beYes];
            });
            
            it(@"should return an error with no data to write", ^{
                [[expectFutureValue(@([syncError code])) shouldEventually] equal:@(HEMHKServiceErrorNoDataToWrite)];
            });
            
        });
        
    });
    
    describe(@"-timelineHasSufficientData:", ^{
        
        __block HEMHealthKitService* service = nil;
        
        beforeAll(^{
            service = [HEMHealthKitService new];
        });
        
        it(@"should return NO when timeline is nil", ^{
            BOOL hasData = [service timelineHasSufficientData:nil];
            [[@(hasData) should] beNo];
        });
        
        it(@"should return NO if timeline condition is unknown", ^{
            SENTimeline* timeline = [SENTimeline new];
            [timeline setScoreCondition:SENConditionUnknown];
            [timeline setMetrics:@[[SENTimelineMetric new]]];
            BOOL hasData = [service timelineHasSufficientData:timeline];
            [[@(hasData) should] beNo];
        });
        
        it(@"should return NO if timeline condition is incomplete", ^{
            SENTimeline* timeline = [SENTimeline new];
            [timeline setScoreCondition:SENConditionIncomplete];
            [timeline setMetrics:@[[SENTimelineMetric new]]];
            BOOL hasData = [service timelineHasSufficientData:timeline];
            [[@(hasData) should] beNo];
        });
        
        it(@"should return NO if timeline has no metrics", ^{
            SENTimeline* timeline = [SENTimeline new];
            [timeline setScoreCondition:SENConditionIdeal];
            [timeline setMetrics:nil];
            BOOL hasData = [service timelineHasSufficientData:timeline];
            [[@(hasData) should] beNo];
        });
        
        it(@"should return YES if timeline has at least 1 metric and condition is not unknown or incomplete", ^{
            SENTimeline* timeline = [SENTimeline new];
            [timeline setScoreCondition:SENConditionIdeal];
            [timeline setMetrics:@[[SENTimelineMetric new]]];
            BOOL hasData = [service timelineHasSufficientData:timeline];
            [[@(hasData) should] beYes];
        });
        
    });
    
    describe(@"-sleepSampleFromTimeline:", ^{
        
        __block HEMHealthKitService* service = nil;
        
        beforeAll(^{
            service = [HEMHealthKitService new];
        });
        
        it(@"should return nil if timeline does not have sufficient data", ^{
            SENTimeline* timeline = [SENTimeline new];
            [timeline setScoreCondition:SENConditionIncomplete];
            [timeline setMetrics:@[[SENTimelineMetric new]]];
            HKSample* sample = [service sleepSampleFromTimeline:timeline];
            [[sample should] beNil];
        });
        
        it(@"should return HKSample if timeline contains sufficient data, including sleep and wake metrics", ^{
            NSTimeInterval nowInSecs = [NSDate timeIntervalSinceReferenceDate];
            SENTimelineMetric* sleepMetric = [SENTimelineMetric new];
            [sleepMetric setName:@"fell_asleep"];
            [sleepMetric setUnit:SENTimelineMetricUnitTimestamp];
            [sleepMetric setType:SENTimelineMetricTypeFellAsleep];
            [sleepMetric setValue:@((nowInSecs- 28800) * 1000)];
            
            SENTimelineMetric* wakeMetric = [SENTimelineMetric new];
            [wakeMetric setName:@"woke_up"];
            [wakeMetric setUnit:SENTimelineMetricUnitTimestamp];
            [wakeMetric setType:SENTimelineMetricTypeWokeUp];
            [wakeMetric setValue:@(nowInSecs * 1000)];
            
            SENTimeline* timeline = [SENTimeline new];
            [timeline setScoreCondition:SENConditionIdeal];
            [timeline setMetrics:@[sleepMetric, wakeMetric]];
            id sample = [service sleepSampleFromTimeline:timeline];
            [[sample should] beKindOfClass:[HKSample class]];
        });
        
    });
    
});

SPEC_END
