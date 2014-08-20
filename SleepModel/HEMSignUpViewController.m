
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAuthorizationService.h>

#import "HEMSignUpViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingHTTPErrorHandler.h"
#import "HelloStyleKit.h"

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

#pragma mark - Sign Up

- (IBAction)didTapSignUp:(id)sender
{
    if ([self isSigningUp] || ![self validateFieldValuesAndShowAlert:YES]) {
        return;
    }

    UIViewController* bluetoothController = [HEMOnboardingStoryboard instantiateBluetoothViewController];
    [[self navigationController] setViewControllers:@[bluetoothController] animated:YES];
    
//    self.signingUp = YES;
//    NSString* emailAddress = self.emailAddressField.text;
//    NSString* password = self.passwordField.text;
//    __weak typeof(self) weakSelf = self;
////    // TODO: show loading screen for "signing up"
//    [SENAPIAccount createAccountWithName:self.nameField.text
//                            emailAddress:emailAddress
//                                password:password
//                              completion:^(NSDictionary* data, NSError* error) {
//                                  typeof(self) strongSelf = weakSelf;
//                                  if (!strongSelf) return;
//                                  
//                                  if (error) {
//                                      [HEMOnboardingHTTPErrorHandler showAlertForHTTPError:error withTitle:NSLocalizedString(@"sign-up.failed.title", nil)];
//                                      strongSelf.signingUp = NO;
//                                      return;
//                                  }
//                                  // TODO: show loading screen for "signing in"
//                                  [SENAuthorizationService authorizeWithUsername:emailAddress password:password callback:^(NSError *signInError) {
//                                      strongSelf.signingUp = NO;
//                                      if (signInError) {
//                                          [HEMOnboardingHTTPErrorHandler showAlertForHTTPError:error withTitle:NSLocalizedString(@"sign-up.failed.title", nil)];
//                                          
//                                          // TODO: show sign in view? retry?
//                                          return;
//                                      }
//                                      
//                                      // we need to replace the root view controller with this controller so user cannot go back to sign up again
//                                      UIViewController* bluetoothController = [HEMOnboardingStoryboard instantiateBluetoothViewController];
//                                      [[strongSelf navigationController] setViewControllers:@[bluetoothController] animated:YES];
//                                  }];
//                              }];
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
        if ([self validateFieldValuesAndShowAlert:NO]) {
            [self didTapSignUp:self];
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

- (BOOL)validateFieldValuesAndShowAlert:(BOOL)shouldShowAlert
{
    NSString* errorMessage = nil;
    if (![self isValidName:self.nameField.text]) {
        errorMessage = NSLocalizedString(@"sign-up.error.name-length", nil);
    } else if (![self isValidEmailAddress:self.emailAddressField.text]) {
        errorMessage = NSLocalizedString(@"sign-up.error.email-invalid", nil);
    } else if (![self isValidPassword:self.passwordField.text]) {
        errorMessage = NSLocalizedString(@"sign-up.error.password-length", nil);
    } else {
        return YES;
    }
    if (errorMessage && shouldShowAlert) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.sign-in.failed.title", nil)
                                    message:errorMessage
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"actions.ok", nil), nil] show];
    }
    return NO;
}

@end
