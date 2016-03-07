//
//  HEMTutorialService.h
//  Sense
//
//  Created by Jimmy Lu on 1/22/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

typedef NS_ENUM(NSInteger, HEMHandHolding) {
    HEMHandHoldingInsightTap = 1,
    HEMHandHoldingSensorScrubbing,
    HEMHandHoldingTimelineSwipe,
    HEMHandHoldingTimelineZoom,
    HEMHandHoldingTimelineOpen
};

@interface HEMHandHoldingService : SENService

- (BOOL)isComplete:(HEMHandHolding)tutorial;
- (BOOL)shouldShow:(HEMHandHolding)tutorial;
- (void)completed:(HEMHandHolding)tutorial;
- (void)reset;

@end
