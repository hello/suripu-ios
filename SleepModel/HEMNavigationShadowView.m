//
//  HEMNavigationShadowView.m
//  Sense
//
//  Created by Jimmy Lu on 12/9/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMNavigationShadowView.h"
#import "HEMStyle.h"

static CGFloat const HEMNavigationShadowViewBorderHeight = 1.0f;

@interface HEMNavigationShadowView()

@property (nonatomic, weak) UIImageView* shadowImageView;
@property (nonatomic, strong) UIView* separatorView;

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
    [shadowView setAlpha:0.0f];
    
    [self addSubview:shadowView];
    [self setTopOffset:HEMStyleSectionTopMargin];
    [self setShadowImageView:shadowView];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}

- (void)addSeparator {
    CGRect separatorFrame = CGRectZero;
    separatorFrame.origin.y = 0.0f;
    separatorFrame.size.width = CGRectGetWidth([self bounds]);
    separatorFrame.size.height = HEMNavigationShadowViewBorderHeight;
    
    UIView* separator = [[UIView alloc] initWithFrame:separatorFrame];
    [separator setAutoresizingMask:UIViewAutoresizingFlexibleWidth
     | UIViewAutoresizingFlexibleTopMargin];
    [separator setBackgroundColor:[UIColor borderColor]];
    
    [self addSubview:separator];
    [self setSeparatorView:separator];
}

- (void)showSeparator:(BOOL)show {
    if (show && ![self separatorView]) {
        [self addSeparator];
    }
    [[self separatorView] setAlpha:show ? 1.0f : 0.0f];
}

- (void)reset {
    [[self shadowImageView] setAlpha:0.0f];
}

- (void)updateVisibilityWithContentOffset:(CGFloat)contentOffset {
    CGFloat diff = MAX(0.0f, contentOffset - [self topOffset]);
    CGFloat alpha = MAX(0.0f, MIN(1.0f, diff / 10.0f));
    [[self shadowImageView] setAlpha:alpha];
    [[self superview] bringSubviewToFront:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat myWidth = CGRectGetWidth([self bounds]);
    CGRect shadowFrame = [[self shadowImageView] frame];
    shadowFrame.size.width = myWidth;
    shadowFrame.origin.x = 0.0f;
    [[self shadowImageView] setFrame:shadowFrame];
    
    CGRect separatorFrame = [[self separatorView] frame];
    separatorFrame.size.width = myWidth;
    separatorFrame.origin.x = 0.0f;
    [[self separatorView] setFrame:separatorFrame];
}

@end
