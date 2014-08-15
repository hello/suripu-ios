
#import <SVProgressHUD/SVProgressHUD.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAPIClient.h>

#import "HEMAuthenticationViewController.h"
#import "HEMHTTPErrorHandler.h"

static NSInteger const HEPURLAlertButtonIndexSave = 1;
static NSInteger const HEPURLAlertButtonIndexReset = 2;

@interface HEMAuthenticationViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField* usernameField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicatorView;
@property (strong, nonatomic) IBOutlet UIView* view;
@end

@implementation HEMAuthenticationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    self.navigationItem.hidesBackButton = YES;
    //    self.title = NSLocalizedString(@"authorization.title", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [self.usernameField becomeFirstResponder];
}

- (void)showURLUpdateAlertView
{
    UIAlertView* URLAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.set-url.title", nil)
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

#pragma mark - Actions

- (IBAction)didTapLogInButton:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"authorization.sign-in.loading-message", nil) maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) weakSelf = self;
    [SENAuthorizationService authorizeWithUsername:self.usernameField.text password:self.passwordField.text callback:^(NSError* error) {
        typeof(self) strongSelf = weakSelf;
        strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
        [SVProgressHUD dismiss];
        if (error) {
            [HEMHTTPErrorHandler showAlertForHTTPError:error withTitle:NSLocalizedString(@"authorization.sign-in.failed.title", nil)];
            return;
        }
        [strongSelf.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }];
}

- (IBAction)didTapSignUpButton:(id)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:[NSBundle mainBundle]];
    UIViewController* signUpController = [storyboard instantiateViewControllerWithIdentifier:@"signUpViewController"];
    //    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:signUpController animated:YES];
}

- (IBAction)didTapForgotPasswordButton:(UIButton*)sender
{
}

- (IBAction)setAPIURL:(id)sender
{
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
    [textField resignFirstResponder];
    if (self.navigationItem.rightBarButtonItem.enabled) {
        [self didTapSignUpButton:self];
    }
    return YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    UITextField* otherField;
    if ([textField isEqual:self.usernameField]) {
        otherField = self.passwordField;
    } else {
        otherField = self.usernameField;
    }
    self.navigationItem.rightBarButtonItem.enabled = newText.length > 0 && otherField.text.length > 0;

    return YES;
}

@end
