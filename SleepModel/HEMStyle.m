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
CGFloat const HEMStyleThickBorder = 1.0f;

static CGFloat const HEMStyleDefaultLineHeight = 24.0f;

NSDictionary* NavTitleAttributes(void) {
    return @{NSForegroundColorAttributeName : [UIColor grey6],
             NSFontAttributeName : [UIFont h6]};
}

NSMutableParagraphStyle* DefaultBodyParagraphStyle() {
    NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setMinimumLineHeight:HEMStyleDefaultLineHeight];
    [style setMaximumLineHeight:HEMStyleDefaultLineHeight];
    return style;
}

UIImage* BackIndicator(void) {
    UIImage* defaultBackImage = [UIImage imageNamed:@"backIcon"];
    defaultBackImage = [defaultBackImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return defaultBackImage;
}
