//
//  HEMInsightFeedViewController.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMInsightFeedViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMInsightsFeedDataSource.h"
#import "HEMCardFlowLayout.h"
#import "HEMQuestionCell.h"

@interface HEMInsightFeedViewController () <
    UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HEMInsightsFeedDataSource* dataSource;

@end

@implementation HEMInsightFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDataSource:[[HEMInsightsFeedDataSource alloc] init]];
    [[self collectionView] setDataSource:[self dataSource]];
    [[self collectionView] setDelegate:self];
}

- (void)viewDidBecomeActive {
    [super viewDidBecomeActive];
    [[self dataSource] refresh:^{
        [[self collectionView] reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self dataSource] refresh:^{
        [[self collectionView] reloadData];
    }];
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HEMCardFlowLayout* cardLayout = (HEMCardFlowLayout*)collectionViewLayout;
    CGSize itemSize = [cardLayout itemSize];
    
    CGFloat textPadding = 0.0f;
    if ([indexPath section] == HEMInsightsFeedSectQuestions) {
        textPadding = HEMQuestionTextPadding;
    }
    
    itemSize.height = [[self dataSource] heightForCellAtIndexPath:indexPath
                                                        withWidth:itemSize.width - (textPadding*2)];
    return itemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    HEMCardFlowLayout* layout = (HEMCardFlowLayout*)collectionViewLayout;
    
    UIEdgeInsets insets = [layout sectionInset];
    if (section == HEMInsightsFeedSectQuestions) {
        insets.bottom = 0.0f;
    } else if (section == HEMInsightsFeedSectInsights) {
        insets.top = [layout minimumInteritemSpacing];
    }
    
    return insets;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[HEMQuestionCell class]]) {
        HEMQuestionCell* qCell = (HEMQuestionCell*)cell;
        NSString* body = [[self dataSource] bodyTextForCellAtIndexPath:indexPath];
        [[qCell questionLabel] setText:body];
    }
    
}

@end

