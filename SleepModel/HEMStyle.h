//
//  HEMStyle.h
//  Sense
//
//  Created by Jimmy Lu on 12/17/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMGradient.h"
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"
#import "NSShadow+HEMStyle.h"

extern CGFloat const HEMStyleCardErrorTextHorzMargin;
extern CGFloat const HEMStyleCardErrorTextVertMargin;
extern CGFloat const HEMStyleSectionTopMargin;
extern CGFloat const HEMStyleDeviceSectionTopMargin;
extern CGFloat const HEMStyleButtonContainerBorderWidth;
extern CGFloat const HEMStyleDefaultNavBarButtonItemWidth;

void ApplyHelloStyles (void);
void ApplyDefaultStyleForNavBarAppearance(UINavigationBar* navBar);
void ApplyDefaultTabBarItemStyle(UITabBarItem* tabBarItem);
NSMutableParagraphStyle* DefaultParagraphStyle(void);
