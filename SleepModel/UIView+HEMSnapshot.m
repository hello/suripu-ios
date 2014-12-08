//
//  UIView+HEMSnapshot.m
//  Sense
//
//  Created by Jimmy Lu on 11/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIImage+ImageEffects.h"
#import "UIView+HEMSnapshot.h"

@implementation UIView (HEMSnapshot)

static CGFloat const kHEMSnapshotBlurRadius = 3.0f;
static CGFloat const kHEMSnapshotSaturationFactor = 1.5f;

- (UIImage*)snapshot {
    UIGraphicsBeginImageContextWithOptions([self bounds].size, NO, 0);
    
    [self drawViewHierarchyInRect:[self bounds] afterScreenUpdates:NO];
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}

- (UIImage*)snapshotOfRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGRect enlargedRect = CGRectMake(-CGRectGetMinX(rect), -CGRectGetMinY(rect),
                                     CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [self drawViewHierarchyInRect:enlargedRect afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*)blurredSnapshotWithTint:(UIColor*)color {
    return [[self snapshot] applyBlurWithRadius:kHEMSnapshotBlurRadius
                                      tintColor:color
                          saturationDeltaFactor:kHEMSnapshotSaturationFactor
                                      maskImage:nil];
}

@end
