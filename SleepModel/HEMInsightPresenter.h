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

@protocol HEMInsightActionDelegate <NSObject>

- (void)closeInsightFromPresenter:(HEMInsightPresenter*)presenter;

@end

@interface HEMInsightPresenter : HEMPresenter

@property (nonatomic, weak, nullable) id<HEMInsightActionDelegate> actionDelegate;

- (instancetype)initWithInsightService:(HEMInsightsService*)insightsService
                            forInsight:(SENInsight*)insight;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;
- (void)bindWithCloseButton:(UIButton*)button
           bottomConstraint:(NSLayoutConstraint*)bottomConstraint;

@end

NS_ASSUME_NONNULL_END