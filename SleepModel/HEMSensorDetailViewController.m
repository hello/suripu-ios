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

@interface HEMSensorDetailViewController ()

@property (weak, nonatomic) IBOutlet HEMSubNavigationView *subNavBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HEMSensorService* sensorService;

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
    [subNavPresenter bindwithSubNavigationView:[self subNavBar]];
    
    [self setSensorService:sensorService];
    [self addPresenter:subNavPresenter];
}

@end
