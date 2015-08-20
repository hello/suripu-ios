//
//  HEMTappableView.h
//  Sense
//
//  A UIView that is tappable.  This is an alternative to subclassing UIControl,
//  which requires the custom control to repeat the logic necessary to properly
//  handle the events.
//
//  Created by Jimmy Lu on 8/12/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMTappableView : UIView

@property (nonatomic, assign, getter=isHighlighted) BOOL highlighted;

/**
 * @method addTapTarget:action
 *
 * @discussion:
 * Add a tap target and corresponding action to call upon tapping on this view
 *
 * @param target: the target to call on tap
 * @param action: the selector to call on the target
 */
- (void)addTapTarget:(id)target action:(SEL)action;

@end
