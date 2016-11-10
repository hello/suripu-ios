//
//  HEMAlarmExpansionSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/20/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENExpansion.h>

#import "HEMAlarmExpansionSetupViewController.h"
#import "HEMAlarmExpansionSetupPresenter.h"
#import "HEMExpansionService.h"
#import "HEMTutorial.h"

@interface HEMAlarmExpansionSetupViewController() <
    HEMAlarmExpansionActionDelegate,
    HEMPresenterErrorDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HEMAlarmExpansionSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    [[self presenter] setActionDelegate:self];
    [[self presenter] bindWithTableView:[self tableView]];
    [[self presenter] bindWithNavigationItem:[self navigationItem]];
    [[self presenter] bindWithShadowView:[self shadowView]];
    [[self presenter] setErrorDelegate:self];
    [self addPresenter:[self presenter]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self presenter] bindWithActivityContainerView:[[self navigationController] view]];
}

#pragma mark - HEMPresenterErrorDelegate

- (void)showErrorWithTitle:(NSString *)title
                andMessage:(NSString *)message
              withHelpPage:(NSString *)helpPage
             fromPresenter:(HEMPresenter *)presenter {
    [self showMessageDialog:message title:title];
}

#pragma mark - HEMAlarmExpansionActionDelegate

- (void)showLightsExpansionInfoFrom:(HEMAlarmExpansionSetupPresenter*)presenter {
    [HEMTutorial showInfoForAlarmLightsSetupFrom:[self navigationController]];
}

- (void)showThermostatExpansionInfoFrom:(HEMAlarmExpansionSetupPresenter*)presenter {
    [HEMTutorial showInfoForAlarmThermostatSetupFrom:[self navigationController]];
}

- (void)showController:(UIViewController *)controller
         fromPresenter:(HEMAlarmExpansionSetupPresenter *)presenter {
    [self presentViewController:controller animated:YES completion:nil];
}

@end
