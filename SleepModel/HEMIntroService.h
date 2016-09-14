//
//  HEMIntroService.h
//  Sense
//
//  Created by Jimmy Lu on 8/31/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SenseKit.h>

typedef NS_ENUM(NSUInteger, HEMIntroType) {
    HEMIntroTypeUnknown = 0,
    HEMIntroTypeRoomConditions
};

@interface HEMIntroService : SENService

- (BOOL)shouldIntroduceType:(HEMIntroType)type;
- (void)incrementIntroViewsForType:(HEMIntroType)introType;
- (void)reset;

@end
