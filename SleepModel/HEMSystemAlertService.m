//
//  HEMSystemAlertService.m
//  Sense
//
//  Created by Jimmy Lu on 12/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAPIDevice.h>
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENPillMetadata.h>

#import "HEMSystemAlertService.h"

NSString* const HEMSystemAlertDomain = @"is.hello.app.sysalert";

@interface HEMSystemAlertService()

@property (nonatomic, strong) SENPairedDevices* devices;

@end

@implementation HEMSystemAlertService

- (void)checkSystemState:(HEMSystemAlertStateCallback)completion {
    if (![SENAuthorizationService isAuthorized]) {
        completion (HEMSystemAlertStateUnknown);
        return;
    }
 
    __weak typeof(self) weakSelf = self;
    [SENAPIDevice getPairedDevices:^(SENPairedDevices* devices, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [SENAnalytics trackError:error];
            completion (HEMSystemAlertStateUnknown);
            return;
        }
        
        [strongSelf setDevices:devices];
    }];
}

@end
