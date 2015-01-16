//
//  HEMUpdateEmailViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENServiceAccount.h>

#import "HEMUpdateEmailViewController.h"
#import "HEMSimpleLineTextField.h"
#import "NSString+HEMUtils.h"
#import "HEMDialogViewController.h"

@interface HEMUpdateEmailViewController() <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet HEMSimpleLineTextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *hiddenField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation HEMUpdateEmailViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self emailField] becomeFirstResponder];
}

- (void)enableControls:(BOOL)enable {
    [[self cancelButton] setEnabled:enable];
    [[self doneButton] setEnabled:enable];
    
    if (!enable) {
        [[self hiddenField] becomeFirstResponder];
    }
    
    [[self emailField] setEnabled:enable];
    
    if (enable) {
        [[self emailField] becomeFirstResponder];
    }
}

- (void)showError:(__unused NSError*)error {
    UIView* seeThroughView = [[self navigationController] view];
    
    HEMDialogViewController* dialogVC = [[HEMDialogViewController alloc] init];
    [dialogVC setTitle:NSLocalizedString(@"account.update.failed.title", nil)];
    [dialogVC setMessage:NSLocalizedString(@"account.update.error.email", nil)];
    [dialogVC setShowHelp:YES];
    [dialogVC setViewToShowThrough:seeThroughView];
    
    [dialogVC showFrom:self onDone:^{
        // don't weak reference this since controller must remain until it has
        // been dismissed
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
    [[self delegate] didUpdateEmail:NO from:self];
}

- (IBAction)done:(id)sender {
    NSString* email = [[self emailField] text];
    if ([email length] > 0) {
        [[self activityIndicator] setHidden:NO];
        [[self activityIndicator] startAnimating];
        [self enableControls:NO];
        __weak typeof(self) weakSelf = self;
        [[SENServiceAccount sharedService] changeEmail:[email trim] completion:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [[strongSelf activityIndicator] stopAnimating];
                [strongSelf enableControls:YES];
                if (error != nil) {
                    [strongSelf showError:error];
                } else {
                    [[strongSelf delegate] didUpdateEmail:YES from:strongSelf];
                }
            }
            
        }];
        
    }

}

@end
