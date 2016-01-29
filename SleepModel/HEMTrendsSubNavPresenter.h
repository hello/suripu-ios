//
//  HEMTrendsTimeScalePresenter.h
//  Sense
//
//  Created by Jimmy Lu on 1/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMTrendsService;
@class HEMSubNavigationView;

NS_ASSUME_NONNULL_BEGIN

@interface HEMTrendsSubNavPresenter : HEMPresenter

- (instancetype)initWithTrendsService:(HEMTrendsService*)trendsService;
- (void)bindWithSubNav:(HEMSubNavigationView*)subNav
  withHeightConstraint:(NSLayoutConstraint*)heightConstraint;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;

@end

NS_ASSUME_NONNULL_END