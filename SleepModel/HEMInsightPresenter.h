//
//  HEMInsightPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 12/4/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMInsightsService;
@class HEMInsightPresenter;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMInsightErrorDelegate <NSObject>

- (void)didFailToLoadInsight:(SENInsight*)insight fromPresenter:(HEMInsightPresenter*)presenter;

@end

@interface HEMInsightPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMInsightErrorDelegate> insightErrorDelegate;

- (instancetype)initWithInsightService:(HEMInsightsService*)insightsService
                            forInsight:(SENInsight*)insight;
- (void)bindWithCollectionView:(UICollectionView*)collectionView
                withImageColor:(UIColor*)imageColor;
- (void)bindWithButtonShadow:(UIImageView*)buttonShadow;

@end

NS_ASSUME_NONNULL_END
