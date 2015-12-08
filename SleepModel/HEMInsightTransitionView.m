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

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

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
    
    UIImageView* imageView = [self imageView];
    if (![self imageView]) {
        imageView = [UIImageView new];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [imageView setClipsToBounds:YES];
        
        [self addSubview:imageView];
        [self setImageView:imageView];
    }
    [imageView setFrame:imageFrame];
    [imageView setImage:[cellImageView image]];
    [imageView setContentMode:[cellImageView contentMode]];
    [imageView setBackgroundColor:[cellImageView backgroundColor]];
}

- (void)expand:(CGSize)size imageHeight:(CGFloat)imageHeight {
    CGRect frame = [self frame];
    frame.origin = CGPointZero;
    frame.size = size;
    
    CGRect imageFrame = [[self imageView] frame];
    imageFrame.size.height = imageHeight;
    [[self imageView] setFrame:imageFrame];
    
    [self setFrame:frame];
}

- (void)shrink:(CGRect)frame imageHeight:(CGFloat)imageHeight {
    CGRect imageFrame = [[self imageView] frame];
    imageFrame.size.height = imageHeight;
    [[self imageView] setFrame:imageFrame];
    [self setFrame:frame];
}

@end
