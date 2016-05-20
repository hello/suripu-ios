//
//  HEMNewAccountPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 5/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "NSString+HEMUtils.h"

#import "HEMNewAccountPresenter.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMTextFieldCollectionViewCell.h"
#import "HEMNewProfileCollectionViewCell.h"
#import "HEMActivityCoverView.h"
#import "HEMOnboardingService.h"
#import "HEMFacebookService.h"
#import "HEMProfileImageView.h"
#import "HEMSimpleLineTextField.h"

static CGFloat const HEMNewAccountPresenterPhotoHeight = 226.0f;
static CGFloat const HEMNewAccountPresenterFieldHeight = 72.0f;
static CGFloat const HEMNewAccountPresenterCellMargin = 24.0f;
static CGFloat const HEMNewAccountPresenterAutoScrollTopMargin = 15.0f;
static CGFloat const HEMNewAccountPresenterScrollDuration = 0.25f;

typedef NS_ENUM(NSInteger, HEMNewAccountRow) {
    HEMNewAccountRowProfilePicture = 0,
    HEMNewAccountRowFirstName,
    HEMNewAccountRowLastName,
    HEMNewAccountRowEmail,
    HEMNewAccountRowPassword,
    HEMNewAccountRowCount
};

@interface HEMNewAccountPresenter() <
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UITextFieldDelegate
>

@property (nonatomic, weak) UIViewController* controller;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak) NSLayoutConstraint* bottomConstraint;
@property (nonatomic, assign) CGFloat origBottomConstraint;
@property (nonatomic, weak) UIButton* nextButton;
@property (nonatomic, strong) HEMActivityCoverView* activityView;
@property (nonatomic, weak) UIView* activityContainerView;
@property (nonatomic, strong) SENAccount* tempAccount;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, copy) NSString* fbPhotoUrl;
@property (nonatomic, strong) UIImage* photo;
@property (nonatomic, weak) HEMOnboardingService* onbService;
@property (nonatomic, weak) HEMFacebookService* fbService;
@property (nonatomic, assign) HEMNewAccountRow rowWithError;
@property (nonatomic, assign) BOOL autofilled;

@end

@implementation HEMNewAccountPresenter

- (instancetype)initWithOnboardingService:(HEMOnboardingService*)onbService
                          facebookService:(HEMFacebookService*)fbService {
    self = [super init];
    if (self) {
        _onbService = onbService;
        _fbService = fbService;
        _tempAccount = [SENAccount new];
    }
    return self;
}

- (void)bindWithControllerToLaunchFacebook:(UIViewController*)controller {
    [self setController:controller];
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView
           andBottomConstraint:(NSLayoutConstraint*)bottomConstraint {
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [self setCollectionView:collectionView];
    [self setBottomConstraint:bottomConstraint];
    [self setOrigBottomConstraint:[bottomConstraint constant]];
    
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

- (void)bindWithActivityContainerView:(UIView*)activityContainerView {
    [self setActivityContainerView:activityContainerView];
}

- (void)bindWithNextButton:(UIButton*)button {
    [button setEnabled:NO];
    [button addTarget:self
               action:@selector(next:)
     forControlEvents:UIControlEventTouchUpInside];
    [self setNextButton:button];
}

#pragma mark - Presenter Events

- (void)didAppear {
    [super didAppear];
    if ([self rowWithError] != HEMNewAccountRowProfilePicture
        && [self rowWithError] != HEMNewAccountRowCount) {
        [self putFocusOnTextFieldAtRow:[self rowWithError]];
        [self setRowWithError:HEMNewAccountRowProfilePicture];
    }
}

- (void)didDisappear {
    [super didDisappear];
    
    if ([[self activityView] isShowing]) {
        NSString* done = NSLocalizedString(@"status.success", nil);
        [[self activityView] dismissWithResultText:done showSuccessMark:YES remove:YES completion:nil];
    }
}

#pragma mark - Actions

- (void)showFBInfo {
    [[self delegate] showSupportPageWithSlug:NSLocalizedString(@"help.url.slug.facebook-import", nil)];
}

- (void)autofillFromFB {
    [[self collectionView] endEditing:NO];
    
    __weak typeof(self) weakSelf = self;
    [[self fbService] profileFrom:[self controller] completion:^(SENAccount* account, NSString* photoUrl, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            NSString* title = NSLocalizedString(@"account.error.facebook-access.title", nil);
            NSString* message = NSLocalizedString(@"account.error.facebook-access", nil);
            [[strongSelf delegate] showError:message title:title from:strongSelf];
        } else {
            [strongSelf setAutofilled:YES];
            [[strongSelf tempAccount] setEmail:[account email]];
            [[strongSelf tempAccount] setLastName:[account lastName]];
            [[strongSelf tempAccount] setFirstName:[account firstName]];
            [strongSelf setFbPhotoUrl:photoUrl];
            [[strongSelf collectionView] reloadData];
        }
    }];
}

- (void)next:(id)sender {
    NSString* errorMessage = nil;
    if (![[self onbService] isFirstNameValid:[[self tempAccount] firstName]]) {
        errorMessage = NSLocalizedString(@"account.error.invalid-first-name", nil);
        [self setRowWithError:HEMNewAccountRowFirstName];
    } else if (![[self onbService] isLastNameValid:[[self tempAccount] lastName]]) {
        errorMessage = NSLocalizedString(@"account.error.invalid-last-name", nil);
        [self setRowWithError:HEMNewAccountRowLastName];
    } else if (![[self onbService] isEmailValid:[[self tempAccount] email]]) {
        errorMessage = NSLocalizedString(@"account.error.invalid-email", nil);
        [self setRowWithError:HEMNewAccountRowEmail];
    } else if (![[self onbService] isPasswordValid:[self password]]) {
        errorMessage = NSLocalizedString(@"account.error.invalid-password", nil);
        [self setRowWithError:HEMNewAccountRowPassword];
    }
    
    if (errorMessage) {
        NSString* title = NSLocalizedString(@"sign-up.failed.title", nil);
        [[self delegate] showError:errorMessage title:title from:self];
    } else {
        [self signUp];
    }
    
}

- (void)signUp {
    [self showActivity:^{
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
                [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                    NSString* title = NSLocalizedString(@"sign-up.failed.title", nil);
                    [[strongSelf delegate] showError:[error localizedDescription] title:title from:strongSelf];
                    [[strongSelf collectionView] setUserInteractionEnabled:YES];
                    [[strongSelf nextButton] setEnabled:YES];
                }];
                return;
            }
            
            [[strongSelf delegate] proceedFrom:strongSelf];
        };
        
        [[self onbService] createAccount:[self tempAccount]
                            withPassword:[self password]
                       onAccountCreation:creationBlock
                              completion:doneBlock];
    }];
}

