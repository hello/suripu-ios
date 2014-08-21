
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAuthorizationService.h>

#import "HEMSignUpViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingHTTPErrorHandler.h"
#import "HelloStyleKit.h"
#import "NSString+Email.h"
#import "UIViewController+Keyboard.h"

@interface HEMSignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField* emailAddressField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UITextField* nameField;
@property (weak, nonatomic) IBOutlet HEMActionButton* signUpButton;
@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (nonatomic, getter=isSigningUp) BOOL signingUp;
@end

@implementation HEMSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self listenForKeyboardNotifications];
}

#pragma mark - Keyboard Mangement

- (void)listenForKeyboardNotifications {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(keyboardWillDisappear:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
}

- (void)keyboardWillDisappear:(NSNotification*)notification {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Activity

- (void)enableControls:(BOOL)enable {
    [[self nameField] setEnabled:enable];
    [[self emailAddressField] setEnabled:enable];
    [[self passwordField] setEnabled:enable];
}

- (void)showActivity {
    self.signingUp = YES;
    [self enableControls:NO];
    [[self signUpButton] showActivity];
}

- (void)stopActivity {
    self.signingUp = NO;
    [self enableControls:YES];
    [[self signUpButton] stopActivity];
}

#pragma mark - Sign Up

- (void)signup {
    NSString* emailAddress = self.emailAddressField.text;
    NSString* password = self.passwordField.text;

    __weak typeof(self) weakSelf = self;
    [SENAPIAccount createAccountWithName:self.nameField.text
                            emailAddress:emailAddress
                                password:password
                              completion:^(NSDictionary* data, NSError* error) {
                                  typeof(self) strongSelf = weakSelf;
                                  if (!strongSelf) return;
                                  
                                  if (error) {
                                      [strongSelf stopActivity];
                                      [HEMOnboardingHTTPErrorHandler showAlertForHTTPError:error withTitle:NSLocalizedString(@"sign-up.failed.title", nil)];
                                      return;
                                  }
                                  
                                  [SENAuthorizationService authorizeWithUsername:emailAddress password:password callback:^(NSError *signInError) {
                                      [strongSelf stopActivity];
                                      if (signInError) {
                                          [HEMOnboardingHTTPErrorHandler showAlertForHTTPError:error withTitle:NSLocalizedString(@"sign-up.failed.title", nil)];
                                          // TODO: show sign in view? retry?
                                          return;
                                      }
                                      // we need to replace the root view controller with this controller so user cannot go back to sign up again
                                      UIViewController* bluetoothController = [HEMOnboardingStoryboard instantiateBluetoothViewController];
                                      [[strongSelf navigationController] setViewControllers:@[bluetoothController] animated:YES];
                                  }];
                              }];
}

- (IBAction)didTapSignUp:(id)sender {
    if ([self validateFieldValuesAndShowAlert:YES] && ![self isSigningUp]) {
        [self showActivity];
        [self signup];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if ([textField isEqual:self.nameField]) {
        [self.emailAddressField becomeFirstResponder];
        [self scrollToTextField:self.emailAddressField];
    } else if ([textField isEqual:self.emailAddressField]) {
        [self.passwordField becomeFirstResponder];
        [self scrollToTextField:self.passwordField];
    } else if ([textField isEqual:self.passwordField]) {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
        [textField resignFirstResponder];
        if ([self validateFieldValuesAndShowAlert:YES]) {
            __weak typeof(self) weakSelf = self;
            [self actAfterKeyboardDismissed:^{
                __strong typeof(weakSelf) strongSelf = self;
                if (strongSelf && ![strongSelf isSigningUp]) {
                    [strongSelf showActivity];
                    [strongSelf signup];
                }
            }];
        }
    }

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* nextText = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    [[self labelForTextField:textField] setHidden:[nextText length] == 0];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self scrollToTextField:textField];
}

- (void)scrollToTextField:(UITextField*)textField
{
    [self.scrollView setContentOffset:CGPointMake(0, CGRectGetMinY(textField.frame) - CGRectGetMinY(self.nameField.frame)) animated:YES];
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

// email validated through NSString+Email

- (UILabel*)labelForTextField:(UITextField*)textField {
    UILabel* label = nil;
    if ([textField isEqual:[self nameField]]) {
        label = [self nameLabel];
    } else if ([textField isEqual:[self emailAddressField]]) {
        label = [self emailLabel];
    } else if ([textField isEqual:[self passwordField]]) {
        label = [self passwordLabel];
    }
    return label;
}

- (BOOL)validateFieldValuesAndShowAlert:(BOOL)shouldShowAlert
{
    NSString* errorMessage = nil;
    if (![self isValidName:self.nameField.text]) {
        errorMessage = NSLocalizedString(@"sign-up.error.name-length", nil);
    } else if (![self.emailAddressField.text isValidEmail]) {
        errorMessage = NSLocalizedString(@"sign-up.error.email-invalid", nil);
    } else if (![self isValidPassword:self.passwordField.text]) {
        errorMessage = NSLocalizedString(@"sign-up.error.password-length", nil);
    } else {
        return YES;
    }
    if (errorMessage && shouldShowAlert) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sign-up.failed.title", nil)
                                    message:errorMessage
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"actions.ok", nil), nil] show];
    }
    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
