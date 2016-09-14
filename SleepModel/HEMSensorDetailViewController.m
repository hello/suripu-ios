//
//  HEMSensorDetailViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSensorDetailViewController.h"
#import "HEMSubNavigationView.h"
#import "HEMSensorDetailViewController.h"
#import "HEMSensorService.h"
#import "HEMSensorDetailSubNavPresenter.h"
#import "HEMSensorDetailPresenter.h"

@interface HEMSensorDetailViewController () <
    HEMSensorDetailSubNavDelegate
>

@property (weak, nonatomic) IBOutlet HEMSubNavigationView *subNavBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HEMSensorService* sensorService;
@property (weak, nonatomic) HEMSensorDetailSubNavPresenter* subNavPresenter;
@property (weak, nonatomic) HEMSensorDetailPresenter* detailPresenter;

@end

@implementation HEMSensorDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenters];
}

- (void)configurePresenters {
    HEMSensorService* sensorService = [HEMSensorService new];
    HEMSensorDetailSubNavPresenter* subNavPresenter =
        [[HEMSensorDetailSubNavPresenter alloc] initWithSensorService:sensorService];
    [subNavPresenter bindWithSubNavigationView:[self subNavBar]];
    [subNavPresenter setDelegate:self];
    [self setSensorService:sensorService];
    [self setSubNavPresenter:subNavPresenter];
    [self addPresenter:subNavPresenter];
    
    HEMSensorDetailPresenter* presenter =
        [[HEMSensorDetailPresenter alloc] initWithSensorService:sensorService
                                                      forSensor:[self sensor]];
    [presenter bindWithCollectionView:[self collectionView]];
    [presenter bindWithSubNavigationView:[self subNavBar]];
    [presenter setPollScope:[subNavPresenter scopeSelected]];
    [self setDetailPresenter:presenter];
    [self addPresenter:presenter];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([[self navigationController] navigationBar]
        && ![[self subNavPresenter] hasNavBar]) {
        [[self subNavPresenter] bindWithNavBar:[[self navigationController] navigationBar]];
    }
}

#pragma mark - HEMSensorDetailSubNavDelegate

- (void)didChangeScopeTo:(HEMSensorServiceScope)scope fromPresenter:(HEMSensorDetailSubNavPresenter *)presenter {
    [[self detailPresenter] setPollScope:scope];
}

@end
