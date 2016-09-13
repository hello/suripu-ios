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
#import "HEMSensorDataRequestOperation.h"

static double const kHEMSensorPollInterval = 20.0f;

NSString* const kHEMSensorErrorDomain = @"is.hello.app.service.sensor";

@interface HEMSensorService()

@property (nonatomic, copy) HEMSensorPollHandler pollHandler;
@property (nonatomic, strong) SENSensorDataRequest* pollRequest;
@property (nonatomic, strong) NSOperationQueue* pollQueue;
@property (nonatomic, assign, getter=shouldStopPolling) BOOL stopPolling;

@end

@implementation HEMSensorService

- (instancetype)init {
    if (self = [super init]) {
        _pollQueue = [NSOperationQueue new];
        [_pollQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

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

- (void)pollDataForSensor:(SENSensor*)sensor withScope:(HEMSensorServiceScope)scope completion:(HEMSensorPollHandler)completion {
    [self setStopPolling:NO];
    [[self pollQueue] cancelAllOperations];
    
    __weak typeof(self) weakSelf = self;
    HEMSensorDataRequestOperation* op = [HEMSensorDataRequestOperation new];
    SENSensorDataScope apiScope;
    switch (scope) {
        // TODO: api not supporting anything else right now
        case HEMSensorServiceScopeDay:
        case HEMSensorServiceScopeWeek:
        default:
            apiScope = SENSensorDataScopeDay5Min;
            break;
    }
    
    [op setDataScope:apiScope];
    [op setDataMethod:SENSensorDataMethodAverage];
    [op setFilterByTypes:[NSSet setWithObject:@([sensor type])]];
    [op setExclude:NO];
    [op setDataHandler:^(SENSensorStatus* status, SENSensorDataCollection* data, NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [SENAnalytics trackError:error];
        }
        if (completion) {
            completion (status, data, error);
        }
        
        if (![strongSelf shouldStopPolling]) {
            [strongSelf addPollDelay:^{
                __strong typeof(weakSelf) safeSelf = weakSelf;
                [safeSelf pollDataForSensor:sensor withScope:scope completion:completion];
            }];
        }
    }];
    
    [[self pollQueue] addOperation:op];
}

- (void)pollDataForSensorsExcept:(NSSet<NSNumber*>*)sensorTypes completion:(HEMSensorPollHandler)completion {
    [self setStopPolling:NO];
    [[self pollQueue] cancelAllOperations];
    
    __weak typeof(self) weakSelf = self;
    HEMSensorDataRequestOperation* op = [HEMSensorDataRequestOperation new];
    [op setDataScope:SENSensorDataScopeDay5Min];
    [op setDataMethod:SENSensorDataMethodAverage];
    [op setFilterByTypes:sensorTypes];
    [op setExclude:YES];
    [op setDataHandler:^(SENSensorStatus* status, SENSensorDataCollection* data, NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [SENAnalytics trackError:error];
        }
        if (completion) {
            completion (status, data, error);
        }
        
        if (![strongSelf shouldStopPolling]) {
            [strongSelf addPollDelay:^{
                __strong typeof(weakSelf) safeSelf = weakSelf;
                [safeSelf pollDataForSensorsExcept:sensorTypes completion:completion];
            }];
        }
    }];
    
    [[self pollQueue] addOperation:op];
}

- (void)addPollDelay:(void(^)(void))action {
    int64_t delayInSecs = (int64_t) (kHEMSensorPollInterval * NSEC_PER_SEC);
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
    dispatch_after(delay, dispatch_get_main_queue(), action);
}

- (void)stopPollingForData {
    [[self pollQueue] cancelAllOperations];
    [self setStopPolling:YES];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_pollQueue) {
        [_pollQueue cancelAllOperations];
    }
}

@end
