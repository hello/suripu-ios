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

typedef void(^HEMInsightsPresenterCompletion)(void);

@protocol HEMInsightsFeedPresenterDelegate <NSObject>

- (void)presenter:(nonnull HEMInsightsFeedPresenter*)presenter showInsight:(nonnull SENInsight*)insight;
- (void)presenter:(nonnull HEMInsightsFeedPresenter*)presenter
    showQuestions:(nonnull NSArray<SENQuestion*>*)questions
       completion:(nullable HEMInsightsPresenterCompletion)completion;

@end

@interface HEMInsightsFeedPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMInsightsFeedPresenterDelegate> delegate;

- (nonnull instancetype)initWithInsightsService:(nonnull HEMInsightsService*)insightsService
                               questionsService:(nonnull HEMQuestionsService*)questionsService
                                  unreadService:(nonnull HEMUnreadAlertService*)unreadService;

- (void)bindWithCollectionView:(nonnull UICollectionView*)collectionView;

- (void)bindWithActivityIndicator:(nonnull HEMActivityIndicatorView*)activityIndicator;

- (void)refresh;

@end
