//
//  HEMChoiceViewController.m
//  Sense
//
//  Created by Jimmy Lu on 1/22/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMChoiceViewController.h"
#import "HEMSettingsTableViewCell.h"
#import "HEMMainStoryboard.h"

@interface HEMChoiceViewController() <
    UITableViewDataSource,
    UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *choiceTableView;

@end

@implementation HEMChoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTable];
}

- (void)configureTable {
    CGRect frame = CGRectZero;
    frame.size.height = HEMSettingsCellTableMargin;
    frame.size.width = CGRectGetWidth([[self choiceTableView] bounds]);
    
    [[self choiceTableView] setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
    [[self choiceTableView] setTableFooterView:[[UIView alloc] initWithFrame:frame]];
    [[self choiceTableView] setDataSource:self];
    [[self choiceTableView] setDelegate:self];
}

#pragma mark - UITableViewDataSource / UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self choices] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard choiceCellReuseIdentifier]];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    HEMSettingsTableViewCell* settingsCell = (HEMSettingsTableViewCell*)cell;
    NSInteger row = [indexPath row];
    
    [[settingsCell titleLabel] setText:[self choices][row]];
    [[settingsCell accessory] setHidden:[self selectedIndex] != row];
    [settingsCell setTag:row];

    if (row == 0) {
        [settingsCell showTopCorners];
    } else if (row == [[self choices] count] - 1) {
        [settingsCell showBottomCorners];
    } else {
        [settingsCell showNoCorners];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray* visibleCells = [tableView visibleCells];
    for (HEMSettingsTableViewCell* cell in visibleCells) {
        [[cell accessory] setHidden:[cell tag] != [indexPath row]];
    }
    [[self delegate] didSelectChoiceAtIndex:[indexPath row] from:self];
}

@end
