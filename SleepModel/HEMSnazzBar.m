//
//  HEMSnazzBar.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSnazzBar.h"
#import "HEMSnazzBarButton.h"

CGFloat const HEMSnazzBarAnimationDuration = 0.25f;

@interface HEMSnazzBar ()

@property (nonatomic, strong) UIView* indicatorView;
@end

@implementation HEMSnazzBar

static CGFloat const HEMSnazzBarMargin = 8.f;
static CGFloat const HEMSnazzBarIndicatorHeight = 2.f;

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutBarButtons];
}

- (void)layoutBarButtons
{
    NSArray* buttons = [self buttons];
    if (buttons.count == 0)
        return;

    CGFloat outerMargin = HEMSnazzBarMargin * 2;
    CGFloat innerMargin = HEMSnazzBarMargin * (buttons.count - 1);
    CGFloat width = ((CGRectGetWidth(self.bounds) - outerMargin - innerMargin) / buttons.count);
    CGSize buttonSize = CGSizeMake(width, CGRectGetHeight(self.bounds) - outerMargin);
    for (int i = 0; i < buttons.count; i++) {
        UIButton* button = buttons[i];
        CGFloat x = (i * buttonSize.width) + (HEMSnazzBarMargin * (i + 1));
        button.frame = (CGRect){ .size = buttonSize, .origin = CGPointMake(x, HEMSnazzBarMargin)};
        if ([button isSelected])
            [self indicateButtonSelected:button];
    }
}

- (void)indicateButtonSelected:(UIButton*)button
{
    CGRect frame = CGRectMake(CGRectGetMinX(button.frame),
                              CGRectGetHeight(self.bounds) - HEMSnazzBarIndicatorHeight,
                              CGRectGetWidth(button.bounds),
                              HEMSnazzBarIndicatorHeight);
    if (self.indicatorView) {
        self.indicatorView.frame = frame;
    } else {
        self.indicatorView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:self.indicatorView];
    }
    self.indicatorView.backgroundColor = self.selectionColor;
}

- (void)setSelectionColor:(UIColor *)selectionColor
{
    self.indicatorView.backgroundColor = selectionColor;
    for (UIButton* button in self.buttons) {
        [button setTintColor:self.selectionColor];
    }
    _selectionColor = selectionColor;
}

#pragma mark - Button management

- (NSArray*)buttons
{
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:self.subviews.count];
    for (UIView* view in self.subviews) {
        if ([view isKindOfClass:[HEMSnazzBarButton class]])
            [buttons addObject:view];
    }
    return buttons;
}

- (void)buttonPressed:(UIButton*)button
{
    NSUInteger index = [self.buttons indexOfObjectIdenticalTo:button];
    if (index != NSNotFound)
        [self.delegate bar:self didReceiveTouchUpInsideAtIndex:index];
}

- (void)addButtonWithTitle:(NSString *)title image:(UIImage *)image
{
    [self addButtonAtIndex:self.buttons.count withTitle:title image:image];
}

- (void)addButtonAtIndex:(NSUInteger)index withTitle:(NSString *)title image:(UIImage *)image
{
    HEMSnazzBarButton* button = [HEMSnazzBarButton buttonWithType:UIButtonTypeCustom];
    button.accessibilityLabel = title;
    UIImage* template = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:template forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTintColor:self.selectionColor];
    [self addSubview:button];
    [self setNeedsLayout];
}

- (void)selectButtonAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    NSArray* buttons = [self buttons];
    if (index >= buttons.count)
        return;

    for (int i = 0; i < buttons.count; i++) {
        UIButton* button = buttons[i];
        if ((button.selected = (i == index))) {
            void (^animations)() = ^{
                [self indicateButtonSelected:button];
            };
            if (animated)
                [UIView animateWithDuration:HEMSnazzBarAnimationDuration
                                      delay:0
                     usingSpringWithDamping:0.8
                      initialSpringVelocity:0
                                    options:(UIViewAnimationOptionCurveEaseInOut)
                                 animations:animations
                                 completion:NULL];
            else
                animations();
        }
    }
}

- (void)removeAllButtons
{
    [self.buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)removeButtonAtIndex:(NSUInteger)index
{
    NSArray* buttons = [self buttons];
    if (index >= buttons.count)
        return;

    UIButton* button = buttons[index];
    [button removeFromSuperview];
    [self setNeedsLayout];
}

@end
