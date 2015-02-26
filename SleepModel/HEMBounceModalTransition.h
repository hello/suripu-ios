//
//  HEMBounceTransitionDelegate.h
//  Sense
//
//  Created by Jimmy Lu on 2/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEMTransitionDelegate.h"

@interface HEMBounceModalTransition : HEMTransitionDelegate

@property (nonatomic, assign) CGFloat bounceDamping;
@property (nonatomic, copy)   NSString* message;

/**
 * Initialize an instance of the transition delegate with an optional end message
 * and the bounce damping value between 0 - 1.0f
 *
 * @param message:       an optional end message to be displayed when dismissed
 * @param bounceDamping: the damping value
 */
- (instancetype)initWithEndMessage:(NSString*)message andBounceDamping:(CGFloat)bounceDamping;

@end
