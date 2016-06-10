//
//  HEMStyle.m
//  Sense
//
//  Created by Jimmy Lu on 1/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMStyle.h"
#import "HEMStyledNavigationViewController.h"

CGFloat const HEMStyleCardErrorTextHorzMargin = 16.0f;
CGFloat const HEMStyleCardErrorTextVertMargin = 26.0f;
CGFloat const HEMStyleSectionTopMargin = 12.0f;
CGFloat const HEMStyleDeviceSectionTopMargin = 15.0f;
CGFloat const HEMStyleButtonContainerBorderWidth = 0.5f;

void ApplyHelloStyles (void) {
    UINavigationBar* appearance = [UINavigationBar appearanceWhenContainedIn:[HEMStyledNavigationViewController class], nil];
    
    [appearance setBackgroundImage:[[UIImage alloc] init]
                    forBarPosition:UIBarPositionAny
                        barMetrics:UIBarMetricsDefault];
    [appearance setShadowImage:[[UIImage alloc] init]];
    [appearance setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor grey6],
                                         NSFontAttributeName : [UIFont h5]}];
    
    NSDictionary* barButtonAttrs = @{NSFontAttributeName : [UIFont button],
                                     NSForegroundColorAttributeName : [UIColor tintColor]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAttrs
                                                forState:UIControlStateNormal];
    
    [UIColor applyDefaultColorAppearances];
}