//
//  HEMHealthKitService.m
//  Sense
//
//  Created by Jimmy Lu on 1/19/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <HealthKit/HealthKit.h>
#import <SenseKit/SENService+Protected.h>
#import <SenseKit/Model.h>
#import <SenseKit/SENAPITimeline.h>
#import <SenseKit/SENLocalPreferences.h>

#import "HEMHealthKitService.h"

static NSString* const HEMHKServiceErrorDomain = @"is.hello.service.hk";
static NSString* const HEMHKServiceLastDateWritten = @"is.hello.service.hk.lastdate";
static NSString* const HEMHKServiceEnable = @"is.hello.service.hk.enable";
static CGFloat const HEMHKServiceBackFillLimit = 3;

@interface HEMHealthKitService()

@property (nonatomic, strong) HKHealthStore* hkStore;

@end

@implementation HEMHealthKitService

+ (id)sharedService {
    static HEMHealthKitService* service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[super alloc] init];
    });
    return service;
}

- (id)init {
    self = [super init];
    if (self) {
        [self configureStore];
    }
    return self;
}

- (void)configureStore {
    if ([HKHealthStore isHealthDataAvailable]) {
        [self setHkStore:[[HKHealthStore alloc] init]];
    }
}

#pragma mark - Preferences / Settings

- (void)setEnableHealthKit:(BOOL)enable {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    [preferences setUserPreference:@(enable) forKey:HEMHKServiceEnable];
}

- (BOOL)isHealthKitEnabled {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    return [[preferences userPreferenceForKey:HEMHKServiceEnable] boolValue];
}

- (void)saveLastSyncDate:(NSDate*)date {
    if (date == nil) {
        return;
    }
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    [preferences setUserPreference:date forKey:HEMHKServiceLastDateWritten];
}

- (NSDate*)lastSyncDate {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    return [preferences userPreferenceForKey:HEMHKServiceLastDateWritten];
}

#pragma mark - Support / Authorization

- (BOOL)isSupported {
    return [self hkStore] != nil;
}

- (BOOL)canWriteSleepAnalysis {
    if (![self isSupported]) return NO;
    HKCategoryType* hkSleepCategory = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    HKAuthorizationStatus status = [[self hkStore] authorizationStatusForType:hkSleepCategory];
    return status == HKAuthorizationStatusSharingAuthorized;
}

- (void)requestAuthorization:(void(^)(NSError* error))completion {
    if (![self isSupported]) {
        if (completion) {
            completion ([NSError errorWithDomain:HEMHKServiceErrorDomain
                                            code:HEMHKServiceErrorNotSupported
                                        userInfo:nil]);
        }
        return;
    }
    
    HKCategoryType* hkSleepCategory = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    
    NSSet* writeTypes = [NSSet setWithObject:hkSleepCategory];
    NSSet* readTypes = [NSSet setWithObject:hkSleepCategory]; // there will be more, soon
    
    [[self hkStore] requestAuthorizationToShareTypes:writeTypes readTypes:readTypes completion:^(BOOL success, NSError *error) {
        NSError* serviceError = error;
        HKAuthorizationStatus status = [[self hkStore] authorizationStatusForType:hkSleepCategory];
        switch (status) {
            case HKAuthorizationStatusSharingDenied:
                serviceError = [NSError errorWithDomain:HEMHKServiceErrorDomain
                                                   code:HEMHKServiceErrorNotAuthorized
                                               userInfo:nil];
                break;
            case HKAuthorizationStatusNotDetermined: // user cancelled form
                serviceError = [NSError errorWithDomain:HEMHKServiceErrorDomain
                                                   code:HEMHKServiceErrorCancelledAuthorization
                                               userInfo:nil];
                break;
            default:
                break;
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion (serviceError);
            });
        }
        
    }];
}

#pragma mark - Sync

- (void)sync:(void(^)(NSError* error))completion {
    void(^done)(NSError* error) = ^(NSError* error) {
        if (completion) {
            completion (error);
        }
    };
    
    BOOL enabled = [self isHealthKitEnabled];
    BOOL supported = [self isSupported];
    BOOL authorized = [self canWriteSleepAnalysis];
    
    if (enabled && supported && authorized) {
        [self syncRecentMissingDays:done];
    } else {
        HEMHKServiceError code;
        if (!enabled) {
            code = HEMHKServiceErrorNotEnabled;
        } else if (!supported) {
            code = HEMHKServiceErrorNotSupported;
        } else {
            code = HEMHKServiceErrorNotAuthorized;
        }
        done ([NSError errorWithDomain:HEMHKServiceErrorDomain code:code userInfo:nil]);
    }
}

