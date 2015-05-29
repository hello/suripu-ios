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
#import "SENSleepResult.h"
#import "SENAPITimeline.h"
#import "SENLocalPreferences.h"

#ifndef ddLogLevel
#define ddLogLevel LOG_LEVEL_VERBOSE
#endif

static NSString* const SENServiceHKErrorDomain = @"is.hello.service.hk";
static NSString* const SENServiceHKLastDateWritten = @"is.hello.service.hk.lastdate";
static NSString* const SENSErviceHKEnable = @"is.hello.service.hk.enable";

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

#pragma mark -

- (BOOL)isSupported {
    return [self hkStore] != nil;
}

- (BOOL)canWriteSleepAnalysis {
    if (![self isSupported]) return NO;
    HKCategoryType* hkSleepCategory = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    HKAuthorizationStatus status = [[self hkStore] authorizationStatusForType:hkSleepCategory];
    return status == HKAuthorizationStatusSharingAuthorized;
}

- (BOOL)addedDataPointFor:(NSDate*)date {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    NSDate* lastWrittenDate = [preferences userPreferenceForKey:SENServiceHKLastDateWritten];
    return [lastWrittenDate isEqualToDate:date];
}

- (void)saveLastWrittenDate:(NSDate*)date {
    if (date == nil) return;
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    [preferences setUserPreference:date forKey:SENServiceHKLastDateWritten];
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
        NSDate* lastNight = [self lastNight];
        if (![self addedDataPointFor:lastNight]) {
            [self writeSleepAnalysisIfDataAvailableFor:lastNight completion:completion];
            return;
        } else {
            done ([NSError errorWithDomain:SENServiceHKErrorDomain
                                      code:SENServiceHealthKitErrorAlreadySynced
                                  userInfo:nil]);
        }
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

/**
 * @return NSDate without time to represent the previous day
 */
- (NSDate*)lastNight {
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSCalendarUnit unitsWeWant = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    NSDateComponents* todayComponents = [calendar components:unitsWeWant fromDate:[NSDate date]];
    NSDate* today = [calendar dateFromComponents:todayComponents];
    
    NSDateComponents* lastNightComponents = [[NSDateComponents alloc] init];
    [lastNightComponents setDay:-1];
    return [calendar dateByAddingComponents:lastNightComponents toDate:today options:0];
}

- (void)writeSleepAnalysisIfDataAvailableFor:(NSDate*)date completion:(void(^)(NSError* error))completion {
    SENSleepResult* result = [SENSleepResult sleepResultForDate:date];

    if ([[result segments] count] > 0) {
        DDLogVerbose(@"adding sleep data point to health kit for date %@", [result date]);
        [self writeSleepDataPoints:result forDate:date completion:completion];
    } else {
        DDLogVerbose(@"pulling from server since no data is in the cache");
        [SENAPITimeline timelineForDate:date completion:^(NSArray* timelines, NSError* error) {
            if (error == nil) {
                
                if ([[result segments] count] > 0) {
                    DDLogVerbose(@"adding sleep data point to HealthKit for date %@", [result date]);
                    NSDictionary* timeline = [timelines firstObject];
                    [result updateWithDictionary:timeline];
                    [result save];
                    [self writeSleepDataPoints:result forDate:date completion:completion];
                } else {
                    if (completion) {
                        completion ([NSError errorWithDomain:SENServiceHKErrorDomain
                                                        code:SENServiceHealthKitErrorNoDataToWrite
                                                    userInfo:nil]);
                    }
                }
            } else if (completion) {
                completion (error);
            }
        }];
    }
}

- (NSArray*)sleepDataPointsForSleepResult:(SENSleepResult*)sleepResult {
    NSMutableArray* dataPoints = [NSMutableArray arrayWithCapacity:1];
    HKCategoryType* hkSleepCategory = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    NSDate* wakeUpDate = nil;
    NSDate* sleepDate = nil;
    NSArray* segments = [sleepResult segments];
    
    // first, find the sleep date from the front of the array
    for (SENSleepResultSegment* segment in segments) {
        if ([[segment eventType] isEqualToString:SENSleepResultSegmentEventTypeSleep]) {
            sleepDate = [segment date];
            break;
        }
    }
    
    if (sleepDate != nil) {
        // look for wake up time from the back
        SENSleepResultSegment* segment = nil;
        for (NSInteger i = [segments count] - 1; i >= 0; i--) {
            segment = segments[i];
            if ([[segment eventType] isEqualToString:SENSleepResultSegmentEventTypeWakeUp]) {
                wakeUpDate = [segment date];
                break;
            }
        }
    }
    
    if (wakeUpDate != nil && sleepDate != nil) {
        DDLogVerbose(@"adding asleep data point");
        if ([wakeUpDate compare:sleepDate] > NSOrderedAscending) {
            [dataPoints addObject:[HKCategorySample categorySampleWithType:hkSleepCategory
                                                                     value:HKCategoryValueSleepAnalysisAsleep
                                                                 startDate:sleepDate
                                                                   endDate:wakeUpDate]];
        } else {
            DDLogVerbose(@"wake up time %@ is before sleep time %@", wakeUpDate, sleepDate);
        }
    }
    
    return dataPoints;
}

- (void)writeSleepDataPoints:(SENSleepResult*)sleepReult
                     forDate:(NSDate*)date
                  completion:(void(^)(NSError* error))competion {
    
    if (![self isSupported]) {
        if (competion) {
            competion ([NSError errorWithDomain:SENServiceHKErrorDomain
                                           code:SENServiceHealthKitErrorNotSupported
                                       userInfo:nil]);
        }
        return;
    }
    
    void(^finishOnMainThread)(NSError* error) = ^(NSError* error) {
        if (competion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                competion (error);
            });
        }
    };
    
    __weak typeof(self) weakSelf = self;
    long queuePriority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
    dispatch_async(dispatch_get_global_queue(queuePriority, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSArray* sleepObjects = [strongSelf sleepDataPointsForSleepResult:sleepReult];
        
        if ([sleepObjects count] == 0) {
            finishOnMainThread ([NSError errorWithDomain:SENServiceHKErrorDomain
                                                    code:SENServiceHealthKitErrorNoDataToWrite
                                                userInfo:nil]);
            return;
        }
        
        [[strongSelf hkStore] saveObjects:sleepObjects withCompletion:^(BOOL success, NSError *error) {
            
            if (success) {
                DDLogVerbose(@"saved sleep result to health kit.");
                [strongSelf saveLastWrittenDate:date];
            } else {
                DDLogVerbose(@"failed to save sleep result to health kit with error %@", error);
            }
            
            finishOnMainThread (error);
        }];
    });

}

- (void)setEnableHealthKit:(BOOL)enable {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    [preferences setUserPreference:@(enable) forKey:SENSErviceHKEnable];
}

- (BOOL)isHealthKitEnabled {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    return [[preferences userPreferenceForKey:SENSErviceHKEnable] boolValue];
}

@end
