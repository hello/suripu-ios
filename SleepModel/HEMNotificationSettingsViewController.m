//
//  HEMNotificationSettingsViewController.m
//  Sense
//
//  Created by Delisa Mason on 2/9/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENServiceAccount.h>
#import <SenseKit/SENPreference.h>

#import "HEMNotificationSettingsViewController.h"
#import "HEMSettingsTableViewCell.h"
#import "HEMMainStoryboard.h"

typedef NS_ENUM(NSUInteger, HEMNotificationRow) {
    HEMNotificationRowConditionIndex = 0,
    HEMNotificationRowScoreIndex = 1,
    HEMNotificationRowCount = 2
};

@interface HEMNotificationSettingsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@end

@implementation HEMNotificationSettingsViewController

static NSUInteger const HEMNotificationTagOffset = 191883;

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    [[SENServiceAccount sharedService] refreshAccount:^(NSError *error) {
        [weakSelf.tableView reloadData];
    }];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = [UIView new];
}

- (IBAction)didFlipSwitch:(UISwitch*)sender
{
    BOOL isOn = [sender isOn];
    NSUInteger row = sender.tag - HEMNotificationTagOffset;
    SENPreference* preference = [self preferenceAtIndex:row];
    if (!preference)
        return;
    [preference setEnabled:isOn];
    [[SENServiceAccount sharedService] updatePreference:preference completion:^(NSError *error) {
        if (error) {
            sender.on = !isOn;
        }
    }];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - UITableViewDataSource

- (SENPreference*)preferenceAtIndex:(NSUInteger)row
{
    SENServiceAccount* service = [SENServiceAccount sharedService];
    SENPreferenceType type = [self preferenceTypeAtIndex:row];
    return [[service preferences] objectForKey:@(type)];
}

- (SENPreferenceType)preferenceTypeAtIndex:(NSUInteger)row
{
    switch (row) {
        case HEMNotificationRowConditionIndex:
            return SENPreferenceTypePushConditions;
        case HEMNotificationRowScoreIndex:
            return SENPreferenceTypePushScore;
        default:
            return SENPreferenceTypeUnknown;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return HEMNotificationRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HEMSettingsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard preferenceReuseIdentifier]];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(HEMSettingsTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSUInteger row = indexPath.row;
    SENPreference* pref = [self preferenceAtIndex:row];
    UISwitch* prefSwitch = (id)cell.accessory;
    prefSwitch.hidden = NO;
    prefSwitch.on = [pref isEnabled];
    prefSwitch.tag = HEMNotificationTagOffset + row;
    cell.titleLabel.text = [self titleAtIndexPath:indexPath];
    [self layoutCornersOnCell:cell forRow:row];
}

- (void)layoutCornersOnCell:(HEMSettingsTableViewCell*)cell forRow:(NSUInteger)row
{
    if (row == 0) {
        [cell showTopCorners];
    } else if (row == HEMNotificationRowCount - 1) {
        [cell showBottomCorners];
    } else {
        [cell showNoCorners];
    }
}

- (NSString*)titleAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.row) {
        case HEMNotificationRowConditionIndex:
            return NSLocalizedString(@"settings.account.push-conditions", nil);
            break;
        case HEMNotificationRowScoreIndex:
            return NSLocalizedString(@"settings.account.push-score", nil);
        default:
            return nil;
    }
}

@end
