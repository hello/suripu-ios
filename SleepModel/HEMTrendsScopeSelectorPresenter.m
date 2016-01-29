//
//  HEMTrendsTimeScalePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 1/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENTrendsGraph.h>
#import <SenseKit/SENTrends.h>

#import "HEMTrendsScopeSelectorPresenter.h"
#import "HEMTrendsService.h"
#import "HEMStyle.h"

@interface HEMTrendsScopeSelectorPresenter()

@property (nonatomic, weak) HEMTrendsService* trendsService;
@property (nonatomic, weak) UIView* containerView;
@property (nonatomic, weak) NSLayoutConstraint* heightConstraint;
@property (nonatomic, assign) CGFloat originalSelectorHeight;
@property (nonatomic, assign) SENTrendsTimeScale selectedScale;
@property (nonatomic, assign, getter=isConfigured) BOOL configured;

@end

@implementation HEMTrendsScopeSelectorPresenter

- (instancetype)initWithTrendsService:(HEMTrendsService*)trendsService {
    self = [super init];
    if (self) {
        _trendsService = trendsService;
        _selectedScale = SENTrendsTimeScaleWeek;
    }
    return self;
}

- (void)bindWithSelectorContainer:(UIView*)containerView
             withHeightConstraint:(NSLayoutConstraint*)heightConstraint {
    
    [self setOriginalSelectorHeight:[heightConstraint constant]];
    
    // hide the container for now until we know how many time scales are
    // available for the account
    [heightConstraint setConstant:0.0f];
    
    [self setContainerView:containerView];
    [self setHeightConstraint:heightConstraint];
    
    [self configureSelectorWithData];
}

- (void)didRelayout {
    [super didRelayout];
    if (![self isConfigured]) {
        [self configureSelectorWithData];
        [self setConfigured:YES];
    }
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

- (UIButton*)scopeButtonForTimeScale:(SENTrendsTimeScale)timeScale width:(CGFloat)width atIndex:(NSInteger)index {
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(width, CGRectGetHeight([[self containerView] bounds]));
    frame.origin.x = index * width;

    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setFrame:frame];
    [button setTitle:[[self selectorTitleForScale:timeScale] uppercaseString] forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont trendsScopeSelectorTextFont]];
    [button setTitleColor:[UIColor trendsScopeSelectorActiveTextColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor trendsScopeSelectorInactiveTextColor] forState:UIControlStateNormal | UIControlStateHighlighted];
    [button setSelected:timeScale == [self selectedScale]];
    [button setTag:index];
    [button addTarget:self action:@selector(changeScope:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)configureSelectorWithData {
    __weak typeof(self) weakSelf = self;
    [[self trendsService] refreshTrendsFor:[self selectedScale] completion:^(SENTrends * _Nullable trends, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([[trends availableTimeScales] count] > 0) {
            CGFloat containerWidth = CGRectGetWidth([[strongSelf containerView] bounds]);
            CGFloat buttonWidth = containerWidth / [[trends availableTimeScales] count];
            NSInteger index = 0;
            for (NSNumber* timeScaleNumber in [trends availableTimeScales]) {
                SENTrendsTimeScale timeScale = [timeScaleNumber unsignedIntegerValue];
                UIButton* button = [strongSelf scopeButtonForTimeScale:[strongSelf selectedScale]
                                                                 width:buttonWidth
                                                               atIndex:index++];
                [[strongSelf containerView] addSubview:button];
            }
        }
    }];
}

#pragma mark - Scope Selection

- (void)changeScope:(UIButton*)button {
    SENTrendsTimeScale timeScale = [button tag];
    if (timeScale != [self selectedScale]) {
        [button setSelected:YES];
        for (UIView* subview in [self containerView]) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton* otherButton = (UIButton*)subview;
                [otherButton setSelected:NO];
            }
        }
        DDLogVerbose(@"refresh and aniamte!");
    }
}

@end
