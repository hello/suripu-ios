//
//  HEMScopePickerView.m
//  Sense
//
//  Created by Delisa Mason on 1/14/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMScopePickerView.h"
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"

@interface HEMScopePickerView ()
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic, strong) UIView* selectionView;
@property (nonatomic, strong) NSMutableArray* buttons;
@property (nonatomic, strong) NSMutableArray* separatorViews;
@end

@implementation HEMScopePickerView

static CGFloat const HEMScopePickerHeight = 45.f;
static CGFloat const HEMScopePickerSelectionViewHeight = 1.f;
static NSInteger const HEMScopePickerButtonOffset = 3242026;

- (void)awakeFromNib
{
    self.selectionView = [UIView new];
    self.selectionView.backgroundColor = [UIColor tintColor];
    [self addSubview:self.selectionView];
}

- (CGSize)intrinsicContentSize
{
    CGFloat height = self.buttons.count > 1 ? HEMScopePickerHeight : 0;
    return CGSizeMake(CGRectGetWidth(self.bounds), height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat buttonWidth = CGRectGetWidth(self.bounds) / self.buttons.count;
    CGFloat buttonHeight = CGRectGetHeight(self.bounds);
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton* button = self.buttons[i];
        button.frame = CGRectMake(i * buttonWidth, 0, buttonWidth, buttonHeight);
        button.selected = i == self.selectedIndex;
        if (self.separatorViews.count > i) {
            UIView* separator = self.separatorViews[i];
            separator.frame = CGRectMake(CGRectGetMaxX(button.frame), buttonHeight * 0.3, 1, buttonHeight * 0.4);
        }
    }
    if (self.buttons.count > self.selectedIndex)
        [self moveSelectionViewUnderView:self.buttons[self.selectedIndex]];
}

- (IBAction)selectButton:(UIButton*)sender
{
    NSUInteger index = sender.tag - HEMScopePickerButtonOffset;
    if (_selectedIndex == index || index >= self.buttons.count)
        return;
    _selectedIndex = index;
    for (UIButton* button in self.buttons) {
        if ((button.selected = button == sender))
            [self moveSelectionViewUnderView:button];
    }
    [self.delegate didTapButtonWithText:[sender titleForState:UIControlStateNormal]];
}

- (void)setButtonsWithTitles:(NSArray*)titles selectedIndex:(NSUInteger)selectedIndex
{
    [self.buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.buttons = [[NSMutableArray alloc] initWithCapacity:titles.count];
    self.separatorViews = [[NSMutableArray alloc] initWithCapacity:titles.count];
    self.selectedIndex = selectedIndex != NSNotFound ? selectedIndex : 0;
    if (titles.count == 0) {
        [self invalidateIntrinsicContentSize];
        return;
    }
    for (int i = 0; i < titles.count; i++) {
        NSString* title = titles[i];
        UIButton* button = [UIButton new];
        button.tag = i + HEMScopePickerButtonOffset;
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor barButtonDisabledColor]
                     forState:UIControlStateNormal];
        [button setTitleColor:[UIColor tintColor]
                     forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont trendOptionFont];
        [button addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self addSubview:button];
        if (i < titles.count - 1) {
            UIView* separatorView = [UIView new];
            separatorView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.f];
            [self.separatorViews addObject:separatorView];
            [self addSubview:separatorView];
        }
    }
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)moveSelectionViewUnderView:(UIView*)view
{
    CGRect frame = view.frame;
    frame.size.height = HEMScopePickerSelectionViewHeight;
    frame.origin.y = CGRectGetHeight(view.bounds) - HEMScopePickerSelectionViewHeight;
    void (^animations)() = ^{
        self.selectionView.frame = frame;
    };
    if (CGSizeEqualToSize(self.selectionView.bounds.size, CGSizeZero))
        animations();
    else
        [UIView animateWithDuration:0.2f animations:animations];
}

@end
