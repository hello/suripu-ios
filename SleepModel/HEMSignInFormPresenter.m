//
//  HEMSignInFormPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 5/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSignInFormPresenter.h"
#import "HEMOnboardingService.h"
#import "HEMAccountService.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMTextFieldCollectionViewCell.h"
#import "HEMStyle.h"
#import "HEMTitledTextField.h"
#import "HEMSimpleLineTextField.h"
#import "HEMActivityCoverView.h"

typedef NS_ENUM(NSInteger, HEMSignInFormRow) {
    HEMSignInFormRowTitle = 0,
    HEMSignInFormRowEmail,
    HEMSignInFormRowPass,
    HEMSignInFormRowCount
};

typedef NS_ENUM(NSUInteger, HEMSignInButtonType) {
    HEMSignInButtonTypeNext = 1,
    HEMSignInButtonTypeSignIn
};

static CGFloat const HEMSignInFormCellMargins = 20.0f;
static CGFloat const HEMSignInFormTextFieldCellHeight = 72.0f;
static CGFloat const HEMSignInFormTitleCellHeight = 50.0f;
static CGFloat const HEMSignInFormScrollDuration = 0.25f;

@interface HEMSignInFormPresenter() <
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UITextFieldDelegate
>

@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak) HEMOnboardingService* onbService;
@property (nonatomic, weak) HEMAccountService* accountService;
@property (nonatomic, weak) NSLayoutConstraint* bottomConstraint;
@property (nonatomic, weak) HEMActionButton* actionButton;
@property (nonatomic, assign) CGFloat origBottomMargin;
@property (nonatomic, assign, getter=isSigningIn) BOOL signingIn;
@property (nonatomic, weak) HEMSimpleLineTextField* emailField;
@property (nonatomic, weak) HEMSimpleLineTextField* passField;
@property (nonatomic, weak) UIView* activityContainerView;
@property (nonatomic, weak) HEMActivityCoverView* activityView;

@end

@implementation HEMSignInFormPresenter

