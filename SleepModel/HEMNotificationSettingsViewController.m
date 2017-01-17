//
//  HEMNotificationSettingsViewController.m
//  Sense
//
//  Created by Delisa Mason on 2/9/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENPreference.h>

#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"

#import "HEMNotificationSettingsViewController.h"
#import "HEMSettingsStoryboard.h"
#import "HEMSettingsHeaderFooterView.h"
#import "HEMAccountService.h"

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
    UIView* footer = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    [[self tableView] setTableHeaderView:header];
    [[self tableView] setTableFooterView:footer];
}

- (void)reload {
    __weak typeof(self) weakSelf = self;
    HEMAccountService* service = [HEMAccountService sharedService];
    [service refresh:^(SENAccount * _Nullable account, NSDictionary<NSNumber *,SENPreference *> * _Nullable preferences) {
        [weakSelf.tableView reloadData];
    }];
}

- (IBAction)didFlipSwitch:(UISwitch*)sender {
    BOOL isOn = [sender isOn];
    NSUInteger row = sender.tag - HEMNotificationTagOffset;
    SENPreference* preference = [self preferenceAtIndex:row];
    HEMAccountService* service = [HEMAccountService sharedService];
    
    __weak typeof(self) weakSelf = self;
    void(^update)(void) = ^{
        [service enablePreference:isOn forType:[preference type] completion:^(NSError * error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                sender.on = !isOn;
                [strongSelf showError];
            }
        }];
    };
    
    if (!preference) {
        [service refresh:^(SENAccount * account, NSDictionary<NSNumber *,SENPreference *> * preferences) {
            update();
        }];
        return;
    } else {
        update();
    }
}

#pragma mark - Errors

- (void)showError {
    [self showMessageDialog:NSLocalizedString(@"settings.notification.error.update-failed-message", nil)
                      title:NSLocalizedString(@"settings.notification.error.title", nil)];
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
    HEMSettingsHeaderFooterView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    [header setTitle:title];
    return header;
}

#pragma mark - UITableViewDataSource

- (SENPreference*)preferenceAtIndex:(NSUInteger)row {
    HEMAccountService* service = [HEMAccountService sharedService];
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
    return [tableView dequeueReusableCellWithIdentifier:[HEMSettingsStoryboard preferenceReuseIdentifier]];
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
    [[cell textLabel] setTextColor:[UIColor textColor]];
    [[cell textLabel] setFont:[UIFont settingsTableCellFont]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[self shadowView] updateVisibilityWithContentOffset:[scrollView contentOffset].y];
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
