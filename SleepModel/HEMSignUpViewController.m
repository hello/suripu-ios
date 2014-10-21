
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAccount.h>

#import "NSString+Email.h"

#import "HEMSignUpViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingHTTPErrorHandler.h"
#import "HEMBaseController+Protected.h"
#import "HelloStyleKit.h"
#import "HEMUserDataCache.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMSignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField* emailAddressField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UITextField* nameField;
@property (weak, nonatomic) IBOutlet UITextField *hiddenField;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (copy, nonatomic) NSString* doneButtonTitle;

@property (nonatomic, getter=isSigningUp) BOOL signingUp;

@end

@implementation HEMSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[self doneButton] titleLabel] setFont:[UIFont fontWithName:@"Calibre-Medium"
                                                            size:18.0f]];
    [SENAnalytics track:kHEMAnalyticsEventOnBStart];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self nameField] becomeFirstResponder];
}

#pragma mark - Activity

- (void)enableControls:(BOOL)enable {
    if (!enable) {
        // keep the keyboard up at all times
        [[self hiddenField] becomeFirstResponder];
    }
    
    [[self nameField] setEnabled:enable];
    [[self emailAddressField] setEnabled:enable];
    [[self passwordField] setEnabled:enable];
    [[self doneButton] setEnabled:enable];
    
    if (enable) {
        [[self nameField] becomeFirstResponder];
    }
}

- (void)showActivity {
    self.signingUp = YES;
    [self enableControls:NO];
    [[self activityIndicator] startAnimating];
}

- (void)stopActivity {
    self.signingUp = NO;
    [[self activityIndicator] stopAnimating];
    [self enableControls:YES];
}

#pragma mark - Sign Up

- (void)signup {
//    UIViewController* bluetoothController = [HEMOnboardingStoryboard instantiateBluetoothViewController];
//    [[self navigationController] setViewControllers:@[bluetoothController] animated:YES];
    NSString* emailAddress = [self trim:self.emailAddressField.text];
    NSString* password = self.passwordField.text;
    NSString* name = [self trim:self.nameField.text];
    
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount createAccountWithName:name
                            emailAddress:emailAddress
                                password:password
                              completion:^(SENAccount* account, NSError* error) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  if (!strongSelf) return;
                                  
                                  if (error) {
                                      [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
                                      [strongSelf stopActivity];
                                      [HEMOnboardingHTTPErrorHandler showAlertForHTTPError:error withTitle:NSLocalizedString(@"sign-up.failed.title", nil)];
                                      return;
                                  }
                                  // cache the account as that is needed post sign up
                                  // to update the account with further information
                                  [[HEMUserDataCache sharedUserDataCache] setAccount:account];
                                  [strongSelf authenticate:emailAddress password:password rety:YES];
                              }];
}

- (void)authenticate:(NSString*)email password:(NSString*)password rety:(BOOL)retry {
    __weak typeof(self) weakSelf = self;
    [SENAuthorizationService authorizeWithUsername:email password:password callback:^(NSError *signInError) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [strongSelf stopActivity];
        
        if (signInError && !retry) {
            // TODO: what should happen if we land in this case?
            DLog(@"authentication failed post sign up");
            NSString* errTitle = NSLocalizedString(@"sign-up.failed.title", nil);
            [HEMOnboardingHTTPErrorHandler showAlertForHTTPError:signInError withTitle:errTitle];
            return;
        } else if (signInError) { // retry once
            [SENAnalytics trackError:signInError withEventName:kHEMAnalyticsEventError];
            DLog(@"retrying authentication post sign up");
            [strongSelf authenticate:email password:password rety:NO];
            return;
        }
        
        [SENAnalytics setUserId:[SENAuthorizationService accountIdOfAuthorizedUser] properties:nil];
        [self performSegueWithIdentifier:[HEMOnboardingStoryboard moreInfoSegueIdentifier]
                                  sender:self];
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
    } else if ([textField isEqual:self.emailAddressField]) {
        [self.passwordField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordField]) {
        if ([self validateFieldValuesAndShowAlert:YES]) {
            [self showActivity];
            [self signup];
        }
    }

    return YES;
}

#pragma mark - Field Validation

- (NSString*)trim:(NSString*)value {
    NSCharacterSet* spaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [value stringByTrimmingCharactersInSet:spaces];
}

- (BOOL)isValidName:(NSString*)name
{
    return name.length > 1;
}

- (BOOL)isValidPassword:(NSString*)password
{
    return password.length >= 3;
}

// email validated through NSString+Email

- (BOOL)validateFieldValuesAndShowAlert:(BOOL)shouldShowAlert {
    NSString* errorMessage = nil;
    if (![self isValidName:[self trim:self.nameField.text]]) {
        errorMessage = NSLocalizedString(@"sign-up.error.name-length", nil);
    } else if (![[self trim:self.emailAddressField.text] isValidEmail]) {
        errorMessage = NSLocalizedString(@"sign-up.error.email-invalid", nil);
    } else if (![self isValidPassword:self.passwordField.text]) { // allow spaces?
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

@end
