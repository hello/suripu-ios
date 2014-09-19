
#import <SVProgressHUD/SVProgressHUD.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAPIClient.h>

#import "HEMAuthenticationViewController.h"
#import "HEMOnboardingHTTPErrorHandler.h"
#import "HEMActionButton.h"
#import "UIViewController+Keyboard.h"

static NSInteger const HEPURLAlertButtonIndexSave = 1;
static NSInteger const HEPURLAlertButtonIndexReset = 2;

@interface HEMAuthenticationViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField* usernameField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;

@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet HEMActionButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInWidthConstraint;

@property (assign, nonatomic) BOOL signingIn;

@end

@implementation HEMAuthenticationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    self.title = NSLocalizedString(@"authorization.title", nil);
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

- (void)enableControls:(BOOL)enable {
    [[self forgotPasswordButton] setEnabled:enable];
    [[self usernameField] setEnabled:enable];
    [[self passwordField] setEnabled:enable];
}

- (void)showActivity {
    [[self signInButton] showActivityWithWidthConstraint:[self signInWidthConstraint]];
    [self enableControls:NO];
}

- (void)stopActivity {
    [[self signInButton] stopActivity];
    [self enableControls:YES];
}

- (void)signIn {
    [self setSigningIn:YES];

    __weak typeof(self) weakSelf = self;
    [SENAuthorizationService authorizeWithUsername:self.usernameField.text password:self.passwordField.text callback:^(NSError* error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        [strongSelf setSigningIn:NO];
        [strongSelf stopActivity];
        if (error) {
            [HEMOnboardingHTTPErrorHandler showAlertForHTTPError:error withTitle:NSLocalizedString(@"authorization.sign-in.failed.title", nil)];
            return;
        }
        [strongSelf.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }];
}

#pragma mark - Actions

- (IBAction)didTapLogInButton:(id)sender {
    if ([self validateInputValues] && ![self signingIn]) {
        [self showActivity];
        [self signIn];
    }
}

- (IBAction)didTapForgotPasswordButton:(UIButton*)sender {
    NSLog(@"WARNING: this has not been implemented!");
}

- (IBAction)setAPIURL:(id)sender
{
    [self showURLUpdateAlertView];
}

#pragma mark - UIAlertViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* nextText = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:[self usernameField]]) {
        [[self usernameLabel] setHidden:[nextText length] == 0];
    } else if ([textField isEqual:[self passwordField]]) {
        [[self passwordLabel] setHidden:[nextText length] == 0];
    }
    return YES;
}

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
            __weak typeof(self) weakSelf = self;
            [self actAfterKeyboardDismissed:^{
                __strong typeof(weakSelf) strongSelf = self;
                if (strongSelf && ![strongSelf signingIn]) {
                    [strongSelf showActivity];
                    [strongSelf signIn];
                }
            }];
            
        }
    }

    return YES;
}

- (void)scrollToTextField:(UITextField*)textField
{
    [self.scrollView setContentOffset:CGPointMake(0, CGRectGetMinY(textField.frame) - CGRectGetMinY(self.usernameField.frame)) animated:YES];
}

@end
