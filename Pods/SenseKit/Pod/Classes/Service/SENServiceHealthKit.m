//
//  SENServiceHealthKit.m
//  Pods
//
//  Created by Jimmy Lu on 1/26/15.
//
//
#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDLogMacros.h>

#import <HealthKit/HealthKit.h>

#import "SENServiceHealthKit.h"
#import "SENService+Protected.h"
#import "SENSleepResult.h"
#import "SENAPITimeline.h"

#ifndef ddLogLevel
#define ddLogLevel LOG_LEVEL_VERBOSE
#endif

static NSString* const SENServiceHKErrorDomain = @"is.hello.service.hk";
static NSString* const SENServiceHKLastDateWritten = @"is.hello.service.hk.lastdate";

@interface SENServiceHealthKit()

@property (nonatomic, strong) HKHealthStore* hkStore;
@property (nonatomic, strong) NSDateComponents* dateOnlyComponents;

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
        [self configureDates];
    }
    return self;
}

- (void)configureStore {
    if ([HKHealthStore isHealthDataAvailable]) {
        [self setHkStore:[[HKHealthStore alloc] init]];
    }
}

- (void)configureDates {
    if ([self hkStore] != nil) {
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSCalendarUnit unitsWeWant = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
        NSDateComponents *components = [calendar components:unitsWeWant fromDate:[NSDate date]];
        [self setDateOnlyComponents:components];
    }
}

#pragma mark - SENServiceOverrides

- (void)serviceBecameActive {
    [super serviceBecameActive];
    [self sync];
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

- (BOOL)ddedDataPointFor:(NSDate*)date {
    NSDate* lastWrittenDate = [[NSUserDefaults standardUserDefaults] objectForKey:SENServiceHKLastDateWritten];
    return [lastWrittenDate isEqualToDate:date];
}

- (void)saveLastWrittenDate:(NSDate*)date {
    if (date == nil) return;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:date forKey:SENServiceHKLastDateWritten];
    [defaults synchronize];
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
        
        if (success && status == HKAuthorizationStatusSharingAuthorized) {
            DDLogVerbose(@"healthkit authorization granted");
        } else if (success && status == HKAuthorizationStatusSharingDenied) {
            DDLogVerbose(@"healthkit authorization was denied");
            serviceError = [NSError errorWithDomain:SENServiceHKErrorDomain
                                               code:SENServiceHealthKitErrorNotAuthorized
                                           userInfo:nil];
        } else {
            DDLogVerbose(@"healthkit authorization request failed %@", error);
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion (serviceError);
            });
        }
        
    }];
}

- (void)sync {
    if ([self enableWrite] && [self isSupported] && [self canWriteSleepAnalysis]) {
        NSDate* lastNight = [self lastNight];
        if (![self ddedDataPointFor:lastNight]) {
            [self writeSleepAnalysisIfDataAvailableFor:lastNight];
        }
    }
}

- (NSDate*)lastNight {
    // if we want last night's data, we need to request just under 48 hours
    NSTimeInterval diff = -86400 *2;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* todayWithoutTime = [calendar dateFromComponents:[self dateOnlyComponents]];
    return [NSDate dateWithTimeInterval:diff sinceDate:todayWithoutTime];
}

- (void)writeSleepAnalysisIfDataAvailableFor:(NSDate*)date {
    SENSleepResult* result = [SENSleepResult sleepResultForDate:date];
    __weak typeof(self) weakSelf = self;
    
    if ([[result segments] count] > 0) {
        long queuePriority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
        dispatch_async(dispatch_get_global_queue(queuePriority, 0), ^{
            DDLogVerbose(@"adding sleep data point to health kit for date %@", [result date]);
            [weakSelf addSleepDataPoints:result forDate:date];
        });
    } else {
        DDLogVerbose(@"pulling from server since no data is in the cache");
        [SENAPITimeline timelineForDate:date completion:^(NSArray* timelines, NSError* error) {
            if (error == nil) {
                DDLogVerbose(@"adding sleep data point to health kit for date %@", [result date]);
                NSDictionary* timeline = [timelines firstObject];
                [result updateWithDictionary:timeline];
                [result save];
                [weakSelf addSleepDataPoints:result forDate:date];
            }
        }];
    }
}

- (NSArray*)sleepDataPointsForSleepResult:(SENSleepResult*)sleepResult {
    NSMutableArray* dataPoints = [NSMutableArray arrayWithCapacity:2];
    HKCategoryType* hkSleepCategory = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    NSDate* wakeUpDate = nil;
    NSDate* sleepDate = nil;
    
    for (SENSleepResultSegment* segment in [sleepResult segments]) {
        if (wakeUpDate == nil && [[segment eventType] isEqualToString:SENSleepResultSegmentEventTypeWakeUp]) {
            wakeUpDate = [segment date];
        } else if (sleepDate == nil && [[segment eventType] isEqualToString:SENSleepResultSegmentEventTypeSleep]) {
            sleepDate = [segment date];
        }
        
        if (wakeUpDate != nil && sleepDate != nil) {
            DDLogVerbose(@"adding asleep data point");
            [dataPoints addObject:[HKCategorySample categorySampleWithType:hkSleepCategory
                                                                     value:HKCategoryValueSleepAnalysisAsleep
                                                                 startDate:sleepDate
                                                                   endDate:wakeUpDate]];
            break;
        }
    }
    
    return dataPoints;
}

- (void)addSleepDataPoints:(SENSleepResult*)sleepReult forDate:(NSDate*)date {
    if (sleepReult == nil || ![self isSupported]) return;
    
    NSArray* sleepObjects = [self sleepDataPointsForSleepResult:sleepReult];
    
    if ([sleepObjects count] == 0) return;
    
    __weak typeof(self) weakSelf = self;
    [[self hkStore] saveObjects:sleepObjects withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            DDLogVerbose(@"saved sleep result to health kit.");
            [weakSelf saveLastWrittenDate:date];
        } else {
            DDLogVerbose(@"failed to save sleep result to health kit with error %@", error);
        }
    }];
}

@end