
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAuthorizationService.h>
#import "HEMSignUpViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMSignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField* emailAddressField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UITextField* confirmPasswordField;
@property (weak, nonatomic) IBOutlet UITextField* nameField;
@property (strong, nonatomic) UITextField* activeField;
@property (weak, nonatomic) IBOutlet HEMActionButton* signUpButton;
@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@end

@implementation HEMSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.signUpButton.enabled = NO;
    [self registerForKeyboardNotifications];
    //    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [self.nameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSignUp:(id)sender
{
    NSString* emailAddress = self.emailAddressField.text;
    NSString* password = self.passwordField.text;
    __weak typeof(self) weakSelf = self;
    // show loading screen for "signing up"
    [SENAPIAccount createAccountWithName:self.nameField.text
                            emailAddress:emailAddress
                                password:password
                              completion:^(NSDictionary* data, NSError* error) {
                                  typeof(self) strongSelf = weakSelf;
                                  if (error) {
                                      [strongSelf presentAlertForError:error];
                                      return;
                                  }
                                  // show loading screen for "signing in"
                                  [SENAuthorizationService authorizeWithUsername:emailAddress password:password callback:^(NSError *error) {
                                      if (error) {
                                          [strongSelf presentAlertForError:error];
                                          // show sign in view? retry?
                                          return;
                                      }
                                      [strongSelf.navigationController pushViewController:[HEMOnboardingStoryboard instantiateBluetoothViewController] animated:YES];
                                  }];
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

#pragma mark - Keyboard Handling

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    // if we have no view or are not visible in any window, we don't care
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardFrameInWindow;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrameInWindow];
    
    // the keyboard frame is specified in window-level coordinates. this calculates the frame as if it were a subview of our view, making it a sibling of the scroll view
    CGRect keyboardFrameInView = [self.view convertRect:keyboardFrameInWindow fromView:nil];
    
    CGRect scrollViewKeyboardIntersection = CGRectIntersection(_scrollView.frame, keyboardFrameInView);
    UIEdgeInsets newContentInsets = UIEdgeInsetsMake(0, 0, scrollViewKeyboardIntersection.size.height, 0);
    
    // this is an old animation method, but the only one that retains compaitiblity between parameters (duration, curve) and the values contained in the userInfo-Dictionary.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    _scrollView.contentInset = newContentInsets;
    _scrollView.scrollIndicatorInsets = newContentInsets;
    
    /*
     * Depending on visual layout, _focusedControl should either be the input field (UITextField,..) or another element
     * that should be visible, e.g. a purchase button below an amount text field
     * it makes sense to set _focusedControl in delegates like -textFieldShouldBeginEditing: if you have multiple input fields
     */
    if (self.activeField) {
        CGRect controlFrameInScrollView = [self.scrollView convertRect:self.activeField.bounds fromView:self.activeField]; // if the control is a deep in the hierarchy below the scroll view, this will calculate the frame as if it were a direct subview
        controlFrameInScrollView = CGRectInset(controlFrameInScrollView, 0, -10); // replace 10 with any nice visual offset between control and keyboard or control and top of the scroll view.
        
        CGFloat controlVisualOffsetToTopOfScrollview = controlFrameInScrollView.origin.y - _scrollView.contentOffset.y;
        CGFloat controlVisualBottom = controlVisualOffsetToTopOfScrollview + controlFrameInScrollView.size.height;
        
        // this is the visible part of the scroll view that is not hidden by the keyboard
        CGFloat scrollViewVisibleHeight = _scrollView.frame.size.height - scrollViewKeyboardIntersection.size.height;
        
        if (controlVisualBottom > scrollViewVisibleHeight) { // check if the keyboard will hide the control in question
            // scroll up until the control is in place
            CGPoint newContentOffset = _scrollView.contentOffset;
            newContentOffset.y += (controlVisualBottom - scrollViewVisibleHeight);
            
            // make sure we don't set an impossible offset caused by the "nice visual offset"
            // if a control is at the bottom of the scroll view, it will end up just above the keyboard to eliminate scrolling inconsistencies
            newContentOffset.y = MIN(newContentOffset.y, _scrollView.contentSize.height - scrollViewVisibleHeight);
            
            [_scrollView setContentOffset:newContentOffset animated:NO]; // animated:NO because we have created our own animation context around this code
        } else if (controlFrameInScrollView.origin.y < _scrollView.contentOffset.y) {
            // if the control is not fully visible, make it so (useful if the user taps on a partially visible input field
            CGPoint newContentOffset = _scrollView.contentOffset;
            newContentOffset.y = controlFrameInScrollView.origin.y;
            
            [_scrollView setContentOffset:newContentOffset animated:NO]; // animated:NO because we have created our own animation context around this code
        }
    }
    
    [UIView commitAnimations];
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillHide:(NSNotification*)notification
{
    // if we have no view or are not visible in any window, we don't care
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    // undo all that keyboardWillShow-magic
    // the scroll view will adjust its contentOffset apropriately
    _scrollView.contentInset = UIEdgeInsetsZero;
    _scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
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

- (void)presentAlertForError:(NSError*)error
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.sign-in.failed.title", nil)
                                message:error.localizedDescription
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:NSLocalizedString(@"actions.ok", nil), nil] show];
}

@end
