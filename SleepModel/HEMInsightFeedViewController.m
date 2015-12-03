//
//  HEMInsightFeedViewController.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SenseKit.h>

#import "UIView+HEMSnapshot.h"

#import "HEMInsightFeedViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMInsightViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSinkModalTransition.h"
#import "HEMBounceModalTransition.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMAppReview.h"
#import "HEMSleepQuestionsDataSource.h"
#import "HEMActivityIndicatorView.h"
#import "HEMQuestionsService.h"
#import "HEMInsightsService.h"
#import "HEMUnreadAlertService.h"
#import "HEMInsightsFeedPresenter.h"
#import "HEMInsightsUnreadPresenter.h"

@interface HEMInsightFeedViewController () <HEMInsightsFeedPresenterDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) HEMInsightsFeedPresenter* feedPresenter;
@property (strong, nonatomic) HEMInsightsUnreadPresenter* unreadPresenter;
@property (strong, nonatomic) HEMInsightsService* insightsFeedService;
@property (strong, nonatomic) HEMQuestionsService* questionsService;
@property (strong, nonatomic) HEMUnreadAlertService* unreadService;

@property (strong, nonatomic) id <UIViewControllerTransitioningDelegate> sinkTransition;
@property (strong, nonatomic) id <UIViewControllerTransitioningDelegate> questionsTransition;

@end

@implementation HEMInsightFeedViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _insightsFeedService = [HEMInsightsService new];
        _questionsService = [HEMQuestionsService new];
        _unreadService = [HEMUnreadAlertService new];
        _feedPresenter = [[HEMInsightsFeedPresenter alloc] initWithInsightsService:_insightsFeedService
                                                                  questionsService:_questionsService
                                                                     unreadService:_unreadService];
        
        _unreadPresenter = [[HEMInsightsUnreadPresenter alloc] initWithUnreadService:_unreadService];
        // must bind with tab bar here so that the container knows how to display
        // this controller even though the view has yet to be loaded
        [_unreadPresenter bindWithTabBarItem:[self tabBarItem]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self feedPresenter] bindWithCollectionView:[self collectionView]];
    [[self feedPresenter] bindWithActivityIndicator:[self activityIndicator]];
    [[self feedPresenter] setDelegate:self];
}

- (void)viewDidBecomeActive {
    [super viewDidBecomeActive];
    [[self feedPresenter] didComeBackFromBackground];
    [[self unreadPresenter] didComeBackFromBackground];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[self feedPresenter] didAppear];
    [[self unreadPresenter] didAppear];
    
    [SENAnalytics track:kHEMAnalyticsEventFeed];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[self feedPresenter] didDisappear];
    [[self unreadPresenter] didDisappear];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - HEMInsightFeedPresenterDelegate

- (void)presenter:(HEMInsightsFeedPresenter *)presenter showInsight:(SENInsight *)insight {
    if (![self sinkTransition]) {
        HEMSinkModalTransition* modalTransitionDelegate = [[HEMSinkModalTransition alloc] init];
        [modalTransitionDelegate setSinkView:[self view]];
        [self setSinkTransition:modalTransitionDelegate];
    }
    
    HEMInsightViewController* insightVC = (id)[HEMMainStoryboard instantiateSleepInsightViewController];
    [insightVC setInsight:insight];
    [insightVC setModalPresentationStyle:UIModalPresentationCustom];
    [insightVC setTransitioningDelegate:[self sinkTransition]];
    [self presentViewController:insightVC animated:YES completion:nil];
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
        HEMBounceModalTransition* transition = [[HEMBounceModalTransition alloc] init];
        [transition setMessage:NSLocalizedString(@"sleep.questions.end.message", nil)];
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