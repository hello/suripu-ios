
#import <Kiwi/Kiwi.h>
#import "HEMSensor.h"

SPEC_BEGIN(HEMSensorSpec)

describe(@"HEMSensor", ^{

    describe(@"-initWithDictionary:", ^{
        
        __block HEMSensor* sensor;
        NSTimeInterval sensorTimestamp = [[NSDate date] timeIntervalSince1970];
        NSDictionary* sensorValues = @{
                                       @"name":@"temperature",
                                       @"value": @(22.8),
                                       @"unit": @"CENTIGRADE",
                                       @"message": @"It's pretty cold in here.",
                                       @"condition": @"WARNING",
                                       @"last_updated": @(sensorTimestamp)};

        beforeEach(^{
            sensor = [[HEMSensor alloc] initWithDictionary:sensorValues];
        });
        
        it(@"sets the name", ^{
            [[sensor.name should] equal:@"temperature"];
        });
        
        it(@"sets the value", ^{
            [[sensor.value should] equal:@(22.8)];
        });
        
        it(@"sets the unit", ^{
            [[@(sensor.unit) should] equal:@(HEMSensorUnitDegreeCentigrade)];
        });
        
        it(@"sets the message", ^{
            [[sensor.message should] equal:@"It's pretty cold in here."];
        });
        
        it(@"sets the condition", ^{
            [[@(sensor.condition) should] equal:@(HEMSensorConditionWarning)];
        });
        
        it(@"sets the updated date", ^{
            [[@(sensor.lastUpdated.timeIntervalSince1970) should] equal:@(sensorTimestamp)];
        });
    });
});

SPEC_END
