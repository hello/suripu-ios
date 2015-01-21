//
//  HEMRulerView.h
//  Sense
//
//  Created by Jimmy Lu on 1/20/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HEMRulerDirection) {
    HEMRulerDirectionVertical,
    HEMRulerDirectionHorizontal
};

extern CGFloat const HEMRulerSegmentSpacing;

@interface HEMRulerView : UIView

- (id)initWithSegments:(NSUInteger)segments direction:(HEMRulerDirection)direction;

@end
