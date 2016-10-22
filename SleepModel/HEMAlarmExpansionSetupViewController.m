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

@interface HEMAlarmExpansionSetupViewController() <HEMAlarmExpansionActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HEMAlarmExpansionSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    if (![self expansionService]) {
        [self setExpansionService:[HEMExpansionService new]];
    }
    HEMAlarmExpansionSetupPresenter* presenter =
    [[HEMAlarmExpansionSetupPresenter alloc] initWithExpansion:[self expansion]
                                                alarmExpansion:[self alarmExpansion]
                                              expansionService:[self expansionService]];
    [presenter setDelegate:[self setupDelegate]];
    [presenter setActionDelegate:self];
    [presenter bindWithTableView:[self tableView]];
    [presenter bindWithNavigationItem:[self navigationItem]];
    [presenter bindWithShadowView:[self shadowView]];
    [self addPresenter:presenter];
}

#pragma mark - HEMAlarmExpansionActionDelegate

- (void)showExpansionInfoFrom:(HEMAlarmExpansionSetupPresenter *)presenter {
    [HEMTutorial showInfoForExpansionFrom:[self navigationController]];
}

- (void)showController:(UIViewController *)controller
         fromPresenter:(HEMAlarmExpansionSetupPresenter *)presenter {
    [self presentViewController:controller animated:YES completion:nil];
}

@end
