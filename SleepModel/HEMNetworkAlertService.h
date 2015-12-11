//
//  HEMNetworkAlertService.h
//  Sense
//
//  Created by Jimmy Lu on 12/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"

NS_ASSUME_NONNULL_BEGIN

@class HEMNetworkAlertService;

@protocol HEMNetworkAlertDelegate <NSObject>

- (void)networkService:(HEMNetworkAlertService*)networkAlertService detectedNetworkChange:(BOOL)hasNetwork;

@end

@interface HEMNetworkAlertService : SENService

@property (nonatomic, assign, readonly, getter=wasNetworkReachable) BOOL networkReachable;

@property (nonatomic, weak) id<HEMNetworkAlertDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
