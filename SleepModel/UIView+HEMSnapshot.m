//
//  UIView+HEMSnapshot.m
//  Sense
//
//  Created by Jimmy Lu on 11/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIImage+ImageEffects.h"
#import "UIView+HEMSnapshot.h"

static CGFloat const kHEMSnapshotBlurRadius = 3.0f;
static CGFloat const kHEMSnapshotSaturationFactor = 1.5f;

@implementation UIView (HEMSnapshot)

- (UIImage*)snapshot {
    UIGraphicsBeginImageContextWithOptions([self bounds].size, NO, 0);
    
    [self drawViewHierarchyInRect:[self bounds] afterScreenUpdates:NO];
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}

- (UIImage*)blurredSnapshotWithTint:(UIColor*)color {
    return [[self snapshot] applyBlurWithRadius:kHEMSnapshotBlurRadius
                                      tintColor:color
                          saturationDeltaFactor:kHEMSnapshotSaturationFactor
                                      maskImage:nil];
}

@end
