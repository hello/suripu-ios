//
//  HEMShareService.m
//  Sense
//
//  Created by Jimmy Lu on 6/21/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENAPIShare.h>

#import "HEMShareService.h"

@implementation HEMShareService

- (void)shareUrlFor:(id<SENShareable>)shareable completion:(HEMShareUrlHandler)completion {
    [SENAPIShare shareURLFor:shareable completion:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data, error);
    }];
}

- (BOOL)isShareable:(id)shareable {
    return [shareable conformsToProtocol:@protocol(SENShareable)]
        && [(id<SENShareable>)shareable identifier] != nil;
}

@end
