//
//  HEMDeviceServiceSpec.m
//  Sense
//
//  Created by Jimmy Lu on 12/29/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/API.h>
#import <SenseKit/Model.h>
#import <SenseKit/SENServiceDevice.h>
#import "HEMDeviceService.h"
#import "SENAnalytics+HEMAppAnalytics.h"

SPEC_BEGIN(HEMDeviceServiceSpec)

describe(@"HEMDeviceService", ^{
    
    describe(@"-refreshMetadata:", ^{
        
        __block HEMDeviceService* service = nil;
        
        beforeEach(^{
            service = [HEMDeviceService new];
        });
        
        afterEach(^{
            service = nil;
        });
        
        context(@"old service returned an error", ^{
            
            __block SENServiceDevice* oldService = nil;
            
            beforeEach(^{
                oldService = [SENServiceDevice sharedService];
                [oldService stub:@selector(loadDeviceInfo:) withBlock:^id(NSArray *params) {
                    void(^cb)(NSError*) = [params lastObject];
                    cb ([NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
            });
            
            afterEach(^{
                [oldService clearStubs];
            });
            
            it(@"should track error", ^{
                [[SENAnalytics should] receive:@selector(trackError:)];
                [service refreshMetadata:^(SENPairedDevices * _Nullable devices, NSError * _Nullable error) {
                    // do nothing
                }];
            });
            
            it(@"should return an error", ^{
                __block NSError* serviceError = nil;
                [service refreshMetadata:^(SENPairedDevices * _Nullable devices, NSError * _Nullable error) {
                    serviceError = error;
                }];
                [[serviceError should] beNonNil];
            });
            
        });
        
        context(@"old service loaded device info", ^{
            
            __block SENServiceDevice* oldService = nil;
            
            beforeEach(^{
                oldService = [SENServiceDevice sharedService];
                [oldService stub:@selector(loadDeviceInfo:) withBlock:^id(NSArray *params) {
                    void(^cb)(NSError*) = [params lastObject];
                    cb (nil);
                    return nil;
                }];
                [oldService stub:@selector(devices) andReturn:[SENPairedDevices new]];
            });
            
            afterEach(^{
                [oldService clearStubs];
            });
            
            it(@"should not track error", ^{
                [[SENAnalytics shouldNot] receive:@selector(trackError:)];
                [service refreshMetadata:^(SENPairedDevices * _Nullable devices, NSError * _Nullable error) {
                    // do nothing
                }];
            });
            
            it(@"should not return an error", ^{
                __block NSError* serviceError = nil;
                [service refreshMetadata:^(SENPairedDevices * _Nullable devices, NSError * _Nullable error) {
                    serviceError = error;
                }];
                [[serviceError should] beNil];
            });
            
            it(@"should return paired devices", ^{
                __block id pairedDevices = nil;
                [service refreshMetadata:^(SENPairedDevices * _Nullable devices, NSError * _Nullable error) {
                    pairedDevices = devices;
                }];
                [[pairedDevices should] beKindOfClass:[SENPairedDevices class]];
            });
            
        });
        
    });
    
    describe(@"-shouldWarnAboutLastSeenForDevice:", ^{
        
        __block HEMDeviceService* service = nil;
        
        beforeEach(^{
            service = [HEMDeviceService new];
        });
        
        afterEach(^{
            service = nil;
        });
        
        it(@"should be YES if last seen is greater than a day", ^{
            NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents* components = [NSDateComponents new];
            components.day = -1;
            components.minute = -1;
            NSDate* dayOld = [calendar dateByAddingComponents:components
                                                       toDate:[NSDate date]
                                                      options:0];
            NSDictionary* dict = @{@"last_updated" : @([dayOld timeIntervalSince1970] * 1000)};
            SENSenseMetadata* metadata = [[SENSenseMetadata alloc] initWithDictionary:dict];
            BOOL warn = [service shouldWarnAboutLastSeenForDevice:metadata];
            [[@(warn) should] beYes];
        });
        
        it(@"should be NO if last seen is 23 hours ago", ^{
            NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents* components = [NSDateComponents new];
            components.hour = -23;
            NSDate* hoursAgo = [calendar dateByAddingComponents:components
                                                         toDate:[NSDate date]
                                                        options:0];
            NSDictionary* dict = @{@"last_updated" : @([hoursAgo timeIntervalSince1970] * 1000)};
            SENSenseMetadata* metadata = [[SENSenseMetadata alloc] initWithDictionary:dict];
            BOOL warn = [service shouldWarnAboutLastSeenForDevice:metadata];
            [[@(warn) should] beNo];
        });
        
        it(@"should be NO if no last seen date in metadata", ^{
            SENSenseMetadata* metadata = [SENSenseMetadata new];
            BOOL warn = [service shouldWarnAboutLastSeenForDevice:metadata];
            [[@(warn) should] beNo];
        });
        
    });
    
    describe(@"-shouldShowPillInfo", ^{
        
        context(@"has no device data", ^{
            __block BOOL showPill = YES;
            
            beforeEach(^{
                HEMDeviceService* service = [HEMDeviceService new];
                showPill = [service shouldShowPillInfo];
            });
            
            afterEach(^{
                showPill = YES;
            });
            
            it(@"should return NO", ^{
                [[@(showPill) should] beNo];
            });
        });
        
        context(@"has pill meta data, but no sense", ^{
            __block BOOL showPill = NO;
            
            beforeEach(^{
                HEMDeviceService* service = [HEMDeviceService new];
                
                SENPillMetadata* pill = [SENPillMetadata new];
                [pill stub:@selector(uniqueId) andReturn:@"1"];
                
                SENPairedDevices* devices = [SENPairedDevices new];
                [devices stub:@selector(pillMetadata) andReturn:pill];
                
                [service stub:@selector(devices) andReturn:devices];

                showPill = [service shouldShowPillInfo];
            });
            
            afterEach(^{
                showPill = NO;
            });
            
            it(@"should return YES", ^{
                [[@(showPill) should] beYes];
            });
        });
        
        context(@"has no pill meta data and has sense meta data", ^{
            __block BOOL showPill = NO;
            
            beforeEach(^{
                HEMDeviceService* service = [HEMDeviceService new];
                
                SENSenseMetadata* sense = [SENSenseMetadata new];
                [sense stub:@selector(uniqueId) andReturn:@"1"];
                
                SENPairedDevices* devices = [SENPairedDevices new];
                [devices stub:@selector(senseMetadata) andReturn:sense];
                
                [service stub:@selector(devices) andReturn:devices];
                
                showPill = [service shouldShowPillInfo];
            });
            
            afterEach(^{
                showPill = NO;
            });
            
            it(@"should return YES", ^{
                [[@(showPill) should] beYes];
            });
        });
        
        context(@"has no pill meta data and no sense meta data", ^{
            __block BOOL showPill = NO;
            
            beforeEach(^{
                HEMDeviceService* service = [HEMDeviceService new];
                [service stub:@selector(devices) andReturn:[SENPairedDevices new]];
                showPill = [service shouldShowPillInfo];
            });
            
            afterEach(^{
                showPill = NO;
            });
            
            it(@"should return NO", ^{
                [[@(showPill) should] beNo];
            });
        });

    });
    
});

SPEC_END
