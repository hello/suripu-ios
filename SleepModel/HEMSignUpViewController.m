
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

@interface HEMSignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField* emailAddressField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UITextField* nameField;
@property (weak, nonatomic) IBOutlet HEMActionButton *nextButton;

@property (nonatomic, getter=isSigningUp) BOOL signingUp;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTopConstraint;
@end

@implementation HEMSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self trackAnalyticsEvent:HEMAnalyticsEventAccount];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self nameField] becomeFirstResponder];
}

- (void)adjustConstraintsForIPhone4 {
    [self updateConstraint:[self nameTopConstraint] withDiff:40.0f];
}

#pragma mark - Activity

- (void)enableControls:(BOOL)enable {
    [[self nameField] setEnabled:enable];
    [[self emailAddressField] setEnabled:enable];
    [[self passwordField] setEnabled:enable];
    [[self nextButton] setEnabled:enable];
}

- (void)showActivity:(void(^)(void))completion {
    self.signingUp = YES;
    [self enableControls:NO];
    NSString* message = NSLocalizedString(@"sign-up.activity.message", nil);
    [self showActivityWithMessage:message completion:completion];
}

- (void)stopActivity:(void(^)(void))completion enableControls:(BOOL)enable {
    self.signingUp = NO;
    
    [self stopActivityWithMessage:nil success:NO completion:^{
        [self enableControls:enable];
        if (completion) completion ();
    }];
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
    
    // remove the activity slightly after the next view has been pushed
    __weak typeof(self) weakSelf = self;
    NSTimeInterval delayInSeconds = 0.5f;
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
        [weakSelf stopActivity:nil enableControls:NO];
    });
}

@end
