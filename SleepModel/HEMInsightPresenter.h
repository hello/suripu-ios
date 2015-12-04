//
//  HEMInsightPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 12/4/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMInsightsService;

NS_ASSUME_NONNULL_BEGIN

@interface HEMInsightPresenter : HEMPresenter

- (instancetype)initWithInsightService:(HEMInsightsService*)insightsService
                            forInsight:(SENInsight*)insight;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;

@end

NS_ASSUME_NONNULL_END