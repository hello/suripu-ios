//
//  UIView+HEMSnapshot.h
//  Sense
//
//  Created by Jimmy Lu on 11/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HEMSnapshot)

/**
 * Take a snapshot image of this view
 * @param snapshot
 */
- (UIImage*)snapshot;

/**
 * Take a blurred snapshot of this view with the tint color specified
 * @param color: the tint color to apply to the blurred image
 * @return blurred snapshot
 */
- (UIImage*)blurredSnapshotWithTint:(UIColor*)color;

@end
