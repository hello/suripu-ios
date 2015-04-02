//
//  HEMFullscreenDialogView.m
//  Sense
//
//  Created by Delisa Mason on 1/27/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIImageEffects/UIImage+ImageEffects.h>
#import "HEMFullscreenDialogView.h"
#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"

@interface HEMFullscreenDialogView () <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardBottomConstraint;

@property (strong, nonatomic) NSArray *contents;
@property (nonatomic) NSUInteger selectedIndex;
@property (strong, nonatomic) UISwipeGestureRecognizer *previousGestureRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer *nextGestureRecognizer;
@end

@implementation HEMDialogContent

@end

@implementation HEMFullscreenDialogView

static CGFloat const HEMFullscreenDialogDefaultCardSpacing = 60.f;
static CGFloat const HEMFullscreenDialogCornerRadius = 2.f;
static CGFloat const HEMFullscreenDialogLineSpacing = 6.f;
static HEMFullscreenDialogView *fullscreenDialogView = nil;

+ (void)showDialogsWithContent:(NSArray *)contents {
    if (fullscreenDialogView || contents.count == 0)
        return;
    fullscreenDialogView = [self createDialogView];
    fullscreenDialogView.contents = contents;
    [fullscreenDialogView start];
    [UIView animateWithDuration:0.25f animations:^{ fullscreenDialogView.alpha = 1; }];
}

+ (HEMFullscreenDialogView *)createDialogView {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    HEMFullscreenDialogView *dialogView = [nibContents firstObject];
    dialogView.frame = [[UIScreen mainScreen] bounds];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (!window)
        window = [[[UIApplication sharedApplication] windows] firstObject];
    UIImage *backgroundImage = [self imageForModalBackgroundInView:window.rootViewController.view];
    dialogView.backgroundImageView.image = backgroundImage;
    dialogView.alpha = 0;
    [window addSubview:dialogView];
    return dialogView;
}

+ (UIImage *)imageForModalBackgroundInView:(UIView *)view {
    return [view blurredSnapshotWithTint:[UIColor colorWithWhite:0.f alpha:0.6f]];
}

- (void)awakeFromNib {
    self.contentContainerView.layer.cornerRadius = HEMFullscreenDialogCornerRadius;
    self.imageView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.f].CGColor;
    self.imageView.layer.borderWidth = 0.5f;
    [self.actionButton addTarget:self
                          action:@selector(presentNextDialog:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.pageControl addTarget:self action:@selector(changeSelectedPage:) forControlEvents:UIControlEventValueChanged];
    [self configureGestureRecognizers];
    CGFloat height = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    self.cardTopConstraint.constant = height;
    self.cardBottomConstraint.constant = -(height - (HEMFullscreenDialogDefaultCardSpacing * 2));
    [self setNeedsUpdateConstraints];
}

- (void)configureGestureRecognizers {
    self.nextGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    self.nextGestureRecognizer.delegate = self;
    self.nextGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.previousGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    self.previousGestureRecognizer.delegate = self;
    self.previousGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.contentContainerView addGestureRecognizer:self.nextGestureRecognizer];
    [self.contentContainerView addGestureRecognizer:self.previousGestureRecognizer];
}

- (void)presentNextDialog:(UIButton *)sender {
    if (self.contents.count > self.selectedIndex + 1) {
        [self configureDialogWithContentAtIndex:self.selectedIndex + 1];
    } else {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.25f
            animations:^{ weakSelf.alpha = 0; }
            completion:^(BOOL finished) { [weakSelf removeFromSuperview]; }];
        fullscreenDialogView = nil;
    }
}

- (void)changeSelectedPage:(UIPageControl *)pageControl {
    [self configureDialogWithContentAtIndex:pageControl.currentPage];
}

