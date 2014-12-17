//
//  HEMInsightsFeedDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NSInteger const HEMInsightsFeedSectQuestions;
NSInteger const HEMInsightsFeedSectInsights;
NSInteger const HEMInsightsFeedSections;

@interface HEMInsightsFeedDataSource : NSObject <UICollectionViewDataSource>

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath*)indexPath withWidth:(CGFloat)width;
- (BOOL)isLoading;
- (void)refresh:(void(^)(void))completion;
- (NSString*)bodyTextForCellAtIndexPath:(NSIndexPath*)indexPath;

@end
