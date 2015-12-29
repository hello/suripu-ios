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

#import "HEMDeviceService.h"

NSString* const HEMDeviceServiceErrorDomain = @"is.hello.app.service.device";

@interface HEMDeviceService()

@property (nonatomic, strong) SENPairedDevices* devices;

@end

@implementation HEMDeviceService

- (NSError*)errorWithCode:(HEMDeviceError)code {
    return [NSError errorWithDomain:HEMDeviceServiceErrorDomain
                               code:code
                           userInfo:nil];
}

- (NSError*)translateOldServiceError:(NSError*)error {
    if (!error) {
        return nil;
    }
    return [self errorWithCode:[error code]];
}

- (void)refreshMetadata:(HEMDeviceMetadataHandler)completion {
    __weak typeof(self) weakSelf = self;
    SENServiceDevice* oldService = [SENServiceDevice sharedService];
    [oldService loadDeviceInfo:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSError* deviceError = [strongSelf translateOldServiceError:error];
        if (deviceError) {
            [SENAnalytics trackError:deviceError];
        } else {
            [strongSelf setDevices:[oldService devices]];
        }
        completion ([strongSelf devices], deviceError);
    }];
}

- (BOOL)shouldWarnAboutLastSeenForDevice:(SENDeviceMetadata*)metadata {
    if (!metadata) {
        return NO;
    }
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components = [NSDateComponents new];
    components.day = -1;
    
    NSDate* dayOld = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
    return [[metadata lastSeenDate] compare:dayOld] == NSOrderedAscending;
}

@end
