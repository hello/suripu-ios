//
//  HEMNavigationShadowView.h
//  Sense
//
//  Created by Jimmy Lu on 12/9/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HEMNavigationShadowView : UIView

@property (nonatomic, assign) CGFloat topOffset;

- (instancetype)initWithNavigationBar:(UIView*)navBar;
- (void)updateVisibilityWithContentOffset:(CGFloat)contentOffset;
- (void)showSeparator:(BOOL)show;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
