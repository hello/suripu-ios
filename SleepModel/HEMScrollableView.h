//
//  HEMScrollableView.h
//  Sense
//
//  Created by Jimmy Lu on 11/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMScrollableView : UIView

/**
 * Append a title view to the scrollable content view.  This will set the
 * default attributes for a title and ensure proper padding around subviews.
 * @param title: title of view
 */
- (void)addTitle:(NSString*)title;

/**
 * Append an image to be displayed in the scrollable content, which will properly
 * set the content size of the scrollable view and add proper padding to content
 * that follow
 *
 * @param image: the image to add
 */
- (void)addImage:(UIImage*)image;

/**
 * Append description to the content that will add proper padding to content added
 * after and also properly adjust content size
 *
 * @param attributedDesc: the description to append
 */
- (void)addDescription:(NSAttributedString*)attributedDesc;

/**
 * @return YES if content is larger than size of scrollView, NO otherwise
 */
- (BOOL)scrollRequired;

@end
