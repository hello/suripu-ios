//
//  HEMScreenUtils.m
//  Sense
//
//  Created by Delisa Mason on 7/13/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMScreenUtils.h"

CGFloat const HEMIPhone4Height = 480.0f;
CGFloat const HEMIPhone5Height = 568.0f;

BOOL HEMIsIPhone4Family() {
    CGFloat screenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    return screenHeight == HEMIPhone4Height;
}

BOOL HEMIsIPhone5Family() {
    CGFloat screenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    return screenHeight == HEMIPhone5Height;
}

CGRect HEMKeyWindowBounds() {
    return [[[UIApplication sharedApplication] keyWindow] bounds];
}