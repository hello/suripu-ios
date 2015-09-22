//
//  HEMTappableView.h
//  Sense
//
//  Created by Jimmy Lu on 8/12/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMTappableView;

@protocol HEMTapDelegate <NSObject>

- (void)didTapOnView:(HEMTappableView*)tappableView;

@end

/** 
 * A UIView that is tappable.  This is an alternative to subclassing UIControl,
 * which requires the custom control to repeat the logic necessary to properly
 * handle the events.
 */
@interface HEMTappableView : UIView

@property (nonatomic, assign, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, weak) id<HEMTapDelegate> tapDelegate;

@end
