//
//  HEMInsightFeedViewController.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SenseKit.h>

#import "UIImage+HEMPixelColor.h"

#import "HEMInsightFeedViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMInsightViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMAppReview.h"
#import "HEMSleepQuestionsDataSource.h"
#import "HEMActivityIndicatorView.h"
#import "HEMQuestionsService.h"
#import "HEMInsightsService.h"
#import "HEMUnreadAlertService.h"
#import "HEMInsightsFeedPresenter.h"
#import "HEMInsightTabPresenter.h"
#import "HEMInsightTransition.h"
#import "HEMInsightCollectionViewCell.h"
#import "HEMURLImageView.h"
#import "HEMRootViewController.h"
#import "HEMSimpleModalTransitionDelegate.h"
#import "HEMHandHoldingService.h"
#import "HEMInsightsHandHoldingPresenter.h"

@interface HEMInsightFeedViewController () <HEMInsightsFeedPresenterDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) HEMInsightsFeedPresenter* feedPresenter;
@property (weak, nonatomic) HEMInsightsHandHoldingPresenter* handHoldingPresenter;
@property (strong, nonatomic) HEMInsightsService* insightsFeedService;
@property (strong, nonatomic) HEMQuestionsService* questionsService;
@property (strong, nonatomic) HEMUnreadAlertService* unreadService;
@property (strong, nonatomic) HEMHandHoldingService* handHoldingService;

@property (strong, nonatomic) id <UIViewControllerTransitioningDelegate> insightTransition;
@property (strong, nonatomic) id <UIViewControllerTransitioningDelegate> questionsTransition;

@end

@implementation HEMInsightFeedViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _insightsFeedService = [HEMInsightsService new];
        _questionsService = [HEMQuestionsService new];
        _unreadService = [HEMUnreadAlertService new];
        _handHoldingService = [HEMHandHoldingService new];
        
        HEMInsightsHandHoldingPresenter* hhPresenter
            = [[HEMInsightsHandHoldingPresenter alloc] initWithHandHoldingService:_handHoldingService];
        _handHoldingPresenter = hhPresenter;
        [self addPresenter:hhPresenter];
        
        HEMInsightsFeedPresenter* feedPresenter
            = [[HEMInsightsFeedPresenter alloc] initWithInsightsService:_insightsFeedService
                                                       questionsService:_questionsService
                                                          unreadService:_unreadService];
        // weak ref so we can bind collection view, activity and set delegate when view is loaded
        _feedPresenter = feedPresenter;
        [self addPresenter:feedPresenter];
        
        HEMInsightTabPresenter* tabPresenter
            = [[HEMInsightTabPresenter alloc] initWithUnreadService:_unreadService];
        // must bind with tab bar here so that the container knows how to display
        // this controller even though the view has yet to be loaded
        [tabPresenter bindWithTabBarItem:[self tabBarItem]];
        [self addPresenter:tabPresenter];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self feedPresenter] bindWithCollectionView:[self collectionView]];
    [[self feedPresenter] bindWithShadowView:[self shadowView]];
    [[self feedPresenter] bindWithActivityIndicator:[self activityIndicator]];
    [[self feedPresenter] setDelegate:self];
    
    __weak typeof(self) weakSelf = self;
    [[self feedPresenter] setOnLoadCallback:^(NSArray* data) {
        UIView* rootView = [[HEMRootViewController rootViewControllerForKeyWindow] view];
        [[weakSelf handHoldingPresenter] showIfNeededIn:rootView
                                     withCollectionView:[weakSelf collectionView]];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SENAnalytics track:kHEMAnalyticsEventFeed];
}

#pragma mark - HEMInsightFeedPresenterDelegate

- (void)presenter:(HEMInsightsFeedPresenter*)presenter
      showInsight:(SENInsight*)insight
         fromCell:(HEMInsightCollectionViewCell*)cell {
    
    HEMInsightTransition* transition = (id)[self insightTransition];
    if (!transition) {
        transition = [HEMInsightTransition new];
        [self setInsightTransition:transition];
    }
    
    UINavigationController* nav = [self navigationController];
    CGRect relativeFrame = [cell convertRect:[cell bounds] toView:[nav view]];
    [transition expandFrom:cell withRelativeFrame:relativeFrame];
    
    HEMInsightViewController* insightVC = (id)[HEMMainStoryboard instantiateSleepInsightViewController];
    [insightVC setInsight:insight];
    [insightVC setImageColor:[[[cell uriImageView] image] colorAtPosition:CGPointMake(1.0f, 1.0f)]];
    [insightVC setModalPresentationStyle:UIModalPresentationCustom];
    [insightVC setTransitioningDelegate:transition];
    [self presentViewController:insightVC animated:YES completion:nil];
    
    [[self handHoldingPresenter] didCompleteHandHolding];
}

- (void)presenter:(HEMInsightsFeedPresenter *)presenter
    showQuestions:(NSArray<SENQuestion *> *)questions
       completion:(nullable HEMInsightsPresenterCompletion)completion {
    
    HEMSleepQuestionsViewController* qVC = (id)[HEMMainStoryboard instantiateSleepQuestionsViewController];
    
    SENQuestion* firstQuestion = [questions firstObject];
    
    id<HEMQuestionsDataSource> dataSource = nil;
    if ([firstQuestion isKindOfClass:[HEMAppReviewQuestion class]]) {
        dataSource = [[HEMAppReviewQuestionsDataSource alloc] initWithAppReviewQuestion:(id)firstQuestion
                                                                                service:[self questionsService]];
        [SENAnalytics track:HEMAnalyticsEventAppReviewStart];
    } else {
        dataSource = [[HEMSleepQuestionsDataSource alloc] initWithQuestions:questions
                                                           questionsService:[self questionsService]];
    }
    [qVC setDataSource:dataSource];
    
    if (![self questionsTransition]) {
        HEMSimpleModalTransitionDelegate* transition = [[HEMSimpleModalTransitionDelegate alloc] init];
        [transition setDismissMessage:NSLocalizedString(@"sleep.questions.end.message", nil)];
        [self setQuestionsTransition:transition];
    }
    
    HEMStyledNavigationViewController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:qVC];
    [nav setModalPresentationStyle:UIModalPresentationCustom];
    [nav setTransitioningDelegate:[self questionsTransition]];
    
    [self presentViewController:nav animated:YES completion:^{
        if (completion) {
            completion ();
        }
    }];
}

#pragma mark - Clean Up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_feedPresenter setDelegate:nil];
}

@end