
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAuthorizationService.h>
#import "HEMSignUpViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMSignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField* emailAddressField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UITextField* confirmPasswordField;
@property (weak, nonatomic) IBOutlet UITextField* nameField;
@property (strong, nonatomic) UITextField* activeField;
@property (weak, nonatomic) IBOutlet HEMActionButton* signUpButton;
@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@end

@implementation HEMSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) * 1.5f);
    //    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.nameField becomeFirstResponder];
}

- (IBAction)didTapSignUp:(id)sender
{
    if (![self validateFieldValuesAndShowAlert:YES])
        return;

    NSString* emailAddress = self.emailAddressField.text;
    NSString* password = self.passwordField.text;
    __weak typeof(self) weakSelf = self;
    // show loading screen for "signing up"
    [SENAPIAccount createAccountWithName:self.nameField.text
                            emailAddress:emailAddress
                                password:password
                              completion:^(NSDictionary* data, NSError* error) {
                                  typeof(self) strongSelf = weakSelf;
                                  if (error) {
                                      [strongSelf presentErrorAlertWithMessage:error.localizedDescription];
                                      return;
                                  }
                                  // show loading screen for "signing in"
                                  [SENAuthorizationService authorizeWithUsername:emailAddress password:password callback:^(NSError *signInError) {
                                      if (signInError) {
                                          [strongSelf presentErrorAlertWithMessage:signInError.localizedDescription];
                                          // show sign in view? retry?
                                          return;
                                      }
                                      [strongSelf.navigationController pushViewController:[HEMOnboardingStoryboard instantiateBluetoothViewController] animated:YES];
                                  }];
                              }];
}

#pragma mark - Field Validation

- (BOOL)isValidName:(NSString*)name
{
    return name.length > 1;
}

- (BOOL)isValidPassword:(NSString*)password
{
    return password.length >= 3;
}

- (BOOL)isValidEmailAddress:(NSString*)emailAddress
{
    return [emailAddress rangeOfString:@"@"].location != NSNotFound;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField*)textField
{
    self.activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if ([textField isEqual:self.nameField]) {
        [self.emailAddressField becomeFirstResponder];
        [self scrollToTextField:textField];
    } else if ([textField isEqual:self.emailAddressField]) {
        [self.passwordField becomeFirstResponder];
        [self scrollToTextField:textField];
    } else if ([textField isEqual:self.passwordField]) {
        [self.confirmPasswordField becomeFirstResponder];
        [self scrollToTextField:textField];
    } else if ([textField isEqual:self.confirmPasswordField]) {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
        [textField resignFirstResponder];
        if ([self validateFieldValuesAndShowAlert:NO]) {
            [self didTapSignUp:self];
        }
    }

    return YES;
}

- (void)scrollToTextField:(UITextField*)textField
{
    [self.scrollView setContentOffset:CGPointMake(0, CGRectGetMinY(textField.frame) - CGRectGetMinY(self.nameField.frame)) animated:YES];
}

- (BOOL)validateFieldValuesAndShowAlert:(BOOL)shouldShowAlert
{
    NSString* errorMessage = nil;
    if (![self isValidName:self.nameField.text]) {
        errorMessage = NSLocalizedString(@"sign-up.error.name-length", nil);
    } else if (![self isValidEmailAddress:self.emailAddressField.text]) {
        errorMessage = NSLocalizedString(@"sign-up.error.email-invalid", nil);
    } else if (![self isValidPassword:self.passwordField.text]) {
        errorMessage = NSLocalizedString(@"sign-up.error.password-length", nil);
    } else if (![self.passwordField.text isEqualToString:self.confirmPasswordField.text]) {
        errorMessage = NSLocalizedString(@"sign-up.error.password-match", nil);
    } else {
        return YES;
    }
    if (errorMessage && shouldShowAlert) {
        [self presentErrorAlertWithMessage:errorMessage];
    }
    return NO;
}

- (void)presentErrorAlertWithMessage:(NSString*)message
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.sign-in.failed.title", nil)
                                message:message
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:NSLocalizedString(@"actions.ok", nil), nil] show];
}

@end
