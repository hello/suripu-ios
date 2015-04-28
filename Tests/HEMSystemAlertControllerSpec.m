//
//  HEMSystemAlertControllerSpec.m
//  Sense
//
//  Created by Jimmy Lu on 4/1/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Kiwi/Kiwi.h>
#import <SenseKit/SENAPITimeZone.h>
#import <SenseKit/SENServiceDevice.h>
#import "HEMSystemAlertController.h"

@interface HEMSystemAlertController ()

- (void)checkTimeZone;
- (void)showTimeZoneWarning;
- (void)checkSystemIfEnabled;
- (void)showDeviceWarning;

@end

SPEC_BEGIN(HEMSystemAlertControllerSpec)

describe(@"HEMSystemAlertController", ^{

    __block HEMSystemAlertController* alertController = nil;
    
    beforeEach(^{
        UIViewController* fakeVC = [[UIViewController alloc] init];
        alertController = [[HEMSystemAlertController alloc] initWithViewController:fakeVC];
    });
    
    describe(@"-checkSystemIfEnabled", ^{
        
        it(@"should attempt to show device warning if sense not paired", ^{
            SENServiceDevice* deviceService = [SENServiceDevice sharedService];
            
            [deviceService stub:@selector(checkDevicesState:) withBlock:^id(NSArray *params) {
                void(^cb)(SENServiceDeviceState state) = [params lastObject];
                cb (SENServiceDeviceStateSenseNotPaired);
                return nil;
            }];
            
            [alertController enableSystemMonitoring:YES];
            [[alertController should] receive:@selector(showDeviceWarning)];
            [alertController checkSystemIfEnabled];
        });
        
        it(@"should attempt to show device warning if pill not paired", ^{
            SENServiceDevice* deviceService = [SENServiceDevice sharedService];
            
            [deviceService stub:@selector(checkDevicesState:) withBlock:^id(NSArray *params) {
                void(^cb)(SENServiceDeviceState state) = [params lastObject];
                cb (SENServiceDeviceStatePillNotPaired);
                return nil;
            }];
            
            [alertController enableSystemMonitoring:YES];
            [[alertController should] receive:@selector(showDeviceWarning)];
            [alertController checkSystemIfEnabled];
        });
        
        it(@"should attempt to show device warning if pill has low battery", ^{
            SENServiceDevice* deviceService = [SENServiceDevice sharedService];
            
            [deviceService stub:@selector(checkDevicesState:) withBlock:^id(NSArray *params) {
                void(^cb)(SENServiceDeviceState state) = [params lastObject];
                cb (SENServiceDeviceStatePillLowBattery);
                return nil;
            }];
            
            [alertController enableSystemMonitoring:YES];
            [[alertController should] receive:@selector(showDeviceWarning)];
            [alertController checkSystemIfEnabled];
        });
        
        it(@"should attempt to show device warning if sense has not been seen", ^{
            SENServiceDevice* deviceService = [SENServiceDevice sharedService];
            
            [deviceService stub:@selector(checkDevicesState:) withBlock:^id(NSArray *params) {
                void(^cb)(SENServiceDeviceState state) = [params lastObject];
                cb (SENServiceDeviceStateSenseNotSeen);
                return nil;
            }];
            
            [alertController enableSystemMonitoring:YES];
            [[alertController should] receive:@selector(showDeviceWarning)];
            [alertController checkSystemIfEnabled];
        });
        
        it(@"should attempt to show device warning if pill has not been seen", ^{
            SENServiceDevice* deviceService = [SENServiceDevice sharedService];
            
            [deviceService stub:@selector(checkDevicesState:) withBlock:^id(NSArray *params) {
                void(^cb)(SENServiceDeviceState state) = [params lastObject];
                cb (SENServiceDeviceStatePillNotSeen);
                return nil;
            }];
            
            [alertController enableSystemMonitoring:YES];
            [[alertController should] receive:@selector(showDeviceWarning)];
            [alertController checkSystemIfEnabled];
        });
        
        it(@"should check time zone if devices are normal", ^{
            SENServiceDevice* deviceService = [SENServiceDevice sharedService];
            
            [deviceService stub:@selector(checkDevicesState:) withBlock:^id(NSArray *params) {
                void(^cb)(SENServiceDeviceState state) = [params lastObject];
                cb (SENServiceDeviceStateNormal);
                return nil;
            }];
            
            [alertController enableSystemMonitoring:YES];
            [[alertController should] receive:@selector(checkTimeZone)];
            [alertController checkSystemIfEnabled];
        });
        
    });
    
    describe(@"-checkTimeZone", ^{
        
        it(@"should not attempt to show warning when time zone is set", ^{
            
            [SENAPITimeZone stub:@selector(getConfiguredTimeZone:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock cb = [params lastObject];
                cb ([NSTimeZone localTimeZone], nil);
                return nil;
            }];
            
            [[alertController shouldNot] receive:@selector(showTimeZoneWarning)];
            [alertController checkTimeZone];
            
        });
        
        it(@"should not attempt to show warning if an error was encountered", ^{
            
            [SENAPITimeZone stub:@selector(getConfiguredTimeZone:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock cb = [params lastObject];
                cb (nil, [NSError errorWithDomain:@"is.hello.test" code:-1 userInfo:nil]);
                return nil;
            }];
            
            [[alertController shouldNot] receive:@selector(showTimeZoneWarning)];
            [alertController checkTimeZone];
            
        });
        
        it(@"should attempt to show warning if no time zone and no error", ^{
            
            [SENAPITimeZone stub:@selector(getConfiguredTimeZone:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock cb = [params lastObject];
                cb (nil, nil);
                return nil;
            }];
            
            [[alertController should] receive:@selector(showTimeZoneWarning)];
            [alertController checkTimeZone];
            
        });
        
    });
    
});

SPEC_END
