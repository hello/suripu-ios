//
//  HEMAlertUtils.m
//  Sense
//
//  Created by Delisa Mason on 10/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMAlertController.h"

@interface HEMAlertController () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, weak)   UIViewController* presentingController;
@property (nonatomic, strong) NSMutableArray* actions;
@property (nonatomic) HEMAlertControllerStyle style;
@end

@implementation HEMAlertController

static NSString* const HEMAlertControllerButtonTextKey = @"text";
static NSString* const HEMAlertControllerButtonActionKey = @"action";
static NSMutableArray* alertControllers = nil;

+ (void)presentInfoAlertWithTitle:(NSString*)title
                          message:(NSString*)message
             presentingController:(UIViewController*)controller
{
    if (!alertControllers)
        alertControllers = [NSMutableArray new];
    HEMAlertController* alertController = [[self alloc] initWithTitle:title
                                                              message:message
                                                                style:HEMAlertControllerStyleAlert
                                                 presentingController:controller];
    [alertController addActionWithText:NSLocalizedString(@"actions.ok", nil) block:NULL];
    [alertController show];
    [alertControllers addObject:alertController];
}

- (instancetype)initWithTitle:(NSString*)title
                      message:(NSString*)message
                        style:(HEMAlertControllerStyle)style
         presentingController:(UIViewController*)controller
{
    if (self = [super init]) {
        _title = title;
        _message = message;
        _style = style;
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
}

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self activateActionAtIndex:buttonIndex];
    [alertControllers removeObject:[alertControllers lastObject]];
}

- (void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self activateActionAtIndex:buttonIndex];
    [alertControllers removeObject:[alertControllers lastObject]];
}

#pragma mark - Present Alert

- (void)show
{
    if ([self shouldUseUIAlertController])
        [self presentUIAlertController];
    else if (self.style == HEMAlertControllerStyleAlert)
        [self presentUIAlertView];
    else if (self.presentingController)
        [self presentUIActionSheet];
}

- (BOOL)shouldUseUIAlertController
{
    return NSClassFromString(@"UIAlertController") != nil && self.presentingController != nil;
}

- (void)presentUIAlertController
{
    UIAlertControllerStyle style = self.style == HEMAlertControllerStyleAlert
                                       ? UIAlertControllerStyleAlert
                                       : UIAlertControllerStyleActionSheet;
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:self.title
                                                                             message:self.message
                                                                      preferredStyle:style];
    for (NSDictionary* actionProperties in self.actions) {
        void (^block)() = actionProperties[HEMAlertControllerButtonActionKey];
        void (^handler)(UIAlertAction*) = block ? ^(UIAlertAction* action) { block(); } : NULL;
        UIAlertAction* action = [UIAlertAction actionWithTitle:actionProperties[HEMAlertControllerButtonTextKey]
                                                         style:UIAlertActionStyleDefault
                                                       handler:handler];
        [alertController addAction:action];
    }

    [self.presentingController presentViewController:alertController animated:YES completion:NULL];
}

- (void)presentUIAlertView
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:self.title
                                                        message:self.message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
    for (NSDictionary* actionProperties in self.actions) {
        [alertView addButtonWithTitle:actionProperties[HEMAlertControllerButtonTextKey]];
    }
    [alertView show];
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
