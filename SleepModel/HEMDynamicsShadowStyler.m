//
//  HEMDynamicsShadowStyler.m
//  Sense
//
//  Created by Jimmy Lu on 12/9/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMDynamicsShadowStyler.h"

@interface HEMDynamicsShadowStyler()

@property (nonatomic, weak) UIView* shadowView;

@end

@implementation HEMDynamicsShadowStyler

+ (instancetype)styler {
    return [self new];
}

- (UIImageView*)shadowImageViewWithWidth:(CGFloat)width {
    UIImage* image = [UIImage imageNamed:@"bottomShadow"];
    
    CGRect shadowFrame = CGRectZero;
    shadowFrame.origin.y = -image.size.height;
    shadowFrame.size.width = width;
    shadowFrame.size.height = image.size.height;
    
    UIImageView* shadowView = [[UIImageView alloc] initWithImage:image];
    [shadowView setFrame:shadowFrame];
    
    return shadowView;
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController
         didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction
                        forDirection:(MSDynamicsDrawerDirection)direction {
    if (![self shadowView]) {
        CGFloat width = CGRectGetWidth([[dynamicsDrawerViewController view] bounds]);
        UIImageView* shadowView = [self shadowImageViewWithWidth:width];
        
        [[dynamicsDrawerViewController paneView] setClipsToBounds:NO];
        [[dynamicsDrawerViewController paneView] addSubview:shadowView];
        [self setShadowView:shadowView];
    }
    [[self shadowView] setAlpha:1.0f - paneClosedFraction];
}

- (void)stylerWasRemovedFromDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController
                                            forDirection:(MSDynamicsDrawerDirection)direction {
    [[self shadowView] removeFromSuperview];
    [self setShadowView:nil];
}

@end
