//
//  HEMTrendsV2ViewController.m
//  Sense
//
//  Created by Jimmy Lu on 1/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsV2ViewController.h"
#import "HEMTrendsSubNavPresenter.h"
#import "HEMTrendsTabPresenter.h"
#import "HEMTrendsService.h"
#import "HEMSubNavigationView.h"

@interface HEMTrendsV2ViewController()

@property (nonatomic, strong) HEMTrendsService* trendsService;
@property (weak, nonatomic) IBOutlet HEMSubNavigationView *subNav;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subNavHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation HEMTrendsV2ViewController

- (id)initWithCoder:(NSCoder*)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        // required to be done on init since view will not be initially loaded
        // when the back view is set up
        HEMTrendsTabPresenter* tabPresenter = [HEMTrendsTabPresenter new];
        [tabPresenter bindWithTabBarItem:[self tabBarItem]];
        [self addPresenter:tabPresenter];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureScopeSelectorPresenter];
}

- (void)configureScopeSelectorPresenter {
    HEMTrendsService* service = [HEMTrendsService new];
    HEMTrendsSubNavPresenter* subNavPresenter
        = [[HEMTrendsSubNavPresenter alloc] initWithTrendsService:service];
    [subNavPresenter bindWithSubNav:[self subNav]
               withHeightConstraint:[self subNavHeightConstraint]];
    [subNavPresenter bindWithCollectionView:[self collectionView]];
    
    [self addPresenter:subNavPresenter];
    [self setTrendsService:service];
}

@end
