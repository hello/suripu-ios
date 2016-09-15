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

NSString* const kHEMSensorErrorDomain = @"is.hello.app.service.sensor";

@interface HEMSensorService()

@property (nonatomic, copy) HEMSensorPollHandler pollHandler;
@property (nonatomic, strong) SENSensorDataRequest* pollRequest;
@property (nonatomic, strong) NSOperationQueue* pollQueue;

@end

@implementation HEMSensorService

- (instancetype)init {
    if (self = [super init]) {
        _pollQueue = [NSOperationQueue new];
        [_pollQueue setMaxConcurrentOperationCount:2]; // speed up cancelling / restarting
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

- (HEMSensorServiceScope)scopeFromAPIScope:(SENSensorDataScope)scope {
    switch (scope) {
        default:
        case SENSensorDataScopeLast3H5Min:
            return HEMSensorServiceScopeLast3H;
        case SENSensorDataScopeDay5Min:
            return HEMSensorServiceScopeDay;
        case SENSensorDataScopeWeek1Hour:
            return HEMSensorServiceScopeWeek;
    }
}

- (SENSensorDataScope)apiScopeForScope:(HEMSensorServiceScope)scope {
    switch (scope) {
        default:
        case HEMSensorServiceScopeDay:
            return SENSensorDataScopeDay5Min;
        case HEMSensorServiceScopeLast3H:
            return SENSensorDataScopeLast3H5Min;
            break;
        case HEMSensorServiceScopeWeek:
            return SENSensorDataScopeWeek1Hour;
    }
}

- (void)pollDataForSensor:(SENSensor*)sensor
                withScope:(HEMSensorServiceScope)scope
               completion:(HEMSensorPollHandler)completion {
    [[self pollQueue] cancelAllOperations];
    
    HEMSensorDataRequestOperation* op = [HEMSensorDataRequestOperation new];
    [op setDataScope:[self apiScopeForScope:scope]];
    [op setDataMethod:SENSensorDataMethodAverage];
    [op setFilterByTypes:[NSSet setWithObject:@([sensor type])]];
    [op setExclude:NO];
    [op setDataHandler:^(SENSensorDataScope apiScope,
                         SENSensorStatus* status,
                         SENSensorDataCollection* data,
                         NSError* error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (scope, status, data, error);
    }];
    
    [[self pollQueue] addOperation:op];
}

- (void)pollDataForSensorsExcept:(NSSet<NSNumber*>*)sensorTypes
                      completion:(HEMSensorPollHandler)completion {
    [[self pollQueue] cancelAllOperations];
    
    HEMSensorDataRequestOperation* op = [HEMSensorDataRequestOperation new];
    [op setDataScope:SENSensorDataScopeLast3H5Min];
    [op setDataMethod:SENSensorDataMethodAverage];
    [op setFilterByTypes:sensorTypes];
    [op setExclude:YES];
    [op setDataHandler:^(SENSensorDataScope apiScope,
                         SENSensorStatus* status,
                         SENSensorDataCollection* data,
                         NSError* error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (HEMSensorServiceScopeLast3H, status, data, error);
    }];
    
    [[self pollQueue] addOperation:op];
}

- (void)stopPollingForData {
    [[self pollQueue] cancelAllOperations];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_pollQueue) {
        [_pollQueue cancelAllOperations];
    }
}

@end
