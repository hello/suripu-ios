//
//  HEMDeviceActionCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/7/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMDeviceActionCollectionViewCell.h"
#import "HelloStyleKit.h"

static CGFloat const HEMDeviceActionSeparatorSize = 0.5f;
static CGFloat const HEMDeviceActionSeparatorIndentation = 16.0f;

@implementation HEMDeviceActionCollectionViewCell

- (void)awakeFromNib {
    // these colors allow me to draw the separator and have it show through
    [[self contentView] setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundColor:[UIColor whiteColor]];
    [[self action1Button] setBackgroundColor:[UIColor clearColor]];
    [[self action2Button] setBackgroundColor:[UIColor clearColor]];
    [[self action3Button] setBackgroundColor:[UIColor clearColor]];
    [[self action4Button] setBackgroundColor:[UIColor clearColor]];
}


- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetStrokeColorWithColor(context, [[HelloStyleKit settingsSeparatorColor] CGColor]);
    CGContextSetLineWidth(context, HEMDeviceActionSeparatorSize);
    
    // add a separator after every action button that is configured, as long as
    // it's not at the bottom of the view
    [self drawSeparatorAtY:CGRectGetMaxY([[self action1Button] frame]) withContext:context];
    [self drawSeparatorAtY:CGRectGetMaxY([[self action2Button] frame]) withContext:context];
    [self drawSeparatorAtY:CGRectGetMaxY([[self action3Button] frame]) withContext:context];
    [self drawSeparatorAtY:CGRectGetMaxY([[self action4Button] frame]) withContext:context];

    CGContextRestoreGState(context);
    
}

- (void)drawSeparatorAtY:(CGFloat)y withContext:(CGContextRef)context {
    if (y > 0.0f && y != CGRectGetHeight([self bounds])) {
        CGContextMoveToPoint(context, HEMDeviceActionSeparatorIndentation, y);
        CGContextAddLineToPoint(context, CGRectGetWidth([self bounds]), y);
        CGContextStrokePath(context);
    }
}

@end
