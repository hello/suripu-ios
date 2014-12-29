
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAPIClient.h>
#import <CocoaLumberjack/DDLog.h>

#import "UIFont+HEMStyle.h"

#import "HEMAuthenticationViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"
#import "HEMDeviceCenter.h"
#import "HEMBaseController+Protected.h"

@interface HEMAuthenticationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
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
    [[self titleLabel] setFont:[UIFont onboardingTitleFont]];
    [[[self doneButton] titleLabel] setFont:[UIFont navButtonTitleFont]];
    [[self doneButton] setTitleColor:[HelloStyleKit senseBlueColor]
                            forState:UIControlStateNormal];
    
    [SENAnalytics track:kHEMAnalyticsEventSignInStart];
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
        [[self hiddenField] becomeFirstResponder];
    }
    [[self forgotPasswordButton] setEnabled:enable];
    [[self usernameField] setEnabled:enable];
    [[self passwordField] setEnabled:enable];
    [[self doneButton] setEnabled:enable];
    [[self navigationItem] setHidesBackButton:!enable animated:YES];
    
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
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [strongSelf setSigningIn:NO];
        
        if (error) {
            [strongSelf stopActivity];
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
            [HEMOnboardingUtils showAlertForHTTPError:error
                                            withTitle:NSLocalizedString(@"authorization.sign-in.failed.title", nil)
                                                 from:strongSelf];
            return;
        }
        
        [strongSelf checkDevices:^(BOOL hasSense, NSError* error) {
            [strongSelf stopActivity];
            
            if (error != nil) {
                [strongSelf failDeviceCheck:error];
            } else if (!hasSense) {
                [strongSelf makeUserSetupSense];
            } else {
                [strongSelf letUserIntoApp];
            }
        }];
        
    }];
}

- (void)checkDevices:(void(^)(BOOL hasSense, NSError* error))completion {
    [[HEMDeviceCenter sharedCenter] loadDeviceInfo:^(NSError *error) {
        BOOL hasSense
            = error == nil
            && [[HEMDeviceCenter sharedCenter] senseInfo] != nil;
        completion (hasSense, error);
    }];
}

- (void)failDeviceCheck:(NSError*)error {
    [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
    NSString* msg = NSLocalizedString(@"authorization.sign-in.device.error.message", nil);
    NSString* title = NSLocalizedString(@"authorization.sign-in.device.error.title", nil);
    [SENAuthorizationService deauthorize];
    [self showMessageDialog:msg title:title];
}

- (void)letUserIntoApp {
    [HEMAnalytics trackUserSession]; // update user session, since it maybe a different user now
    [SENAnalytics track:kHEMAnalyticsEventSignIn];
    [[self view] endEditing:NO];
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)makeUserSetupSense {
    HEMOnboardingCheckpoint checkpoint = HEMOnboardingCheckpointAccountDone;
    UIViewController* checkpointVC =[HEMOnboardingUtils onboardingControllerForCheckpoint:checkpoint
                                                                               authorized:YES];
    
    // save this checkpoint in case user bails out at the checkpoint and app thinks
    // user is logged in
    [HEMOnboardingUtils saveOnboardingCheckpoint:checkpoint];
    [[self navigationController] setViewControllers:@[checkpointVC] animated:YES];
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
