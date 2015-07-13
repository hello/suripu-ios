//
//  UIImage+HEMBlurTint.m
//  Sense
//
//  Created by Delisa Mason on 7/13/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIImageEffects/UIImage+ImageEffects.h>
#import "UIImage+HEMBlurTint.h"

@implementation UIImage (HEMBlurTint)
static CGFloat const HEMSnapshotBlurRadius = 3.0f;
static CGFloat const HEMSnapshotSaturationFactor = 1.5f;

- (UIImage *)imageWithTint:(UIColor *)color {
    return [self  applyBlurWithRadius:0
                            tintColor:color
                saturationDeltaFactor:HEMSnapshotSaturationFactor
                            maskImage:nil];
}

- (UIImage *)blurredImageWithTint:(UIColor *)color {
    return [self applyBlurWithRadius:HEMSnapshotBlurRadius
                           tintColor:color
               saturationDeltaFactor:HEMSnapshotSaturationFactor
                           maskImage:nil];
}

@end
