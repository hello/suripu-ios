//
//  HEMDynamicsStatusStyler.m
//  Sense
//
//  Created by Delisa Mason on 1/22/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMDynamicsStatusStyler.h"

@implementation HEMDynamicsStatusStyler

static CGFloat const HEMStatusStylerFadeMaxRatio = 0.7f;

+ (instancetype)styler
{
    return [self new];
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController
         didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction
                        forDirection:(MSDynamicsDrawerDirection)direction
{
    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat windowHeight = CGRectGetHeight(windowFrame);
    CGFloat statusBarHeight = MIN(CGRectGetWidth(frame), CGRectGetHeight(frame));
    CGFloat paneVisibleHeight = windowHeight * paneClosedFraction;
    BOOL statusAreaVisible = windowHeight - paneVisibleHeight >= statusBarHeight;
    UIWindowLevel level = statusAreaVisible ? UIWindowLevelNormal : UIWindowLevelStatusBar + 1;
    if (dynamicsDrawerViewController.view.window.windowLevel != level)
        dynamicsDrawerViewController.view.window.windowLevel = level;

    if (direction & MSDynamicsDrawerDirectionAll) {
        dynamicsDrawerViewController.drawerView.alpha = 1.0  - paneClosedFraction * HEMStatusStylerFadeMaxRatio;
    } else {
        dynamicsDrawerViewController.drawerView.alpha = 1.0;
    }
}

- (void)stylerWasRemovedFromDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController
                                            forDirection:(MSDynamicsDrawerDirection)direction
{
    dynamicsDrawerViewController.drawerView.alpha = 1.0;
}

@end
