
#import <SVProgressHUD/SVProgressHUD.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAPIClient.h>

#import "HEMAuthenticationViewController.h"
#import "HEMOnboardingHTTPErrorHandler.h"

static NSInteger const HEPURLAlertButtonIndexSave = 1;
static NSInteger const HEPURLAlertButtonIndexReset = 2;

@interface HEMAuthenticationViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField* usernameField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;

@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicatorView;
@property (strong, nonatomic) IBOutlet UIView* view;
@property (nonatomic, getter=isSigningIn) BOOL signingIn;
@end

@implementation HEMAuthenticationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    self.title = NSLocalizedString(@"authorization.title", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.usernameField becomeFirstResponder];
}

- (void)showURLUpdateAlertView
{
    UIAlertView* URLAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.set-url.title", nil)
                                                           message:NSLocalizedString(@"authorization.set-url.message", nil)
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"actions.cancel", nil)
                                                 otherButtonTitles:NSLocalizedString(@"actions.save", nil), NSLocalizedString(@"authorization.set-url.action.reset", nil), nil];
    URLAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* URLField = [URLAlertView textFieldAtIndex:0];
    URLField.text = [SENAPIClient baseURL].absoluteString;
    URLField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [URLAlertView show];
}

- (BOOL)validateInputValues
{
    return self.usernameField.text.length > 0 && self.passwordField.text.length > 0;
}

#pragma mark - Actions

- (IBAction)didTapLogInButton:(id)sender
{
    if ([self isSigningIn] || ![self validateInputValues])
        return;

    self.signingIn = YES;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"authorization.sign-in.loading-message", nil) maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) weakSelf = self;
    [SENAuthorizationService authorizeWithUsername:self.usernameField.text password:self.passwordField.text callback:^(NSError* error) {
        typeof(self) strongSelf = weakSelf;
        strongSelf.signingIn = NO;
        [SVProgressHUD dismiss];
        if (error) {
            [HEMOnboardingHTTPErrorHandler showAlertForHTTPError:error withTitle:NSLocalizedString(@"authorization.sign-in.failed.title", nil)];
            return;
        }
        [strongSelf.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }];
}

- (IBAction)didTapForgotPasswordButton:(UIButton*)sender
{
}

- (IBAction)setAPIURL:(id)sender
{
    [self showURLUpdateAlertView];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
    case HEPURLAlertButtonIndexReset: {
        [SENAPIClient resetToDefaultBaseURL];
        break;
    }
    case HEPURLAlertButtonIndexSave: {
        UITextField* URLField = [alertView textFieldAtIndex:0];
        if (![SENAPIClient setBaseURLFromPath:URLField.text]) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.failed-url.title", nil)
                                        message:NSLocalizedString(@"authorization.failed-url.message", nil)
                                       delegate:self
                              cancelButtonTitle:NSLocalizedString(@"actions.cancel", nil)
                              otherButtonTitles:nil] show];
        }
        break;
    }
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    [self scrollToTextField:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if ([textField isEqual:self.usernameField]) {
        [self.passwordField becomeFirstResponder];
        [self scrollToTextField:self.passwordField];
    } else {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
        [textField resignFirstResponder];
        if ([self validateInputValues]) {
            [self didTapLogInButton:self];
        }
    }

    return YES;
}

- (void)scrollToTextField:(UITextField*)textField
{
    [self.scrollView setContentOffset:CGPointMake(0, CGRectGetMinY(textField.frame) - CGRectGetMinY(self.usernameField.frame)) animated:YES];
}

@end
