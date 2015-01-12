
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAccount.h>

#import "NSString+HEMUtils.h"

#import "UIFont+HEMStyle.h"

#import "HEMSignUpViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBaseController+Protected.h"
#import "HelloStyleKit.h"
#import "HEMOnboardingCache.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingUtils.h"
#import "HEMBluetoothUtils.h"
#import "HEMActivityCoverView.h"

@interface HEMSignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField* emailAddressField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UITextField* nameField;
@property (weak, nonatomic) IBOutlet HEMActionButton *nextButton;

@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (nonatomic, getter=isSigningUp) BOOL signingUp;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTopConstraint;
@end

@implementation HEMSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SENAnalytics track:kHEMAnalyticsEventOnBStart];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self nameField] becomeFirstResponder];
}

- (void)adjustConstraintsForIPhone4 {
    [self updateConstraint:[self nameTopConstraint]
                  withDiff:8.0f];
}

#pragma mark - Activity

- (void)enableControls:(BOOL)enable {
    if (!enable) {
        [[self view] endEditing:NO];
    }
    
    [[self nameField] setEnabled:enable];
    [[self emailAddressField] setEnabled:enable];
    [[self passwordField] setEnabled:enable];
    [[self nextButton] setEnabled:enable];
    
    if (enable) {
        [[self nameField] becomeFirstResponder];
    }
}

- (void)showActivity:(void(^)(void))completion {
    self.signingUp = YES;
    [self enableControls:NO];
    NSString* message = NSLocalizedString(@"sign-up.activity.message", nil);
    HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] init];
    [activityView showInView:[[self navigationController] view] withText:message activity:YES completion:completion];
    [self setActivityView:activityView];
}

- (void)stopActivity:(void(^)(void))completion enableControls:(BOOL)enable {
    self.signingUp = NO;
    
    if ([self activityView] == nil) {
        [self enableControls:enable];
        if (completion) completion ();
    } else {
        [[self activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
            [self setActivityView:nil];
            [self enableControls:enable];
            if (completion) completion ();
        }];
    }
}

#pragma mark - Sign Up

- (void)signup {
    [self showActivity:^{
        NSString* emailAddress = [self.emailAddressField.text trim];
        NSString* password = self.passwordField.text;
        NSString* name = [self.nameField.text trim];
        
        __weak typeof(self) weakSelf = self;
        [SENAPIAccount createAccountWithName:name
                                emailAddress:emailAddress
                                    password:password
                                  completion:^(SENAccount* account, NSError* error) {
                                      __strong typeof(weakSelf) strongSelf = weakSelf;
                                      
                                      if (error) {
                                          [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
                                          [strongSelf stopActivity:^{
                                              NSString* title = NSLocalizedString(@"sign-up.failed.title", nil);
                                              [HEMOnboardingUtils showAlertForHTTPError:error
                                                                              withTitle:title
                                                                                   from:strongSelf];
                                          } enableControls:YES];
                                          
                                          return;
                                      }
                                      // cache the account as that is needed post sign up
                                      // to update the account with further information
                                      [[HEMOnboardingCache sharedCache] setAccount:account];
                                      [strongSelf authenticate:emailAddress password:password rety:YES];
                                      
                                      // save a checkpoint so that user does not have to try and create
                                      // another account
                                      [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointAccountCreated];
                                  }];
    }];
}

- (void)authenticate:(NSString*)email password:(NSString*)password rety:(BOOL)retry {
    NSString* userName = [self.nameField.text trim];
    __weak typeof(self) weakSelf = self;
    [SENAuthorizationService authorizeWithUsername:email password:password callback:^(NSError *signInError) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (signInError) {
            [strongSelf stopActivity:^{
                if (!retry) {
                    // TODO: what should happen if we land in this case?
                    DDLogInfo(@"authentication failed post sign up %@", signInError);
                    [SENAnalytics trackError:signInError withEventName:kHEMAnalyticsEventError];
                    NSString* errTitle = NSLocalizedString(@"sign-up.failed.title", nil);
                    [HEMOnboardingUtils showAlertForHTTPError:signInError
                                                    withTitle:errTitle
                                                         from:strongSelf];
                    return;
                } else { // retry once
                    [SENAnalytics trackError:signInError withEventName:kHEMAnalyticsEventError];
                    DDLogInfo(@"retrying authentication post sign up %@", signInError);
                    [strongSelf authenticate:email password:password rety:NO];
                    return;
                }
            } enableControls:YES];
        } else {
            [HEMAnalytics trackSignUpWithName:userName];
            [strongSelf next];
            [strongSelf stopActivity:nil enableControls:NO];
        }


    }];
}

- (IBAction)didTapSignUp:(id)sender {
    if ([self validateFieldValuesAndShowAlert:YES] && ![self isSigningUp]) {
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
            [self signup];
        }
    }

    return YES;
}

#pragma mark - Field Validation

- (BOOL)validateFieldValuesAndShowAlert:(BOOL)shouldShowAlert {
    NSString* errorMessage = nil;
    if ([[self.nameField.text trim] length] == 0) {
        errorMessage = NSLocalizedString(@"sign-up.error.name-length", nil);
    } else if (![[self.emailAddressField.text trim] isValidEmail]) {
        errorMessage = NSLocalizedString(@"sign-up.error.email-invalid", nil);
    } else if ([self.passwordField.text length] == 0) {
        errorMessage = NSLocalizedString(@"sign-up.error.password-length", nil);
    } else {
        return YES;
    }
    
    if (errorMessage && shouldShowAlert) {
        [self showMessageDialog:errorMessage title:NSLocalizedString(@"sign-up.failed.title", nil)];
    }
    return NO;
}

#pragma mark - Segues / Navigation

- (void)next {
    if (![HEMBluetoothUtils stateAvailable]) {
        [self performSelector:@selector(next)
                   withObject:nil
                   afterDelay:0.1f];
        return;
    }
    
    NSString* segueId
        = ![HEMBluetoothUtils isBluetoothOn]
        ? [HEMOnboardingStoryboard signupToNoBleSegueIdentifier]
        : [HEMOnboardingStoryboard moreInfoSegueIdentifier];

    [self performSegueWithIdentifier:segueId sender:self];
}

@end
