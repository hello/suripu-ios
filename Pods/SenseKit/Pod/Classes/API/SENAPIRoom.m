
#import "AFHTTPSessionManager.h"
#import "SENAPIRoom.h"

@implementation SENAPIRoom

+ (void)currentWithCompletion:(SENAPIDataBlock)completion
{
    [[SENAPIClient HTTPSessionManager] GET:@"/room/current" parameters:nil success:^(NSURLSessionDataTask* task, id responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        completion(nil, error);
    }];
}

+ (void)hourlyHistoricalDataForSensorWithName:(NSString*)sensorName
                                   completion:(SENAPIDataBlock)completion
{
    [self historicalDataForSensorWithName:sensorName timeScope:@"day" completion:completion];
}

+ (void)dailyHistoricalDataForSensorWithName:(NSString*)sensorName completion:(SENAPIDataBlock)completion
{
    [self historicalDataForSensorWithName:sensorName timeScope:@"week" completion:completion];
}

+ (void)historicalDataForSensorWithName:(NSString*)sensorName
                              timeScope:(NSString*)scope
                             completion:(SENAPIDataBlock)completion
{
    NSString* timestamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    NSString* path = [NSString stringWithFormat:@"/room/%@/%@", sensorName, scope];
    [[SENAPIClient HTTPSessionManager] GET:path parameters:@{ @"from" : timestamp } success:^(NSURLSessionDataTask* task, id responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        completion(nil, error);
    }];
}

@end
