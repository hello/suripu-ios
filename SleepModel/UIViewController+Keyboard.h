//
//  UIViewController+Keyboard.h
//  Sense
//
//  Created by Jimmy Lu on 8/20/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Keyboard)

- (void)actAfterKeyboardDismissed:(void(^)(void))action;

@end
