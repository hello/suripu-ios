
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAPIClient.h>
#import <CocoaLumberjack/DDLog.h>

#import "UIFont+HEMStyle.h"

#import "HEMAuthenticationViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"
#import "HEMBaseController+Protected.h"
#import "HEMActivityCoverView.h"

@interface HEMAuthenticationViewController ()

@property (weak, nonatomic) IBOutlet UITextField* usernameField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UITextField *hiddenField;
@property (weak, nonatomic) IBOutlet UIButton *forgotPassButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *logInButton;

@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (assign, nonatomic) BOOL signingIn;

@end

@implementation HEMAuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureForgotPassword];
    
    [SENAnalytics track:kHEMAnalyticsEventSignInStart];
}

- (void)configureForgotPassword {
    [[self forgotPassButton] setTitleColor:[HelloStyleKit senseBlueColor]
                                  forState:UIControlStateNormal];
    [[[self forgotPassButton] titleLabel] setFont:[UIFont navButtonTitleFont]];
    [[self forgotPassButton] setTitle:NSLocalizedString(@"authorization.forgot-pass", nil)
                             forState:UIControlStateNormal];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [[self forgotPassButton] sizeToFit];
    DDLogVerbose(@"%f %f", CGRectGetWidth([[self forgotPassButton] bounds]),
                 CGRectGetHeight([[self forgotPassButton] bounds]));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self usernameField] becomeFirstResponder];
}

- (BOOL)validateInputValues
{
    return self.usernameField.text.length > 0 && self.passwordField.text.length > 0;
}

- (void)enableControls:(BOOL)enable {
    
    if (!enable) {
        if ([[self usernameField] isFirstResponder]) {
            [[self usernameField] resignFirstResponder];
        } else if ([[self passwordField] isFirstResponder]) {
            [[self passwordField] resignFirstResponder];
        }
    }

    [[self forgotPassButton] setEnabled:enable];
    [[self usernameField] setEnabled:enable];
    [[self passwordField] setEnabled:enable];
    
    if (enable) {
        [[self usernameField] becomeFirstResponder];
    }
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
    [[self view] endEditing:NO];
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)didTapLogInButton:(id)sender {
    if ([self validateInputValues] && ![self signingIn]) {
        [self signIn];
    }
}

- (IBAction)didTapForgotPasswordButton:(UIButton*)sender {
    DDLogVerbose(@"WARNING: this has not been implemented!");
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
