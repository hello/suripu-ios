//
//  UIView+HEMMotionEffects.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "UIView+HEMMotionEffects.h"

@implementation UIView (HEMMotionEffects)

static NSString* const HEMMotionEffectsXKeyPath = @"center.x";
static NSString* const HEMMotionEffectsYKeyPath = @"center.y";

- (void)add3DEffectWithBorder:(CGFloat)border {
    HEMMotionEffectsDirection direction = (HEMMotionEffectsDirectionHorizontal | HEMMotionEffectsDirectionVertical);
    [self add3DEffectWithBorder:border direction:direction];
}

- (void)add3DEffectWithBorder:(CGFloat)border direction:(HEMMotionEffectsDirection)direction
{
    NSMutableArray* effects = [[NSMutableArray alloc] initWithCapacity:2];
    NSNumber* negBorderVal = @(-border);
    NSNumber* borderVal = @(border);

    if ((direction & HEMMotionEffectsDirectionVertical) == HEMMotionEffectsDirectionVertical) {
        UIInterpolatingMotionEffect *vEffect =
        [[UIInterpolatingMotionEffect alloc] initWithKeyPath:HEMMotionEffectsYKeyPath
                                                        type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        [vEffect setMinimumRelativeValue:negBorderVal];
        [vEffect setMaximumRelativeValue:borderVal];
        [effects addObject:vEffect];
    }

    if ((direction & HEMMotionEffectsDirectionHorizontal) == HEMMotionEffectsDirectionHorizontal) {
        UIInterpolatingMotionEffect *hEffect =
        [[UIInterpolatingMotionEffect alloc] initWithKeyPath:HEMMotionEffectsXKeyPath
                                                        type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        [hEffect setMinimumRelativeValue:negBorderVal];
        [hEffect setMaximumRelativeValue:borderVal];
        [effects addObject:hEffect];
    }

    if (effects.count == 0)
        return;


    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = effects;
    [self addMotionEffect:group];
}

@end