- (void)configureDialogWithContentAtIndex:(NSUInteger)index {
    [self layoutIfNeeded];
    if (index >= self.contents.count)
        return;
    self.selectedIndex = index;
    HEMDialogContent *content = self.contents[index];
    BOOL isLastDialog = index == self.contents.count - 1;
    NSAttributedString *title = nil;
    NSAttributedString *message = nil;

    self.pageControl.currentPage = index;
    if (content.title.length > 0)
        title = [[NSAttributedString alloc] initWithString:[content.title uppercaseString]
                                                attributes:@{
                                                    NSKernAttributeName : @(0.5)
                                                }];
    if (content.content.length > 0) {
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.lineSpacing = HEMFullscreenDialogLineSpacing;
        NSDictionary *attributes =
            @{ NSParagraphStyleAttributeName : style, NSFontAttributeName : [UIFont tutorialDialogFont] };
        message = [[NSAttributedString alloc] initWithString:content.content attributes:attributes];
    }
    NSString *buttonKey = nil;
    if (self.contents.count == 1)
        buttonKey = @"actions.ok";
    else
        buttonKey = isLastDialog ? @"actions.done" : @"actions.next";
    NSString *buttonTitle = NSLocalizedString(buttonKey, nil);
    [self.actionButton setTitle:[buttonTitle uppercaseString] forState:UIControlStateNormal];
    [self updateDialogWithTitle:title message:message image:content.image];
    if (self.cardBottomConstraint.constant != HEMFullscreenDialogDefaultCardSpacing) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          __strong typeof(weakSelf) strongSelf = weakSelf;
          strongSelf.cardTopConstraint.constant = HEMFullscreenDialogDefaultCardSpacing;
          strongSelf.cardBottomConstraint.constant = HEMFullscreenDialogDefaultCardSpacing;
          [strongSelf setNeedsUpdateConstraints];
          [UIView animateWithDuration:0.25f animations:^{ [strongSelf.contentContainerView layoutIfNeeded]; }];
        });
    } else { [self setNeedsUpdateConstraints]; }
}

- (void)updateDialogWithTitle:(NSAttributedString *)title message:(NSAttributedString *)message image:(UIImage *)image {
    [UIView animateWithDuration:0.15f
        animations:^{
          self.imageView.alpha = 0;
          self.titleLabel.alpha = 0;
          self.textView.alpha = 0;
        }
        completion:^(BOOL finished) {
          CGFloat constant = image ? (image.size.height / image.size.width) * CGRectGetWidth(self.imageView.bounds) : 0;
          self.imageView.image = image;
          self.imageViewHeightConstraint.constant = constant;
          self.titleLabel.attributedText = title;
          self.textView.attributedText = message;
          self.scrollView.contentOffset = CGPointZero;
          [self.scrollView layoutIfNeeded];
          BOOL hasScrollableContent = self.scrollView.contentSize.height > CGRectGetHeight(self.scrollView.bounds);
          [UIView animateWithDuration:0.15f
              animations:^{
                self.imageView.alpha = 1;
                self.titleLabel.alpha = 1;
                self.textView.alpha = 1;
                if (hasScrollableContent) {
                    [self showShadow];
                } else { [self hideShadow]; }
              }
              completion:^(BOOL finished) {
                if (hasScrollableContent)
                    [self.scrollView flashScrollIndicators];
              }];
        }];
}

- (void)start {
    [self configureDialogWithContentAtIndex:0];
}

- (void)setContents:(NSArray *)contents {
    if ([_contents isEqual:contents])
        return;
    _contents = contents;
    self.pageControl.numberOfPages = contents.count;
}

- (void)didSwipe:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft && self.selectedIndex < self.contents.count) {
        [self configureDialogWithContentAtIndex:self.selectedIndex + 1];
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight && self.selectedIndex > 0) {
        [self configureDialogWithContentAtIndex:self.selectedIndex - 1];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) == scrollView.contentSize.height) {
        [self hideShadow];
    } else { [self showShadow]; }
}

- (void)showShadow {
    self.shadowView.layer.shadowOffset = CGSizeMake(0, -1);
    self.shadowView.layer.shadowRadius = 1.f;
    self.shadowView.layer.shadowOpacity = 0.1f;
}

- (void)hideShadow {
    self.shadowView.layer.shadowOpacity = 0.0f;
}

@end
