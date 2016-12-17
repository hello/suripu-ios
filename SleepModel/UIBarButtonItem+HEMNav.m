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

+ (UIButton*)buttonWithTitle:(NSString*)title andImage:(UIImage*)image {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont body]];
    [button setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [button setTintColor:[UIColor tintColor]];
    [button sizeToFit];
    return button;
}

+ (UIBarButtonItem*)cancelItemWithTitle:(NSString*)title
                                  image:(UIImage*)image
                                 target:(id)target
                                 action:(SEL)action {
    UIButton* cancelButton = [self buttonWithTitle:title andImage:image];
    [cancelButton setTitleColor:[UIColor clearColor] forState:UIControlStateDisabled];
    [cancelButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
}

+ (UIBarButtonItem*)helpButtonWithTarget:(id)target action:(SEL)action {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"helpIconSmall"]
                                            style:UIBarButtonItemStylePlain
                                           target:target
                                           action:action];
}

+ (UIBarButtonItem*)saveButtonWithTarget:(id)target action:(SEL)action {
    NSString* saveTitle = NSLocalizedString(@"actions.save", nil);
    UIButton* saveButton = [self buttonWithTitle:saveTitle andImage:nil];
    [saveButton setTitleColor:[UIColor grey4] forState:UIControlStateDisabled];
    [saveButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:saveButton];
}

+ (UIBarButtonItem*)infoButtonWithTarget:(id)target action:(SEL)action {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"infoIconSmall"]
                                            style:UIBarButtonItemStylePlain
                                           target:target
                                           action:action];
}

@end
