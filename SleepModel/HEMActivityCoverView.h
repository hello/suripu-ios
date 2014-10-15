//
//  HEMActivityCoverView.h
//  Sense
//
//  Created by Jimmy Lu on 10/14/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMActivityCoverView : UIView

@property (nonatomic, strong, readonly) UILabel* activityLabel;

/**
 * @method
 * Show this activity view inside the specified view.  If you want to display this
 * over the navigationBar, then pass in the navigation controller's view
 *
 * @param view:       the view that this view will attach to when displayed
 * @param completion: the block the invoke when this has been shown
 */
- (void)showInView:(UIView*)view completion:(void(^)(void))completion;

/**
 * @method
 * Display the text specified, then dismiss the view after, calling the completion
 * block when all is done.
 * 
 * @param text:       text to display before dismissing
 * @param completion: the block to invoke when this has been dismissed
 */
- (void)dismissWithResultText:(NSString*)text
                   completion:(void(^)(void))completion;

@end
