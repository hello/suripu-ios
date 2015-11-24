//
//  UIBarButtonItem+HEMNav.m
//  Sense
//
//  Created by Jimmy Lu on 11/23/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "UIBarButtonItem+HEMNav.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

@implementation UIBarButtonItem (HEMNav)

+ (UIBarButtonItem*)cancelItemWithTitle:(NSString*)title
                                  image:(UIImage*)image
                                 target:(id)target
                                 action:(SEL)action {
    
    UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:title forState:UIControlStateNormal];
    [cancelButton setImage:image forState:UIControlStateNormal];
    [[cancelButton titleLabel] setFont:[UIFont navButtonTitleFont]];
    [cancelButton setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor clearColor] forState:UIControlStateDisabled];
    [cancelButton setTintColor:[UIColor tintColor]];
    [cancelButton sizeToFit];
    [cancelButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
}

@end
