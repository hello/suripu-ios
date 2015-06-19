//
//  HEMHintMessageView.h
//  Sense
//
//  Created by Jimmy Lu on 6/18/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMHintMessageView : UIView

@property (nonatomic, strong, readonly) UIButton* dismissButton;

/**
 * Initialize the instance with a message to be displayed for the hint.  This
 * is meant to be used within HEMHandholding in junction with HEMHintGestureView
 *
 * @param message: the message to display
 * @param width: the full width of the container
 */
- (instancetype)initWithMessage:(NSString*)message constrainedToWidth:(CGFloat)width;

@end
