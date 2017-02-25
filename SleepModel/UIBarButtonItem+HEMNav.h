//
//  UIBarButtonItem+HEMNav.h
//  Sense
//
//  Created by Jimmy Lu on 11/23/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (HEMNav)

+ (UIBarButtonItem*)cancelItemWithTitle:(nullable NSString*)title
                                  image:(nullable UIImage*)image
                                 target:(id)target
                                 action:(SEL)action;

+ (UIBarButtonItem*)helpButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem*)saveButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem*)infoButtonWithTarget:(id)target action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
