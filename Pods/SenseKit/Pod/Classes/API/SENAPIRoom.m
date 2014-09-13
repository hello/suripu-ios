
#import "AFHTTPSessionManager.h"
#import "SENAPIRoom.h"

@implementation SENAPIRoom

+ (void)currentWithCompletion:(SENAPIDataBlock)completion
{
    [SENAPIClient GET:@"/room/current" parameters:nil completion:completion];
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
    [SENAPIClient  GET:path parameters:@{ @"from" : timestamp } completion:completion];
}

@end
