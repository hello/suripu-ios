//
//  HEMInfoViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/25/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMInfoViewController.h"
#import "HEMSettingsTableViewCell.h"
#import "HEMMainStoryboard.h"

@interface HEMInfoViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;

@end

@implementation HEMInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
}

- (void)configureTableView {
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    
    // header
    CGRect frame = CGRectZero;
    frame.size.height = 20.0f;
    frame.size.width = width;
    [[self infoTableView] setTableFooterView:[[UIView alloc] initWithFrame:frame]];
    
    
    [[self infoTableView] setDelegate:self];
    [[self infoTableView] setDataSource:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self infoSource] numberOfInfoSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self infoSource] numberOfInfoRowsInSection:section];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard infoCellReuseIdentifier]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {

    HEMSettingsTableViewCell *supportCell = (HEMSettingsTableViewCell *)cell;
    [[supportCell titleLabel] setText:[[self infoSource] infoTitleForIndexPath:indexPath]];
    [[supportCell valueLabel] setText:[[self infoSource] infoValueForIndexPath:indexPath]];
    
    NSInteger numberOfRows = [tableView numberOfRowsInSection:[indexPath section]];
    
    if ([indexPath row] == 0 && [indexPath row] == numberOfRows - 1) {
        [supportCell showTopAndBottomCorners];
    } else if ([indexPath row] == 0) {
        [supportCell showTopCorners];
    } else if ([indexPath row] == numberOfRows - 1) {
        [supportCell showBottomCorners];
    } else {
        [supportCell showNoCorners];
    }
    
}

#pragma mark - Actions

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Clean up

- (void)dealloc {
    [_infoTableView setDataSource:nil];
    [_infoTableView setDelegate:nil];
}

@end
