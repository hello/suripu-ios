//
//  HEMInsightFeedViewController.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENServiceQuestions.h>
#import <SenseKit/SENQuestion.h>

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
#import "HEMSinkModalTransitionDelegate.h"

@interface HEMInsightFeedViewController () <
    UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak,   nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HEMInsightsFeedDataSource* dataSource;
@property (strong, nonatomic) id <UIViewControllerTransitioningDelegate> animTransitionDelegate;

@end

@implementation HEMInsightFeedViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.image = [HelloStyleKit senseBarIcon];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HEMSinkModalTransitionDelegate* modalTransitionDelegate = [[HEMSinkModalTransitionDelegate alloc] init];
    [modalTransitionDelegate setSinkView:[self collectionView]];
    [self setAnimTransitionDelegate:modalTransitionDelegate];
    
    [self setDataSource:[[HEMInsightsFeedDataSource alloc] init]];
    
    [[self collectionView] setDataSource:[self dataSource]];
    [[self collectionView] setDelegate:self];
    [[self collectionView] setAlwaysBounceVertical:YES];
}

- (void)viewDidBecomeActive {
    [super viewDidBecomeActive];
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reload];
}

- (void)reload {
    if ([[self dataSource] isLoading]) return;
    
    __weak typeof(self) weakSelf = self;
    [[self dataSource] refresh:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            HEMCardFlowLayout* layout
                = (HEMCardFlowLayout*)[[strongSelf collectionView] collectionViewLayout];
            [layout clearCache];
            [[strongSelf collectionView] reloadData];
        }
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
    
    NSString* body = [[self dataSource] bodyTextForCellAtIndexPath:indexPath];
   
    if ([cell isKindOfClass:[HEMQuestionCell class]]) {
        HEMQuestionCell* qCell = (HEMQuestionCell*)cell;
        NSDictionary* attributes = [HEMQuestionCell questionTextAttributes];
        NSMutableAttributedString* attrBody
            = [[NSMutableAttributedString alloc] initWithString:body attributes:attributes];
        [[qCell questionLabel] setAttributedText:attrBody];
        [[qCell answerButton] addTarget:self
                                 action:@selector(answerQuestions:)
                       forControlEvents:UIControlEventTouchUpInside];
        [[qCell answerButton] setTag:[indexPath row]];
        [[qCell skipButton] addTarget:self
                               action:@selector(skipQuestions:)
                     forControlEvents:UIControlEventTouchUpInside];
        [[qCell skipButton] setTag:[indexPath row]];
    } else if ([cell isKindOfClass:[HEMInsightCollectionViewCell class]]) {
        HEMInsightCollectionViewCell* iCell = (HEMInsightCollectionViewCell*)cell;
        [iCell setMessage:body];
        [[iCell titleLabel] setText:[[self dataSource] insightTitleForCellAtIndexPath:indexPath]];
        [[iCell dateLabel] setText:[[self dataSource] dateForCellAtIndexPath:indexPath]];
    }
    
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
    [insightVC setTransitioningDelegate:[self animTransitionDelegate]];
    [self presentViewController:insightVC animated:YES completion:nil];
}

#pragma mark - Questions

- (void)answerQuestions:(UIButton*)sender {
    NSIndexPath* path = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    
    HEMSleepQuestionsViewController* qVC
        = (HEMSleepQuestionsViewController*)[HEMMainStoryboard instantiateSleepQuestionsViewController];
    [qVC setModalPresentationStyle:UIModalPresentationCustom];
    [qVC setTransitioningDelegate:[self animTransitionDelegate]];
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:qVC];
    
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

@end

