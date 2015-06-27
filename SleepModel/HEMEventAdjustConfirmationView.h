//
//  HEMEventAdjustConfirmationView.h
//  Sense
//
//  Created by Jimmy Lu on 6/26/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMEventAdjustConfirmationView : UIView

/**
 * Initializes the instance with the title, an optional subtitle, and a frame
 * that hints at the size of the view.
 * 
 * @param title: title to be displayed as the confirmation
 * @param subtitle: the subtitle that sits below the title
 * @param frame: a hint for the size of this confirmation
 */
- (instancetype)initWithTitle:(NSString*)title
                     subtitle:(NSString*)subtitle
                        frame:(CGRect)frame;

@end
