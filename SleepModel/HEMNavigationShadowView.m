//
//  HEMNavigationShadowView.m
//  Sense
//
//  Created by Jimmy Lu on 12/9/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMNavigationShadowView.h"
#import "HEMStyle.h"

@interface HEMNavigationShadowView()

@property (nonatomic, weak) UIImageView* shadowImageView;

@end

@implementation HEMNavigationShadowView

- (instancetype)initWithNavigationBar:(UIView*)navBar {
    UIImage* image = [UIImage imageNamed:@"topShadow"];
    CGFloat width = CGRectGetWidth([navBar bounds]);
    CGRect shadowFrame = CGRectZero;
    shadowFrame.size.width = width;
    shadowFrame.size.height = image.size.height;
    shadowFrame.origin.y = CGRectGetHeight([navBar bounds]);
    
    self = [super initWithFrame:shadowFrame];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)configure {
    UIImage* image = [UIImage imageNamed:@"topShadow"];
    UIImageView* shadowView = [[UIImageView alloc] initWithImage:image];
    [shadowView setContentMode:UIViewContentModeScaleAspectFill];
    [shadowView setAutoresizingMask:UIViewAutoresizingFlexibleWidth
                                    | UIViewAutoresizingFlexibleTopMargin];
    [shadowView setFrame:[self bounds]];
    [self addSubview:shadowView];
    [self setAlpha:0.0f];
    [self setTopOffset:HEMStyleSectionTopMargin];
    [self setShadowImageView:shadowView];
}

- (void)updateVisibilityWithContentOffset:(CGFloat)contentOffset {
    CGFloat diff = MAX(0.0f, contentOffset - [self topOffset]);
    CGFloat alpha = MAX(0.0f, MIN(1.0f, diff / 10.0f));
    [self setAlpha:alpha];
    [[self superview] bringSubviewToFront:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat myWidth = CGRectGetWidth([self bounds]);
    CGRect shadowFrame = [[self shadowImageView] frame];
    shadowFrame.size.width = myWidth;
    shadowFrame.origin.x = 0.0f;
    [[self shadowImageView] setFrame:shadowFrame];
}

@end