- (instancetype)initWithOnboardingService:(HEMOnboardingService*)onbService
                           accountService:(HEMAccountService*)accountService {
    self = [super init];
    if (self) {
        _onbService = onbService;
        _accountService = accountService;
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView
              bottomConstraint:(NSLayoutConstraint*)bottomConstraint {
    
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    
    [self setOrigBottomMargin:[bottomConstraint constant]];
    [self setCollectionView:collectionView];
    [self setBottomConstraint:bottomConstraint];
    
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

- (void)bindWithSignInButton:(HEMActionButton*)signInButton {
    [signInButton addTarget:self
                     action:@selector(processAction:)
           forControlEvents:UIControlEventTouchUpInside];
    [self setActionButton:signInButton];
    [self updateToNextButton];
}

- (void)bindWithActivityContainer:(UIView*)activityContainer {
    [self setActivityContainerView:activityContainer];
}

#pragma mark - Presenter events

- (void)didAppear {
    [super didAppear];
    [self putFocusOnTextFieldAtRow:HEMSignInFormRowEmail];
}

#pragma mark -

- (void)putFocusOnTextFieldAtRow:(NSInteger)row {
    NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:0];
    __block UICollectionViewCell* cell = [[self collectionView] cellForItemAtIndexPath:path];
    
    void(^finish)(void) = ^{
        if ([cell isKindOfClass:[HEMTextFieldCollectionViewCell class]]) {
            HEMTextFieldCollectionViewCell* textFieldCell = (id)cell;
            [[textFieldCell textField] becomeFirstResponder];
        }
    };
    
    if (!cell) {
        [UIView animateWithDuration:HEMSignInFormScrollDuration animations:^{
            [[self collectionView] scrollToItemAtIndexPath:path
                                          atScrollPosition:UICollectionViewScrollPositionBottom
                                                  animated:NO];
        } completion:^(BOOL finished) {
            cell = [[self collectionView] cellForItemAtIndexPath:path];
            finish ();
        }];
    } else {
        finish();
    }
}

- (void)updateToNextButton {
    [[self actionButton] setBackgroundColor:[UIColor grey3] forState:UIControlStateNormal];
    [[self actionButton] setBackgroundColor:[UIColor grey4] forState:UIControlStateHighlighted];
    [[self actionButton] setTitle:[NSLocalizedString(@"actions.next", nil) uppercaseString]
                       forState:UIControlStateNormal];
    [[self actionButton] layoutIfNeeded];
    [[self actionButton] setTag:HEMSignInButtonTypeNext];
}

- (void)updateToDoneButton {
    [[self actionButton] setBackgroundColor:[UIColor tintColor] forState:UIControlStateNormal];
    [[self actionButton] setBackgroundColor:[UIColor blue7] forState:UIControlStateHighlighted];
    [[self actionButton] setTitle:[NSLocalizedString(@"actions.sign-in", nil) uppercaseString]
                         forState:UIControlStateNormal];
    [[self actionButton] layoutIfNeeded];
    [[self actionButton] setTag:HEMSignInButtonTypeSignIn];
}

#pragma mark - Big button event

- (void)processAction:(UIButton*)button {
    switch ([button tag]) {
        case HEMSignInButtonTypeSignIn:
            [self signInIfValid];
            break;
        default:
            [self putFocusOnTextFieldAtRow:HEMSignInFormRowPass];
            break;
    }
}

#pragma mark - Keyboard Events

- (void)willShowKeyboard:(NSNotification*)note {
    NSValue* keyboardFrameVal = [[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSNumber* duration = [[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameVal CGRectValue];
    
    CGFloat reduceBottom = CGRectGetHeight(keyboardFrame) + [self origBottomMargin];
    [[self bottomConstraint] setConstant:reduceBottom];
    
    [UIView animateWithDuration:[duration CGFloatValue] animations:^{
        [[self collectionView] layoutIfNeeded];
    }];
}

- (void)willHideKeyboard:(NSNotification*)note {
    [self updateToNextButton];
    [[self bottomConstraint] setConstant:[self origBottomMargin]];
    [[self collectionView] updateConstraintsIfNeeded];
}

#pragma mark - Collection view

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return HEMSignInFormRowCount;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    switch ([indexPath row]) {
        default:
        case HEMSignInFormRowTitle:
            reuseId = [HEMOnboardingStoryboard titleReuseIdentifier];
            break;
        case HEMSignInFormRowEmail:
            reuseId = [HEMOnboardingStoryboard emailReuseIdentifier];
            break;
        case HEMSignInFormRowPass:
            reuseId = [HEMOnboardingStoryboard passwordReuseIdentifier];
            break;
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath row]) {
        default:
        case HEMSignInFormRowTitle:
            [self displayTitleInCell:(id)cell];
            break;
        case HEMSignInFormRowEmail:
        case HEMSignInFormRowPass:
            [self displayTextfieldCell:(id)cell forRow:[indexPath row]];
            break;
    }
}

- (void)displayTitleInCell:(HEMTextCollectionViewCell*)textCell {
    [[textCell textLabel] setText:NSLocalizedString(@"onboarding.account.sign-in.title", nil)];
    [[textCell textLabel] setFont:[UIFont onboardingTitleFont]];
    [[textCell textLabel] setTextColor:[UIColor boldTextColor]];
}

- (void)displayTextfieldCell:(HEMTextFieldCollectionViewCell*)textFieldCell
                      forRow:(HEMSignInFormRow)row {
    NSString* placeholderText = nil;
    BOOL secure = NO;
    UIReturnKeyType returnKeyType = UIReturnKeyNext;
    UIKeyboardType keyboardType = UIKeyboardTypeAlphabet;
    
    switch (row) {
        default:
        case HEMSignInFormRowEmail:
            placeholderText = NSLocalizedString(@"onboarding.account.email", nil);
            keyboardType = UIKeyboardTypeEmailAddress;
            [self setEmailField:[textFieldCell textField]];
            break;
        case HEMSignInFormRowPass:
            placeholderText = NSLocalizedString(@"onboarding.account.password", nil);
            returnKeyType = UIReturnKeyDone;
            secure = YES;
            [self setPassField:[textFieldCell textField]];
            break;
    }
    
    [textFieldCell setPlaceholderText:placeholderText];
    [[textFieldCell textField] setSecurityEnabled:secure];
    [[textFieldCell textField] setTag:row];
    [[textFieldCell textField] setDelegate:self];
    [[textFieldCell textField] setReturnKeyType:returnKeyType];
    [[textFieldCell textField] setKeyboardType:keyboardType];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSInteger row = [textField tag];
    switch (row) {
        default:
        case HEMSignInFormRowEmail:
            [self updateToNextButton];
            break;
        case HEMSignInFormRowPass:
            [self updateToDoneButton];
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    NSInteger row = [textField tag];
    switch (row) {
        default:
        case HEMSignInFormRowEmail:
            [self putFocusOnTextFieldAtRow:row + 1];
            break;
        case HEMSignInFormRowPass:
            [textField resignFirstResponder];
            [self signInIfValid];
            break;
    }
    return YES;
}

#pragma mark - Sign In

- (BOOL)isInputValid {
    // let server determine if input is valid.  check make sure there's characters
    NSString* email = [[self emailField] text];
    NSString* pass = [[self passField] text];
    return [email length] > 0 && [pass length] > 0;
}

- (void)signInIfValid {
    if (![self isSigningIn] && [self isInputValid]) {
        [[self collectionView] endEditing:YES];
        [self setSigningIn:YES];
        [self showActivity:^{
            HEMOnboardingService* service = [HEMOnboardingService sharedService];
            NSString* username = [[self emailField] text];
            NSString* password = [[self passField] text];
    
            __weak typeof(self) weakSelf = self;
            [service authenticateUser:username pass:password retry:YES completion:^(NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
    
                [strongSelf setSigningIn:NO];
    
                if (error) {
                    [strongSelf stopActivity:^{
                        NSString* title = NSLocalizedString(@"authorization.sign-in.failed.title", nil);
                        [[strongSelf delegate] showErrorTitle:title message:[error localizedDescription] from:strongSelf];
                    }];
                } else {
                    [strongSelf refreshAccount];
                    // don't wait for the account to refresh to proceed
                    [service finishSignIn];
                }
            }];
        }];
    }
}

- (void)refreshAccount {
    HEMAccountService* acctService = [HEMAccountService sharedService];
    [acctService refresh:^(SENAccount * _Nullable account, NSDictionary<NSNumber *,SENPreference *> * _Nullable preferences) {
        [SENAnalytics trackUserSession:account];
    }];
}

- (void)showActivity:(void(^)(void))completion {
    NSString* message = NSLocalizedString(@"authorization.sign-in.activity.message", nil);
    HEMActivityCoverView* activityView = [HEMActivityCoverView new];
    [activityView showInView:[self activityContainerView]
                    withText:message
                    activity:YES completion:completion];
    [self setActivityView:activityView];
}

- (void)stopActivity:(void(^)(void))completion {
    if (![self activityView]) {
        completion ();
    } else {
        [[self activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
            [self setActivityView:nil];
            completion();
        }];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout* layout = (id) [collectionView collectionViewLayout];
    
    CGFloat cellMargins = HEMSignInFormCellMargins * 2.0f;
    CGSize itemSize = layout.itemSize;
    itemSize.width = CGRectGetWidth([collectionView bounds]) - cellMargins;
    
    switch ([indexPath row]) {
        case HEMSignInFormRowTitle:
            itemSize.height = HEMSignInFormTitleCellHeight;
            break;
        default:
            itemSize.height = HEMSignInFormTextFieldCellHeight;
            break;
    }
    
    return itemSize;
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_collectionView) {
        [_collectionView setDelegate:nil];
        [_collectionView setDataSource:nil];
    }
}


@end
