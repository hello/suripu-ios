//
//  HEMSensorService.m
//  Sense
//
//  Created by Jimmy Lu on 3/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENSensor.h>
#import <SenseKit/SENAPISensor.h>
#import <SenseKit/SENPreference.h>
#import <SenseKit/SENSensorStatus.h>
#import <SenseKit/SENSensorDataRequest.h>
#import <SenseKit/SENCondition.h>

#import "SENAnalytics+HEMAppAnalytics.h"

#import "HEMSensorService.h"

static double const kHEMSensorPollInterval = 20.0f;

NSString* const kHEMSensorErrorDomain = @"is.hello.app.service.sensor";

@interface HEMSensorService()

@property (nonatomic, copy) HEMSensorPollHandler pollHandler;
@property (nonatomic, strong) SENSensorDataRequest* pollRequest;

@end

@implementation HEMSensorService

#pragma mark - Errors

- (NSError*)errorWithCode:(HEMSensorServiceErrorCode)code
                   reason:(nullable NSString*)reason {
    NSDictionary* info = nil;
    if (reason) {
        info = @{NSLocalizedDescriptionKey : reason};
    }
    return [NSError errorWithDomain:kHEMSensorErrorDomain
                               code:code
                           userInfo:info];
}

#pragma mark - Data

- (void)sensorStatus:(HEMSensorStatusHandler)completion {
    [SENAPISensor getSensorStatus:^(SENSensorStatus* status, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        
        if (completion) {
            completion (status, error);
        }
    }];
}

- (void)dataForSensors:(NSArray<SENSensor*>*)sensors completion:(HEMSensorDataHandler)completion {
    [self dataWithRequest:[self dataRequestForSensors:sensors] completion:completion];
}

- (SENSensorDataRequest*)dataRequestForSensors:(NSArray<SENSensor*>*)sensors {
    SENSensorDataRequest* request  = [SENSensorDataRequest new];
    [request addRequestForSensors:sensors
                      usingMethod:SENSensorDataMethodAverage
                        withScope:SENSensorDataScopeDay5Min];
    return request;
}

- (void)dataWithRequest:(SENSensorDataRequest*)request completion:(HEMSensorDataHandler)completion {
    [SENAPISensor getSensorDataWithRequest:request completion:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data, error);
    }];
}

#pragma mark - Polling

- (void)pollDataForSensorsExcept:(NSSet<NSNumber*>*)sensorTypes completion:(HEMSensorPollHandler)completion {
    // TODO: put this in to an operation queue
    [self stopPollingForData];
    [self setPollHandler:completion];
    [self continuePollingSensorsExcept:sensorTypes];
}

- (void)continuePollingSensorsExcept:(NSSet<NSNumber*>*)sensorTypes {
    if (![self pollHandler]) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void(^again)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf continuePollingSensorsExcept:sensorTypes];
    };
    
    [self sensorStatus:^(SENSensorStatus * _Nullable status, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!status || [[status sensors] count] == 0) {
            [strongSelf addPollDelay:again];
        } else {
            if (![strongSelf pollRequest]) {
                NSArray* filteredSensors = [strongSelf filter:[status sensors] byExcluding:sensorTypes];
                [strongSelf setPollRequest:[strongSelf dataRequestForSensors:filteredSensors]];
            }
            [strongSelf dataWithRequest:[strongSelf pollRequest] completion:^(id _Nullable data, NSError * _Nullable error) {
                if ([strongSelf pollHandler]) {
                    [strongSelf pollHandler] (status, data, error);
                }
                [strongSelf addPollDelay:again];
            }];
        }
    }];
}

- (void)addPollDelay:(void(^)(void))action {
    int64_t delayInSecs = (int64_t) (kHEMSensorPollInterval * NSEC_PER_SEC);
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
    dispatch_after(delay, dispatch_get_main_queue(), action);
}

- (void)stopPollingForData {
    [self setPollRequest:nil];
    [self setPollHandler:nil];
}

- (NSArray<SENSensor*>*)filter:(NSArray<SENSensor*>*)sensors byExcluding:(NSSet<NSNumber*>*)exclusion {
    NSUInteger capacity = [sensors count] - [exclusion count];
    NSMutableArray<SENSensor*>* filtered = [NSMutableArray arrayWithCapacity:capacity];
    for (SENSensor* sensor in sensors) {
        if (![exclusion containsObject:@([sensor type])]) {
            [filtered addObject:sensor];
        }
    }
    return filtered;
}

@end
