//
//  UIViewController+Keyboard.h
//  Sense
//
//  Created by Jimmy Lu on 8/20/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Keyboard)

//
// Convenience method to take action AFTER the keyboard is dismissed.
// WARNING: if the keyboard was never up before calling this, the
// action block will never be called.  You should also dismiss the
// keyboard before calling this method
//
// @param action: the block to call after keyboard has been dismissed.
//
- (void)actAfterKeyboardDismissed:(void(^)(void))action;

@end
