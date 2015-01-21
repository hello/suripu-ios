//
//  HEMRulerView.m
//  Sense
//
//  Created by Jimmy Lu on 1/20/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMRulerView.h"
#import "HelloStyleKit.h"

CGFloat const HEMRulerSegmentSpacing = 15.0f;
CGFloat const HEMRulerSegmentWidth = 1.0f;

static CGFloat const HEMRulerSegmentMaxLength = 48.0f;
static CGFloat const HEMRulerSegmentShortLength = 32.0f;
static NSInteger const HEMRulerSegmentLongSegmentInterval = 5;

@interface HEMRulerView()

@property (assign, nonatomic) HEMRulerDirection direction;
@property (assign, nonatomic) NSInteger segments;

@end

@implementation HEMRulerView

- (id)initWithSegments:(NSUInteger)segments direction:(HEMRulerDirection)direction {
    CGFloat length = (HEMRulerSegmentSpacing + HEMRulerSegmentWidth) * segments;
    CGRect frame = CGRectZero;
    frame.size.height = direction == HEMRulerDirectionVertical ? length : HEMRulerSegmentMaxLength;
    frame.size.width = direction == HEMRulerDirectionHorizontal ? length : HEMRulerSegmentMaxLength;
    self = [super initWithFrame:frame];
    if (self) {
        _direction = direction;
        _segments = segments;
        [self setClipsToBounds:NO];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    for (int i = 0; i < [self segments]; i++) {
        BOOL longSegment = i % HEMRulerSegmentLongSegmentInterval==0;
        [self drawSegmentWithContext:context atIndex:i longSegment:longSegment];
    }
    
    CGContextRestoreGState(context);
}

- (void)drawSegmentWithContext:(CGContextRef)context
                       atIndex:(NSInteger)index
                   longSegment:(BOOL)longSegment {
    
    UIColor* lineColor
        = longSegment
        ? [HelloStyleKit rulerSegmentDarkColor]
        : [HelloStyleKit rulerSegmentLightColor];
    
    CGFloat width = CGRectGetWidth([self bounds]);
    CGFloat height = CGRectGetHeight([self bounds]);
    CGFloat nextDistance = index * (HEMRulerSegmentSpacing + HEMRulerSegmentWidth);
    CGPoint start, end = CGPointZero;
    
    if ([self direction] == HEMRulerDirectionVertical) {
        start.y = nextDistance;
        start.x = longSegment ? 0.0f : width - HEMRulerSegmentShortLength;
        end.y = start.y;
        end.x = width;
    } else {
        start.y = longSegment ? 0.0f : height - HEMRulerSegmentShortLength;
        start.x = nextDistance;
        end.x = start.x;
        end.y = height;
    }
    
    CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
    CGContextSetLineWidth(context, HEMRulerSegmentWidth);
    
    CGContextMoveToPoint(context, start.x, start.y);
    CGContextAddLineToPoint(context, end.x, end.y);
    CGContextStrokePath(context);
}

@end
