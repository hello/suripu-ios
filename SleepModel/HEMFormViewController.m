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
    
    NSString* placeHolderText = [[self delegate] placeHolderTextIn:self atIndex:[indexPath row]];
    NSString* currentText = [[self formContent] objectForKey:placeHolderText];
    
    [fieldCell setDefaultText: currentText ?: [[self delegate] defaultTextIn:self atIndex:[indexPath row]]];
    [fieldCell setPlaceHolder:placeHolderText];
    
    // update appearance of the cell
    BOOL firstRow = [indexPath row] == 0;
    BOOL lastRow = [indexPath row] == [[self delegate] numberOfFieldsIn:self] - 1;
    
    if (firstRow && lastRow) {
        [fieldCell showTopAndBottomCorners];
    } else if (firstRow) {
        [fieldCell showTopCorners];
    } else if (lastRow) {
        [fieldCell showBottomCorners];
    } else {
        [fieldCell showNoCorners];
    }
}

#pragma mark - Text changes

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
        __weak typeof(self) weakSelf = self;
        [[self delegate] saveFormContent:[self formContent] from:self completion:^(NSString* errorMessage) {
            if (errorMessage) {
                [weakSelf showErrorMessage:errorMessage];
            } else {
                [[weakSelf navigationController] popViewControllerAnimated:YES];
            }
        }];
    }
}

@end
