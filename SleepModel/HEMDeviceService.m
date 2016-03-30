//
//  HEMDeviceService.m
//  Sense
//
//  Created by Jimmy Lu on 12/29/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENDeviceMetadata.h>
#import <SenseKit/SENAPIDevice.h>

#import "HEMDeviceService.h"

NSString* const HEMDeviceServiceErrorDomain = @"is.hello.app.service.device";

@interface HEMDeviceService()

@property (nonatomic, strong) SENPairedDevices* devices;

@end

@implementation HEMDeviceService

- (instancetype)init {
    self = [super init];
    if (self) {
        _devices = [[SENServiceDevice sharedService] devices]; // in case already loaded
        [self listenForDeprecatedServiceNotifications];
    }
    return self;
}

- (void)listenForDeprecatedServiceNotifications {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(clearDevicesCache)
                   name:SENServiceDeviceNotificationFactorySettingsRestored
                 object:nil];
    [center addObserver:self
               selector:@selector(clearDevicesCache)
                   name:SENServiceDeviceNotificationSenseUnpaired
                 object:nil];
    [center addObserver:self
               selector:@selector(clearDevicesCache)
                   name:SENServiceDeviceNotificationPillUnpaired
                 object:nil];
}

- (void)clearDevicesCache {
    [self setDevices:nil];
}

- (NSError*)errorWithCode:(HEMDeviceError)code {
    return [NSError errorWithDomain:HEMDeviceServiceErrorDomain
                               code:code
                           userInfo:nil];
}

- (void)refreshMetadata:(HEMDeviceMetadataHandler)completion {
    __weak typeof(self) weakSelf = self;
    [[SENServiceDevice sharedService] loadDeviceInfo:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        SENPairedDevices* devices = nil;
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            devices = [[SENServiceDevice sharedService] devices];
            [strongSelf setDevices:devices];
        }
        completion (devices, error);
    }];
}

- (BOOL)shouldWarnAboutLastSeenForDevice:(SENDeviceMetadata*)metadata {
    if (![metadata lastSeenDate]) {
        return NO;
    }
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components = [NSDateComponents new];
    components.day = -1;
    
    NSDate* dayOld = [calendar dateByAddingComponents:components
                                               toDate:[NSDate date]
                                              options:0];
    return [[metadata lastSeenDate] compare:dayOld] == NSOrderedAscending;
}

- (BOOL)shouldShowPillInfo {
    return [self devices]
        && ([[self devices] hasPairedPill]
            || [[self devices] hasPairedSense]);
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
