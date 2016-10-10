//
//  HEMFeedContentPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 10/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMInsightsService;
@class HEMVoiceService;
@class HEMActivityIndicatorView;
@class HEMSubNavigationView;

@interface HEMFeedContentPresenter : HEMPresenter

- (instancetype)initWithInsightsService:(HEMInsightsService*)insightsService
                           voiceService:(HEMVoiceService*)voiceService;

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)indicatorView;

- (void)bindWithSubNavigationBar:(HEMSubNavigationView*)subNavgationBar
            withHeightConstraint:(NSLayoutConstraint*)heightConstraint;

- (void)bindWithContentView:(UIView*)contentView
        errorCollectionView:(UICollectionView*)errorCollectionView;

@end
