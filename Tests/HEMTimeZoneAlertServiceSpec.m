//
//  HEMTimeZoneAlertServiceSpec.m
//  Sense
//
//  Created by Jimmy Lu on 12/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/API.h>
#import <SenseKit/Model.h>
#import "HEMTimeZoneAlertService.h"
#import "NSDate+HEMRelative.h"

SPEC_BEGIN(HEMNetworkAlertServiceSpec)

describe(@"HEMNetworkAlertService", ^{
    
    describe(@"-checkTimeZoneSetting", ^{
        
        context(@"api returned an error", ^{
            
            __block BOOL needsTimeZoneFlag = YES;
           
            beforeEach(^{
                [SENAPITimeZone stub:@selector(getConfiguredTimeZone:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [[HEMTimeZoneAlertService new] checkTimeZoneSetting:^(BOOL needsTimeZone) {
                    needsTimeZoneFlag = needsTimeZone;
                }];
            });
            
            afterEach(^{
                [SENAPITimeZone clearStubs];
            });
            
            it(@"should return NO", ^{
                [[@(needsTimeZoneFlag) should] beNo];
            });
            
        });
        
        context(@"api returned no time zone or error", ^{
            
            __block BOOL needsTimeZoneFlag = NO;
            
            beforeEach(^{
                [SENAPITimeZone stub:@selector(getConfiguredTimeZone:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, nil);
                    return nil;
                }];
                
                [[HEMTimeZoneAlertService new] checkTimeZoneSetting:^(BOOL needsTimeZone) {
                    needsTimeZoneFlag = needsTimeZone;
                }];
            });
            
            afterEach(^{
                [SENAPITimeZone clearStubs];
            });
            
            it(@"should return YES", ^{
                [[@(needsTimeZoneFlag) should] beYes];
            });
            
        });
        
        context(@"api returned a time zone", ^{
            
            __block BOOL needsTimeZoneFlag = YES;
            
            beforeEach(^{
                [SENAPITimeZone stub:@selector(getConfiguredTimeZone:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb ([NSTimeZone systemTimeZone], nil);
                    return nil;
                }];
                
                [[HEMTimeZoneAlertService new] checkTimeZoneSetting:^(BOOL needsTimeZone) {
                    needsTimeZoneFlag = needsTimeZone;
                }];
            });
            
            afterEach(^{
                [SENAPITimeZone clearStubs];
            });
            
            it(@"should return NO", ^{
                [[@(needsTimeZoneFlag) should] beNo];
            });
            
        });
        
    });
    
});

SPEC_END
