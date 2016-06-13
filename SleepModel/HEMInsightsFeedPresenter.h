//
//  HEMInsightsFeedPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 11/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEMPresenter.h"
#import "HEMRootViewController.h"

@class HEMInsightsFeedPresenter;
@class SENInsight;
@class HEMInsightsService;
@class HEMQuestionsService;
@class HEMUnreadAlertService;
@class HEMWhatsNewService;
@class HEMActivityIndicatorView;
@class HEMInsightCollectionViewCell;
@class HEMHandHoldingService;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMInsightsPresenterCompletion)(void);
typedef void(^HEMInsightsFeedDataLoadedBlock)(NSArray* _Nullable data);

@protocol HEMInsightsFeedPresenterDelegate <NSObject>

- (void)presenter:(HEMInsightsFeedPresenter*)presenter
      showInsight:(SENInsight*)insight
         fromCell:(HEMInsightCollectionViewCell*)cell;
- (void)presenter:(HEMInsightsFeedPresenter*)presenter
    showQuestions:(NSArray<SENQuestion*>*)questions
       completion:(nullable HEMInsightsPresenterCompletion)completion;
- (void)presenter:(HEMInsightsFeedPresenter*)presenter showTab:(HEMRootDrawerTab)tab;

@end

@interface HEMInsightsFeedPresenter : HEMPresenter

@property (nonatomic, weak, nullable) id<HEMInsightsFeedPresenterDelegate> delegate;
@property (nonatomic, copy, nullable) HEMInsightsFeedDataLoadedBlock onLoadCallback;

- (nonnull instancetype)initWithInsightsService:(HEMInsightsService*)insightsService
                               questionsService:(HEMQuestionsService*)questionsService
                                  unreadService:(HEMUnreadAlertService*)unreadService
                                whatsNewService:(HEMWhatsNewService*)whatsNewservice;

- (void)bindWithCollectionView:(UICollectionView*)collectionView;

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator;

- (void)bindWithTutorialContainerView:(UIView*)tutorialContainerView;

- (void)refresh;

@end

NS_ASSUME_NONNULL_END
