
#import "HEMSignUpViewController.h"
#import "HEMActionButton.h"

@interface HEMSignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField* emailAddressField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UITextField* confirmPasswordField;
@property (weak, nonatomic) IBOutlet HEMActionButton* signUpButton;
@end

@implementation HEMSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"sign-up.title", nil);
    self.signUpButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.emailAddressField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSignUp:(id)sender
{
}

- (BOOL)isValidPassword:(NSString*)password
{
    return password.length > 3;
}

- (BOOL)isValidEmailAddress:(NSString*)emailAddress
{
    return [emailAddress rangeOfString:@"@"].location != NSNotFound;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.emailAddressField) {
        self.signUpButton.enabled = [self isValidEmailAddress:newText]
                                    && [self isValidPassword:self.passwordField.text]
                                    && [self.passwordField.text isEqualToString:self.confirmPasswordField.text];
    } else if (textField == self.passwordField) {
        self.signUpButton.enabled = [self isValidEmailAddress:self.emailAddressField.text]
                                    && [self isValidPassword:newText]
                                    && [newText isEqualToString:self.confirmPasswordField.text];
    } else if (textField == self.confirmPasswordField) {
        self.signUpButton.enabled = [self isValidEmailAddress:self.emailAddressField.text]
                                    && [self isValidPassword:newText]
                                    && [newText isEqualToString:self.passwordField.text];
    }
    return YES;
}

@end
