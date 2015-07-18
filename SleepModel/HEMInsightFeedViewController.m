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
#import "HEMInsightsFeedDataSource.h"
#import "HEMCardFlowLayout.h"
#import "HEMQuestionCell.h"
#import "HelloStyleKit.h"
#import "HEMInsightCollectionViewCell.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMInsightViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSinkModalTransition.h"
#import "HEMBounceModalTransition.h"
#import "HEMStyledNavigationViewController.h"

@interface HEMInsightFeedViewController () <
    UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak,   nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HEMInsightsFeedDataSource* dataSource;
@property (strong, nonatomic) id <UIViewControllerTransitioningDelegate> sinkTransition;
@property (strong, nonatomic) id <UIViewControllerTransitioningDelegate> questionsTransition;

@end

@implementation HEMInsightFeedViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.title = NSLocalizedString(@"insights.title", nil);
        self.tabBarItem.image = [HelloStyleKit senseBarIcon];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"senseBarIconActive"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HEMSinkModalTransition* modalTransitionDelegate = [[HEMSinkModalTransition alloc] init];
    [modalTransitionDelegate setSinkView:[self view]];
    [self setSinkTransition:modalTransitionDelegate];
    
    [self setDataSource:[[HEMInsightsFeedDataSource alloc] initWithQuestionTarget:self
                                                             questionSkipSelector:@selector(skipQuestions:)
                                                           questionAnswerSelector:@selector(answerQuestions:)]];
    
    [[self collectionView] setDataSource:[self dataSource]];
    [[self collectionView] setDelegate:self];
    [[self collectionView] setAlwaysBounceVertical:YES];
    
    [SENAnalytics track:kHEMAnalyticsEventFeed];
}

- (void)viewDidBecomeActive {
    [super viewDidBecomeActive];
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reload];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reload)
                                                 name:SENAPIReachableNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload {
    if ([[self dataSource] isLoading]) return;
    
    __weak typeof(self) weakSelf = self;
    [[self dataSource] refresh:^(BOOL didUpdate){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!didUpdate)
            return;
        HEMCardFlowLayout* layout = (id)[[strongSelf collectionView] collectionViewLayout];
        [layout clearCache];
        [[strongSelf collectionView] reloadData];
    }];
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HEMCardFlowLayout* cardLayout = (HEMCardFlowLayout*)collectionViewLayout;
    CGSize itemSize = [cardLayout itemSize];
    
    CGFloat textPadding = [[self dataSource] bodyTextPaddingForCellAtIndexPath:indexPath];
    
    itemSize.height = [[self dataSource] heightForCellAtIndexPath:indexPath
                                                        withWidth:itemSize.width - (textPadding*2)];
    return itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [[self dataSource] displayCell:cell atIndexPath:indexPath];
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SENInsight* insight = [[self dataSource] insightAtIndexPath:indexPath];
    if (insight != nil) {
        [self showInsight:insight];
    }
}


- (void)removeCellAtIndexPath:(NSIndexPath*)indexPath {
    [[self collectionView] performBatchUpdates:^{
        [[self dataSource] removeQuestionAtIndexPath:indexPath];
        [[self collectionView] deleteItemsAtIndexPaths:@[indexPath]];
    } completion:nil];
}

#pragma mark - Insights

- (void)showInsight:(SENInsight*)insight {
    HEMInsightViewController* insightVC
        = (HEMInsightViewController*)[HEMMainStoryboard instantiateSleepInsightViewController];
    [insightVC setInsight:insight];
    [insightVC setModalPresentationStyle:UIModalPresentationCustom];
    [insightVC setTransitioningDelegate:[self sinkTransition]];
    [self presentViewController:insightVC animated:YES completion:nil];
}

#pragma mark - Questions

- (void)answerQuestions:(UIButton*)sender {
    NSIndexPath* path = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    
    HEMSleepQuestionsViewController* qVC
        = (HEMSleepQuestionsViewController*)[HEMMainStoryboard instantiateSleepQuestionsViewController];
    
    if ([self questionsTransition] == nil) {
        HEMBounceModalTransition* transition = [[HEMBounceModalTransition alloc] init];
        [transition setMessage:NSLocalizedString(@"sleep.questions.end.message", nil)];
        [self setQuestionsTransition:transition];
    }
    
    HEMStyledNavigationViewController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:qVC];
    [nav setModalPresentationStyle:UIModalPresentationCustom];
    [nav setTransitioningDelegate:[self questionsTransition]];
    
    [self presentViewController:nav animated:YES completion:^{
        [self removeCellAtIndexPath:path];
    }];
}

- (void)skipQuestions:(UIButton*)sender {
    [sender setEnabled:NO];
    NSIndexPath* path = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    SENQuestion* question = [[self dataSource] questionAtIndexPath:path];
    __weak typeof(self) weakSelf = self;
    [[SENServiceQuestions sharedService] skipQuestion:question completion:^(NSError *error) {
        [weakSelf removeCellAtIndexPath:path];
        [sender setEnabled:YES];
    }];
}

#pragma mark - Clean Up

- (void)dealloc {
    [_collectionView setDelegate:nil];
    [_collectionView setDataSource:nil];
}

@end