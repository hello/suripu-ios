//
//  HEMUpdatePasswordViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/5/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENServiceAccount.h>

#import "HEMUpdatePasswordViewController.h"
#import "HEMSimpleLineTextField.h"
#import "HEMBaseController+Protected.h"

@interface HEMUpdatePasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet HEMSimpleLineTextField *currentField;
@property (weak, nonatomic) IBOutlet HEMSimpleLineTextField *passwordUpdateField;
@property (weak, nonatomic) IBOutlet UITextField *hiddenField; // used to keep keyboard up

@end

@implementation HEMUpdatePasswordViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self currentField] becomeFirstResponder];
}

- (void)enableControls:(BOOL)enable {
    [[self cancelButton] setEnabled:enable];
    [[self doneButton] setEnabled:enable];
    
    if (!enable) {
        [[self hiddenField] becomeFirstResponder];
    }
    
    [[self currentField] setEnabled:enable];
    [[self passwordUpdateField] setEnabled:enable];
    
    if (enable) {
        [[self passwordUpdateField] becomeFirstResponder];
    }
}

- (void)updatePassword {
    SENServiceAccount* service = [SENServiceAccount sharedService];
    NSString* username = [[service account] email];
    
    if ([username length] == 0) {
        [self showMessageDialog:NSLocalizedString(@"account.update.error.missing-account-info", nil)
                          title:NSLocalizedString(@"account.update.failed.title", nil)];
        return;
    }
    
    [self enableControls:NO];
    [[self activityIndicator] startAnimating];
    
    NSString* currentPassword = [[self currentField] text];
    NSString* nextPassword = [[self passwordUpdateField] text];
    
    __weak typeof(self) weakSelf = self;
    
    [service changePassword:currentPassword
              toNewPassword:nextPassword
                forUsername:username
                 completion:^(NSError *error) {
                     __strong typeof(weakSelf) strongSelf = weakSelf;
                     [[strongSelf activityIndicator] stopAnimating];
                     [strongSelf enableControls:YES];
                     
                     if (error != nil) {
                         [strongSelf showMessageDialog:NSLocalizedString(@"account.update.error.password", nil)
                                                 title:NSLocalizedString(@"account.update.failed.title", nil)];
                         return;
                     }
                     
                     [[strongSelf delegate] didUpdatePassword:YES from:strongSelf];
                 }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == [self currentField]) {
        [[self passwordUpdateField] becomeFirstResponder];
    } else if (textField == [self passwordUpdateField]) {
        [self done:self];
    }
    return YES;
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender {
    [[self delegate] didUpdatePassword:NO from:self];
}

- (IBAction)done:(id)sender {
    if ([[self currentField] text] > 0 && [[self passwordUpdateField] text] > 0) {
        [self updatePassword];
    }
}

@end
