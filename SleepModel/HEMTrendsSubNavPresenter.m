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
#import "HEMActivityIndicatorView.h"
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
@property (nonatomic, weak) HEMActivityIndicatorView* loadingIndicator;

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
    
    [self configureSelectorWithData];
}

- (void)bindWithCollectionView:(UICollectionView *)collectionView {
    [self setCollectionView:collectionView];
}

- (void)bindWithLoadingIndicator:(HEMActivityIndicatorView*)loadingIndicator {
    [self setLoadingIndicator:loadingIndicator];
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
    [[button titleLabel] setFont:[UIFont trendsScopeSelectorTextFont]];
    [button setTitleColor:[UIColor trendsScopeSelectorActiveTextColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor trendsScopeSelectorActiveTextColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor trendsScopeSelectorInactiveTextColor] forState:UIControlStateNormal];
    [button setSelected:timeScale == [self selectedScale]];
    [button setTag:timeScale];
    [button addTarget:self action:@selector(changeScope:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)showLoading:(BOOL)loading {
    // only show indicator on first load
    if (loading && ![[self subNav] hasControls]) {
        [[self loadingIndicator] start];
        [[self loadingIndicator] setHidden:NO];
    } else if ([[self loadingIndicator] isAnimating]){
        [[self loadingIndicator] stop];
        [[self loadingIndicator] setHidden:YES];
    }
}

- (void)configureSelectorWithData {
    [self showLoading:YES];
    __weak typeof(self) weakSelf = self;
    [[self trendsService] refreshTrendsFor:[self selectedScale] completion:^(SENTrends * _Nullable trends, SENTrendsTimeScale scale, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([[trends availableTimeScales] count] >= HEMTrendsSubNavMinimumOptions) {
            [[strongSelf heightConstraint] setConstant:[strongSelf originalSelectorHeight]];

            for (NSNumber* timeScaleNumber in [trends availableTimeScales]) {
                SENTrendsTimeScale timeScale = [timeScaleNumber integerValue];
                UIButton* button = [strongSelf scopeButtonForTimeScale:timeScale];
                [[strongSelf subNav] addControl:button];
            }
            [strongSelf showLoading:NO];
            [[strongSelf subNav] setNeedsDisplay];
            [[strongSelf collectionView] reloadData];
        }
    }];
}

#pragma mark - Scope Selection

- (void)changeScope:(UIButton*)button {
    SENTrendsTimeScale timeScale = [button tag];
    if (timeScale != [self selectedScale]) {
        [self setSelectedScale:timeScale];
        [self updateDataForSelectedScale];
        DDLogVerbose(@"refresh and aniamte!");
    }
}

- (void)updateDataForSelectedScale {
    __weak typeof(self) weakSelf = self;
    [[self trendsService] refreshTrendsFor:[self selectedScale] completion:^(SENTrends * _Nullable trends, SENTrendsTimeScale scale, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf selectedScale] == scale) {
            [[strongSelf collectionView] reloadData];
        }
    }];
}

@end
