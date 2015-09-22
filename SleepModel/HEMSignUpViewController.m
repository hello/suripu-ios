
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAccount.h>

#import "NSString+HEMUtils.h"

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMSignUpViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingService.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBluetoothUtils.h"

@interface HEMSignUpViewController () <UITextFieldDelegate>

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
        
        void(^creationBlock)(SENAccount* account) = ^(SENAccount* account) {
            [SENAnalytics trackSignUpOfNewAccount:account];
            // checkpoint must be made here so that upon completion, user is not
            // pushed in to the app
            HEMOnboardingService* service = [HEMOnboardingService sharedService];
            [service saveOnboardingCheckpoint:HEMOnboardingCheckpointAccountCreated];
        };
        
        __weak typeof(self) weakSelf = self;
        void(^doneBlock)(SENAccount* account, NSError* error) = ^(SENAccount* account, NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                [SENAnalytics trackError:error];
                [strongSelf stopActivity:^{
                    NSString* title = NSLocalizedString(@"sign-up.failed.title", nil);
                    [strongSelf showMessageDialog:[error localizedDescription] title:title];
                } enableControls:YES];
                return;
            }

            [strongSelf next];
        };
        
        HEMOnboardingService* service = [HEMOnboardingService sharedService];
        [service createAccountWithName:name
                                 email:emailAddress
                                  pass:password
                     onAccountCreation:creationBlock
                            completion:doneBlock];
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
