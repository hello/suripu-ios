//
//  HEMAlertUtils.m
//  Sense
//
//  Created by Delisa Mason on 10/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMActionSheetController.h"
#import "UIFont+HEMStyle.h"

@interface HEMActionSheetController () <UIActionSheetDelegate>

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, weak)   UIViewController* presentingController;
@property (nonatomic, strong) NSMutableArray* actions;
@property (nonatomic, strong) UIControl* inputView;
@property (nonatomic, weak) UITextField* textField;
@property (nonatomic, copy) void (^inputChangeHandler)(UITextField*);
@end

@implementation HEMActionSheetController

static NSString* const HEMAlertControllerButtonTextKey = @"text";
static NSString* const HEMAlertControllerButtonActionKey = @"action";
static NSMutableArray* alertControllers = nil;

- (instancetype)initWithTitle:(NSString*)title
                      message:(NSString*)message
         presentingController:(UIViewController*)controller
{
    if (self = [super init]) {
        _title = title;
        _message = message;
        _presentingController = controller;
        _actions = [NSMutableArray new];
    }
    return self;
}

- (void)addActionWithText:(NSString*)text block:(void (^)())block
{
    if (text.length == 0)
        return;
    NSMutableDictionary* action = [[NSMutableDictionary alloc] initWithDictionary:@{ HEMAlertControllerButtonTextKey : text }];
    if (block)
        action[HEMAlertControllerButtonActionKey] = block;
    [self.actions addObject:action];
}

#pragma mark - Respond to Events

- (void)activateActionAtIndex:(NSInteger)index
{
    if (index >= self.actions.count)
        return;

    NSDictionary* actionProperties = self.actions[index];
    void (^block)() = actionProperties[HEMAlertControllerButtonActionKey];
    if (block)
        block();
    [alertControllers removeObject:[alertControllers lastObject]];
}

- (void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self activateActionAtIndex:buttonIndex];
}

#pragma mark - Present Sheet

- (void)show
{
    if (!alertControllers)
        alertControllers = [NSMutableArray new];
    [alertControllers addObject:self];

    if ([self shouldUseUIAlertController])
        [self presentUIAlertController];
    else if (self.presentingController)
        [self presentUIActionSheet];
}

- (BOOL)shouldUseUIAlertController
{
    return NSClassFromString(@"UIAlertController") != nil && self.presentingController != nil;
}

- (void)presentUIAlertController
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:self.title
                                                                             message:self.message
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSDictionary* actionProperties in self.actions) {
        void (^block)() = actionProperties[HEMAlertControllerButtonActionKey];
        void (^handler)(UIAlertAction*) = block ? ^(UIAlertAction* action) { block(); } : NULL;
        UIAlertAction* action = [UIAlertAction actionWithTitle:actionProperties[HEMAlertControllerButtonTextKey]
                                                         style:UIAlertActionStyleDefault
                                                       handler:handler];
        [alertController addAction:action];
    }

    if (self.inputView) {
        __weak typeof(self) weakSelf = self;
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            __strong HEMActionSheetController *strongSelf = weakSelf;
            textField.inputView = strongSelf.inputView;
            strongSelf.textField = textField;
            if (strongSelf.inputChangeHandler)
                strongSelf.inputChangeHandler(textField);
        }];
    }

    [self.presentingController presentViewController:alertController animated:YES completion:NULL];
}

- (void)presentUIActionSheet
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:self.title
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    for (NSDictionary* actionProperties in self.actions) {
        [sheet addButtonWithTitle:actionProperties[HEMAlertControllerButtonTextKey]];
    }
    [sheet showInView:self.presentingController.view];
}

@end
