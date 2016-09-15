//
//  SENAPISensor.m
//  Pods
//
//  Created by Jimmy Lu on 9/1/16.
//
//

#import "SENAPISensor.h"
#import "SENPreference.h"
#import "SENSensor.h"
#import "SENSensorStatus.h"
#import "SENSensorDataRequest.h"

static NSString* const kSENAPISensorPath = @"v2/sensors";
static NSUInteger const kSENAPISensorDefaultDataPointCapacity = 288;

@implementation SENAPISensor

#pragma mark - API

+ (void)getSensorStatus:(SENAPIDataBlock)completion {
    [SENAPIClient GET:kSENAPISensorPath parameters:nil completion:^(id data, NSError *error) {
        SENSensorStatus* status = nil;
        if (!error && [data isKindOfClass:[NSDictionary class]]) {
            status = [[SENSensorStatus alloc] initWithDictionary:data];
        }
        completion (status, error);
    }];
}

+ (void)getSensorDataWithRequest:(SENSensorDataRequest*)request
                      completion:(SENAPIDataBlock)completion {
    // A POST is used to send complex parameters in the body
    NSDictionary* params = [request dictionaryValue];
    [SENAPIClient POST:kSENAPISensorPath parameters:params completion:^(id data, NSError *error) {
        //  {
        //      "timestamps" : [
        //      ],
        //      "sensors" : {
        //          "TEMP" : [],
        //          "HUMIDITY" : [],
        //                ...
        //      }
        //  }
        if (!error && [data isKindOfClass:[NSDictionary class]]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                SENSensorDataCollection* collection = [[SENSensorDataCollection alloc] initWithDictionary:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion (collection, error);
                });
            });

        } else {
            completion (nil, error);
        }
    }];
}

@end
