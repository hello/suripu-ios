#import <SenseKit/SENAuthorizationService.h>

#import "UIFont+HEMStyle.h"

#import "HEMAuthenticationViewController.h"
#import "HEMActionButton.h"
#import "UIColor+HEMStyle.h"
#import "HEMActivityCoverView.h"
#import "HEMNotificationHandler.h"
#import "HEMSupportUtil.h"
#import "HEMConfig.h"
#import "HEMAccountService.h"
#import "HEMTitledTextField.h"
#import "HEMSimpleLineTextField.h"

NSString* const HEMAuthenticationNotificationDidSignIn = @"HEMAuthenticationNotificationDidSignIn";

@interface HEMAuthenticationViewController ()

@property (weak, nonatomic) IBOutlet HEMTitledTextField *emailField;
@property (weak, nonatomic) IBOutlet HEMTitledTextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *forgotPassButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *logInButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonBottomConstraint;

@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (assign, nonatomic) BOOL signingIn;
@property (assign, nonatomic, getter=isLoaded) BOOL loaded;
@property (assign, nonatomic) CGFloat origBottomMargin;

@end

@implementation HEMAuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureForgotPassword];
    [self showBackButtonAsCancelWithSelector:@selector(cancel:)];
    [self configureFields];
    [self listenForKeyboardNotifications];
    
    [SENAnalytics track:kHEMAnalyticsEventSignInStart];
}

- (void)listenForKeyboardNotifications {
    [self setOrigBottomMargin:[[self buttonBottomConstraint] constant]];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(willShowKeyboard:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(willHideKeyboard:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
}

- (void)willShowKeyboard:(NSNotification*)note {
    NSValue* keyboardFrameVal = [[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSNumber* duration = [[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameVal CGRectValue];
    
    CGFloat reduceBottom = CGRectGetHeight(keyboardFrame) + [self origBottomMargin];
    [[self buttonBottomConstraint] setConstant:reduceBottom];
    
    [UIView animateWithDuration:[duration CGFloatValue] animations:^{
        [[[self logInButton] superview] layoutIfNeeded];
    }];
}

- (void)willHideKeyboard:(NSNotification*)note {
    [[self buttonBottomConstraint] setConstant:[self origBottomMargin]];
    [[self logInButton] updateConstraintsIfNeeded];
}

- (void)configureFields {
    NSString* emailPlaceholder = NSLocalizedString(@"onboarding.account.email", nil);
    [[self emailField] setPlaceholderText:emailPlaceholder];
    [[[self emailField] textField] setDelegate:self];
    
    NSString* passwordPlaceholder = NSLocalizedString(@"onboarding.account.password", nil);
    [[self passwordField] setPlaceholderText:passwordPlaceholder];
    [[[self passwordField] textField] setSecurityEnabled:YES];
    [[[self passwordField] textField] setDelegate:self];
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
    [self setOrigBottomMargin:10.0f];
    [self updateConstraint:[self emailTopConstraint] withDiff:-60.0f];
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
        [[[self emailField] textField] becomeFirstResponder];
        [self setLoaded:YES];
    } else {
        [[[self passwordField] textField] becomeFirstResponder];
    }
}

- (BOOL)validateInputValues {
    // let api reject invalid emails
    BOOL emailIsValid = [[[[self emailField] textField] text] length] > 0;
    BOOL passIsValid = [[[[self passwordField] textField] text] length] > 0;
    return emailIsValid && passIsValid;
}

- (void)enableControls:(BOOL)enable {
    [[self forgotPassButton] setEnabled:enable];
    [[[self emailField] textField] setEnabled:enable];
    [[[self passwordField] textField] setEnabled:enable];
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
        
        HEMOnboardingService* service = [HEMOnboardingService sharedService];
        NSString* username = [[[self emailField] textField] text];
        NSString* password = [[[self passwordField] textField] text];
        
        __weak typeof(self) weakSelf = self;
        [service authenticateUser:username pass:password retry:YES completion:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf setSigningIn:NO];
            
            if (error) {
                [strongSelf stopActivity:^{
                    [SENAnalytics trackError:error];
                    
                    NSString* title = NSLocalizedString(@"authorization.sign-in.failed.title", nil);
                    [strongSelf showMessageDialog:[error localizedDescription] title:title];
                }];
            } else {
                HEMAccountService* acctService = [HEMAccountService sharedService];
                [acctService refresh:^(SENAccount * _Nullable account, NSDictionary<NSNumber *,SENPreference *> * _Nullable preferences) {
                    [SENAnalytics trackUserSession:account];
                }];
                // don't wait for the account to refresh to proceed
                [strongSelf letUserIntoApp];
            }
        }];
    }];
}

- (void)letUserIntoApp {
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
    [HEMSupportUtil openURL:[HEMConfig stringForConfig:HEMConfPassResetURL] from:self];
}

- (void)cancel:(id)sender {
    [[self view] endEditing:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    if ([textField isEqual:[[self emailField] textField]]) {
        [[self.passwordField textField] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        if ([self validateInputValues]) {
            [self signIn];
            
        }
    }

    return YES;
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
