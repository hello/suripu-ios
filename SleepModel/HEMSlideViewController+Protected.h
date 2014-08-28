//
//  HEMSlideViewController+Protected.h
//  Sense
//
//  Created by Jimmy Lu on 8/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSlideViewController.h"

@interface HEMSlideViewController (Protected)

/**
 * Obtain the slide gesture used to move the controller as it slides
 * @return slideGesture: the slide gesture
 */
- (UIPanGestureRecognizer*)slideGesture;

/**
 * Called when sliding begins, before motion has started.  If you override this,
 * be sure to call [super beginSliding];
 */
- (void)beginSliding;

/**
 * Called when sliding ends, after motion has stopped.  If you override this,
 * be sure to call [super endSliding];
 */
- (void)endSliding;

@end
