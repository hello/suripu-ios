//
//  HEMFormPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/21/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import "NSString+HEMUtils.h"

#import "HEMFormPresenter.h"
#import "HEMTextFieldCollectionViewCell.h"
#import "HEMActivityCoverView.h"
#import "HEMRootViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMTitledTextField.h"
#import "HEMSimpleLineTextField.h"
#import "HEMStyle.h"

static CGFloat const HEMFormCellHeight = 72.0f;
static CGFloat const HEMFormCellSideMargins = 24.0f;
static CGFloat const HEMFormAutoScrollDuration = 0.15f;

@interface HEMFormPresenter() <
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UITextFieldDelegate
>

@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak) UIBarButtonItem* saveItem;
@property (nonatomic, strong) NSMutableDictionary* formContent;
@property (nonatomic, assign) CGFloat origBottomMargin;
@property (nonatomic, weak) NSLayoutConstraint* bottomConstraint;

@end

@implementation HEMFormPresenter

- (void)bindWithSaveItem:(UIBarButtonItem*)saveItem {
    UIColor* disabledColor = [UIColor disabledColor];
    NSDictionary* attributes = @{NSForegroundColorAttributeName : disabledColor};
    [saveItem setTitleTextAttributes:attributes
                                         forState:UIControlStateDisabled];
    [saveItem setEnabled:NO]; // disable to start since nothing has changed
    [saveItem setTarget:self];
    [saveItem setAction:@selector(save)];
    [self setSaveItem:saveItem];
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView
              bottomConstraint:(NSLayoutConstraint*)bottomConstraint {
    [self setFormContent:[NSMutableDictionary dictionary]];
    
    [collectionView setBackgroundColor:[UIColor whiteColor]];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(willShowKeyboard:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    
    [self setOrigBottomMargin:[bottomConstraint constant]];
    [self setBottomConstraint:bottomConstraint];
    [self setCollectionView:collectionView];
}

#pragma mark - Keyboard events

- (void)willShowKeyboard:(NSNotification*)note {
    NSValue* keyboardFrameVal = [[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSNumber* duration = [[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameVal CGRectValue];
    CGFloat reduceBottom = CGRectGetHeight(keyboardFrame) + [self origBottomMargin];
    [[self bottomConstraint] setConstant:reduceBottom];
    
    [UIView animateWithDuration:[duration CGFloatValue] animations:^{
        [[[self collectionView] superview] layoutIfNeeded];
    }];
}

#pragma mark - Presenter events

- (void)didAppear {
    [super didAppear];
    // TODO: handle keyboard
    [self putFocusOnTextFieldAtRow:0]; // first field
}

#pragma mark - Placeholders

- (NSString*)existingTextForFieldInRow:(NSInteger)row {
    return nil;
}

- (NSString*)placeHolderTextForFieldInRow:(NSInteger)row {
    return nil;
}

- (UIKeyboardType)keyboardTypeForFieldInRow:(NSInteger)row {
    return UIKeyboardTypeDefault;
}

- (BOOL)isFieldSecureInRow:(NSInteger)row {
    return NO;
}

- (BOOL)canEnableSave:(NSDictionary*)formContent {
    return [formContent count] == [self numberOfFields];
}

- (void)saveContent:(NSDictionary*)content completion:(HEMFormSaveHandler)completion {
    completion (nil);
}

- (void)save {
    if ([[self saveItem] isEnabled]) {
        [[self collectionView] endEditing:NO];
        
        __weak typeof(self) weakSelf = self;
        
        HEMRootViewController* rootVC = [HEMRootViewController rootViewControllerForKeyWindow];
        HEMActivityCoverView* activityView = [HEMActivityCoverView new];
        NSString* activityText = NSLocalizedString(@"activity.saving.changes", nil);
        
        [activityView showInView:[rootVC view] withText:activityText activity:YES completion:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf saveContent:[strongSelf formContent] completion:^(NSString * _Nullable errorMessage) {
                if (errorMessage) {
                    [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                        [[strongSelf delegate] showErrorTitle:[self title] message:errorMessage fromPresenter:strongSelf];
                    }];
                } else {
                    [[strongSelf delegate] dismissFrom:strongSelf];
                    NSString* successText = NSLocalizedString(@"status.success", nil);
                    [activityView dismissWithResultText:successText showSuccessMark:YES remove:YES completion:nil];
                }
            }];
        }];
    }
}

#pragma mark - UICollectionView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout* verticalLayout = (id)collectionViewLayout;
    CGSize itemSize = [verticalLayout itemSize];
    itemSize.width = CGRectGetWidth([collectionView bounds]) - (HEMFormCellSideMargins * 2);
    itemSize.height = HEMFormCellHeight;
    return itemSize;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:[HEMMainStoryboard fieldReuseIdentifier]
                                                     forIndexPath:indexPath];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfFields];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = [indexPath row];
    HEMTextFieldCollectionViewCell* fieldCell = (id) cell;
    HEMSimpleLineTextField* textField = [fieldCell textField];

    NSString* placeholderText = [self placeHolderTextForFieldInRow:row];
    [fieldCell setPlaceholderText:[self placeHolderTextForFieldInRow:row]];
    
    NSString* currentText = [[self formContent] objectForKey:placeholderText];
    [textField setText:currentText ?: [self existingTextForFieldInRow:row]];
    
    BOOL firstRow = [indexPath row] == 0;
    BOOL lastRow = [indexPath row] == [self numberOfFields] - 1;
    if (firstRow && lastRow) {
        [textField setReturnKeyType:UIReturnKeyDone];
    } else if (firstRow) {
        [textField setReturnKeyType:UIReturnKeyNext];
    } else if (lastRow) {
        [textField setReturnKeyType:UIReturnKeyDone];
    } else {
        [textField setReturnKeyType:UIReturnKeyNext];
    }

    [textField setSecurityEnabled:[self isFieldSecureInRow:row]];
    [textField setDelegate:self];
    [textField setTag:row];
    [textField setKeyboardType:[self keyboardTypeForFieldInRow:row]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger row = [textField tag];
    BOOL lastRow = row == [self numberOfFields] - 1;
    
    if (lastRow) {
        [self save];
    } else {
        [self putFocusOnTextFieldAtRow:row + 1];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self updateValuesFromTextField:textField withText:nil];
    return YES;
}

- (void)updateValuesFromTextField:(UITextField*)textField withText:(NSString*)text {
    NSInteger row = [textField tag];
    NSString* placeholderText = [self placeHolderTextForFieldInRow:row];
    NSString* contentInField = [[textField text] trim];
    NSString* formValue = text ?: contentInField;
    [[self formContent] setValue:([formValue length] > 0 ? formValue : nil) forKey:placeholderText];
    [[self saveItem] setEnabled:[self canEnableSave:[self formContent]]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* currenText = [textField text];
    NSString* changedText = [currenText stringByReplacingCharactersInRange:range withString:string];
    [self updateValuesFromTextField:textField withText:changedText];
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
        [UIView animateWithDuration:HEMFormAutoScrollDuration animations:^{
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_collectionView setDataSource:nil];
    [_collectionView setDelegate:nil];
}

@end
