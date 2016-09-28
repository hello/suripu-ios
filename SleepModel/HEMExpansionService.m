//
//  HEMExpansionService.m
//  Sense
//
//  Created by Jimmy Lu on 9/27/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENAPIExpansion.h>
#import <SenseKit/SENExpansion.h>
#import <SenseKit/SENService+Protected.h>

#import "HEMExpansionService.h"

@interface HEMExpansionService()

@property (nonatomic, strong) NSArray<SENExpansion*>* expansions;

@end

@implementation HEMExpansionService

#pragma mark - Service events

- (void)serviceReceivedMemoryWarning {
    [super serviceReceivedMemoryWarning];
    [self setExpansions:nil];
}

#pragma mark - Interface methods

- (BOOL)isEnabledForHardware:(SENSenseHardware)hardware {
    return hardware != SENSenseHardwareOne;
}

- (void)getListOfExpansion:(HEMExpansionListHandler)completion {
    __weak typeof (self) weakSelf = self;
    [SENAPIExpansion getSupportedExpansions:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            [strongSelf setExpansions:data];
        }
        completion (data, error);
    }];
}

@end
