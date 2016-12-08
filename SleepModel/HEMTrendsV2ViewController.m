//
//  HEMTrendsV2ViewController.m
//  Sense
//
//  Created by Jimmy Lu on 1/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"

#import "HEMTrendsV2ViewController.h"
#import "HEMTrendsGraphsPresenter.h"
#import "HEMTrendsService.h"
#import "HEMActivityIndicatorView.h"

@interface HEMTrendsV2ViewController()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *loadingIndicator;

@end

@implementation HEMTrendsV2ViewController

- (id)initWithCoder:(NSCoder*)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        _tabIcon = [UIImage imageNamed:@"trendsTabBarIcon"];
        _tabIconHighlighted = [UIImage imageNamed:@"trendsTabBarIconHighlighted"];
        _tabTitle = NSLocalizedString(@"trends.title", nil);
    }
    return self;
}

- (NSString*)tabTitle {
    return [[self presenter] scaleTitle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindPresenter];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SENAnalytics track:HEMAnalyticsEventTrends];
}

- (void)bindPresenter {
    [[self presenter] bindWithCollectionView:[self collectionView]];
    [[self presenter] bindWithLoadingIndicator:[self loadingIndicator]];
    [self addPresenter:[self presenter]];
}

@end
