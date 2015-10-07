//
//  HEMSnazzBar.h
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const HEMSnazzBarAnimationDuration;

@class HEMSnazzBar;

@protocol HEMSnazzBarDelegate <NSObject>

@required

- (void)bar:(HEMSnazzBar*)bar didReceiveTouchUpInsideAtIndex:(NSUInteger)index;
@end

@interface HEMSnazzBar : UIView

- (void)removeAllButtons;
- (void)addButtonWithTitle:(NSString*)title image:(UIImage*)image selectedImage:(UIImage*)selectedImage;
- (void)selectButtonAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)showUnreadIndicator:(BOOL)unread atIndex:(NSUInteger)index;
- (void)removeButtonAtIndex:(NSUInteger)index;
- (void)setSelectionRatio:(CGFloat)ratio;

@property (nonatomic, weak) id<HEMSnazzBarDelegate> delegate;
@property (nonatomic, strong) UIColor* selectionColor;
@end
