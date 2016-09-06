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

#import "SENAnalytics+HEMAppAnalytics.h"

#import "HEMSensorService.h"

static double const kHEMSensorPollInterval = 30.0f;
NSString* const kHEMSensorErrorDomain = @"is.hello.app.service.sensor";

@interface HEMSensorService()

@property (nonatomic, assign, getter=isPolling) BOOL polling;
@property (nonatomic, copy) HEMSensorRoomHandler pollHander;

@end

@implementation HEMSensorService

- (NSArray<SENSensor*>*)sortedCacheSensors {
    NSComparator comparator = [self preferredSensorOrderComparator];
    return [[SENSensor sensors] sortedArrayUsingComparator:comparator];
}

- (NSComparator)preferredSensorOrderComparator {
    return ^NSComparisonResult(SENSensor *obj1, SENSensor *obj2) {
        NSInteger obj1Index = [self preferredOrderIndexForSensor:obj1];
        NSInteger obj2Index = [self preferredOrderIndexForSensor:obj2];
        return [@(obj1Index) compare:@(obj2Index)];
    };
}

- (NSInteger)preferredOrderIndexForSensor:(SENSensor *)sensor {
    switch (sensor.unit) {
        case SENSensorUnitDegreeCentigrade:
            return 0;
        case SENSensorUnitPercent:
            return 1;
        case SENSensorUnitAQI:
            return 2;
        case SENSensorUnitLux:
            return 3;
        case SENSensorUnitDecibel:
            return 4;
        case SENSensorUnitUnknown:
        default:
            return 5;
    }
}

- (SENAPISensorTempUnit)sensorTempUnitFromPreferences {
    return [SENPreference useCentigrade]
        ? SENAPISensorTempUnitCelcius
        : SENAPISensorTempUnitFahrenheit;
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

- (void)roomConditions:(HEMSensorRoomHandler)completion {
    __block NSArray<SENSensor*>* sensors = nil;
    __block NSDictionary<NSString*, NSArray<SENSensorDataPoint*>*>* data = nil;
    __block NSError* metadataError = nil;
    __block NSError* dataError = nil;
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    [self roomMetadata:^(NSArray<SENSensor *> * data, NSError * error) {
        sensors = data;
        metadataError = error;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [self roomData:^(NSDictionary<NSString *,NSArray<SENSensorDataPoint*>*>* response, NSError * error) {
        data = response;
        dataError = error;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completion (sensors, data, metadataError ?: dataError);
    });
}

- (void)roomMetadata:(HEMSensorMetadataHandler)completion {
    SENAPISensorTempUnit unit = [self sensorTempUnitFromPreferences];
    [SENAPISensor currentConditionsWithTempUnit:unit completion:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        
        // force the sensors in to a specific order
        NSArray<SENSensor*>* sensors = data;
        if (sensors) {
            NSComparator comparator = [self preferredSensorOrderComparator];
            sensors = [sensors sortedArrayUsingComparator:comparator];
        }
        
        if (completion) {
            completion (data, error);
        }
    }];
}

- (void)roomData:(HEMSensorDataHandler)completion {
    [SENAPISensor dataForAllSensorsWithScope:SENAPISensorDataScopeDay
                                  completion:^(id data, NSError *error) {
                                      if (error) {
                                          [SENAnalytics trackError:error];
                                      }
                                      completion (data, error);
                                  }];
}

- (void)pollRoomConditions:(HEMSensorRoomHandler)update {
    if ([self isPolling]) {
        NSError* error = [self errorWithCode:HEMSensorServiceErrorCodePollingAlreadyStarted
                                      reason:nil];
        [SENAnalytics trackError:error];
        return update (nil, nil, error);
    }
    
    [self setPollHander:update];
    [self setPolling:YES];
    [self refreshCurrentConditions];
}

- (void)stopPollingForRoomConditions {
    [self setPollHander:nil];
    [self setPolling:NO];
}

- (void)refreshCurrentConditions {
    __weak typeof(self) weakSelf = self;
    [self roomConditions:^(NSArray<SENSensor*>* sensors,
                           NSDictionary<NSString *,NSArray<SENSensorDataPoint*>*>* data,
                           NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf pollHander]) {
            [strongSelf pollHander] (sensors, data, error);
        }
        
        if ([strongSelf isPolling] && [strongSelf pollHander]) {
            int64_t delayInSecs = (int64_t)(kHEMSensorPollInterval * NSEC_PER_SEC);
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [strongSelf refreshCurrentConditions];
            });
        }
    }];
}

@end
