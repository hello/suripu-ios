//
//  HEMUnitPreferenceViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/1/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSettings.h>

#import "UIFont+HEMStyle.h"

#import "HEMUnitPreferenceViewController.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"
#import "HEMSettingsTableViewCell.h"
#import "HEMChoiceViewController.h"

static NSUInteger const HEMUnitPreferenceTime = 0;
static NSUInteger const HEMUnitPreferenceTemp = 1;

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
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = [HEMMainStoryboard unitCellReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:cellId];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HEMSettingsTableViewCell* settingsCell = (HEMSettingsTableViewCell*)cell;
    NSString* title = nil;
    NSString* value = nil;
    NSInteger row = [indexPath row];
    BOOL showTopCorners = NO;
    BOOL showBotCorners = NO;
    
    if (row == HEMUnitPreferenceTime) {
        showTopCorners = YES;
        title = NSLocalizedString(@"settings.units.clock", nil);
        
        if ([SENSettings timeFormat] == SENTimeFormat24Hour) {
            value = NSLocalizedString(@"settings.units.24-hour", nil);
        } else {
            value = NSLocalizedString(@"settings.units.12-hour", nil);
        }
    } else if (row == HEMUnitPreferenceTemp) {
        showBotCorners = YES;
        title = NSLocalizedString(@"settings.units.temp", nil);
        
        if ([SENSettings temperatureFormat] == SENTemperatureFormatCentigrade) {
            value = NSLocalizedString(@"settings.units.celcius", nil);
        } else {
            value = NSLocalizedString(@"settings.units.fahrenheit", nil);
        }
    }
    
    [[settingsCell titleLabel] setText:title];
    [[settingsCell valueLabel] setText:value];
    
    if (showTopCorners) {
        [settingsCell showTopCorners];
    } else if (showBotCorners) {
        [settingsCell showBottomCorners];
    } else {
        [settingsCell showNoCorners];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setSelectedPath:indexPath];
    [self performSegueWithIdentifier:[HEMMainStoryboard choiceSegueIdentifier]
                              sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[HEMChoiceViewController class]]) {
        HEMChoiceViewController* choiceVC = [segue destinationViewController];
        NSInteger row = [[self selectedPath] row];
        NSArray* choices = nil;
        NSInteger selectedIndex = 0;
        NSString* title = nil;
        
        if (row == HEMUnitPreferenceTime) {
            title = NSLocalizedString(@"settings.units.clock", nil);
            choices = @[NSLocalizedString(@"settings.units.12-hour", nil),
                        NSLocalizedString(@"settings.units.24-hour", nil)];
            selectedIndex = [SENSettings timeFormat] == SENTimeFormat12Hour ? 0 : 1;
        } else if (row == HEMUnitPreferenceTemp) {
            title = NSLocalizedString(@"settings.units.temp", nil);
            choices = @[NSLocalizedString(@"settings.units.celcius", nil),
                        NSLocalizedString(@"settings.units.fahrenheit", nil)];
            selectedIndex = [SENSettings temperatureFormat] == SENTemperatureFormatCentigrade ? 0 : 1;
        }
        
        [choiceVC setDelegate:self];
        [choiceVC setChoices:choices];
        [choiceVC setSelectedIndex:selectedIndex];
        [choiceVC setTitle:title];
    }
}

#pragma mark - HEMChoiceDelegate

- (void)didSelectChoiceAtIndex:(NSUInteger)index from:(HEMChoiceViewController *)controller {
    NSInteger row = [[self selectedPath] row];
    if (row == HEMUnitPreferenceTime) {
        SENTimeFormat format
            = index == 0
            ? SENTimeFormat12Hour
            : SENTimeFormat24Hour;
        [SENSettings setTimeFormat:format];
    } else if (row == HEMUnitPreferenceTemp) {
        SENTemperatureFormat format
            = index == 0
            ? SENTemperatureFormatCentigrade
            : SENTemperatureFormatFahrenheit;
        [SENSettings setTemperatureFormat:format];
    }
    [[self unitTableView] reloadData];
}

@end
