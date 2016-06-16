//
//  HEMTrendsTimeScalePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 1/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENTrendsGraph.h>
#import <SenseKit/SENTrends.h>

#import "HEMTrendsSubNavPresenter.h"
#import "HEMSubNavigationView.h"
#import "HEMTrendsService.h"
#import "HEMStyle.h"

static NSUInteger const HEMTrendsSubNavMinimumOptions = 2;

@interface HEMTrendsSubNavPresenter()

@property (nonatomic, weak) HEMTrendsService* trendsService;
@property (nonatomic, weak) HEMSubNavigationView* subNav;
@property (nonatomic, weak) NSLayoutConstraint* heightConstraint;
@property (nonatomic, assign) CGFloat originalSelectorHeight;
@property (nonatomic, assign) SENTrendsTimeScale selectedScale;
@property (nonatomic, assign, getter=isConfigured) BOOL configured;
@property (nonatomic, weak) UICollectionView* collectionView;

@end

@implementation HEMTrendsSubNavPresenter

- (instancetype)initWithTrendsService:(HEMTrendsService*)trendsService {
    self = [super init];
    if (self) {
        _trendsService = trendsService;
        _selectedScale = SENTrendsTimeScaleWeek;
    }
    return self;
}

- (void)bindWithSubNav:(HEMSubNavigationView*)subNav
  withHeightConstraint:(NSLayoutConstraint*)heightConstraint {
    
    [self setOriginalSelectorHeight:[heightConstraint constant]];
    
    // hide the container for now until we know how many time scales are
    // available for the account
    [heightConstraint setConstant:0.0f];
    
    [self setSubNav:subNav];
    [self setHeightConstraint:heightConstraint];
    [self loadTrends:nil];
}

- (void)bindWithCollectionView:(UICollectionView *)collectionView {
    [self setCollectionView:collectionView];
}

- (NSString*)selectorTitleForScale:(SENTrendsTimeScale)timeScale {
    switch (timeScale) {
        case SENTrendsTimeScaleWeek:
            return NSLocalizedString(@"trends.scope.week", nil);
        case SENTrendsTimeScaleMonth:
            return NSLocalizedString(@"trends.scope.month", nil);
        case SENTrendsTimeScaleQuarter:
            return NSLocalizedString(@"trends.scope.quarter", nil);
        default:
            return NSLocalizedString(@"empty-data", nil);
    }
}

- (UIButton*)scopeButtonForTimeScale:(SENTrendsTimeScale)timeScale {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitle:[[self selectorTitleForScale:timeScale] uppercaseString] forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont subNavTitleTextFont]];
    [button setTitleColor:[UIColor subNavActiveTitleColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor subNavActiveTitleColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor subNavInactiveTitleColor] forState:UIControlStateNormal];
    [button setSelected:timeScale == [self selectedScale]];
    [button setTag:timeScale];
    return button;
}

- (void)loadTrends:(void(^)(void))beforeDataLoadedHandler {
    __weak typeof(self) weakSelf = self;
    void(^update)(SENTrends * trends, SENTrendsTimeScale scale, NSError * error) = ^(SENTrends * trends, SENTrendsTimeScale scale, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (beforeDataLoadedHandler) {
            beforeDataLoadedHandler ();
        }
        
        if ([[trends availableTimeScales] count] >= HEMTrendsSubNavMinimumOptions) {
            [[strongSelf heightConstraint] setConstant:[strongSelf originalSelectorHeight]];
            
            for (NSNumber* timeScaleNumber in [trends availableTimeScales]) {
                SENTrendsTimeScale timeScale = [timeScaleNumber integerValue];
                UIButton* button = [strongSelf scopeButtonForTimeScale:timeScale];
                [[strongSelf subNav] addControl:button];
                
                // must add target after adding the control to the subnav to ensure
                // order of when events are fired
                [button addTarget:self
                           action:@selector(changeScope:)
                 forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        [[strongSelf subNav] setNeedsDisplay];
        [[strongSelf collectionView] reloadData];
    };
    
    [[self trendsService] reloadTrends:[self selectedScale] completion:update];
    
}

- (void)reloadCurrentTrends {
    if (![[self trendsService] isRefreshing]) {
        [[self subNav] setPreviousControlTag:[[self subNav] selectedControlTag]];
        [self loadTrends:nil];
    }
}

#pragma mark - Scope Selection

- (void)changeScope:(UIButton*)button {
    SENTrendsTimeScale timeScale = [button tag];
    if (timeScale != [self selectedScale]) {
        [self setSelectedScale:timeScale];
        [[self trendsService] trendsFor:[self selectedScale] completion:nil];
        [SENAnalytics trackTrendsTimescaleChange:[self selectedScale]];
    }
}

#pragma mark - Presenter events

- (void)didComeBackFromBackground {
    [super didComeBackFromBackground];
    [self reloadCurrentTrends];
}

- (void)didGainConnectivity {
    [super didGainConnectivity];
    [self reloadCurrentTrends];
}

@end