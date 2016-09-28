//
//  HEMRoomConditionPollOperation.h
//  Sense
//
//  Created by Jimmy Lu on 9/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SenseKit/SENSensor.h>

@class SENSensorStatus;
@class SENSensorDataCollection;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMSensorDataPollHandler)(SENSensorDataScope dataScope,
                                        SENSensorStatus* _Nullable status,
                                        SENSensorDataCollection* _Nullable data,
                                        NSError* _Nullable error);

@interface HEMSensorDataRequestOperation : NSOperation

@property (nonatomic, copy) HEMSensorDataPollHandler dataHandler;
@property (nonatomic, strong) NSSet<NSNumber*>* filterByTypes;
@property (nonatomic, assign) BOOL exclude;
@property (nonatomic, assign) SENSensorDataScope dataScope;
@property (nonatomic, assign) double repeatDelay;

@end

NS_ASSUME_NONNULL_END