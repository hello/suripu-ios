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

static CGFloat const kHemUnitPrefSegControlWidth = 157;

@interface HEMUnitPreferenceViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *unitTableView;

@property (strong, nonatomic) IBOutlet UISegmentedControl* clockStyleSegmentControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl* temperatureSegmentControl;

@end

@implementation HEMUnitPreferenceViewController

- (void)viewDidLoad {
    self.title = NSLocalizedString(@"settings.units", nil);
    [super viewDidLoad];
    [[self unitTableView] setTableFooterView:[[UIView alloc] init]];
    [self setupClockControl];
    [self setupTemperatureControl];
}

- (void)setupClockControl {
    NSString* h24 = NSLocalizedString(@"settings.units.24-hour", nil);
    NSString* h12 = NSLocalizedString(@"settings.units.12-hour", nil);
    UISegmentedControl* clockControl = [[UISegmentedControl alloc] initWithItems:@[h24, h12]];
    [clockControl setSelectedSegmentIndex:[SENSettings timeFormat] == SENTimeFormat24Hour?0:1];
    [clockControl addTarget:self
                     action:@selector(clockFormatChanged:)
           forControlEvents:UIControlEventValueChanged];
    
    [self styleControl:clockControl];
    [self setClockStyleSegmentControl:clockControl];
}

- (void)setupTemperatureControl {
    NSString* celcius = NSLocalizedString(@"settings.units.celcius", nil);
    NSString* fahrenheit = NSLocalizedString(@"settings.units.fahrenheit", nil);
    NSInteger selectedIndex = [SENSettings temperatureFormat] == SENTemperatureFormatCentigrade?0:1;
    
    UISegmentedControl* tempControl = [[UISegmentedControl alloc] initWithItems:@[celcius, fahrenheit]];
    [tempControl setSelectedSegmentIndex:selectedIndex];
    [tempControl addTarget:self
                     action:@selector(temperatureFormatChanged:)
           forControlEvents:UIControlEventValueChanged];
    
    [self styleControl:tempControl];
    [self setTemperatureSegmentControl:tempControl];
}

- (void)styleControl:(UISegmentedControl*)control {
    [control setTintColor:[HelloStyleKit backViewTextColor]];
    [control setTitleTextAttributes:@{
                                NSFontAttributeName : [UIFont fontWithName:@"Agile-Light" size:18],
                                NSForegroundColorAttributeName : [HelloStyleKit backViewTextColor]
                           }
                           forState:UIControlStateNormal];
    
    CGRect controlFrame = [control frame];
    controlFrame.size.width = kHemUnitPrefSegControlWidth;
    [control setFrame:controlFrame];
}

#pragma mark - Actions

- (void)clockFormatChanged:(UISegmentedControl*)control {
    if ([control selectedSegmentIndex] == 0) {
        [SENSettings setTimeFormat:SENTimeFormat24Hour];
    } else {
        [SENSettings setTimeFormat:SENTimeFormat12Hour];
    }
}

- (void)temperatureFormatChanged:(UISegmentedControl*)control {
    if ([control selectedSegmentIndex] == 0) {
        [SENSettings setTemperatureFormat:SENTemperatureFormatCentigrade];
    } else {
        [SENSettings setTemperatureFormat:SENTemperatureFormatFahrenheit];
    }
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
    
    if ([[cell reuseIdentifier] isEqualToString:[HEMMainStoryboard unitCellReuseIdentifier]]) {
        UISegmentedControl* control = nil;
        NSString* title = nil;
        if ([indexPath row] == 0) {
            title = NSLocalizedString(@"settings.units.clock", nil);
            control = [self clockStyleSegmentControl];
        } else if ([indexPath row] == 1) {
            title = NSLocalizedString(@"settings.units.temp", nil);
            control = [self temperatureSegmentControl];
        }
        
        [[cell textLabel] setText:title];
        [[cell textLabel] setTextColor:[HelloStyleKit backViewTextColor]];
        [[cell textLabel] setFont:[UIFont settingsTitleFont]];
        [control setTitleTextAttributes:@{NSFontAttributeName:[UIFont settingsTableCellDetailFont]}
                               forState:UIControlStateNormal];
        
        [cell setAccessoryView:control];
    }
    
}

@end
