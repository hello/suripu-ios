
#import "AFHTTPSessionManager.h"
#import "SENAPIRoom.h"
#import "SENSensor.h"
#import "SENSettings.h"

@implementation SENAPIRoom

static NSString* const SENAPIRoomUnitCentigrade = @"c";
static NSString* const SENAPIRoomUnitFahrenheit = @"f";
static NSString* const SENAPIRoomScopeDay = @"day";
static NSString* const SENAPIRoomScopeWeek = @"week";
static NSString* const SENAPIRoomPathFormat = @"room/%@/%@";
static NSString* const SENAPIRoomParamTimestamp = @"from";
static NSString* const SENAPIRoomParamUnit = @"temperature_unit";

+ (void)currentWithCompletion:(SENAPIDataBlock)completion
{
    NSString* unitParam = [SENSettings useCentigrade] ? SENAPIRoomUnitCentigrade : SENAPIRoomUnitFahrenheit;
    [SENAPIClient GET:@"room/current" parameters:@{SENAPIRoomParamUnit:unitParam} completion:completion];
}

+ (void)hourlyHistoricalDataForSensor:(SENSensor*)sensor
                           completion:(SENAPIDataBlock)completion
{
    [self historicalDataForSensor:sensor timeScope:SENAPIRoomScopeDay completion:completion];
}

+ (void)dailyHistoricalDataForSensor:(SENSensor*)sensor
                          completion:(SENAPIDataBlock)completion
{
    [self historicalDataForSensor:sensor timeScope:SENAPIRoomScopeWeek completion:completion];
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
        params[SENAPIRoomParamTimestamp] = timestamp;
    NSString* path = [NSString stringWithFormat:SENAPIRoomPathFormat, sensor.name, scope];
    [SENAPIClient GET:path parameters:params completion:^(NSArray* data, NSError *error) {
        NSMutableArray* points = [[NSMutableArray alloc] initWithCapacity:data.count];
        for (NSDictionary* pointData in data) {
            SENSensorDataPoint* point = [[SENSensorDataPoint alloc] initWithDictionary:pointData];
            if (point)
                [points addObject:point];
        }
        completion(points, error);
    }];
}

+ (NSString*)parameterForCurrentDate
{
    static NSString* const SENAPIRoomTimestampFormat = @"%.0f";
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:SENAPIRoomTimestampFormat, seconds * 1000];
}

@end
