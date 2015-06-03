//
//  HEMFormViewController.m
//  Sense
//
//  Created by Jimmy Lu on 5/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMFormViewController.h"
#import "HEMFieldTableViewCell.h"
#import "HEMMainStoryboard.h"
#import "HEMAlertViewController.h"
#import "HEMActivityCoverView.h"

@interface HEMFormViewController () <UITableViewDataSource, UITableViewDelegate, HEMFieldTableViewCellDelegate>

@property (weak,   nonatomic) IBOutlet UITableView *formTableview;
@property (strong, nonatomic) NSMutableDictionary* formContent;
@property (assign, nonatomic, getter=isChanged) BOOL changed;

@end

@implementation HEMFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTitle];
    [self configureTableView];
}

- (void)configureTitle {
    if ([[self delegate] respondsToSelector:@selector(titleForForm:)]) {
        [self setTitle:[[self delegate] titleForForm:self]];
    }
}

- (void)configureTableView {
    [self setFormContent:[[NSMutableDictionary alloc] init]];
    
    CGRect frame = CGRectZero;
    frame.size.height = HEMSettingsCellTableMargin;
    [[self formTableview] setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
    
    [[self formTableview] setKeyboardDismissMode:UIScrollViewKeyboardDismissModeInteractive];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self forceFirstResponderToBeAtRowAtIndex:0];
}

- (void)forceFirstResponderToBeAtRowAtIndex:(NSInteger)index {
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    HEMFieldTableViewCell* cell = (id)[[self formTableview] cellForRowAtIndexPath:indexPath];
    [cell becomeFirstResponder];
}

#pragma mark - UITableViewDelegate / DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self delegate] numberOfFieldsIn:self];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard fieldCellReuseIdentifier]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    HEMFieldTableViewCell* fieldCell = (id)cell;
    [fieldCell setDelegate:self];
    [fieldCell setTag:[indexPath row]];
    
    NSString* placeHolderText = [[self delegate] placeHolderTextIn:self atIndex:[indexPath row]];
    [fieldCell setPlaceHolder:placeHolderText];
    
    if ([[self delegate] respondsToSelector:@selector(defaultTextIn:atIndex:)]) {
        NSString* currentText = [[self formContent] objectForKey:placeHolderText];
        [fieldCell setDefaultText: currentText ?: [[self delegate] defaultTextIn:self atIndex:[indexPath row]]];
    }

    if ([[self delegate] respondsToSelector:@selector(keyboardTypeForFieldIn:atIndex:)]) {
        [fieldCell setKeyboardType:[[self delegate] keyboardTypeForFieldIn:self atIndex:[indexPath row]]];
    }
    
    if ([[self delegate] respondsToSelector:@selector(shouldFieldBeSecureIn:atIndex:)]) {
        [fieldCell setSecure:[[self delegate] shouldFieldBeSecureIn:self atIndex:[indexPath row]]];
    }
    
    // update appearance of the cell
    BOOL firstRow = [indexPath row] == 0;
    BOOL lastRow = [indexPath row] == [[self delegate] numberOfFieldsIn:self] - 1;
    
    if (firstRow && lastRow) {
        [fieldCell showTopAndBottomCorners];
        [fieldCell setKeyboardReturnKeyType:UIReturnKeyDone];
    } else if (firstRow) {
        [fieldCell showTopCorners];
        [fieldCell setKeyboardReturnKeyType:UIReturnKeyNext];
    } else if (lastRow) {
        [fieldCell showBottomCorners];
        [fieldCell setKeyboardReturnKeyType:UIReturnKeyDone];
    } else {
        [fieldCell showNoCorners];
        [fieldCell setKeyboardReturnKeyType:UIReturnKeyNext];
    }
}

#pragma mark - Text changes / HEMFieldTableViewCellDelegate

- (void)didTapOnKeyboardReturnKeyFrom:(HEMFieldTableViewCell *)cell {
    NSInteger numberOfFields = [[self delegate] numberOfFieldsIn:self];
    BOOL lastRow = [cell tag] == numberOfFields - 1;
    if (lastRow) {
        [self saveChanges:self];
    } else {
        NSInteger nextIndex = ([cell tag] + 1) % numberOfFields;
        [self forceFirstResponderToBeAtRowAtIndex:nextIndex];
    }
}

- (void)didChangeTextTo:(NSString *)text from:(HEMFieldTableViewCell *)cell {
    [self setChanged:YES];
    [[self formContent] setValue:text forKey:[cell placeHolderText]];
}

#pragma mark - Errors

- (void)showErrorMessage:(NSString*)message {
    UIViewController* rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    HEMAlertViewController* dialogVC = [[HEMAlertViewController alloc] init];
    [dialogVC setTitle:[self title]];
    [dialogVC setMessage:message];
    [dialogVC setViewToShowThrough:[rootVC view]];
    
    [dialogVC showFrom:self onDefaultActionSelected:^{
        // don't weak reference this since controller must remain until it has
        // been dismissed
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - Actions

- (IBAction)saveChanges:(id)sender {
    if ([self isChanged]) {
        [[self view] endEditing:NO];
        
        UIViewController* rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] initWithFrame:[[rootVC view] bounds]];
        
        __weak typeof(self) weakSelf = self;
        NSString* activityText = NSLocalizedString(@"activity.saving.changes", nil);
        [activityView showInView:[rootVC view] withText:activityText activity:YES completion:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [[strongSelf delegate] saveFormContent:[strongSelf formContent] from:strongSelf completion:^(NSString* errorMessage) {
                if (errorMessage) {
                    [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                        [strongSelf showErrorMessage:errorMessage];
                    }];
                } else {
                    [[strongSelf navigationController] popViewControllerAnimated:NO];
                    NSString* successText = NSLocalizedString(@"status.success", nil);
                    [activityView dismissWithResultText:successText showSuccessMark:YES remove:YES completion:nil];
                }
            }];
        }];

    }
}

@end
