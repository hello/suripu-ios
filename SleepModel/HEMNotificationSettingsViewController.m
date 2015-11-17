//
//  HEMNotificationSettingsViewController.m
//  Sense
//
//  Created by Delisa Mason on 2/9/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENServiceAccount.h>
#import <SenseKit/SENPreference.h>

#import "UIColor+HEMStyle.h"

#import "HEMNotificationSettingsViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSettingsHeaderFooterView.h"

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
    [self configureTable];
    [self reload];
}

- (void)configureTable {
    UIView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    UIView* footer = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:YES bottomBorder:NO];
    [[self tableView] setTableHeaderView:header];
    [[self tableView] setTableFooterView:footer];
    [[self tableView] setSeparatorColor:[UIColor separatorColor]];
}

- (void)reload {
    __weak typeof(self) weakSelf = self;
    [[SENServiceAccount sharedService] refreshAccount:^(NSError *error) {
        [weakSelf.tableView reloadData];
    }];
}

- (IBAction)didFlipSwitch:(UISwitch*)sender {
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

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEMSettingsHeaderFooterHeightWithTitle;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString* title = [NSLocalizedString(@"settings.notifications.section.push", nil) uppercaseString];
    HEMSettingsHeaderFooterView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:YES];
    [header setTitle:title];
    return header;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return HEMNotificationRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard preferenceReuseIdentifier]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
    SENPreference* pref = [self preferenceAtIndex:row];
    
    UISwitch *preferenceSwitch = [UISwitch new];
    [preferenceSwitch setOn:[pref isEnabled]];
    [preferenceSwitch setTag:HEMNotificationTagOffset + row];
    [preferenceSwitch setOnTintColor:[UIColor tintColor]];
    [preferenceSwitch addTarget:self
                         action:@selector(didFlipSwitch:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell setAccessoryView:preferenceSwitch];
    [[cell textLabel] setText:[self titleAtIndexPath:indexPath]];
}

- (NSString*)titleAtIndexPath:(NSIndexPath*)indexPath {
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
