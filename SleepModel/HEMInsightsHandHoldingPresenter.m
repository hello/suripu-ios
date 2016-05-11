//
//  HEMInsightsHandHoldingPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 1/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMInsightsHandHoldingPresenter.h"
#import "HEMHandHoldingService.h"
#import "HEMHandholdingView.h"
#import "HEMInsightCollectionViewCell.h"

@interface HEMInsightsHandHoldingPresenter()

@property (nonatomic, weak) HEMHandHoldingService* service;

@end

@implementation HEMInsightsHandHoldingPresenter

- (instancetype)initWithHandHoldingService:(HEMHandHoldingService*)service {
    self = [super init];
    if (self) {
        _service = service;
    }
    return self;
}

- (UICollectionViewCell*)insightCellToShowTapTargetOnIn:(UICollectionView*)collectionView {
    NSArray* visibleCells = [collectionView visibleCells];
    UICollectionViewCell* firstUsableInsightCell = [visibleCells firstObject];
    
    CGFloat currentOffset = [collectionView contentOffset].y;
    for (UICollectionViewCell* cell in visibleCells) {
        CGFloat minY = CGRectGetMinY([cell frame]);
        if ([cell isKindOfClass:[HEMInsightCollectionViewCell class]]
            && minY > currentOffset - 10.0f
            && minY < CGRectGetMinY([firstUsableInsightCell frame])) {
            firstUsableInsightCell = cell;
        }
    }
    
    return firstUsableInsightCell;
}

- (void)showIfNeededIn:(UIView*)containerView withCollectionView:(UICollectionView*)collectionView {
    if (!containerView || ![[self service] shouldShow:HEMHandHoldingInsightTap]) {
        return;
    }
    
    NSInteger numberOfItems = [collectionView numberOfItemsInSection:0];
    if (numberOfItems > 0) {
        int64_t delay = (int64_t)(1.0f * NSEC_PER_SEC);
        __weak typeof(self) weakSelf = self;
        
        // must dispatch after a delay due to rendering of the cells and also
        // because we want a slight delay anyways
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if ([strongSelf isVisible]) {
                UICollectionViewCell* insightCell = [strongSelf insightCellToShowTapTargetOnIn:collectionView];
                if (insightCell) {
                    CGRect frame = [insightCell convertRect:[insightCell bounds]
                                                     toView:containerView];
                    CGPoint midPoint = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
                    
                    HEMHandholdingView* handholdingView = [[HEMHandholdingView alloc] init];
                    [handholdingView setGestureStartCenter:midPoint];
                    [handholdingView setGestureEndCenter:midPoint];
                    
                    [handholdingView setMessage:NSLocalizedString(@"handholding.message.insight-tap", nil)];
                    [handholdingView setAnchor:HEMHHDialogAnchorBottom];
                    
                    __weak typeof(self) weakSelf = self;
                    [handholdingView showInView:containerView fromContentView:collectionView dismissAction:^(BOOL shown) {
                        __strong typeof(weakSelf) strongSelf = self;
                        if (shown) {
                            [strongSelf didCompleteHandHolding];
                        }
                    }];
                    
                } else {
                    DDLogVerbose(@"did not find first insight cell to show handholding");
                }
                
            }
        });
        
    }
}

- (void)didCompleteHandHolding {
    [[self service] completed:HEMHandHoldingInsightTap];
}

@end
