//
//  HEMUnitsViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSettings.h>

#import "HEMUnitsViewController.h"

@interface HEMUnitsViewController()

@property (weak, nonatomic) IBOutlet UISegmentedControl* clockStyleSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl* temperatureSegmentControl;
@property (strong, nonatomic) IBOutlet UITableView *unitsTableView;

@end

@implementation HEMUnitsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self unitsTableView] setTableFooterView:[[UIView alloc] init]];
    
    if ([SENSettings temperatureFormat] == SENTemperatureFormatCentigrade) {
        self.temperatureSegmentControl.selectedSegmentIndex = 0;
    } else {
        self.temperatureSegmentControl.selectedSegmentIndex = 1;
    }
    if ([SENSettings timeFormat] == SENTimeFormat24Hour) {
        self.clockStyleSegmentControl.selectedSegmentIndex = 0;
    } else {
        self.clockStyleSegmentControl.selectedSegmentIndex = 1;
    }
}

#pragma mark - SegmentedControl Toggles

- (IBAction)temperatureFormatChanged:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex == 0) {
        [SENSettings setTemperatureFormat:SENTemperatureFormatCentigrade];
    } else {
        [SENSettings setTemperatureFormat:SENTemperatureFormatFahrenheit];
    }
}

- (IBAction)clockStyleChanged:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex == 0) {
        [SENSettings setTimeFormat:SENTimeFormat24Hour];
    } else {
        [SENSettings setTimeFormat:SENTimeFormat12Hour];
    }
}

#pragma mark - UITableViewDelegate

@end
