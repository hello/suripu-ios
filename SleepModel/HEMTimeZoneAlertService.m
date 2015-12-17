//
//  HEMTimeZoneAlertService.m
//  Sense
//
//  Created by Jimmy Lu on 12/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <SenseKit/SENAPITimeZone.h>
#import "HEMTimeZoneAlertService.h"

@implementation HEMTimeZoneAlertService

- (void)checkTimeZoneSetting:(HEMTimeZoneAlertCallback)completion {
    [SENAPITimeZone getConfiguredTimeZone:^(NSTimeZone* data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data == nil && error == nil);
    }];
}

@end
