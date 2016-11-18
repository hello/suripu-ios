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
NSString* const kHEMSensorNotifyStatusChanged = @"kHEMSensorNotifyStatusChanged";
NSString* const kHEMSensorNotifyStatusKey = @"status";

NSInteger const kHEMSensorSentinelValue = -1;

@interface HEMSensorService()

@property (nonatomic, copy) HEMSensorPollHandler pollHandler;
@property (nonatomic, strong) SENSensorDataRequest* pollRequest;
@property (nonatomic, strong) NSOperationQueue* pollQueue;
@property (nonatomic, strong) SENSensorStatus* previousStatus;

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

#pragma mark - Notifications

- (void)notifyOfStatusChangeIfNeeded:(SENSensorStatus*)status {
    if (status
        && (![self previousStatus]
            || ![[self previousStatus] isEqual:status])) {
        NSDictionary* info = @{kHEMSensorNotifyStatusKey : status};
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        NSNotification* note = [NSNotification notificationWithName:kHEMSensorNotifyStatusChanged
                                                             object:nil
                                                           userInfo:info];
        [center postNotification:note];
        [self setPreviousStatus:status];
    }

}

#pragma mark - Data

- (void)sensorStatus:(HEMSensorStatusHandler)completion {
    __weak typeof(self) weakSelf = self;
    [SENAPISensor getSensorStatus:^(SENSensorStatus* status, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [SENAnalytics trackError:error];
        }
        
        [strongSelf notifyOfStatusChangeIfNeeded:status];
        
        if (completion) {
            completion (status, error);
        }
    }];
}

- (void)dataForSensors:(NSArray<SENSensor*>*)sensors completion:(HEMSensorDataHandler)completion {
    [self dataWithRequest:[self dataRequestForSensors:sensors] completion:completion];
}

- (SENSensorDataRequest*)dataRequestForSensors:(NSArray<SENSensor*>*)sensors {
    SENSensorDataRequest* request  = [[SENSensorDataRequest alloc] initWithScope:SENSensorDataScopeDay5Min];
    [request addSensors:sensors];
    return request;
}

- (void)dataWithRequest:(SENSensorDataRequest*)request completion:(HEMSensorDataHandler)completion {
    [SENAPISensor getSensorDataWithRequest:request completion:^(SENSensorDataCollection* data, NSError *error) {
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

- (void)pollDataForSensorType:(SENSensorType)type
                    withScope:(HEMSensorServiceScope)scope
                   completion:(HEMSensorPollHandler)completion {
    [[self pollQueue] cancelAllOperations];
    
    __weak typeof(self) weakSelf = self;
    HEMSensorDataRequestOperation* op = [HEMSensorDataRequestOperation new];
    [op setDataScope:[self apiScopeForScope:scope]];
    [op setFilterByTypes:[NSSet setWithObject:@(type)]];
    [op setExclude:NO];
    [op setDataHandler:^(SENSensorDataScope apiScope,
                         SENSensorStatus* status,
                         SENSensorDataCollection* data,
                         NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [SENAnalytics trackError:error];
        }
        
        [strongSelf notifyOfStatusChangeIfNeeded:status];
        
        completion (scope, status, data, error);
    }];
    
    [[self pollQueue] addOperation:op];
}

- (void)pollDataForSensorsExcept:(NSSet<NSNumber*>*)sensorTypes
                      completion:(HEMSensorPollHandler)completion {
    [[self pollQueue] cancelAllOperations];
    
    __weak typeof(self) weakSelf = self;
    HEMSensorDataRequestOperation* op = [HEMSensorDataRequestOperation new];
    [op setDataScope:SENSensorDataScopeLast3H5Min];
    [op setFilterByTypes:sensorTypes];
    [op setExclude:YES];
    [op setDataHandler:^(SENSensorDataScope apiScope,
                         SENSensorStatus* status,
                         SENSensorDataCollection* data,
                         NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [SENAnalytics trackError:error];
        }
        
        [strongSelf notifyOfStatusChangeIfNeeded:status];
        
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
