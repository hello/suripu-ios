
#import <SenseKit/SENAPIAccount.h>
#import "HEMSignUpViewController.h"
#import "HEMActionButton.h"

@interface HEMSignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField* emailAddressField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UITextField* confirmPasswordField;
@property (weak, nonatomic) IBOutlet UITextField* nameField;
@property (weak, nonatomic) IBOutlet HEMActionButton* signUpButton;
@end

@implementation HEMSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"sign-up.title", nil);
    self.signUpButton.enabled = NO;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.nameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSignUp:(id)sender
{
    [SENAPIAccount createAccountWithName:self.nameField.text
                            emailAddress:self.emailAddressField.text
                                password:self.passwordField.text
                              completion:^(id data, NSError* error) {
                                  if (error) {
                                      [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.sign-in.failed.title", nil)
                                                                  message:error.localizedDescription
                                                                 delegate:nil
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"actions.ok", nil), nil] show];
                                      return;
                                  }
                              }];
}

#pragma mark - Field Validation

- (BOOL)isValidName:(NSString*)name
{
    return name.length > 1;
}

- (BOOL)isValidPassword:(NSString*)password
{
    return password.length > 3;
}

- (BOOL)isValidEmailAddress:(NSString*)emailAddress
{
    return [emailAddress rangeOfString:@"@"].location != NSNotFound;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (self.signUpButton.enabled) {
        [self didTapSignUp:self];
    }
    return YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.nameField) {
        self.signUpButton.enabled = [self isValidName:newText]
                                    && [self isValidEmailAddress:self.emailAddressField.text]
                                    && [self isValidPassword:self.passwordField.text]
                                    && [self.passwordField.text isEqualToString:self.confirmPasswordField.text];
    } else if (textField == self.emailAddressField) {
        self.signUpButton.enabled = [self isValidName:self.nameField.text]
                                    && [self isValidEmailAddress:newText]
                                    && [self isValidPassword:self.passwordField.text]
                                    && [self.passwordField.text isEqualToString:self.confirmPasswordField.text];
    } else if (textField == self.passwordField) {
        self.signUpButton.enabled = [self isValidName:self.nameField.text]
                                    && [self isValidEmailAddress:self.emailAddressField.text]
                                    && [self isValidPassword:newText]
                                    && [newText isEqualToString:self.confirmPasswordField.text];
    } else if (textField == self.confirmPasswordField) {
        self.signUpButton.enabled = [self isValidName:self.nameField.text]
                                    && [self isValidEmailAddress:self.emailAddressField.text]
                                    && [self isValidPassword:newText]
                                    && [newText isEqualToString:self.passwordField.text];
    }
    return YES;
}

@end
