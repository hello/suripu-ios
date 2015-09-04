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
        
        context(@"temperature value is not a whole number and locale in US", ^{
            
            beforeEach(^{
                NSLocale* locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
                [NSLocale stub:@selector(currentLocale) andReturn:locale];
                [formatter setSensorUnit:SENSensorUnitDegreeCentigrade];
                sensorValue = [formatter stringFromSensorValue:@31.6];
            });
            
            afterEach(^{
                [NSLocale clearStubs];
            });
            
            it(@"should not contain fractions, rounded up and converted to Fahrenheit ", ^{
                [[sensorValue should] equal:@"89"];
            });
            
        });
        
        context(@"light value is less than 0", ^{
            
            beforeEach(^{
                [formatter setSensorUnit:SENSensorUnitLux];
                sensorValue = [formatter stringFromSensorValue:@0.40365];
            });
            
            it(@"should be rounded up with 1 max fraction digits", ^{
                [[sensorValue should] equal:@"0.5"];
            });

        });
        
        context(@"light value is less than 10, but greater than 1", ^{
            
            beforeEach(^{
                [formatter setSensorUnit:SENSensorUnitLux];
                sensorValue = [formatter stringFromSensorValue:@9.8];
            });
            
            it(@"should show 2 digits, with 1 of those fractional digits", ^{
                [[sensorValue should] equal:@"9.8"];
            });
            
        });
        
        context(@"light value is greater than 10, but less than 100", ^{
            
            beforeEach(^{
                [formatter setSensorUnit:SENSensorUnitLux];
                sensorValue = [formatter stringFromSensorValue:@25];
            });
            
            it(@"should show 2 digits, with zero fractional digits", ^{
                [[sensorValue should] equal:@"25"];
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
