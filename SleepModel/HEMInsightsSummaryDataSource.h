//
//  HEMInsightsSummaryDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 10/30/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SENInsight;

@interface HEMInsightsSummaryDataSource : NSObject <UICollectionViewDataSource>

/**
 * Initialize the data source with the collection view that will be using this
 * source.  It is used to register the class used to display the insights
 * 
 * @param collectionView: collectionView that will be using this as the data source
 */
- (id)initWithCollectionView:(UICollectionView*)collectionView;

/**
 * Refresh the insights
 * 
 * @param completion: the block to call when it's done
 */
- (void)refreshInsights:(void(^)(void))completion;

/**
 * @return YES when insights exist, NO otherwise
 */
- (BOOL)hasInsights;

/**
 * @param indexPath: the index path of the displayed insight
 * @return SENInsight object
 */
- (SENInsight*)insightAtIndexPath:(NSIndexPath*)indexPath;

@end
