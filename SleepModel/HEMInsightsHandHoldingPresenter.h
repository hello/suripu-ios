//
//  HEMInsightsHandHoldingPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 1/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMHandHoldingService;

NS_ASSUME_NONNULL_BEGIN

@interface HEMInsightsHandHoldingPresenter : HEMPresenter

- (instancetype)initWithHandHoldingService:(HEMHandHoldingService*)service;

/**
 * @discussion
 * Show hand holding tutorials as needed
 *
 * @param containerView: the view to place the hand holding views in
 */
- (void)showIfNeededIn:(UIView*)containerView withCollectionView:(UICollectionView*)collectionView;

/**
 * @discussion
 *
 * Controller should call this when the action was completed
 */
- (void)didCompleteHandHolding;

@end

NS_ASSUME_NONNULL_END