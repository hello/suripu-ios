//
//  HEMInsightFeedViewController.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import "Sense-Swift.h"

#import <SenseKit/SenseKit.h>

#import "UIImage+HEMPixelColor.h"

#import "HEMInsightFeedViewController.h"
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
#import "HEMInsightTransition.h"
#import "HEMInsightCollectionViewCell.h"
#import "HEMURLImageView.h"
#import "HEMSimpleModalTransitionDelegate.h"
#import "HEMHandHoldingService.h"
#import "HEMInsightsHandHoldingPresenter.h"
#import "HEMWhatsNewService.h"
#import "HEMShareService.h"

@interface HEMInsightFeedViewController () <HEMInsightsFeedPresenterDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) HEMInsightsFeedPresenter* feedPresenter;
@property (weak, nonatomic) HEMInsightsHandHoldingPresenter* handHoldingPresenter;
@property (strong, nonatomic) HEMInsightsService* insightsFeedService;
@property (strong, nonatomic) HEMQuestionsService* questionsService;
@property (strong, nonatomic) HEMHandHoldingService* handHoldingService;
@property (strong, nonatomic) HEMWhatsNewService* whatsNewService;
@property (strong, nonatomic) HEMShareService* shareService;

@property (strong, nonatomic) id <UIViewControllerTransitioningDelegate> insightTransition;
@property (strong, nonatomic) id <UIViewControllerTransitioningDelegate> questionsTransition;

@end

@implementation HEMInsightFeedViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _tabIcon = [UIImage imageNamed:@"feedTabBarIcon"];
        _tabIconHighlighted = [UIImage imageNamed:@"feedTabBarIconHighlighted"];
        _tabTitle = NSLocalizedString(@"insights.title", nil);
    }
    return self;
}

- (UIViewController*)childViewControllerForStatusBarHidden {
    DDLogVerbose(@"status bar controller %@", self.presentedViewController);
    return self.presentedViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenters];
}

- (void)configurePresenters {
    [self setInsightsFeedService:[HEMInsightsService new]];
    [self setQuestionsService:[HEMQuestionsService new]];
    [self setHandHoldingService:[HEMHandHoldingService new]];
    [self setWhatsNewService:[HEMWhatsNewService new]];
    [self setShareService:[HEMShareService new]];
    
    if ([self unreadService]) {
        [self setUnreadService:[HEMUnreadAlertService new]];
    }
    
    HEMInsightsHandHoldingPresenter* hhPresenter
        = [[HEMInsightsHandHoldingPresenter alloc] initWithHandHoldingService:_handHoldingService];
    [self addPresenter:hhPresenter];
    [self setHandHoldingPresenter:hhPresenter];
    
    HEMInsightsFeedPresenter* feedPresenter
    = [[HEMInsightsFeedPresenter alloc] initWithInsightsService:_insightsFeedService
                                               questionsService:_questionsService
                                                  unreadService:_unreadService
                                                whatsNewService:_whatsNewService
                                                   shareService:_shareService];
    
    [feedPresenter bindWithCollectionView:[self collectionView]];
    [feedPresenter bindWithActivityIndicator:[self activityIndicator]];
    [feedPresenter bindWithSubNavBar:[self subNavBar]];
    [feedPresenter setDelegate:self];
    
    __weak typeof(self) weakSelf = self;
    [feedPresenter setOnLoadCallback:^(NSArray* data) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        UIView* rootView = [[RootViewController currentRootViewController] view];
        [[strongSelf handHoldingPresenter] showIfNeededIn:rootView
                                       withCollectionView:[strongSelf collectionView]];
    }];
    
    [self addPresenter:feedPresenter];
    [self setFeedPresenter:feedPresenter];
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
    [insightVC setInsightService:[self insightsFeedService]];
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
        [transition setWantsStatusBar:YES];
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

- (void)presenter:(HEMInsightsFeedPresenter*)presenter
          showTab:(MainTab)tab {
    [self switchMainTab:tab];
}

- (UIView*)activityContainerViewFor:(HEMInsightsFeedPresenter*)presenter {
    return [[self rootViewController] view];
}

- (void)presenter:(HEMInsightsFeedPresenter *)presenter showController:(UIViewController*)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)presenter:(HEMInsightsFeedPresenter*)presenter
   showErrorTitle:(NSString*)title
          message:(NSString*)message {
    [self showMessageDialog:message title:title];
}

#pragma mark - Clean Up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_feedPresenter setDelegate:nil];
}

@end
