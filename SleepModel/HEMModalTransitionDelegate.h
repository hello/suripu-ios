//
//  HEMModalTransitionDelegate.h
//  Sense
//
//  Created by Jimmy Lu on 10/26/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMTransitionDelegate.h"

typedef NS_ENUM(NSUInteger, HEMModalTransitionStyle) {
    HEMModalTransitionStyleNormal = 0
};

@interface HEMModalTransitionDelegate : HEMTransitionDelegate

@property (nonatomic, assign) HEMModalTransitionStyle transitionStyle;

/**
 * @discussion
 * Show the status bar before the transition.  Upon dismissal, status bar
 * will restore to previous state
 */
@property (nonatomic, assign) BOOL wantsStatusBar;

@end
