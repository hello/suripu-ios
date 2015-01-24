//
//  HEMDynamicsStatusStyler.m
//  Sense
//
//  Created by Delisa Mason on 1/22/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMDynamicsStatusStyler.h"

@implementation HEMDynamicsStatusStyler

+ (instancetype)styler
{
    return [self new];
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController
         didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction
                        forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneClosedFraction > 0.95) {
        dynamicsDrawerViewController.view.window.windowLevel = UIWindowLevelStatusBar + 1;
    } else {
        dynamicsDrawerViewController.view.window.windowLevel = UIWindowLevelNormal;
    }
}
@end
