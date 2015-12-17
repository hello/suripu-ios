//
//  HEMInsightTransitionView.h
//  Sense
//
//  Created by Jimmy Lu on 12/7/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMInsightCollectionViewCell;

NS_ASSUME_NONNULL_BEGIN

@interface HEMInsightTransitionView : UIView

+ (instancetype)transitionViewFromCell:(HEMInsightCollectionViewCell*)cell;
- (void)copyFromCell:(HEMInsightCollectionViewCell*)cell;
- (void)expand:(CGSize)size imageHeight:(CGFloat)imageHeight;
- (void)shrink:(CGRect)frame imageHeight:(CGFloat)imageHeight;

@end

NS_ASSUME_NONNULL_END