- (void)syncRecentMissingDays:(void(^)(NSError* error))completion {
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // last night
    NSCalendarUnit unitsWeCareAbout = NSCalendarUnitYear |NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents* todayComponents = [calendar components:unitsWeCareAbout fromDate:[NSDate date]];
    NSDate* today = [calendar dateFromComponents:todayComponents];
    
    NSDateComponents* lastNightComponents = [[NSDateComponents alloc] init];
    [lastNightComponents setDay:-1];
    NSDate* lastNight = [calendar dateByAddingComponents:lastNightComponents toDate:today options:0];
    
    // last time it was sync'ed
    NSDate* lastSyncDate = [self lastSyncDate];
    NSDate* syncFromDate = nil;
    
    if (lastSyncDate) {
        NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                                   fromDate:lastSyncDate
                                                     toDate:lastNight
                                                    options:0];
        if ([difference day] == 0) {
            completion ([NSError errorWithDomain:HEMHKServiceErrorDomain
                                            code:HEMHKServiceErrorAlreadySynced
                                        userInfo:nil]);
            return;
        } else if ([difference day] == 1) {
            // special case for when user is consistently syncing everyday.  This
            // can be handled by the else case, but this just avoids having to do
            // the arithmetic
            syncFromDate = lastNight;
        } else {
            NSDateComponents* backFillComps = [[NSDateComponents alloc] init];
            [backFillComps setDay:-(MIN([difference day], HEMHKServiceBackFillLimit) - 1)];
            syncFromDate = [calendar dateByAddingComponents:backFillComps
                                                     toDate:lastNight
                                                    options:0];
        }
    } else { // if never been sync'ed before, just sync last night's data
        syncFromDate = lastNight;
    }
    
    __weak typeof(self) weakSelf = self;
    [self syncTimelineDataFrom:syncFromDate until:lastNight withCalendar:calendar completion:^(NSArray* timelines, NSError *error) {
        if (!error) {
            [weakSelf saveLastSyncDate:lastNight];
        }
        completion (error);
    }];
}

- (void)syncTimelineDataFrom:(NSDate*)startDate
                       until:(NSDate*)endDate
                withCalendar:(NSCalendar*)calendar
                  completion:(void(^)(NSArray* timelines, NSError* error))completion {
    NSCalendarUnit unitsWeCareAbout = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    NSDate* nextStartDate = startDate;
    NSDateComponents* components = nil;
    
    BOOL haveTimelines = NO;
    NSMutableArray* timelines = [NSMutableArray array];
    dispatch_group_t getTimelineGroup = dispatch_group_create();
    
    __weak typeof(self) weakSelf = self;
    while ([calendar compareDate:nextStartDate toDate:endDate toUnitGranularity:unitsWeCareAbout] != NSOrderedDescending) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        DDLogVerbose(@"retrieving timeline for date %@ to sync to healthkit", nextStartDate);
        
        haveTimelines = YES;
        
        dispatch_group_enter(getTimelineGroup);
        [strongSelf timelineForDate:nextStartDate completion:^(SENTimeline *timeline, NSError *error) {
            if (timeline) {
                [timelines addObject:timeline];
            }
            dispatch_group_leave(getTimelineGroup);
        }];
        
        components = [[NSDateComponents alloc] init];
        [components setDay:1];
        nextStartDate = [calendar dateByAddingComponents:components toDate:nextStartDate options:0];
    }
    
    if (!haveTimelines) {
        completion (nil, [NSError errorWithDomain:HEMHKServiceErrorDomain
                                             code:HEMHKServiceErrorNoDataToWrite
                                         userInfo:@{NSLocalizedDescriptionKey : @"start and end date did not evaluate to timelines"}]);
        return;
    }
    
    long queuePriority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
    dispatch_queue_t queue = dispatch_get_global_queue(queuePriority, 0);
    dispatch_group_notify(getTimelineGroup, queue, ^{
        [weakSelf syncTimelinesToHealthKit:timelines completion:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion (timelines, error);
            });
        }];
    });
    
}

