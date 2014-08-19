//
//  UIView+HEMMotionEffects.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/14.
//  Copyright (c) 2014 Delisa Mason. All rights reserved.
//

#import "UIView+HEMMotionEffects.h"

@implementation UIView (HEMMotionEffects)

- (void)add3DEffectWithBorder:(CGFloat)border {
    NSNumber* negBorderVal = @(-border);
    NSNumber* borderVal = @(border);
    
    UIInterpolatingMotionEffect *vEffect =
        [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                        type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    [vEffect setMinimumRelativeValue:negBorderVal];
    [vEffect setMaximumRelativeValue:borderVal];

    UIInterpolatingMotionEffect *hEffect =
        [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                        type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    [hEffect setMinimumRelativeValue:negBorderVal];
    [hEffect setMaximumRelativeValue:borderVal];

    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[vEffect, hEffect];
    [self addMotionEffect:group];
}

@end
