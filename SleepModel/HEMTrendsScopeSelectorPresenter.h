//
//  HEMTrendsTimeScalePresenter.h
//  Sense
//
//  Created by Jimmy Lu on 1/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMTrendsService;

NS_ASSUME_NONNULL_BEGIN

@interface HEMTrendsScopeSelectorPresenter : HEMPresenter

- (instancetype)initWithTrendsService:(HEMTrendsService*)trendsService;
- (void)bindWithSelectorContainer:(UIView*)containerView
             withHeightConstraint:(NSLayoutConstraint*)heightConstraint;

@end

NS_ASSUME_NONNULL_END