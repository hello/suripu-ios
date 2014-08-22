//
//  UIViewController+Keyboard.m
//  Sense
//
//  Created by Jimmy Lu on 8/20/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "UIViewController+Keyboard.h"

@implementation UIViewController (Keyboard)

- (void)actAfterKeyboardDismissed:(void(^)(void))action {
    if (!action) return;
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    __block id observer =
    [center addObserverForName:UIKeyboardDidHideNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note) {
                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
                        action();
                    }];
}

@end
