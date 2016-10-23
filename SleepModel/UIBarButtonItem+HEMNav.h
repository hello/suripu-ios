//
//  UIBarButtonItem+HEMNav.h
//  Sense
//
//  Created by Jimmy Lu on 11/23/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (HEMNav)

+ (UIBarButtonItem*)cancelItemWithTitle:(NSString*)title
                                  image:(UIImage*)image
                                 target:(id)target
                                 action:(SEL)action;

+ (UIBarButtonItem*)helpButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem*)saveButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem*)infoButtonWithTarget:(id)target action:(SEL)action;

@end
