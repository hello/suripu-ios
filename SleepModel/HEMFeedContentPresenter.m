//
//  HEMFeedContentPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMFeedContentPresenter.h"
#import "HEMInsightsService.h"
#import "HEMVoiceService.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSubNavigationView.h"

@interface HEMFeedContentPresenter()

@property (nonatomic, weak) HEMInsightsService* insightsService;
@property (nonatomic, weak) HEMVoiceService* voiceService;
@property (nonatomic, weak) HEMActivityIndicatorView* activityIndicator;
@property (nonatomic, weak) UICollectionView* errorCollectionView;
@property (nonatomic, weak) UIView* contentView;
@property (nonatomic, weak) HEMSubNavigationView* subNavBar;

@end

@implementation HEMFeedContentPresenter

- (instancetype)initWithInsightsService:(HEMInsightsService*)insightsService
                           voiceService:(HEMVoiceService*)voiceService {
    if (self = [super init]) {
        _insightsService = insightsService;
        _voiceService = voiceService;
    }
    return self;
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)indicatorView {
    
}

- (void)bindWithSubNavigationBar:(HEMSubNavigationView*)subNavgationBar
            withHeightConstraint:(NSLayoutConstraint*)heightConstraint {
    
}

- (void)bindWithContentView:(UIView*)contentView
        errorCollectionView:(UICollectionView*)errorCollectionView {
    
}

@end
