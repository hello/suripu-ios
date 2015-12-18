//
//  HEMGradient.m
//  Sense
//
//  Created by Jimmy Lu on 12/17/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMGradient.h"

@interface HEMGradient()

@property (nonatomic, assign) CGGradientRef gradientRef;

@end

@implementation HEMGradient

+ (HEMGradient*)gradientForTimelineSleepSegment {
    UIColor* color1 = [UIColor colorWithWhite:1.0f alpha:0.12f];
    UIColor* color2 = [UIColor colorWithWhite:1.0f alpha:0.0f];
    CGFloat locations[] = {0, 1};
    return [[HEMGradient alloc] initWithColors:@[color1, color2] locations:locations];
}

- (instancetype)initWithColors:(NSArray*)colors locations:(const CGFloat*)locations {
    self = [super init];
    if (self) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSMutableArray* cgColors = [NSMutableArray array];
        for (UIColor* color in colors) {
            [cgColors addObject: (id)color.CGColor];
        }
        
        _gradientRef = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)cgColors, locations);
        CGColorSpaceRelease(colorSpace);
    }
    return self;
}

- (void)dealloc {
    if (_gradientRef) {
        CGGradientRelease(_gradientRef);
    }
}

@end
