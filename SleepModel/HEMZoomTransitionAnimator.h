//
//  HEMZoomTransitionAnimator.h
//  Sense
//
//  This class provides a zoom like transition where the controller being presented
//  will initially started zoomed in and will end in place while also fading in.
//
//  On dismissal, the controller presented will zoom "away" while also fading out
//
//  Created by Jimmy Lu on 9/12/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMZoomTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@end
