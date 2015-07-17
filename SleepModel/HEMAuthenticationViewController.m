
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAPIClient.h>
#import <CocoaLumberjack/DDLog.h>

#import "UIFont+HEMStyle.h"

#import "HEMAuthenticationViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingUtils.h"
#import "UIColor+HEMStyle.h"
#import "HEMBaseController+Protected.h"
#import "HEMActivityCoverView.h"
#import "HEMNotificationHandler.h"
#import "HEMSupportUtil.h"

NSString* const HEMAuthenticationNotificationDidSignIn = @"HEMAuthenticationNotificationDidSignIn";

@interface HEMAuthenticationViewController ()

@property (weak, nonatomic) IBOutlet UITextField* usernameField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UIButton *forgotPassButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *logInButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailTopConstraint;

@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (assign, nonatomic) BOOL signingIn;
@property (assign, nonatomic, getter=isLoaded) BOOL loaded;

@end

@implementation HEMAuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureForgotPassword];
    
    [SENAnalytics track:kHEMAnalyticsEventSignInStart];
}

- (void)configureForgotPassword {
    [[self forgotPassButton] setTitleColor:[UIColor tintColor]
                                  forState:UIControlStateNormal];
    [[[self forgotPassButton] titleLabel] setFont:[UIFont navButtonTitleFont]];
    [[self forgotPassButton] setTitle:NSLocalizedString(@"authorization.forgot-pass", nil)
                             forState:UIControlStateNormal];
}

- (void)adjustConstraintsForIPhone4 {
    [super adjustConstraintsForIPhone4];
    [self setTitle:nil]; // removing title per design for iphone 4s
    [self updateConstraint:[self emailTopConstraint] withDiff:-40.0f];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // FIXME (jimmy): this may be an iOS bug (very likely), but if the username
    // field is given focus again, say after an alert is dismissed, the textfield
    // causes the textfield text to hide and show temporarily on every key stroke.
    // maybe it's related to the fact that the keyboard type for this field is
    // for an email?  This doesn't happen in sign up controller b/c the field
    // that is given focus to after appearance does not have the same keyboard type
    if (![self isLoaded]) {
        [[self usernameField] becomeFirstResponder];
        [self setLoaded:YES];
    } else {
        [[self passwordField] becomeFirstResponder];
    }
}

- (BOOL)validateInputValues
{
    return self.usernameField.text.length > 0 && self.passwordField.text.length > 0;
}

- (void)enableControls:(BOOL)enable {
    [[self forgotPassButton] setEnabled:enable];
    [[self usernameField] setEnabled:enable];
    [[self passwordField] setEnabled:enable];
}

- (void)showActivity:(void(^)(void))completion {
    [self enableControls:NO];
    
    NSString* message = NSLocalizedString(@"authorization.sign-in.activity.message", nil);
    HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] init];
    [activityView showInView:[[self navigationController] view] withText:message activity:YES completion:completion];

    [self setActivityView:activityView];
}

- (void)stopActivity:(void(^)(void))completion {
    if ([self activityView] == nil) {
        [self enableControls:YES];
        if (completion) completion ();
    } else {
        [[self activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
            [self setActivityView:nil];
            [self enableControls:YES];
            if (completion) completion ();
        }];
    }
}

- (void)signIn {
    [self showActivity:^{
        [self setSigningIn:YES];
        
        __weak typeof(self) weakSelf = self;
        [SENAuthorizationService authorizeWithUsername:self.usernameField.text password:self.passwordField.text callback:^(NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf setSigningIn:NO];
            
            if (error) {
                [strongSelf stopActivity:^{
                    [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
                    [HEMOnboardingUtils showAlertForHTTPError:error
                                                    withTitle:NSLocalizedString(@"authorization.sign-in.failed.title", nil)
                                                         from:strongSelf];
                    return;
                }];
            } else {
                [strongSelf letUserIntoApp];
                [strongSelf stopActivity:nil];
            }
            
        }];
    }];
}

- (void)letUserIntoApp {
    [HEMAnalytics trackUserSession]; // update user session, since it maybe a different user now
    [SENAnalytics track:kHEMAnalyticsEventSignIn];
    [HEMNotificationHandler registerForRemoteNotificationsIfEnabled];
    [[self view] endEditing:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:HEMAuthenticationNotificationDidSignIn object:nil];
}

#pragma mark - Actions

- (IBAction)didTapLogInButton:(id)sender {
    if ([self validateInputValues] && ![self signingIn]) {
        [self signIn];
    }
}

- (IBAction)didTapForgotPasswordButton:(UIButton*)sender {
    [HEMSupportUtil openURL:NSLocalizedString(@"help.forgot-password", nil) from:self];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if ([textField isEqual:self.usernameField]) {
        [self.passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        if ([self validateInputValues]) {
            [self signIn];
            
        }
    }

    return YES;
}

@end
