//
//  HEMTimelineLayoutAttributes.m
//  Sense
//
//  Created by Delisa Mason on 6/4/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTimelineLayoutAttributes.h"

@implementation HEMTimelineLayoutAttributes

- (id)copyWithZone:(NSZone *)zone
{
    HEMTimelineLayoutAttributes *copy = [super copyWithZone:zone];
    copy.ratioFromCenter = self.ratioFromCenter;
    return copy;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[HEMTimelineLayoutAttributes class]]) {
        return NO;
    }

    HEMTimelineLayoutAttributes *otherObject = object;
    if (self.ratioFromCenter != otherObject.ratioFromCenter) {
        return NO;
    }
    return [super isEqual:otherObject];
}

@end
