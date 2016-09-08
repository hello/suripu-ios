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

static double const kHEMSensorPollInterval = 30.0f;

NSString* const kHEMSensorErrorDomain = @"is.hello.app.service.sensor";

@interface HEMSensorService()

@property (nonatomic, copy) HEMSensorDataHandler pollHander;
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

- (void)roomStatus:(HEMSensorStatusHandler)completion {
    [SENAPISensor getSensorStatus:^(SENSensorStatus* status, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        if (completion) {
            completion (status, error);
        }
    }];
}

- (void)roomDataForSensors:(NSArray<SENSensor*>*)sensors completion:(HEMSensorDataHandler)completion {
    [self setPollRequest:[self dataRequestForSensors:sensors]];
    [self roomDataWithRequest:[self pollRequest] completion:completion];
}

- (SENSensorDataRequest*)dataRequestForSensors:(NSArray<SENSensor*>*)sensors {
    SENSensorDataRequest* request  = [SENSensorDataRequest new];
    [request addRequestForSensors:sensors
                      usingMethod:SENSensorDataMethodAverage
                        withScope:SENSensorDataScopeDay5Min];
    return request;
}

- (void)roomDataWithRequest:(SENSensorDataRequest*)request completion:(HEMSensorDataHandler)completion {
    [SENAPISensor getSensorDataWithRequest:request completion:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data, error);
    }];
}

- (void)pollRoomDataForSensors:(NSArray<SENSensor*>*)sensors update:(HEMSensorDataHandler)update {
    if ([self pollRequest]) {
        NSError* error = [self errorWithCode:HEMSensorServiceErrorCodePollingAlreadyStarted
                                      reason:nil];
        [SENAnalytics trackError:error];
        return update (nil, error);
    }
    
    [self setPollRequest:[self dataRequestForSensors:sensors]];
    [self setPollHander:update];
    [self continuePollingRoomData];
}

- (void)stopPollingForRoomData {
    [self setPollHander:nil];
    [self setPollRequest:nil];
}

- (void)continuePollingRoomData {
    if (![self pollRequest]) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self roomDataWithRequest:[self pollRequest] completion:^(NSDictionary<NSString *,NSArray<SENSensorDataPoint*>*>* data, NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf pollHander]) {
            [strongSelf pollHander] (data, error);
        }
        
        if ([strongSelf pollHander] && [strongSelf pollRequest]) {
            int64_t delayInSecs = (int64_t)(kHEMSensorPollInterval * NSEC_PER_SEC);
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [strongSelf continuePollingRoomData];
            });
        }

    }];
}

@end
