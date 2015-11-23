//
//  HEMFormViewController.m
//  Sense
//
//  Created by Jimmy Lu on 5/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "UIColor+HEMStyle.h"

#import "HEMFormViewController.h"
#import "HEMSettingsHeaderFooterView.h"
#import "HEMFieldTableViewCell.h"
#import "HEMMainStoryboard.h"
#import "HEMAlertViewController.h"
#import "HEMActivityCoverView.h"

@interface HEMFormViewController () <UITableViewDataSource, UITableViewDelegate, HEMFieldTableViewCellDelegate>

@property (weak,   nonatomic) IBOutlet UITableView *formTableview;
@property (weak,   nonatomic) IBOutlet UIBarButtonItem *saveButtonItem;
@property (strong, nonatomic) NSMutableDictionary* formContent;
@property (assign, nonatomic) NSUInteger numberOfFields;

@end

@implementation HEMFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureTableView];
}

- (void)configureNavigationBar {
    if ([[self delegate] respondsToSelector:@selector(titleForForm:)]) {
        [self setTitle:[[self delegate] titleForForm:self]];
    }
    
    UIColor* disabledColor = [UIColor barButtonDisabledColor];
    NSDictionary* attributes = @{NSForegroundColorAttributeName : disabledColor};
    [[self saveButtonItem] setTitleTextAttributes:attributes
                                         forState:UIControlStateDisabled];
    [[self saveButtonItem] setEnabled:NO]; // disable to start since nothing has changed
}

- (void)configureTableView {
    [self setNumberOfFields:[[self delegate] numberOfFieldsIn:self]];
    [self setFormContent:[[NSMutableDictionary alloc] initWithCapacity:[self numberOfFields]]];
    
    UIView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:YES];
    UIView* footer = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:YES bottomBorder:NO];
    [[self formTableview] setTableHeaderView:header];
    [[self formTableview] setTableFooterView:footer];
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
    return [self numberOfFields];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard fieldCellReuseIdentifier]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    HEMFieldTableViewCell* fieldCell = (id)cell;
    [fieldCell setDelegate:self];
    [fieldCell setTag:[indexPath row]];
    
    UIImage* icon = [[self delegate] iconIn:self atIndex:[indexPath row]];
    [[fieldCell imageView] setImage:icon];
    
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

#pragma mark - Text changes / HEMFieldTableViewCellDelegate

- (void)didTapOnKeyboardReturnKeyFrom:(HEMFieldTableViewCell *)cell {
    BOOL lastRow = [cell tag] == [self numberOfFields] - 1;
    if (lastRow) {
        [self saveChanges:self];
    } else {
        NSInteger nextIndex = ([cell tag] + 1) % [self numberOfFields];
        [self forceFirstResponderToBeAtRowAtIndex:nextIndex];
    }
}

- (void)didChangeTextTo:(NSString *)text from:(HEMFieldTableViewCell *)cell {
    [[self formContent] setValue:([text length] > 0 ? text : nil) forKey:[cell placeHolderText]];
    [[self saveButtonItem] setEnabled:[[self formContent] count] == [self numberOfFields]];
}

#pragma mark - Errors
- (void)showErrorMessage:(NSString*)message {
    UIViewController* rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    HEMAlertViewController* dialogVC = [[HEMAlertViewController alloc] initWithTitle:self.title message:message];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.ok", nil) style:HEMAlertViewButtonStyleRoundRect action:nil];
    [dialogVC setViewToShowThrough:[rootVC view]];
    [dialogVC showFrom:self];
}

#pragma mark - Actions

- (IBAction)saveChanges:(id)sender {
    if ([[self saveButtonItem] isEnabled]) {
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
