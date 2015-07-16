
#import "AFHTTPSessionManager.h"
#import "SENAPIRoom.h"
#import "SENSensor.h"
#import "SENPreference.h"
#import "SENServiceAccount.h"

@implementation SENAPIRoom

static NSString* const SENAPIRoomUnitCentigrade = @"c";
static NSString* const SENAPIRoomUnitFahrenheit = @"f";
static NSString* const SENAPIRoomSensorScopeDay = @"day";
static NSString* const SENAPIRoomSensorScopeWeek = @"week";
static NSString* const SENAPIRoomAllSensorsScopeDay = @"24hours";
static NSString* const SENAPIRoomAllSensorsScopeWeek = @"week";
static NSString* const SENAPIRoomSensorPathFormat = @"v1/room/%@/%@";
static NSString* const SENAPIRoomAllSensorsPathFormat = @"v1/room/all_sensors/%@";
static NSString* const SENAPIRoomCurrentPath = @"v1/room/current";
static NSString* const SENAPIRoomSensorParamTimestamp = @"from";
static NSString* const SENAPIRoomAllSensorsParamTimestamp = @"from_utc";
static NSString* const SENAPIRoomParamUnit = @"temp_unit";

+ (void)currentWithCompletion:(SENAPIDataBlock)completion
{
    NSString* unitParam = [SENPreference useCentigrade] ? SENAPIRoomUnitCentigrade : SENAPIRoomUnitFahrenheit;
    [SENAPIClient GET:SENAPIRoomCurrentPath parameters:@{SENAPIRoomParamUnit:unitParam} completion:completion];
}

+ (void)hourlyHistoricalDataForSensor:(SENSensor*)sensor
                           completion:(SENAPIDataBlock)completion
{
    [self historicalDataForSensor:sensor timeScope:SENAPIRoomSensorScopeDay completion:completion];
}

+ (void)dailyHistoricalDataForSensor:(SENSensor*)sensor
                          completion:(SENAPIDataBlock)completion
{
    [self historicalDataForSensor:sensor timeScope:SENAPIRoomSensorScopeWeek completion:completion];
}

+ (void)historicalConditionsForLast24HoursWithCompletion:(SENAPIDataBlock)completion
{
    [self historicalDataForAllSensorsWithTimeScope:SENAPIRoomAllSensorsScopeDay completion:completion];
}

+ (void)historicalConditionsForPastWeekWithCompletion:(SENAPIDataBlock)completion
{
    [self historicalDataForAllSensorsWithTimeScope:SENAPIRoomAllSensorsScopeWeek completion:completion];
}

+ (void)historicalDataForAllSensorsWithTimeScope:(NSString*)scope completion:(SENAPIDataBlock)completion
{
    if (!completion)
        return;
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSString* path = [NSString stringWithFormat:SENAPIRoomAllSensorsPathFormat, scope];
    NSString* timestamp = [self parameterForCurrentDate];
    if (timestamp)
        params[SENAPIRoomAllSensorsParamTimestamp] = timestamp;
    [SENAPIClient GET:path parameters:params completion:^(NSDictionary* data, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __block NSMutableDictionary* response = [[NSMutableDictionary alloc] initWithCapacity:data.count];
            [data enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSArray* data, BOOL *stop) {
                NSArray* points = [self dataPointsFromArray:data];
                if (points)
                    response[key] = points;
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(response, error);
            });
        });
    }];
}

+ (void)historicalDataForSensor:(SENSensor*)sensor
                      timeScope:(NSString*)scope
                     completion:(SENAPIDataBlock)completion
{
    if (!completion)
        return;
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSString* timestamp = [self parameterForCurrentDate];
    if (timestamp)
        params[SENAPIRoomSensorParamTimestamp] = timestamp;
    NSString* path = [NSString stringWithFormat:SENAPIRoomSensorPathFormat, sensor.name, scope];
    [SENAPIClient GET:path parameters:params completion:^(NSArray* data, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray* points = [self dataPointsFromArray:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(points, error);
            });
        });
    }];
}

+ (NSArray*)dataPointsFromArray:(NSArray*)data
{
    NSMutableArray* points = [[NSMutableArray alloc] initWithCapacity:data.count];
    for (NSDictionary* pointData in data) {
        SENSensorDataPoint* point = [[SENSensorDataPoint alloc] initWithDictionary:pointData];
        if (point)
            [points addObject:point];
    }
    return points;
}

+ (NSString*)parameterForCurrentDate
{
    static NSString* const SENAPIRoomTimestampFormat = @"%.0f";
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:SENAPIRoomTimestampFormat, seconds * 1000];
}

@end
