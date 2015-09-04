//
//  HEMSensorValueFormatterSpec.m
//  Sense
//
//  Created by Jimmy Lu on 8/5/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SenseKit.h>
#import "HEMSensorValueFormatter.h"

@interface HEMSensorValueFormatter()


@end

SPEC_BEGIN(HEMSensorValueFormatterSpec)

describe(@"HEMSensorValueFormatter", ^{
    
    __block HEMSensorValueFormatter* formatter;
    
    beforeEach(^{
        formatter = [[HEMSensorValueFormatter alloc] init];
    });
    
    describe(@"-stringFromSensorValue:", ^{
        
        __block NSString* sensorValue = nil;
        
        context(@"sensor value is nil", ^{
            
            __block NSString* emptyValue = nil;
            
            beforeEach(^{
                emptyValue = NSLocalizedString(@"empty-data", nil);
                [formatter setSensorUnit:SENSensorUnitPercent];
                sensorValue = [formatter stringFromSensorValue:nil];
            });
            
            it(@"should not be nil", ^{
                [[emptyValue should] beNonNil];
            });
            
            it(@"should equal to the empty data value", ^{
                [[sensorValue should] equal:emptyValue];
            });
            
        });
        
        context(@"temperature value is not a whole number", ^{
            
            beforeEach(^{
                [formatter setSensorUnit:SENSensorUnitDegreeCentigrade];
                [SENPreference stub:@selector(temperatureFormat) andReturn:@(SENTemperatureFormatCentigrade)];
                sensorValue = [formatter stringFromSensorValue:@89.6];
            });
            
            it(@"should not contain fractions and rounded up", ^{
                [[sensorValue should] equal:@"90"];
            });
            
        });
        
        context(@"light value is less than 0", ^{
            
            beforeEach(^{
                [formatter setSensorUnit:SENSensorUnitLux];
                sensorValue = [formatter stringFromSensorValue:@0.40365];
            });
            
            it(@"should be rounded up with 2 max fraction digits", ^{
                [[sensorValue should] equal:@"0.41"];
            });
            
        });
        
        context(@"light value is less than 10, but greater than 1", ^{
            
            beforeEach(^{
                [formatter setSensorUnit:SENSensorUnitLux];
                sensorValue = [formatter stringFromSensorValue:@9.8];
            });
            
            it(@"should show 3 digits, with 2 of those fractional digits", ^{
                [[sensorValue should] equal:@"9.80"];
            });
            
        });
        
        context(@"light value is greater than 10, but less than 100", ^{
            
            beforeEach(^{
                [formatter setSensorUnit:SENSensorUnitLux];
                sensorValue = [formatter stringFromSensorValue:@25];
            });
            
            it(@"should show 3 digits, with 1 of those fractional digits", ^{
                [[sensorValue should] equal:@"25.0"];
            });
            
        });
        
        context(@"light value is 125", ^{
            
            beforeEach(^{
                [formatter setSensorUnit:SENSensorUnitLux];
                sensorValue = [formatter stringFromSensorValue:@125];
            });
            
            it(@"should show 3 digits, with zero fractional digits", ^{
                [[sensorValue should] equal:@"125"];
            });
            
        });
        
    });
    
    
});

SPEC_END
