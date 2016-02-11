//
//  HEMSubNavigationView.m
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSubNavigationView.h"
#import "HEMStyle.h"

static CGFloat const HEMSubNavigationViewBorderHeight = 1.0f;

@interface HEMSubNavigationView()

@property (nonatomic, assign) NSInteger controlCount;

@end

@implementation HEMSubNavigationView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addSeparator];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSeparator];
    }
    return self;
}

- (void)addSeparator {
    CGRect separatorFrame = CGRectZero;
    separatorFrame.origin.y = CGRectGetHeight([self bounds]) - HEMSubNavigationViewBorderHeight;
    separatorFrame.size.width = CGRectGetWidth([self bounds]);
    separatorFrame.size.height = HEMSubNavigationViewBorderHeight;
    
    UIView* separator = [[UIView alloc] initWithFrame:separatorFrame];
    [separator setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
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
}

- (BOOL)hasControls {
    return [self controlCount] > 0;
}

- (void)addControl:(UIControl*)control {
    [control addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    [self setControlCount:[self controlCount] + 1];
    [self addSubview:control];
    [self setNeedsLayout];
    
    if ([control isSelected]) {
        [self setSelectedControlTag:[control tag]];
    }
}

- (void)select:(UIControl*)control {
    [self setSelectedControlTag:[control tag]];
    for (UIView* subview in [self subviews]) {
        if ([subview isKindOfClass:[UIControl class]]) {
            UIControl* subControl = (UIControl*) subview;
            [subControl setSelected:control == subControl];
        }
    }
}

@end
