//
//  HEMExpansionsConfigViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/4/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENExpansion.h>

#import "HEMExpansionsConfigViewController.h"
#import "HEMConfigurationsPresenter.h"
#import "HEMExpansionService.h"
#import "HEMActionButton.h"

@interface HEMExpansionsConfigViewController () <HEMConfigurationsDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet HEMActionButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation HEMExpansionsConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    if (![self expansionService]) {
        [self setExpansionService:[HEMExpansionService new]];
    }
    
    HEMConfigurationsPresenter* presenter =
        [[HEMConfigurationsPresenter alloc] initWithConfigs:[self configs]
                                               forExpansion:[self expansion]
                                           expansionService:[self expansionService]];
    [presenter bindWithTitleLabel:[self titleLabel] descriptionLabel:[self descriptionLabel]];
    [presenter bindWithTableView:[self tableView]];
    [presenter bindWithActivityContainer:[[self navigationController] view]];
    [presenter bindWithDoneButton:[self finishButton]];
    [presenter bindWithSkipButton:[self skipButton]];
    [presenter setConfigDelegate:self];
    [presenter setConnectDelegate:[self connectDelegate]];

    [self addPresenter:presenter];
}

#pragma mark - HEMConfigurationsDelegate

- (void)dismissConfigurationFrom:(HEMConfigurationsPresenter *)presenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
