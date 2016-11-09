//
//  HEMSystemAlertService.m
//  Sense
//
//  Created by Jimmy Lu on 11/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENAPISystemAlerts.h>
#import <SenseKit/SENSystemAlert.h>

#import "HEMSystemAlertService.h"

@implementation HEMSystemAlertService

- (void)getNextAvailableAlert:(HEMSystemAlertHandler)completion {
    [SENAPISystemAlerts getSystemAlerts:^(NSArray* alerts, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion ([alerts firstObject], error);
    }];
}

@end
