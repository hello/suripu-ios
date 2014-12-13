//
//  HEMSnazzBarControllerSpec.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "HEMSnazzBarController.h"
#import "HEMSnazzBar.h"

@interface HEMSnazzBar ()
- (NSArray*)buttons;
@end

SPEC_BEGIN(HEMSnazzBarControllerSpec)

__block HEMSnazzBarController* controller;
__block NSArray* childControllers = nil;

beforeEach(^{
    controller = [HEMSnazzBarController new];
    childControllers = @[[UIViewController new], [UIViewController new], [UIViewController new]];
    controller.viewControllers = childControllers;
    controller.selectedIndex = 0;
});

describe(@"setSelectedIndex:animated:", ^{

    NSUInteger selectedIndex = 1;

    beforeEach(^{
        [controller setSelectedIndex:selectedIndex animated:NO];
    });

    it(@"updates the selectedIndex property", ^{
        [[@(controller.selectedIndex) should] equal:@(selectedIndex)];
    });

    it(@"updates the selected view controller", ^{
        [[controller.selectedViewController should] equal:childControllers[selectedIndex]];
    });

    it(@"ignores invalid indices", ^{
        [controller setSelectedIndex:5 animated:NO];
        [[@(controller.selectedIndex) should] equal:@(selectedIndex)];
    });
});

describe(@"selectedViewController", ^{
    beforeEach(^{
        [controller setSelectedIndex:2 animated:NO];
    });

    it(@"has a view in the visible content", ^{
        UIView* childView = controller.selectedViewController.view;
        [[controller.view.subviews should] containObjects:childView.superview, nil];
    });
});

describe(@"tapping a tab button", ^{

    __block UIButton* button = nil;

    NSUInteger selectedIndex = 2;

    beforeEach(^{
        HEMSnazzBar* bar = nil;
        for (UIView* view in controller.view.subviews) {
            if ([view isKindOfClass:[HEMSnazzBar class]]) {
                bar = (id)view;
                break;
            }
        }
        button = bar.buttons[selectedIndex];
        [button sendActionsForControlEvents:UIControlEventTouchUpInside];
    });

    it(@"sets the button as selected", ^{
        [[@([button isSelected]) shouldAfterWaitOf(0.3)] beYes];
    });

    it(@"updates selected index", ^{
        [[@(controller.selectedIndex) shouldAfterWaitOf(0.3)] equal:@(selectedIndex)];
    });

    it(@"updates the visible view controller", ^{
        UIViewController* child = childControllers[selectedIndex];
        [[child.view.superview shouldNot] beNil];
        [[controller.view.subviews shouldAfterWaitOf(0.3)] containObjects:child.view.superview, nil];
    });
});

SPEC_END
