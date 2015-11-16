//
//  HEMInsightsFeedDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEMUnreadAlertService.h"

@class SENInsight;
@class SENQuestion;

typedef NS_ENUM(NSInteger, HEMInsightsFeedError) {
    HEMInsightsFeedErrorNoData = -1
};

@interface HEMInsightsFeedDataSource : NSObject <UICollectionViewDataSource>

- (id)initWithQuestionTarget:(id)target questionSkipSelector:(SEL)skipSelector questionAnswerSelector:(SEL)answerSelector;

/**
 * Check to see if either insights or questions have anything new.  At the time
 * of this implementation, this matches exactly as the service's hasUnread method,
 * but this guards against changes to that method that is not relevant to this
 * controller
 */
- (BOOL)hasUnreadItems;
- (void)updateLastViewed:(HEMUnreadTypes)types completion:(void(^)(NSError* error))completion;
- (CGFloat)heightForCellAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width;
- (CGFloat)bodyTextPaddingForCellAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)isLoading;
- (BOOL)hasData;
- (void)refresh:(void(^)(BOOL didUpdate))completion;
- (SENQuestion*)questionAtIndexPath:(NSIndexPath*)indexPath;
- (SENInsight*)insightAtIndexPath:(NSIndexPath*)indexPath;
- (void)removeQuestionAtIndexPath:(NSIndexPath*)indexPath;
- (NSString*)dateForCellAtIndexPath:(NSIndexPath*)indexPath;
- (NSString*)insightTitleForCellAtIndexPath:(NSIndexPath*)indexPath;
- (NSString*)bodyTextForCellAtIndexPath:(NSIndexPath*)indexPath;
- (void)displayCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;

@end
