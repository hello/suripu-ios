//
//  HEMTutorialService.h
//  Sense
//
//  Created by Jimmy Lu on 1/22/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

typedef NS_ENUM(NSInteger, HEMTutorial) {
    HEMTutorialInsightTap = 1,
    HEMTutorialSensorScrubbing,
    HEMTutorialTimelineSwipe,
    HEMTutorialTimelineZoom,
    HEMTutorialTimelineExplanation
};

@interface HEMTutorialService : SENService

@end
