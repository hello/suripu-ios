//
//  HEMInsightsFeedPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 11/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEMPresenter.h"

@class HEMInsightsFeedPresenter;
@class SENInsight;
@class HEMInsightsService;
@class HEMQuestionsService;
@class HEMUnreadAlertService;
@class HEMActivityIndicatorView;
@class HEMInsightCollectionViewCell;
@class HEMHandHoldingService;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMInsightsPresenterCompletion)(void);

@protocol HEMInsightsFeedPresenterDelegate <NSObject>

- (void)presenter:(HEMInsightsFeedPresenter*)presenter
      showInsight:(SENInsight*)insight
         fromCell:(HEMInsightCollectionViewCell*)cell;
- (void)presenter:(HEMInsightsFeedPresenter*)presenter
    showQuestions:(NSArray<SENQuestion*>*)questions
       completion:(nullable HEMInsightsPresenterCompletion)completion;

@end

@interface HEMInsightsFeedPresenter : HEMPresenter

@property (nonatomic, weak, nullable) id<HEMInsightsFeedPresenterDelegate> delegate;

- (nonnull instancetype)initWithInsightsService:(HEMInsightsService*)insightsService
                               questionsService:(HEMQuestionsService*)questionsService
                                  unreadService:(HEMUnreadAlertService*)unreadService
                             handHoldingService:(HEMHandHoldingService*)handHoldingService;

- (void)bindWithCollectionView:(UICollectionView*)collectionView;

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator;

- (void)bindWithTutorialContainerView:(UIView*)tutorialContainerView;

- (void)refresh;

@end

NS_ASSUME_NONNULL_END
