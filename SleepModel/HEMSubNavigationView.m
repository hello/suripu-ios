//
//  HEMSubNavigationView.m
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSubNavigationView.h"
#import "HEMNavigationShadowView.h"
#import "HEMStyle.h"

static CGFloat const HEMSubNavigationViewBorderHeight = 1.0f;

@interface HEMSubNavigationView()

@property (nonatomic, assign) NSInteger controlCount;
@property (nonatomic, weak) HEMNavigationShadowView* shadowView;

@end

@implementation HEMSubNavigationView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addSeparator];
        [self addShadowView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSeparator];
        [self addShadowView];
    }
    return self;
}

- (void)addShadowView {
    HEMNavigationShadowView* shadowView
        = [[HEMNavigationShadowView alloc] initWithNavigationBar:self];
    [self addSubview:shadowView];
    [self setShadowView:shadowView];
    [self setClipsToBounds:NO];
}

- (void)addSeparator {
    CGRect separatorFrame = CGRectZero;
    separatorFrame.origin.y = CGRectGetHeight([self bounds]) - HEMSubNavigationViewBorderHeight;
    separatorFrame.size.width = CGRectGetWidth([self bounds]);
    separatorFrame.size.height = HEMSubNavigationViewBorderHeight;
    
    UIView* separator = [[UIView alloc] initWithFrame:separatorFrame];
    [separator setAutoresizingMask:UIViewAutoresizingFlexibleWidth
                                    | UIViewAutoresizingFlexibleTopMargin];
    [separator setBackgroundColor:[UIColor borderColor]];
    
    [self addSubview:separator];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSInteger controlIndex = 0;
    CGFloat fullWidth = CGRectGetWidth([self bounds]);
    CGFloat fullHeight = CGRectGetHeight([self bounds]);
    CGFloat controlWidth = fullWidth / MAX(1, [self controlCount]);
    
    for (UIView* subview in [self subviews]) {
        if ([subview isKindOfClass:[UIControl class]]) {
            CGRect controlFrame = [subview frame];
            controlFrame.origin.x = controlIndex * controlWidth;
            controlFrame.size.width = controlWidth;
            controlFrame.size.height = fullHeight - HEMSubNavigationViewBorderHeight;
            [subview setFrame:controlFrame];
            controlIndex++;
        }
    }
    
    CGRect shadowFrame = [[self shadowView] frame];
    shadowFrame.size.width = fullWidth;
    shadowFrame.origin.y = fullHeight;
    shadowFrame.origin.x = 0.0f;
    [[self shadowView] setFrame:shadowFrame];
}

- (BOOL)hasControls {
    return [self controlCount] > 0;
}

- (void)reset {
    for (UIView* subview in [self subviews]) {
        if ([subview isKindOfClass:[UIControl class]]) {
            [subview removeFromSuperview];
        }
    }
    [self setSelectedControlTag:-1];
    [self setPreviousControlTag:-1];
    [self setControlCount:0];
}

- (void)addControl:(UIControl*)control {
    id existingControl = [self viewWithTag:[control tag]];
    if (!existingControl) {
        [control addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
        [self setControlCount:[self controlCount] + 1];
        [self addSubview:control];
        [self setNeedsLayout];
        
        if ([control isSelected]) {
            [self setSelectedControlTag:[control tag]];
        }
    }
}

- (void)select:(UIControl*)control {
    [self selectControlWithTag:[control tag]];
}

- (void)selectControlWithTag:(NSInteger)tag {
    [self setPreviousControlTag:[self selectedControlTag]];
    [self setSelectedControlTag:tag];
    for (UIView* subview in [self subviews]) {
        if ([subview isKindOfClass:[UIControl class]]) {
            UIControl* subControl = (UIControl*) subview;
            [subControl setSelected:tag == [subControl tag]];
        }
    }
}

@end
