//
//  HEMUpdateNameViewController.m
//  Sense
//
//  Created by Delisa Mason on 2/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENServiceAccount.h>
#import "HEMUpdateNameViewController.h"
#import "HEMSimpleLineTextField.h"
#import "HEMAlertViewController.h"

@interface HEMUpdateNameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet HEMSimpleLineTextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *hiddenField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation HEMUpdateNameViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self nameField] becomeFirstResponder];
}

- (void)enableControls:(BOOL)enable {
    [[self cancelButton] setEnabled:enable];
    [[self doneButton] setEnabled:enable];

    if (!enable) {
        [[self hiddenField] becomeFirstResponder];
    }

    [[self nameField] setEnabled:enable];

    if (enable) {
        [[self nameField] becomeFirstResponder];
    }
}

- (void)showError:(__unused NSError*)error {
    UIView* seeThroughView = [[self navigationController] view];

    HEMAlertViewController* dialogVC = [[HEMAlertViewController alloc] init];
    [dialogVC setTitle:NSLocalizedString(@"account.update.failed.title", nil)];
    [dialogVC setMessage:NSLocalizedString(@"account.update.error.email", nil)];
    [dialogVC setViewToShowThrough:seeThroughView];
    [dialogVC showFrom:self onDefaultActionSelected:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self done:self];
    return YES;
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender {
    [[self delegate] didUpdateName:NO from:self];
}

- (IBAction)done:(id)sender {
    NSString* name = [[self nameField] text];
    if ([name length] == 0) {
        return;
    }
    [[self activityIndicator] setHidden:NO];
    [[self activityIndicator] startAnimating];
    [self enableControls:NO];
    __weak typeof(self) weakSelf = self;
    [[SENServiceAccount sharedService] changeName:name completion:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[strongSelf activityIndicator] stopAnimating];
        [strongSelf enableControls:YES];
        if (error != nil) {
            [strongSelf showError:error];
        } else {
            [[strongSelf delegate] didUpdateName:YES from:strongSelf];
        }
    }];
}

@end
