//
//  HEMTrendsV2ViewController.m
//  Sense
//
//  Created by Jimmy Lu on 1/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"

#import "HEMTrendsV2ViewController.h"
#import "HEMTrendsSubNavPresenter.h"
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
        NSString* iconName = @"trendsTabBarIcon";
        NSString* title = NSLocalizedString(@"trends.title", nil);
        TabPresenter* presenter = [[TabPresenter alloc] initWithIconBaseName:iconName title:title];
        [presenter bindWithTabItem:[self tabBarItem]];
        [self addPresenter:presenter];
        
        _trendsService = [HEMTrendsService new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureGraphsPresenter];
    [self configureSubNavPresenter]; // must come after graphs
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
