//
//  SENServiceHealthKit.m
//  Pods
//
//  Created by Jimmy Lu on 1/26/15.
//
//
#import <CocoaLumberjack/DDLog.h>

#import <HealthKit/HealthKit.h>

#import "SENServiceHealthKit.h"
#import "SENService+Protected.h"
#import "SENTimeline.h"
#import "SENAPITimeline.h"
#import "SENLocalPreferences.h"

#ifndef ddLogLevel
#define ddLogLevel LOG_LEVEL_VERBOSE
#endif

static NSString* const SENServiceHKErrorDomain = @"is.hello.service.hk";
static NSString* const SENServiceHKLastDateWritten = @"is.hello.service.hk.lastdate";
static NSString* const SENServiceHKEnable = @"is.hello.service.hk.enable";
static CGFloat const SENServiceHKBackFillLimit = 3;

@interface SENServiceHealthKit()

@property (nonatomic, strong) HKHealthStore* hkStore;

@end

@implementation SENServiceHealthKit

+ (id)sharedService {
    static SENServiceHealthKit* service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[super allocWithZone:NULL] init];
    });
    return service;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedService];
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
    [preferences setUserPreference:@(enable) forKey:SENServiceHKEnable];
}

- (BOOL)isHealthKitEnabled {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    return [[preferences userPreferenceForKey:SENServiceHKEnable] boolValue];
}

- (void)saveLastWrittenDate:(NSDate*)date {
    if (date == nil) {
        return;
    }
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    [preferences setUserPreference:date forKey:SENServiceHKLastDateWritten];
}

- (NSDate*)lastWrittenDate {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    return [preferences userPreferenceForKey:SENServiceHKLastDateWritten];
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
            completion ([NSError errorWithDomain:SENServiceHKErrorDomain
                                            code:SENServiceHealthKitErrorNotSupported
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
                serviceError = [NSError errorWithDomain:SENServiceHKErrorDomain
                                                   code:SENServiceHealthKitErrorNotAuthorized
                                               userInfo:nil];
                break;
            case HKAuthorizationStatusNotDetermined: // user cancelled form
                serviceError = [NSError errorWithDomain:SENServiceHKErrorDomain
                                                   code:SENServiceHealthKitErrorCancelledAuthorization
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
        SENServiceHealthKitError code;
        if (!enabled) {
            code = SENServiceHealthKitErrorNotEnabled;
        } else if (!supported) {
            code = SENServiceHealthKitErrorNotSupported;
        } else {
            code = SENServiceHealthKitErrorNotAuthorized;
        }
        done ([NSError errorWithDomain:SENServiceHKErrorDomain code:code userInfo:nil]);
    }
}

- (void)syncRecentMissingDays:(void(^)(NSError* error))completion {
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // last night
    NSCalendarUnit unitsWeCareAbout = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    NSDateComponents* todayComponents = [calendar components:unitsWeCareAbout fromDate:[NSDate date]];
    NSDate* today = [calendar dateFromComponents:todayComponents];
    
    NSDateComponents* lastNightComponents = [[NSDateComponents alloc] init];
    [lastNightComponents setDay:-1];
    NSDate* lastNight = [calendar dateByAddingComponents:lastNightComponents toDate:today options:0];
    
    // last time it was sync'ed
    NSDate* syncStartDate = [self lastWrittenDate];
    
    if (syncStartDate) {
        NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                                   fromDate:syncStartDate
                                                     toDate:lastNight
                                                    options:0];
        if ([difference day] == 0) {
            completion ([NSError errorWithDomain:SENServiceHKErrorDomain
                                            code:SENServiceHealthKitErrorAlreadySynced
                                        userInfo:nil]);
            return;
        } else if ([difference day] > SENServiceHKBackFillLimit) { // make sure we don't backfill too much
            NSDateComponents* backFillComps = [[NSDateComponents alloc] init];
            [backFillComps setDay:-SENServiceHKBackFillLimit];
            syncStartDate = [calendar dateByAddingComponents:backFillComps toDate:lastNight options:0];
        }
    } else { // if never been sync'ed before, just sync last night's data
        syncStartDate = lastNight;
    }
    
    __weak typeof(self) weakSelf = self;
    [self syncTimelineDataAfter:syncStartDate until:lastNight withCalendar:calendar completion:^(NSError *error) {
        if (!error) {
            [weakSelf saveLastWrittenDate:lastNight];
        }
        completion (error);
    }];
}

- (void)syncTimelineDataAfter:(NSDate*)startDate
                        until:(NSDate*)endDate
                 withCalendar:(NSCalendar*)calendar
                   completion:(void(^)(NSError* error))completion {
    NSCalendarUnit unitsWeCareAbout = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    NSDate* nextStartDate = startDate;
    NSUInteger daysFromStartDate = 0;
    NSDateComponents* components = nil;
    
    NSMutableArray* timelines = [NSMutableArray array];
    dispatch_group_t getTimelineGroup = dispatch_group_create();
    
    __weak typeof(self) weakSelf = self;
    while ([calendar compareDate:nextStartDate toDate:endDate toUnitGranularity:unitsWeCareAbout] != NSOrderedDescending) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        dispatch_group_enter(getTimelineGroup);
        [strongSelf timelineForDate:nextStartDate completion:^(SENTimeline *timeline, NSError *error) {
            if (timeline) {
                [timelines addObject:timeline];
            }
            dispatch_group_leave(getTimelineGroup);
        }];
        
        components = [calendar components:unitsWeCareAbout fromDate:nextStartDate];
        [components setDay:daysFromStartDate];
        nextStartDate = [calendar dateByAddingComponents:components toDate:nextStartDate options:0];
        daysFromStartDate++;
    }
    
    long queuePriority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
    dispatch_queue_t queue = dispatch_get_global_queue(queuePriority, 0);
    dispatch_group_notify(getTimelineGroup, queue, ^{
        [weakSelf syncTimelinesToHealthKit:timelines completion:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion (error);
            });
        }];
    });

}

