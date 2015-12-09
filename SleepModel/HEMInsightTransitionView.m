//
//  HEMInsightTransitionView.m
//  Sense
//
//  Created by Jimmy Lu on 12/7/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMInsightTransitionView.h"
#import "HEMInsightCollectionViewCell.h"
#import "HEMURLImageView.h"

@interface HEMInsightTransitionView()

@property (weak, nonatomic) IBOutlet UIView* containerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign, nonatomic) CGPoint originalImageOrigin;

@end

@implementation HEMInsightTransitionView

+ (instancetype)transitionViewFromCell:(HEMInsightCollectionViewCell*)cell {
    HEMInsightTransitionView* transitionView = [HEMInsightTransitionView new];
    [transitionView setFrame:[cell bounds]];
    [transitionView setBackgroundColor:[UIColor whiteColor]];
    [transitionView setClipsToBounds:YES];
    [transitionView copyFromCell:cell];
    return transitionView;
}

- (void)copyFromCell:(HEMInsightCollectionViewCell*)cell {
    HEMURLImageView* cellImageView = [cell uriImageView];
    CGFloat cellWidth = CGRectGetWidth([cell bounds]);
    CGFloat imageHeight = CGRectGetHeight([cellImageView bounds]);
    
    CGRect imageFrame = CGRectZero;
    imageFrame.size = CGSizeMake(cellWidth, imageHeight);
    imageFrame.origin = [cellImageView frame].origin;
    
    CGRect containerFrame = [[cell imageContainer] frame];
    containerFrame.origin = CGPointZero;
    containerFrame.size = CGSizeMake(cellWidth, CGRectGetHeight(containerFrame));
    
    UIView* containerView = nil;
    UIImageView* imageView = [self imageView];
    if (![self imageView]) {
        containerView = [UIView new];
        [containerView setClipsToBounds:YES];
        [containerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        imageView = [UIImageView new];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [imageView setClipsToBounds:NO];
        
        [containerView addSubview:imageView];
        [self addSubview:containerView];
        [self setImageView:imageView];
        [self setContainerView:containerView];
    }
    
    [containerView setFrame:containerFrame];
    [containerView setBackgroundColor:[[cell imageContainer] backgroundColor]];

    [imageView setFrame:imageFrame];
    [imageView setImage:[cellImageView image]];
    [imageView setContentMode:[cellImageView contentMode]];
    [imageView setBackgroundColor:[cellImageView backgroundColor]];
    
    [self setOriginalImageOrigin:[cellImageView frame].origin];
}

- (void)expand:(CGSize)size imageHeight:(CGFloat)imageHeight {
    CGRect frame = [self frame];
    frame.origin = CGPointZero;
    frame.size = size;
    
    CGRect containerFrame = [[self containerView] frame];
    containerFrame.size.height = imageHeight;
    [[self containerView] setFrame:containerFrame];
    
    CGRect imageFrame = [[self imageView] frame];
    imageFrame.origin = CGPointZero;
    imageFrame.size.height = imageHeight;
    [[self imageView] setFrame:imageFrame];
    
    [self setFrame:frame];
}

- (void)shrink:(CGRect)frame imageHeight:(CGFloat)imageHeight {
    CGRect containerFrame = [[self containerView] frame];
    containerFrame.size.height = imageHeight;
    [[self containerView] setFrame:containerFrame];
    
    CGRect imageFrame = [[self imageView] frame];
    imageFrame.origin = [self originalImageOrigin];
    imageFrame.size.height = imageHeight;
    [[self imageView] setFrame:imageFrame];
    
    [self setFrame:frame];
}

@end
