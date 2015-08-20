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

#import "HEMUnitPreferenceViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSettingsTableViewCell.h"
#import "HEMChoiceViewController.h"

static NSUInteger const HEMUnitPreferenceTime = 0;
static NSUInteger const HEMUnitPreferenceTemp = 1;
static NSUInteger const HEMUnitPreferenceWeight = 2;
static NSUInteger const HEMUnitPreferenceHeight = 3;

@interface HEMUnitPreferenceViewController () <
    UITableViewDataSource,
    UITableViewDelegate,
    HEMChoiceDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *unitTableView;
@property (copy, nonatomic) NSIndexPath* selectedPath;

@end

@implementation HEMUnitPreferenceViewController

- (void)viewDidLoad {
    self.title = NSLocalizedString(@"settings.units", nil);
    [super viewDidLoad];
    [self configureTable];
    [SENAnalytics track:kHEMAnalyticsEventUnitsNTime];
}

- (void)configureTable {
    CGRect frame = CGRectZero;
    frame.size.height = HEMSettingsCellTableMargin;
    frame.size.width = CGRectGetWidth([[self unitTableView] bounds]);
    
    [[self unitTableView] setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
    [[self unitTableView] setTableFooterView:[[UIView alloc] initWithFrame:frame]];
    [[self unitTableView] setDataSource:self];
    [[self unitTableView] setDelegate:self];
}

#pragma mark - UITableViewDelegate / DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = [HEMMainStoryboard unitCellReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:cellId];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(HEMSettingsTableViewCell*)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCornersForCell:cell atIndexPath:indexPath];
    switch (indexPath.row) {
        case HEMUnitPreferenceTime:
            [self configureTimeSettingCell:cell];
            break;
        case HEMUnitPreferenceTemp:
            [self configureTemperatureSettingCell:cell];
            break;
        case HEMUnitPreferenceHeight:
            [self configureForHeightSettingCell:cell];
            break;
        case HEMUnitPreferenceWeight:
            [self configureWeightSettingCell:cell];
            break;
    }
}

- (void)configureCornersForCell:(HEMSettingsTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row == 0) {
        [cell showTopCorners];
    } if (indexPath.row == [self tableView:nil numberOfRowsInSection:indexPath.section] - 1) {
        [cell showBottomCorners];
    } else {
        [cell showNoCorners];
    }
}

- (void)configureTimeSettingCell:(HEMSettingsTableViewCell*)cell {
    [[cell titleLabel] setText:NSLocalizedString(@"settings.units.clock", nil)];
    if ([SENPreference timeFormat] == SENTimeFormat24Hour)
        cell.valueLabel.text = NSLocalizedString(@"settings.units.24-hour", nil);
    else
        cell.valueLabel.text = NSLocalizedString(@"settings.units.12-hour", nil);
}

- (void)configureWeightSettingCell:(HEMSettingsTableViewCell*)cell {
    [[cell titleLabel] setText:NSLocalizedString(@"settings.units.weight", nil)];
    if ([SENPreference useMetricUnitForWeight])
        cell.valueLabel.text = NSLocalizedString(@"settings.units.kilograms", nil);
    else
        cell.valueLabel.text = NSLocalizedString(@"settings.units.pounds", nil);
}

- (void)configureForHeightSettingCell:(HEMSettingsTableViewCell*)cell {
    [[cell titleLabel] setText:NSLocalizedString(@"settings.units.height", nil)];
    if ([SENPreference useMetricUnitForHeight])
        cell.valueLabel.text = NSLocalizedString(@"settings.units.centimeters", nil);
    else
        cell.valueLabel.text = NSLocalizedString(@"settings.units.feet", nil);
}

- (void)configureTemperatureSettingCell:(HEMSettingsTableViewCell*)cell {
    [[cell titleLabel] setText:NSLocalizedString(@"settings.units.temp", nil)];
    if ([SENPreference temperatureFormat] == SENTemperatureFormatCentigrade)
        cell.valueLabel.text = NSLocalizedString(@"settings.units.celsius", nil);
    else
        cell.valueLabel.text = NSLocalizedString(@"settings.units.fahrenheit", nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setSelectedPath:indexPath];
    [self performSegueWithIdentifier:[HEMMainStoryboard choiceSegueIdentifier]
                              sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[HEMChoiceViewController class]]) {
        HEMChoiceViewController* choiceVC = [segue destinationViewController];
        [self configureChoiceViewController:choiceVC withRow:[[self selectedPath] row]];
        [choiceVC setDelegate:self];
    }
}

- (void)configureChoiceViewController:(HEMChoiceViewController*)controller withRow:(NSUInteger)row {
    switch (row) {
        case HEMUnitPreferenceTime: {
            controller.title = NSLocalizedString(@"settings.units.clock", nil);
            controller.choices = @[NSLocalizedString(@"settings.units.12-hour", nil),
                                   NSLocalizedString(@"settings.units.24-hour", nil)];
            controller.selectedIndex = [SENPreference timeFormat] == SENTimeFormat12Hour ? 0 : 1;
        } break;
        case HEMUnitPreferenceTemp: {
            controller.title = NSLocalizedString(@"settings.units.temp", nil);
            controller.choices = @[NSLocalizedString(@"settings.units.celsius", nil),
                        NSLocalizedString(@"settings.units.fahrenheit", nil)];
            controller.selectedIndex = [SENPreference temperatureFormat] == SENTemperatureFormatCentigrade ? 0 : 1;
        } break;
        case HEMUnitPreferenceHeight: {
            controller.title = NSLocalizedString(@"settings.units.height", nil);
            controller.choices = @[NSLocalizedString(@"settings.units.feet", nil),
                                   NSLocalizedString(@"settings.units.centimeters", nil)];
            controller.selectedIndex = [SENPreference useMetricUnitForHeight] ? 1 : 0;
        } break;
        case HEMUnitPreferenceWeight: {
            controller.title = NSLocalizedString(@"settings.units.weight", nil);
            controller.choices = @[NSLocalizedString(@"settings.units.pounds", nil),
                                   NSLocalizedString(@"settings.units.kilograms", nil)];
            controller.selectedIndex = [SENPreference useMetricUnitForWeight] ? 1 : 0;
        } break;
    }
}

#pragma mark - HEMChoiceDelegate

- (void)didSelectChoiceAtIndex:(NSUInteger)index from:(HEMChoiceViewController *)controller {
    switch ([[self selectedPath] row]) {
        case HEMUnitPreferenceTime:
            [self updatePreference:SENPreferenceTypeTime24 withValue:index != 0];
            break;
        case HEMUnitPreferenceTemp:
            [self updatePreference:SENPreferenceTypeTempCelcius withValue:index == 0];
            break;
        case HEMUnitPreferenceHeight:
            [self updatePreference:SENPreferenceTypeHeightMetric withValue:index != 0];
            break;
        case HEMUnitPreferenceWeight:
            [self updatePreference:SENPreferenceTypeWeightMetric withValue:index != 0];
            break;
    }
    [[self unitTableView] reloadData];
}

- (void)updatePreference:(SENPreferenceType)type withValue:(BOOL)isEnabled {
    SENPreference* preference = [[SENPreference alloc] initWithType:type enable:isEnabled];
    [[SENServiceAccount sharedService] updatePreference:preference completion:nil];
}

@end
