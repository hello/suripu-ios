//
//  HEMTimeZoneViewController.m
//  Sense
//
//  Created by Jimmy Lu on 3/17/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTimeZoneViewController.h"
#import "HEMTimeZonePresenter.h"
#import "HEMTimeZoneService.h"

@interface HEMTimeZoneViewController()

@property (weak,   nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) HEMTimeZoneService* service;

@end

@implementation HEMTimeZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureService];
    [self configurePresenter];
    [SENAnalytics track:HEMAnalyticsEventTimeZone];
}

- (void)configureService {
    [self setService:[HEMTimeZoneService new]];
}

- (void)configurePresenter {
    HEMTimeZonePresenter* presenter = [[HEMTimeZonePresenter alloc] initWithService:[self service]
                                                                         controller:self];
    [presenter bindNavigationItem:[self navigationItem] withAction:@selector(dismiss)];
    
    __weak typeof(self) weakSelf = self;
    [presenter bindTableView:[self tableView] whenDonePerform:^{
        [weakSelf dismiss];
    }];
    
    [self addPresenter:presenter];
}

#pragma mark - Actions

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