#pragma mark - Keyboard

- (void)willShowKeyboard:(NSNotification*)note {
    NSValue* keyboardFrameVal = [[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSNumber* duration = [[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameVal CGRectValue];
    CGFloat reduceBottom = CGRectGetHeight(keyboardFrame) + [self origBottomConstraint];
    [[self bottomConstraint] setConstant:reduceBottom];
    
    [UIView animateWithDuration:[duration CGFloatValue] animations:^{
        [[[self collectionView] superview] layoutIfNeeded];
    }];
}

- (void)willHideKeyboard:(NSNotification*)note {
    [[self bottomConstraint] setConstant:[self origBottomConstraint]];
    [[self collectionView] updateConstraintsIfNeeded];
}

#pragma mark - Activity

- (void)showActivity:(void(^)(void))completion {
    [[self collectionView] endEditing:NO];
    [[self collectionView] setUserInteractionEnabled:NO];
    [[self nextButton] setEnabled:NO];
    
    NSString* message = NSLocalizedString(@"sign-up.activity.message", nil);
    [self showActivityWithMessage:message completion:completion];
}

- (void)showActivityWithMessage:(NSString*)message completion:(void(^)(void))completion {
    if ([self activityView] != nil) {
        [[self activityView] removeFromSuperview];
    }
    
    UIView* containerView = [self activityContainerView] ?: [self collectionView];
    [self setActivityView:[[HEMActivityCoverView alloc] init]];
    [[self activityView] showInView:containerView
                           withText:message
                           activity:YES
                         completion:completion];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return HEMNewAccountRowCount;
}

- (UICollectionViewCell*)cellWithIdentifier:(NSString*)identifier atIndexPath:(NSIndexPath*)path {
    UICollectionViewCell* cell = [[self collectionView] dequeueReusableCellWithReuseIdentifier:identifier
                                                                                  forIndexPath:path];
    
    if ([path row] == HEMNewAccountRowProfilePicture) {
        [self configurePhotoCell:(id)cell];
    } else {
        [self configureTextFieldCell:(id)cell atIndex:[path row]];
    }

    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    switch ([indexPath row]) {
        default:
        case HEMNewAccountRowProfilePicture:
            reuseId = [HEMOnboardingStoryboard photoReuseIdentifier];
            break;
        case HEMNewAccountRowFirstName:
            reuseId = [HEMOnboardingStoryboard firstNameReuseIdentifier];
            break;
        case HEMNewAccountRowLastName:
            reuseId = [HEMOnboardingStoryboard lastNameReuseIdentifier];
            break;
        case HEMNewAccountRowEmail:
            reuseId = [HEMOnboardingStoryboard emailReuseIdentifier];
            break;
        case HEMNewAccountRowPassword:
            reuseId = [HEMOnboardingStoryboard passwordReuseIdentifier];
            break;
    }
    
    return [self cellWithIdentifier:reuseId atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == HEMNewAccountRowProfilePicture) {
        [collectionView endEditing:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout* layout = (id) [collectionView collectionViewLayout];
    
    CGFloat cellMargins = HEMNewAccountPresenterCellMargin * 2.0f;
    CGSize itemSize = layout.itemSize;
    itemSize.width = CGRectGetWidth([collectionView bounds]) - cellMargins;
    
    switch ([indexPath row]) {
        case HEMNewAccountRowProfilePicture:
            itemSize.height = HEMNewAccountPresenterPhotoHeight;
            break;
        default:
            itemSize.height = HEMNewAccountPresenterFieldHeight;
            break;
    }
    
    return itemSize;
}

#pragma mark - Displaying Cells

- (void)configurePhotoCell:(HEMNewProfileCollectionViewCell*)profilePhotoCell {
    [[profilePhotoCell fbInfoButton] addTarget:self
                                        action:@selector(showFBInfo)
                              forControlEvents:UIControlEventTouchUpInside];
    [[profilePhotoCell fbAutofillButton] addTarget:self
                                            action:@selector(autofillFromFB)
                                  forControlEvents:UIControlEventTouchUpInside];
    [[profilePhotoCell fbAutofillButton] setSelected:[self autofilled]];
    
    if ([self fbPhotoUrl]) {
        __weak typeof(self) weakSelf = self;
        [[profilePhotoCell profileImageView] setImageWithURL:[self fbPhotoUrl] completion:^(UIImage * image, NSString * url, NSError * error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if ([url isEqualToString:[strongSelf fbPhotoUrl]]) {
                [strongSelf setPhoto:image];
            }
        }];
    }
    
}

- (void)configureTextFieldCell:(HEMTextFieldCollectionViewCell*)cell atIndex:(NSInteger)index {
    NSString* placeholderText = nil;
    NSString* value = nil;
    BOOL secure = NO;
    UIReturnKeyType returnKeyType = UIReturnKeyNext;
    UIKeyboardType keyboardType = UIKeyboardTypeAlphabet;
    
    switch (index) {
        default:
        case HEMNewAccountRowFirstName:
            placeholderText = NSLocalizedString(@"onboarding.account.firstname", nil);
            value = [[self tempAccount] firstName];
            break;
        case HEMNewAccountRowLastName:
            placeholderText = NSLocalizedString(@"onboarding.account.lastname", nil);
            value = [[self tempAccount] lastName];
            break;
        case HEMNewAccountRowEmail:
            placeholderText = NSLocalizedString(@"onboarding.account.email", nil);
            keyboardType = UIKeyboardTypeEmailAddress;
            value = [[self tempAccount] email];
            break;
        case HEMNewAccountRowPassword:
            placeholderText = NSLocalizedString(@"onboarding.account.password", nil);
            secure = YES;
            returnKeyType = UIReturnKeyDone;
            value = [self password];
            break;
    }
    
    [cell setPlaceholderText:placeholderText];
    [[cell textField] setSecurityEnabled:secure];
    [[cell textField] setText:value];
    [[cell textField] setTag:index];
    [[cell textField] setDelegate:self];
    [[cell textField] setReturnKeyType:returnKeyType];
    [[cell textField] setKeyboardType:keyboardType];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    switch ([textField tag]) {
        case HEMNewAccountRowFirstName: {
            NSIndexPath* namePath = [NSIndexPath indexPathForRow:[textField tag]
                                                       inSection:0];
            UICollectionViewCell* textCell =
                (id) [[self collectionView] cellForItemAtIndexPath:namePath];
            CGFloat topOfCell = CGRectGetMinY([textCell frame]);
            CGPoint topWithMargin = CGPointMake(0.0f, topOfCell - HEMNewAccountPresenterAutoScrollTopMargin);
            [[self collectionView] setContentOffset:topWithMargin animated:YES];
            break;
        }
        default:
            break;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch ([textField tag]) {
        case HEMNewAccountRowPassword:
            [self next:textField];
            break;
        default:
            [self putFocusOnTextFieldAtRow:[textField tag] + 1];
            break;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self updateValuesFromTextField:textField withText:nil];
    return YES;
}

- (void)updateValuesFromTextField:(UITextField*)textField withText:(NSString*)text {
    switch ([textField tag]) {
        default:
        case HEMNewAccountRowFirstName:
            [[self tempAccount] setFirstName:text ?: [[textField text] trim]];
            break;
        case HEMNewAccountRowLastName:
            [[self tempAccount] setLastName:text ?: [[textField text] trim]];
            break;
        case HEMNewAccountRowEmail:
            [[self tempAccount] setEmail:text ? : [[textField text] trim]];
            break;
        case HEMNewAccountRowPassword:
            [self setPassword:text ?: [textField text]];
            break;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* currenText = [textField text];
    NSString* changedText = [currenText stringByReplacingCharactersInRange:range withString:string];
    [self updateValuesFromTextField:textField withText:changedText];
    [[self nextButton] setEnabled:[[self onbService] hasRequiredFields:[self tempAccount] password:[self password]]];
    return YES;
}
             
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
        [UIView animateWithDuration:HEMNewAccountPresenterScrollDuration animations:^{
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

#pragma mark - Clean up

- (void)dealloc {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    
    if (_collectionView) {
        [_collectionView setDataSource:nil];
        [_collectionView setDelegate:nil];
    }
}

@end