- (void)timelineForDate:(NSDate*)date completion:(void(^)(SENTimeline* timeline, NSError* error))completion {
    SENTimeline* timeline = [SENTimeline timelineForDate:date];
    if ([[timeline metrics] count] > 0 && [timeline scoreCondition] != SENConditionUnknown) {
        completion (timeline, nil);
    } else {
        [SENAPITimeline timelineForDate:date completion:^(id data, NSError *error) {
            SENTimeline* timeline = data;
            if (!error) {
                if ([timeline isKindOfClass:[SENTimeline class]]) {
                    [timeline save];
                } else {
                    timeline = nil;
                    error = [NSError errorWithDomain:SENServiceHKErrorDomain
                                                code:SENServiceHealthKitErrorUnexpectedAPIResponse
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
        completion ([NSError errorWithDomain:SENServiceHKErrorDomain
                                        code:SENServiceHealthKitErrorNoDataToWrite
                                    userInfo:nil]);
        return;
    }
    
    HKSample* sample = nil;
    NSMutableArray* samples = [NSMutableArray arrayWithCapacity:timelineCount];
    for (SENTimeline* timeline in timelines) {
        sample = [self sleepSampleFromTimeline:timeline];
        if (sample) {
            [samples addObject:sample];
        }
    }
    
    if ([samples count] == 0) {
        if (completion) {
            completion ([NSError errorWithDomain:SENServiceHKErrorDomain
                                            code:SENServiceHealthKitErrorNoDataToWrite
                                        userInfo:nil]);
        }
        return;
    }
    
    [[self hkStore] saveObjects:samples withCompletion:^(BOOL success, NSError *error) {
        completion (error);
    }];
}

- (HKSample*)sleepSampleFromTimeline:(SENTimeline*)sleepResult {
    HKSample* sample = nil;
    HKCategoryType* hkSleepCategory = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    NSDate* wakeUpDate = nil;
    NSDate* sleepDate = nil;
    NSArray* metrics = [sleepResult metrics];

    for (SENTimelineMetric* metric in metrics) {
        if (!sleepDate
            && metric.type == SENTimelineMetricTypeFellAsleep
            && metric.unit == SENTimelineMetricUnitTimestamp) {
            sleepDate = [NSDate dateWithTimeIntervalSince1970:[metric.value doubleValue] / 1000];
        }

        if (sleepDate != nil
            && metric.type == SENTimelineMetricTypeWokeUp
            && metric.unit == SENTimelineMetricUnitTimestamp) {
            wakeUpDate = [NSDate dateWithTimeIntervalSince1970:[metric.value doubleValue] / 1000];
        }
    }
    
    if (wakeUpDate != nil && sleepDate != nil) {
        DDLogVerbose(@"adding asleep data point");
        if ([wakeUpDate compare:sleepDate] > NSOrderedAscending) {
            sample = [HKCategorySample categorySampleWithType:hkSleepCategory
                                                        value:HKCategoryValueSleepAnalysisAsleep
                                                    startDate:sleepDate
                                                      endDate:wakeUpDate];
        } else {
            DDLogVerbose(@"wake up time %@ is before sleep time %@", wakeUpDate, sleepDate);
        }
    }
    
    return sample;
}

@end
