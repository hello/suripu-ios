//
//  HEMDeviceAlertServiceSpec.m
//  Sense
//
//  Created by Jimmy Lu on 12/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENAPIDevice.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/Model.h>
#import "HEMDeviceAlertService.h"
#import "NSDate+HEMRelative.h"

SPEC_BEGIN(HEMDeviceAlertServiceSpec)

describe(@"HEMDeviceAlertService", ^{
    
    describe(@"-checkDeviceState:", ^{
        
        __block HEMDeviceAlertService* service = nil;
        
        beforeEach(^{
            [SENAuthorizationService stub:@selector(isAuthorized) andReturn:[KWValue valueWithBool:YES]];
            service = [HEMDeviceAlertService new];
        });
        
        afterEach(^{
            [SENAuthorizationService clearStubs];
            service = nil;
        });
        
        context(@"error returned from api", ^{
            
            __block HEMDeviceAlertState deviceState = HEMDeviceAlertStateNormal;
            
            beforeEach(^{
                
                [SENAPIDevice stub:@selector(getPairedDevices:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [service checkDeviceState:^(HEMDeviceAlertState state) {
                    deviceState = state;
                }];
                
            });
            
            afterEach(^{
                [SENAPIDevice clearStubs];
                deviceState = HEMDeviceAlertStateNormal;
            });
            
            it(@"should return unknown state", ^{
                [[@(deviceState) should] equal:@(HEMDeviceAlertStateUnknown)];
            });
            
        });
        
        context(@"sense not paired", ^{
            
            __block HEMDeviceAlertState deviceState = HEMDeviceAlertStateNormal;
            
            beforeEach(^{
                [SENAPIDevice stub:@selector(getPairedDevices:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb ([SENPairedDevices new], nil);
                    return nil;
                }];
                
                [service checkDeviceState:^(HEMDeviceAlertState state) {
                    deviceState = state;
                }];
            });
            
            afterEach(^{
                [SENAPIDevice clearStubs];
                deviceState = HEMDeviceAlertStateNormal;
            });
            
            it(@"should return a no sense paired state", ^{
                [[@(deviceState) should] equal:@(HEMDeviceAlertStateSenseNotPaired)];
            });
            
        });
        
        context(@"sense paired", ^{
            
            __block SENPairedDevices* devices = nil;
            __block SENSenseMetadata* senseMetadata = nil;
            __block HEMDeviceAlertState deviceState = HEMDeviceAlertStateUnknown;
            
            beforeEach(^{
                senseMetadata = [SENSenseMetadata new];
                [senseMetadata stub:@selector(lastSeenDate) andReturn:[NSDate date]];
                
                devices = [SENPairedDevices new];
                [devices stub:@selector(hasPairedSense) andReturn:[KWValue valueWithBool:YES]];
                [devices stub:@selector(senseMetadata) andReturn:senseMetadata];
            });
            
            afterEach(^{
                [SENAPIDevice clearStubs];
                deviceState = HEMDeviceAlertStateUnknown;
                devices = nil;
                senseMetadata = nil;
            });
            
            context(@"sense last seen was yesterday", ^{
                
                beforeEach(^{
                    [senseMetadata stub:@selector(lastSeenDate) andReturn:[[NSDate date] previousDay]];
                    
                    [SENAPIDevice stub:@selector(getPairedDevices:) withBlock:^id(NSArray *params) {
                        SENAPIDataBlock cb = [params lastObject];
                        cb (devices, nil);
                        return nil;
                    }];
                    
                    [service checkDeviceState:^(HEMDeviceAlertState state) {
                        deviceState = state;
                    }];
                });
                
                afterEach(^{
                    [SENAPIDevice clearStubs];
                    [senseMetadata clearStubs];
                    deviceState = HEMDeviceAlertStateUnknown;
                });
                
                it(@"should return a sense not seen state", ^{
                    [[@(deviceState) should] equal:@(HEMDeviceAlertStateSenseNotSeen)];
                });
                
                it(@"should not return a sense not seen state if already seen today", ^{
                    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
                    [localPrefs stub:@selector(userPreferenceForKey:) andReturn:[NSDate date]];
                    
                    [service checkDeviceState:^(HEMDeviceAlertState state) {
                        deviceState = state;
                    }];
                    
                    [[@(deviceState) shouldNot] equal:@(HEMDeviceAlertStateSenseNotSeen)];
                });
                
                it(@"should return a sense not seen state, if last shown was yesterday", ^{
                    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
                    [localPrefs stub:@selector(userPreferenceForKey:) andReturn:[[NSDate date] previousDay]];
                    
                    [service checkDeviceState:^(HEMDeviceAlertState state) {
                        deviceState = state;
                    }];
                    
                    [[@(deviceState) should] equal:@(HEMDeviceAlertStateSenseNotSeen)];
                });
                
            });
            
            context(@"pill not paired", ^{
                
                beforeEach(^{
                    [senseMetadata stub:@selector(lastSeenDate) andReturn:[NSDate date]];
                    
                    [SENAPIDevice stub:@selector(getPairedDevices:) withBlock:^id(NSArray *params) {
                        SENAPIDataBlock cb = [params lastObject];
                        cb (devices, nil);
                        return nil;
                    }];
                    
                    [service checkDeviceState:^(HEMDeviceAlertState state) {
                        deviceState = state;
                    }];
                });
                
                afterEach(^{
                    [SENAPIDevice clearStubs];
                    [senseMetadata clearStubs];
                    deviceState = HEMDeviceAlertStateUnknown;
                });
                
                it(@"should return a no pill paired state", ^{
                    [[@(deviceState) should] equal:@(HEMDeviceAlertStatePillNotPaired)];
                });
                
            });
            
            context(@"pill has low battery", ^{
                
                __block SENPillMetadata* pillMetadata;
                
                beforeEach(^{
                    [senseMetadata stub:@selector(lastSeenDate) andReturn:[NSDate date]];
                    
                    pillMetadata = [[SENPillMetadata alloc] initWithDictionary:@{@"state" : @"LOW_BATTERY"}];
                    [pillMetadata stub:@selector(lastSeenDate) andReturn:[NSDate date]];
                    
                    [devices stub:@selector(pillMetadata) andReturn:pillMetadata];
                    [devices stub:@selector(hasPairedPill) andReturn:[KWValue valueWithBool:YES]];
                    
                    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
                    [localPrefs stub:@selector(userPreferenceForKey:) andReturn:[[NSDate date] previousDay]];
                    
                    
                    [SENAPIDevice stub:@selector(getPairedDevices:) withBlock:^id(NSArray *params) {
                        SENAPIDataBlock cb = [params lastObject];
                        cb (devices, nil);
                        return nil;
                    }];
                    
                });
                
                afterEach(^{
                    [SENAPIDevice clearStubs];
                    [senseMetadata clearStubs];
                    [[SENLocalPreferences sharedPreferences] clearStubs];
                    pillMetadata = nil;
                    deviceState = HEMDeviceAlertStateUnknown;
                });
                
                it(@"should return a low battery state", ^{
                    [service checkDeviceState:^(HEMDeviceAlertState state) {
                        deviceState = state;
                    }];
                    [[@(deviceState) should] equal:@(HEMDeviceAlertStatePillLowBattery)];
                });
                
                it(@"should not show a low battery state, if already shown today", ^{
                    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
                    [localPrefs stub:@selector(userPreferenceForKey:) andReturn:[NSDate date]];
                    
                    [service checkDeviceState:^(HEMDeviceAlertState state) {
                        deviceState = state;
                    }];
                    
                    [[@(deviceState) should] equal:@(HEMDeviceAlertStateNormal)];
                });
                
                it(@"should show a low battery state, if last low battery shown was yesterday", ^{
                    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
                    [localPrefs stub:@selector(userPreferenceForKey:) andReturn:[[NSDate date] previousDay]];
                    
                    [service checkDeviceState:^(HEMDeviceAlertState state) {
                        deviceState = state;
                    }];
                    
                    [[@(deviceState) should] equal:@(HEMDeviceAlertStatePillLowBattery)];
                });
                
            });
            
            context(@"pill not seen for at least a day", ^{
                
                __block SENPillMetadata* pillMetadata;
                
                beforeEach(^{
                    [senseMetadata stub:@selector(lastSeenDate) andReturn:[NSDate date]];
                    
                    pillMetadata = [SENPillMetadata new];
                    [pillMetadata stub:@selector(state) andReturn:[KWValue valueWithInteger:SENPillStateNormal]];
                    [pillMetadata stub:@selector(lastSeenDate) andReturn:[[NSDate date] previousDay]];
                    
                    [devices stub:@selector(pillMetadata) andReturn:pillMetadata];
                    [devices stub:@selector(hasPairedPill) andReturn:[KWValue valueWithBool:YES]];
                    
                    [SENAPIDevice stub:@selector(getPairedDevices:) withBlock:^id(NSArray *params) {
                        SENAPIDataBlock cb = [params lastObject];
                        cb (devices, nil);
                        return nil;
                    }];
                    
                    [service checkDeviceState:^(HEMDeviceAlertState state) {
                        deviceState = state;
                    }];
                    
                });
                
                afterEach(^{
                    [senseMetadata clearStubs];
                    [SENAPIDevice clearStubs];
                    pillMetadata = nil;
                    deviceState = HEMDeviceAlertStateUnknown;
                });
                
                it(@"should return a pill not seen state", ^{
                    [[@(deviceState) should] equal:@(HEMDeviceAlertStatePillNotSeen)];
                });
                
                it(@"should not return a pill not seen state if already seen today", ^{
                    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
                    [localPrefs stub:@selector(userPreferenceForKey:) andReturn:[NSDate date]];
                    
                    [service checkDeviceState:^(HEMDeviceAlertState state) {
                        deviceState = state;
                    }];
                    
                    [[@(deviceState) shouldNot] equal:@(HEMDeviceAlertStatePillNotSeen)];
                });
                
                it(@"should return a pill not seen state, if last shown was yesterday", ^{
                    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
                    [localPrefs stub:@selector(userPreferenceForKey:) andReturn:[[NSDate date] previousDay]];
                    
                    [service checkDeviceState:^(HEMDeviceAlertState state) {
                        deviceState = state;
                    }];
                    
                    [[@(deviceState) should] equal:@(HEMDeviceAlertStatePillNotSeen)];
                });
                
            });
            
        });
        
    });
    
});

SPEC_END
