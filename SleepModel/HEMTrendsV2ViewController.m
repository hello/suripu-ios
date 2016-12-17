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

@interface HEMTrendsV2ViewController() <Scrollable>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *loadingIndicator;
@property (assign, nonatomic, getter=isConfigured) BOOL configured;

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SENAnalytics track:HEMAnalyticsEventTrends];
    
    if (![self isConfigured]) {
        [self bindPresenter];
        [self setConfigured:YES];
    }
}

- (void)bindPresenter {
    [[self presenter] bindWithLoadingIndicator:[self loadingIndicator]];
    [[self presenter] bindWithCollectionView:[self collectionView]];
    [self addPresenter:[self presenter]];
}

#pragma mark - Scrollable 

- (void)scrollToTop {
    [[self collectionView] setContentOffset:CGPointZero animated:YES];
}

@end
