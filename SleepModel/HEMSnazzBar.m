//
//  HEMSnazzBar.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIColor+HEMStyle.h"

#import "HEMSnazzBar.h"
#import "HEMSnazzBarButton.h"

CGFloat const HEMSnazzBarAnimationDuration = 0.25f;

@interface HEMSnazzBar ()

@property (nonatomic, strong) UIView* indicatorView;
@property (nonatomic, strong) UIView* bottomBorderView;
@property (nonatomic) NSUInteger selectionIndex;
@end

@implementation HEMSnazzBar

static CGFloat const HEMSnazzBarTopMargin = 20.f;
static CGFloat const HEMSnazzBarIndicatorHeight = 1.0f;
static CGFloat const HEMSnazzBarBorderHeight = 1.0f;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _bottomBorderView = [UIView new];
        _bottomBorderView.backgroundColor = [UIColor borderColor];
        [self addSubview:_bottomBorderView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutBarButtons];
    [self layoutBorder];
}

- (void)layoutBorder {
    CGRect borderRect = [[self bottomBorderView] frame];
    borderRect.size.height = HEMSnazzBarBorderHeight;
    borderRect.size.width = CGRectGetWidth([self bounds]);
    borderRect.origin.y = CGRectGetHeight([self bounds]) - HEMSnazzBarBorderHeight;
    [[self bottomBorderView] setFrame:borderRect];
}

- (void)layoutBarButtons
{
    NSArray* buttons = [self buttons];
    if (buttons.count == 0)
        return;

    CGFloat width = ((CGRectGetWidth(self.bounds)) / buttons.count);
    CGSize buttonSize = CGSizeMake(width, CGRectGetHeight(self.bounds) - HEMSnazzBarTopMargin);
    for (int i = 0; i < buttons.count; i++) {
        UIButton* button = buttons[i];
        CGFloat x = i * buttonSize.width;
        button.frame = (CGRect){ .size = buttonSize, .origin = CGPointMake(x, HEMSnazzBarTopMargin)};
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

- (void)addButtonWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage
{
    [self addButtonAtIndex:self.buttons.count withTitle:title image:image selectedImage:selectedImage];
}

- (void)addButtonAtIndex:(NSUInteger)index
               withTitle:(NSString *)title
                   image:(UIImage *)image
           selectedImage:(UIImage*)selectedImage
{
    HEMSnazzBarButton* button = [HEMSnazzBarButton buttonWithType:UIButtonTypeCustom];
    button.accessibilityLabel = title;
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:selectedImage forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [self setNeedsLayout];
}

- (void)selectButtonAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    NSArray* buttons = [self buttons];
    if (index >= buttons.count)
        return;

    self.selectionIndex = index;
    for (int i = 0; i < buttons.count; i++) {
        HEMSnazzBarButton* button = buttons[i];
        if ((button.selected = (i == index))) {
            [button setUnread:NO]; // always hide when selected
            
            void (^animations)() = ^{
                [self indicateButtonSelected:button];
                button.selected = YES;
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
        } else {
            button.selected = NO;
        }
    }
}

- (void)showUnreadIndicator:(BOOL)unread atIndex:(NSUInteger)index {
    NSArray* buttons = [self buttons];
    if (index < buttons.count) {
        HEMSnazzBarButton* snazzButton = buttons[index];
        [snazzButton setUnread:unread];
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

- (void)animateSelectedButtonState:(BOOL)selected {
    NSArray* buttons = [self buttons];
    UIButton* button = buttons[self.selectionIndex];
    if (button.selected == selected) {
        return;
    }
    
    // selected state of a UIButton is not a property that can be animated and thus
    // using transitionWithView
    [UIView transitionWithView:button
                      duration:HEMSnazzBarAnimationDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                               | UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
                        button.selected = selected;
                    }
                    completion:nil];
}

- (void)setSelectionRatio:(CGFloat)ratio
{
    CGFloat indicatorWidth = CGRectGetWidth(self.indicatorView.bounds);
    if (indicatorWidth == 0.0f) {
        return;
    }
    
    CGFloat totalWidth = CGRectGetWidth(self.bounds);
    CGFloat ratioOfOneSelection = indicatorWidth / totalWidth;
    CGFloat partialIndex = ratio / ratioOfOneSelection;
    CGFloat remainder = fabs(floorf(partialIndex) - partialIndex);
    
    CGFloat const epsilon = 0.000000001f;
    BOOL partialSelection = remainder > epsilon;

    if (partialSelection && self.selectionIndex != NSNotFound) {
        [self animateSelectedButtonState:NO];
        [self setSelectionIndex:NSNotFound];
    } else if (!partialSelection) {
        [self setSelectionIndex:ceilf(partialIndex)];
        [self animateSelectedButtonState:YES];
    }

    CGRect frame = self.indicatorView.frame;
    frame.origin.x = ratio * totalWidth;
    self.indicatorView.frame = frame;
}

@end
