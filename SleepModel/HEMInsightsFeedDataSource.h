//
//  HEMInsightsFeedDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SENInsight;
@class SENQuestion;

@interface HEMInsightsFeedDataSource : NSObject <UICollectionViewDataSource>

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width;
- (CGFloat)bodyTextPaddingForCellAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)isLoading;
- (void)refresh:(void(^)(void))completion;
- (SENQuestion*)questionAtIndexPath:(NSIndexPath*)indexPath;
- (SENInsight*)insightAtIndexPath:(NSIndexPath*)indexPath;
- (void)removeQuestionAtIndexPath:(NSIndexPath*)indexPath;
- (NSString*)dateForCellAtIndexPath:(NSIndexPath*)indexPath;
- (NSString*)insightTitleForCellAtIndexPath:(NSIndexPath*)indexPath;
- (NSString*)bodyTextForCellAtIndexPath:(NSIndexPath*)indexPath;

@end
