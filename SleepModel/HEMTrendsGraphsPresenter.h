//
//  HEMTrendsGraphsPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMTrendsService;
@class HEMActivityIndicatorView;

NS_ASSUME_NONNULL_BEGIN

@interface HEMTrendsGraphsPresenter : HEMPresenter

- (instancetype)initWithTrendsService:(HEMTrendsService*)trendService
                            dataScale:(SENTrendsTimeScale)scale;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;
- (void)bindWithLoadingIndicator:(HEMActivityIndicatorView*)loadingIndicator;
- (NSString*)scaleTitle;

@end

NS_ASSUME_NONNULL_END
