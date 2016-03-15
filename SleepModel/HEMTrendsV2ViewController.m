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
#import "HEMTrendsGraphsPresenter.h"
#import "HEMTrendsService.h"
#import "HEMSubNavigationView.h"
#import "HEMActivityIndicatorView.h"

@interface HEMTrendsV2ViewController()

@property (nonatomic, strong) HEMTrendsService* trendsService;
@property (weak, nonatomic) IBOutlet HEMSubNavigationView *subNav;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subNavHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *loadingIndicator;

@end

@implementation HEMTrendsV2ViewController

- (id)initWithCoder:(NSCoder*)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        HEMTrendsService* service = [HEMTrendsService new];
        [self setTrendsService:service];
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
    [self configureGraphsPresenter];
    [self configureSubNavPresenter]; // must come after graphs
    
    [SENAnalytics track:HEMAnalyticsEventTrends];
}

- (void)configureSubNavPresenter {
    HEMTrendsSubNavPresenter* subNavPresenter
        = [[HEMTrendsSubNavPresenter alloc] initWithTrendsService:[self trendsService]];
    [subNavPresenter bindWithSubNav:[self subNav]
               withHeightConstraint:[self subNavHeightConstraint]];
    [subNavPresenter bindWithCollectionView:[self collectionView]];
    [self addPresenter:subNavPresenter];
}

- (void)configureGraphsPresenter {
    HEMTrendsGraphsPresenter* graphsPresenter
        = [[HEMTrendsGraphsPresenter alloc] initWithTrendsService:[self trendsService]];
    [graphsPresenter bindWithCollectionView:[self collectionView]];
    [graphsPresenter bindWithSubNav:[self subNav]];
    [graphsPresenter bindWithLoadingIndicator:[self loadingIndicator]];
    [self addPresenter:graphsPresenter];
}

@end
