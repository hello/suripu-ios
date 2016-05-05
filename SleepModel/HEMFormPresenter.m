//
//  HEMFormPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/21/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMFormPresenter.h"
#import "HEMSettingsHeaderFooterView.h"
#import "HEMFieldTableViewCell.h"
#import "HEMActivityCoverView.h"
#import "HEMRootViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMStyle.h"

@interface HEMFormPresenter() <UITableViewDataSource, UITableViewDelegate, HEMFieldTableViewCellDelegate>

@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) UIBarButtonItem* saveItem;
@property (nonatomic, strong) NSMutableDictionary* formContent;

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

- (void)bindWithTableView:(UITableView*)tableView {
    [self setFormContent:[NSMutableDictionary dictionary]];
    
    UIView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:YES];
    UIView* footer = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:YES bottomBorder:NO];
    [tableView setTableHeaderView:header];
    [tableView setTableFooterView:footer];
    [tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeInteractive];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [self setTableView:tableView];
}

- (void)forceFirstResponderToBeAtRowAtIndex:(NSInteger)index {
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    HEMFieldTableViewCell* cell = (id)[[self tableView] cellForRowAtIndexPath:indexPath];
    [cell becomeFirstResponder];
}

#pragma mark - Presenter events

- (void)didAppear {
    [super didAppear];
    [self forceFirstResponderToBeAtRowAtIndex:0];
}

#pragma mark - Placeholders

- (NSString*)existingTextForFieldInRow:(NSInteger)row {
    return nil;
}

- (UIImage*)iconForFieldInRow:(NSInteger)row {
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

- (void)saveContent:(NSDictionary*)content completion:(HEMFormSaveHandler)completion {
    completion (nil);
}

- (void)save {
    if ([[self saveItem] isEnabled]) {
        [[self tableView] endEditing:NO];
        
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

#pragma mark - Table View

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfFields];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard fieldCellReuseIdentifier]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    
    HEMFieldTableViewCell* fieldCell = (id)cell;
    [fieldCell setDelegate:self];
    [fieldCell setTag:row];
    
    [[fieldCell imageView] setImage:[self iconForFieldInRow:row]];
    
    NSString* placeHolderText = [self placeHolderTextForFieldInRow:row];
    [fieldCell setPlaceHolder:placeHolderText];
    
    NSString* currentText = [[self formContent] objectForKey:placeHolderText];
    [fieldCell setDefaultText: currentText ?: [self existingTextForFieldInRow:row]];
    
    [fieldCell setKeyboardType:[self keyboardTypeForFieldInRow:row]];
    [fieldCell setSecure:[self isFieldSecureInRow:row]];
    
    // update appearance of the cell
    BOOL firstRow = [indexPath row] == 0;
    BOOL lastRow = [indexPath row] == [self numberOfFields] - 1;
    
    if (firstRow && lastRow) {
        [fieldCell setKeyboardReturnKeyType:UIReturnKeyDone];
    } else if (firstRow) {
        [fieldCell setKeyboardReturnKeyType:UIReturnKeyNext];
    } else if (lastRow) {
        [fieldCell setKeyboardReturnKeyType:UIReturnKeyDone];
    } else {
        [fieldCell setKeyboardReturnKeyType:UIReturnKeyNext];
    }
}

#pragma mark - HEMFieldTableViewCellDelegate

- (void)didTapOnKeyboardReturnKeyFrom:(HEMFieldTableViewCell *)cell {
    BOOL lastRow = [cell tag] == [self numberOfFields] - 1;
    if (lastRow) {
        [self save];
    } else {
        NSInteger nextIndex = ([cell tag] + 1) % [self numberOfFields];
        [self forceFirstResponderToBeAtRowAtIndex:nextIndex];
    }
}

- (void)didChangeTextTo:(NSString *)text from:(HEMFieldTableViewCell *)cell {
    [[self formContent] setValue:([text length] > 0 ? text : nil) forKey:[cell placeHolderText]];
    [[self saveItem] setEnabled:[[self formContent] count] == [self numberOfFields]];
}

#pragma mark - Clean up

- (void)dealloc {
    [_tableView setDataSource:nil];
    [_tableView setDelegate:nil];
}

@end