- (BOOL)timelineHasSufficientData:(SENTimeline*)timeline {
    return [timeline scoreCondition] != SENConditionUnknown
        && [timeline scoreCondition] != SENConditionIncomplete
        && [[timeline segments] count] > 0;
}

- (void)timelineForDate:(NSDate*)date completion:(void(^)(SENTimeline* timeline, NSError* error))completion {
    SENTimeline* timeline = [SENTimeline timelineForDate:date];
    // if cached timeline does not have sufficient data, grab an update, if any
    if ([self timelineHasSufficientData:timeline]) {
        completion (timeline, nil);
    } else {
        [SENAPITimeline timelineForDate:date completion:^(id data, NSError *error) {
            SENTimeline* timeline = data;
            if (!error) {
                if ([timeline isKindOfClass:[SENTimeline class]]) {
                    [timeline save];
                } else {
                    timeline = nil;
                    error = [NSError errorWithDomain:HEMHKServiceErrorDomain
                                                code:HEMHKServiceErrorUnexpectedAPIResponse
                                            userInfo:nil];
                }
            }
            completion (timeline, error);
        }];
    }
}

- (void)syncTimelinesToHealthKit:(NSArray*)timelines completion:(void(^)(NSError* error))completion {
    NSUInteger timelineCount = [timelines count];
    if (timelineCount == 0) {
        completion ([NSError errorWithDomain:HEMHKServiceErrorDomain
                                        code:HEMHKServiceErrorNoDataToWrite
                                    userInfo:nil]);
        return;
    }
    
    HKSample* sample = nil;
    NSMutableArray* samples = [NSMutableArray arrayWithCapacity:timelineCount];
    
    for (SENTimeline* timeline in timelines) {
        sample = [self sleepSampleForType:HKCategoryValueSleepAnalysisInBed fromTimeline:timeline];
        if (sample) {
            [samples addObject:sample];
        }
        
        sample = [self sleepSampleForType:HKCategoryValueSleepAnalysisAsleep fromTimeline:timeline];
        if (sample) {
            [samples addObject:sample];
        }
    }
    
    if ([samples count] == 0) {
        completion ([NSError errorWithDomain:HEMHKServiceErrorDomain
                                        code:HEMHKServiceErrorNoDataToWrite
                                    userInfo:nil]);
        return;
    }
    
    [[self hkStore] saveObjects:samples withCompletion:^(BOOL success, NSError *error) {
        completion (error);
    }];
}

- (HKSample*)sleepSampleForType:(HKCategoryValueSleepAnalysis)type fromTimeline:(SENTimeline*)timeline {
    if (![self timelineHasSufficientData:timeline]) {
        return nil;
    }
    
    HKSample* sample = nil;
    NSDate* endDate = nil;
    NSDate* startDate = nil;
    NSString* timeZoneName = nil;
    
    // look for in bed event from the beginning
    for (SENTimelineSegment* segment in [timeline segments]) {
        if ((type == HKCategoryValueSleepAnalysisAsleep && [segment type] == SENTimelineSegmentTypeFellAsleep)
            || (type == HKCategoryValueSleepAnalysisInBed && [segment type] == SENTimelineSegmentTypeGotInBed)) {
            startDate = [segment date];
            timeZoneName = [[segment timezone] name];
            break;
        }
    }
    
    if (startDate) {
        // look for out of bed event from the end of the segments to reduce iterations
        for (NSInteger idx = [[timeline segments] count] - 1; idx >= 0; idx--) {
            SENTimelineSegment* segment = [timeline segments][idx];
            if ((type == HKCategoryValueSleepAnalysisAsleep && [segment type] == SENTimelineSegmentTypeWokeUp)
                || (type == HKCategoryValueSleepAnalysisInBed && [segment type] == SENTimelineSegmentTypeGotOutOfBed)) {
                endDate = [segment date];
                if (!timeZoneName) {
                    timeZoneName = [[segment timezone] name];
                }
                break;
            }
        }
    }
    
    if (startDate && endDate && [startDate compare:endDate] == NSOrderedAscending) {
        NSDictionary* metadata = nil;
        if (timeZoneName) {
            metadata = @{HKMetadataKeyTimeZone : timeZoneName};
        }
        HKCategoryType* hkSleepCategory = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
        sample = [HKCategorySample categorySampleWithType:hkSleepCategory
                                                    value:type
                                                startDate:startDate
                                                  endDate:endDate
                                                 metadata:metadata];
    }
    
    return sample;
}

@end
