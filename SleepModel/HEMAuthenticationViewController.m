
#import <SVProgressHUD/SVProgressHUD.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAPIClient.h>
#import <CocoaLumberjack/DDLog.h>

#import "HEMAuthenticationViewController.h"
#import "HEMOnboardingHTTPErrorHandler.h"
#import "HEMActionButton.h"

static NSInteger const HEPURLAlertButtonIndexSave = 1;
static NSInteger const HEPURLAlertButtonIndexReset = 2;

@interface HEMAuthenticationViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField* usernameField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UITextField *hiddenField;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (assign, nonatomic) BOOL signingIn;

@end

@implementation HEMAuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[self doneButton] titleLabel] setFont:[UIFont fontWithName:@"Calibre-Medium"
                                                            size:18.0f]];
    
    [SENAnalytics track:kHEMAnalyticsEventSignInStart];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self usernameField] becomeFirstResponder];
}

- (void)showURLUpdateAlertView
{
    UIAlertView* URLAlertView =
        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.set-url.title", nil)
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
    if (!enable) {
        [[self hiddenField] becomeFirstResponder];
    }
    [[self forgotPasswordButton] setEnabled:enable];
    [[self usernameField] setEnabled:enable];
    [[self passwordField] setEnabled:enable];
    [[self doneButton] setEnabled:enable];
    if (enable) {
        [[self usernameField] becomeFirstResponder];
    }
}

- (void)showActivity {
    [self enableControls:NO];
    [[self activityIndicator] startAnimating];
}

- (void)stopActivity {
    [[self activityIndicator] stopAnimating];
    [self enableControls:YES];
}

- (void)signIn {
    [self setSigningIn:YES];

    __weak typeof(self) weakSelf = self;
    [SENAuthorizationService authorizeWithUsername:self.usernameField.text password:self.passwordField.text callback:^(NSError* error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [strongSelf setSigningIn:NO];
    
        if (error) {
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
            [strongSelf stopActivity];
            [HEMOnboardingHTTPErrorHandler showAlertForHTTPError:error withTitle:NSLocalizedString(@"authorization.sign-in.failed.title", nil)];
            return;
        }

        [SENAnalytics setUserId:[SENAuthorizationService accountIdOfAuthorizedUser] properties:nil];
        [SENAnalytics track:kHEMAnalyticsEventSignIn];

        [[strongSelf view] endEditing:NO];
        [strongSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
        
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
    DDLogVerbose(@"WARNING: this has not been implemented!");
}

- (IBAction)setAPIURL:(id)sender
{
    // TODO (jimmy): what is this and how do get to it? :P
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

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if ([textField isEqual:self.usernameField]) {
        [self.passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        if ([self validateInputValues]) {
            [self showActivity];
            [self signIn];
            
        }
    }

    return YES;
}

@end
