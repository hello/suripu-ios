//
//  HEMUnitPreferenceViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/1/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENPreference.h>
#import <SenseKit/SENServiceAccount.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

#import "HEMUnitPreferenceViewController.h"
#import "HEMSettingsHeaderFooterView.h"
#import "HEMMainStoryboard.h"

typedef NS_ENUM(NSInteger, HEMUnitSection) {
    HEMUnitSectionTime = 0,
    HEMUnitSectionTemp = 1,
    HEMUnitSectionWeight = 2,
    HEMUnitSectionHeight = 3,
    HEMUnitSectionTotal = 4
};

@interface HEMUnitPreferenceViewController () <
    UITableViewDataSource,
    UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *unitTableView;

@end

@implementation HEMUnitPreferenceViewController

- (void)viewDidLoad {
    self.title = NSLocalizedString(@"settings.units", nil);
    [super viewDidLoad];
    [self configureTable];
    [SENAnalytics track:kHEMAnalyticsEventUnitsNTime];
}

- (void)configureTable {
    UIView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    UIView* footer = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    
    [[self unitTableView] setTableHeaderView:header];
    [[self unitTableView] setTableFooterView:footer];
    [[self unitTableView] setDataSource:self];
    [[self unitTableView] setDelegate:self];
}

- (NSString*)sectionTitleForSection:(NSInteger)section {
    switch (section) {
        case HEMUnitSectionTime:
            return NSLocalizedString(@"settings.units.clock", nil);
        case HEMUnitSectionTemp:
            return NSLocalizedString(@"settings.units.temp", nil);
        case HEMUnitSectionWeight:
            return NSLocalizedString(@"settings.units.weight", nil);
        case HEMUnitSectionHeight:
            return NSLocalizedString(@"settings.units.height", nil);
        default:
            return nil;
    }
}

- (void)updatePreference:(SENPreferenceType)type withValue:(BOOL)isEnabled {
    SENPreference* preference = [[SENPreference alloc] initWithType:type enable:isEnabled];
    [[SENServiceAccount sharedService] updatePreference:preference completion:nil];
}

#pragma mark - UITableViewDelegate / DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return HEMUnitSectionTotal;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEMSettingsHeaderFooterHeightWithTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return HEMSettingsHeaderFooterHeight;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HEMSettingsHeaderFooterView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    [header setTitle:[[self sectionTitleForSection:section] uppercaseString]];
    return header;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = [HEMMainStoryboard unitCellReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:cellId];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell*)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIImageView* toggleView = (id) [cell accessoryView];
    if (!toggleView) {
        [cell setAccessoryView:[self unitToggleAccessoryView:NO]];
    }
    
    [[cell textLabel] setFont:[UIFont settingsTableCellFont]];
    [[cell textLabel] setTextColor:[UIColor settingsCellTitleTextColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    switch ([indexPath section]) {
        case HEMUnitSectionTime:
            [self configureTimeSettingCell:cell forIndexPath:indexPath];
            break;
        case HEMUnitSectionTemp:
            [self configureTemperatureSettingCell:cell forIndexPath:indexPath];
            break;
        case HEMUnitSectionWeight:
            [self configureWeightSettingCell:cell forIndexPath:indexPath];
            break;
        case HEMUnitSectionHeight:
            [self configureHeightSettingCell:cell forIndexPath:indexPath];
            break;
    }
}

- (UIImageView*)unitToggleAccessoryView:(BOOL)selected {
    UIImage* activeToggleImage = [UIImage imageNamed:@"settingsToggleIconActive"];
    UIImage* inactiveToggleImage = [UIImage imageNamed:@"settingsToggleIconInactive"];
    UIImageView* toggleView = [[UIImageView alloc] initWithImage:inactiveToggleImage
                                                highlightedImage:activeToggleImage];
    
    CGRect toggleFrame = CGRectZero;
    toggleFrame.size = [activeToggleImage size];
    [toggleView setFrame:toggleFrame];
    
    [toggleView setHighlighted:selected];
    
    return toggleView;
}

- (void)configureTimeSettingCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)path {
    NSInteger row = [path row];
    UIImageView* toggleView = (id) [cell accessoryView];

    if (row == 0) {
        [[cell textLabel] setText:NSLocalizedString(@"settings.units.12-hour", nil)];
        [toggleView setHighlighted:[SENPreference timeFormat] != SENTimeFormat24Hour];
    } else {
        [[cell textLabel] setText:NSLocalizedString(@"settings.units.24-hour", nil)];
        [toggleView setHighlighted:[SENPreference timeFormat] == SENTimeFormat24Hour];
    }
}

- (void)configureWeightSettingCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)path  {
    NSInteger row = [path row];
    UIImageView* toggleView = (id) [cell accessoryView];

    if (row == 0) {
        [[cell textLabel] setText:NSLocalizedString(@"settings.units.pounds", nil)];
        [toggleView setHighlighted:[SENPreference useMetricUnitForWeight]];
    } else {
        [[cell textLabel] setText:NSLocalizedString(@"settings.units.kilograms", nil)];
        [toggleView setHighlighted:![SENPreference useMetricUnitForWeight]];
    }
}

- (void)configureHeightSettingCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)path  {
    NSInteger row = [path row];
    UIImageView* toggleView = (id) [cell accessoryView];
    
    if (row == 0) {
        [[cell textLabel] setText:NSLocalizedString(@"settings.units.feet", nil)];
        [toggleView setHighlighted:[SENPreference useMetricUnitForHeight]];
    } else {
        [[cell textLabel] setText:NSLocalizedString(@"settings.units.centimeters", nil)];
        [toggleView setHighlighted:![SENPreference useMetricUnitForHeight]];
    }
}

- (void)configureTemperatureSettingCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)path  {
    NSInteger row = [path row];
    UIImageView* toggleView = (id) [cell accessoryView];
    
    if (row == 0) {
        [[cell textLabel] setText:NSLocalizedString(@"settings.units.celsius", nil)];
        [toggleView setHighlighted:[SENPreference useCentigrade]];
    } else {
        [[cell textLabel] setText:NSLocalizedString(@"settings.units.fahrenheit", nil)];
        [toggleView setHighlighted:![SENPreference useCentigrade]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    NSInteger sec = [indexPath section];
    
    switch (sec) {
        case HEMUnitSectionTime:
            [self updatePreference:SENPreferenceTypeTime24 withValue:row != 0];
            break;
        case HEMUnitSectionTemp:
            [self updatePreference:SENPreferenceTypeTempCelcius withValue:row == 0];
            break;
        case HEMUnitSectionWeight:
            [self updatePreference:SENPreferenceTypeWeightMetric withValue:row == 0];
            break;
        case HEMUnitSectionHeight:
            [self updatePreference:SENPreferenceTypeHeightMetric withValue:row == 0];
            break;
        default:
            break;
    }
    
    // prevent reloading section headers as well
    NSIndexPath* firstPath = [NSIndexPath indexPathForRow:0 inSection:sec];
    NSIndexPath* secondPath = [NSIndexPath indexPathForRow:1 inSection:sec];
    [tableView reloadRowsAtIndexPaths:@[firstPath, secondPath]
                     withRowAnimation:UITableViewRowAnimationNone];
    
}

@end
