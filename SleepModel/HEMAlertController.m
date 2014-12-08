//
//  HEMAlertUtils.m
//  Sense
//
//  Created by Delisa Mason on 10/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMAlertController.h"
#import "UIFont+HEMStyle.h"

@interface HEMAlertController () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, weak)   UIViewController* presentingController;
@property (nonatomic, strong) NSMutableArray* actions;
@property (nonatomic, strong) UIControl* inputView;
@property (nonatomic, weak) UITextField* textField;
@property (nonatomic) HEMAlertControllerStyle style;
@property (nonatomic, copy) void (^inputChangeHandler)(UITextField*);
@end

@implementation HEMAlertController

static NSString* const HEMAlertControllerButtonTextKey = @"text";
static NSString* const HEMAlertControllerButtonActionKey = @"action";
static NSMutableArray* alertControllers = nil;

+ (void)presentInfoAlertWithTitle:(NSString*)title
                          message:(NSString*)message
             presentingController:(UIViewController*)controller
{
    HEMAlertController* alertController = [[self alloc] initWithTitle:title
                                                              message:message
                                                                style:HEMAlertControllerStyleAlert
                                                 presentingController:controller];
    [alertController addActionWithText:NSLocalizedString(@"actions.ok", nil) block:NULL];
    [alertController show];
}

+ (void)presentDatePickerAlertWithTitle:(NSString *)title
                                message:(NSString *)message
                   presentingController:(UIViewController *)controller
                         datePickerMode:(UIDatePickerMode)pickerMode
                            initialDate:(NSDate *)date
                             completion:(void (^)(NSDate *))completionHandler
{
    HEMAlertController* alertController = [[self alloc] initWithTitle:title
                                                              message:message
                                                                style:HEMAlertControllerStyleAlert
                                                 presentingController:controller];
    UIDatePicker* picker = [UIDatePicker new];
    picker.datePickerMode = UIDatePickerModeTime;
    picker.date = date;
    NSDateFormatter* formatter = [NSDateFormatter new];
    formatter.dateFormat = @"hh:mm a";
    [alertController addActionWithText:NSLocalizedString(@"actions.save", nil) block:^{
        if (completionHandler)
            completionHandler(picker.date);
    }];
    [alertController addActionWithText:NSLocalizedString(@"actions.cancel", nil) block:^{
        if (completionHandler)
            completionHandler(nil);
    }];
    [alertController showTextFieldWithInputView:picker withChangeHandler:^(UITextField *textField) {
        textField.font = [UIFont timelineEventMessageBoldFont];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.tintColor = [UIColor clearColor];
        textField.text = [[formatter stringFromDate:picker.date] lowercaseString];
    }];
    [alertController show];
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

- (void)showTextFieldWithInputView:(UIControl*)inputView withChangeHandler:(void(^)(UITextField*))handler
{
    self.inputView = inputView;
    [self.inputView addTarget:self
                       action:@selector(inputViewContentsChanged:)
             forControlEvents:UIControlEventValueChanged];
    self.inputChangeHandler = handler;
}

#pragma mark - Respond to Events

- (void)inputViewContentsChanged:(UIControl*)control
{
    if (self.inputChangeHandler && self.textField) {
        self.inputChangeHandler(self.textField);
    }
}

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
    if (!alertControllers)
        alertControllers = [NSMutableArray new];
    [alertControllers addObject:self];

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

    if (self.inputView) {
        __weak typeof(self) weakSelf = self;
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            __strong HEMAlertController *strongSelf = weakSelf;
            textField.inputView = strongSelf.inputView;
            strongSelf.textField = textField;
            if (strongSelf.inputChangeHandler)
                strongSelf.inputChangeHandler(textField);
        }];
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
    if (self.inputView) {
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField* textField = [alertView textFieldAtIndex:0];
        textField.inputView = self.inputView;
        self.textField = textField;
        if (self.inputChangeHandler)
            self.inputChangeHandler(textField);
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
