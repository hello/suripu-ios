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
CGFloat const HEMStyleTabBarItemTopInset = 6.0f;
CGFloat const HEMStyleDefaultNavBarButtonItemWidth = 50.0f;

void ApplyHelloStyles (void) {
    NSArray* classes = @[[HEMStyledNavigationViewController class]];
    UINavigationBar* appearance = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:classes];
    ApplyDefaultStyleForNavBarAppearance(appearance);
    
    appearance = [UINavigationBar appearance];
    ApplyDefaultStyleForNavBarAppearance(appearance);
    
    NSDictionary* barButtonAttrs = @{NSFontAttributeName : [UIFont button],
                                     NSForegroundColorAttributeName : [UIColor tintColor]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAttrs
                                                forState:UIControlStateNormal];
    
    [UIColor applyDefaultColorAppearances];
}

void ApplyDefaultStyleForNavBarAppearance(UINavigationBar* navBar) {
    [navBar setBackgroundImage:[[UIImage alloc] init]
                forBarPosition:UIBarPositionAny
                    barMetrics:UIBarMetricsDefault];
    [navBar setShadowImage:[[UIImage alloc] init]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor grey6],
                                     NSFontAttributeName : [UIFont h6]}];
}
