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

@interface HEMFullscreenDialogView ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (strong, nonatomic) NSArray* contents;
@property (nonatomic) NSUInteger selectedIndex;
@property (strong, nonatomic) UISwipeGestureRecognizer* previousGestureRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer* nextGestureRecognizer;
@end

@implementation HEMDialogContent

@end

@implementation HEMFullscreenDialogView

static CGFloat const HEMFullscreenDialogCornerRadius = 6.f;
static CGFloat const HEMFullscreenDialogLineSpacing = 6.f;
static HEMFullscreenDialogView* fullscreenDialogView = nil;

+ (void)showDialogsWithContent:(NSArray *)contents
{
    if (fullscreenDialogView || contents.count == 0)
        return;
    fullscreenDialogView = [self createDialogView];
    fullscreenDialogView.contents = contents;
    [fullscreenDialogView start];
    [UIView animateWithDuration:0.25f animations:^{
        fullscreenDialogView.alpha = 1;
    }];
}

+ (HEMFullscreenDialogView*)createDialogView
{
    NSArray* nibContents = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    HEMFullscreenDialogView* dialogView = [nibContents firstObject];
    dialogView.frame = [[UIScreen mainScreen] bounds];
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    if (!window)
        window = [[[UIApplication sharedApplication] windows] firstObject];
    UIImage* backgroundImage = [self imageForModalBackgroundInView:window.rootViewController.view];
    dialogView.backgroundImageView.image = backgroundImage;
    dialogView.alpha = 0;
    [window addSubview:dialogView];
    return dialogView;
}

+ (UIImage*)imageForModalBackgroundInView:(UIView*)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [backgroundImage applyBlurWithRadius:3
                                      tintColor:[UIColor colorWithWhite:0.f alpha:0.4f]
                          saturationDeltaFactor:1.2f
                                      maskImage:nil];
}

- (void)awakeFromNib
{
    self.contentContainerView.layer.cornerRadius = HEMFullscreenDialogCornerRadius;
    self.imageView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.f].CGColor;
    self.imageView.layer.borderWidth = 0.5f;
    [self.actionButton addTarget:self
                          action:@selector(presentNextDialog:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.pageControl addTarget:self action:@selector(changeSelectedPage:) forControlEvents:UIControlEventValueChanged];
    [self configureGestureRecognizers];
}

- (void)configureGestureRecognizers
{
    self.nextGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(didSwipe:)];
    self.nextGestureRecognizer.delegate = self;
    self.nextGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.previousGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(didSwipe:)];
    self.previousGestureRecognizer.delegate = self;
    self.previousGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.contentContainerView addGestureRecognizer:self.nextGestureRecognizer];
    [self.contentContainerView addGestureRecognizer:self.previousGestureRecognizer];
}

- (void)presentNextDialog:(UIButton*)sender
{
    if (self.contents.count > self.selectedIndex + 1) {
        [self configureDialogWithContentAtIndex:self.selectedIndex + 1];
    } else {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.25f animations:^{
            weakSelf.alpha = 0;
        } completion:^(BOOL finished) {
            [weakSelf removeFromSuperview];
        }];
        fullscreenDialogView = nil;
    }
}

- (void)changeSelectedPage:(UIPageControl*)pageControl
{
    [self configureDialogWithContentAtIndex:pageControl.currentPage];
}

- (void)configureDialogWithContentAtIndex:(NSUInteger)index
{
    [self layoutIfNeeded];
    if (index >= self.contents.count)
        return;
    self.selectedIndex = index;
    HEMDialogContent* content = self.contents[index];
    BOOL isLastDialog = index == self.contents.count - 1;
    NSAttributedString* title = nil;
    NSAttributedString* message = nil;

    self.pageControl.currentPage = index;
    if (content.title.length > 0)
        title = [[NSAttributedString alloc] initWithString:[content.title uppercaseString]
                                                attributes:@{NSKernAttributeName:@(0.5)}];
    if (content.content.length > 0) {
        NSMutableParagraphStyle* style = [NSMutableParagraphStyle new];
        style.lineSpacing = HEMFullscreenDialogLineSpacing;
        NSDictionary* attributes = @{NSParagraphStyleAttributeName:style, NSFontAttributeName: [UIFont tutorialDialogFont]};
        message = [[NSAttributedString alloc] initWithString:content.content
                                                  attributes:attributes];
    }
    NSString* buttonKey = nil;
    if (self.contents.count == 1)
        buttonKey = @"actions.ok";
    else
        buttonKey = isLastDialog ? @"actions.done" : @"actions.next";
    NSString* buttonTitle = NSLocalizedString(buttonKey, nil);
    [self.actionButton setTitle:[buttonTitle uppercaseString] forState:UIControlStateNormal];
    [self updateDialogWithTitle:title message:message image:content.image];
    [self setNeedsUpdateConstraints];
}

- (void)updateDialogWithTitle:(NSAttributedString*)title message:(NSAttributedString*)message image:(UIImage*)image
{
    [UIView animateWithDuration:0.15f animations:^{
        self.imageView.alpha = 0;
        self.titleLabel.alpha = 0;
        self.textView.alpha = 0;
    } completion:^(BOOL finished) {
        CGFloat constant = image ? (image.size.height/image.size.width) * CGRectGetWidth(self.imageView.bounds) : 0;
        self.imageView.image = image;
        self.imageViewHeightConstraint.constant = constant;
        self.titleLabel.attributedText = title;
        self.textView.attributedText = message;
        self.scrollView.contentOffset = CGPointZero;
        [UIView animateWithDuration:0.15f animations:^{
            self.imageView.alpha = 1;
            self.titleLabel.alpha = 1;
            self.textView.alpha = 1;
        }];
    }];
}

- (void)start
{
    [self configureDialogWithContentAtIndex:0];
}

- (void)setContents:(NSArray *)contents
{
    if ([_contents isEqual:contents])
        return;
    _contents = contents;
    self.pageControl.numberOfPages = contents.count;
}

- (void)didSwipe:(UISwipeGestureRecognizer*)recognizer
{
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft && self.selectedIndex < self.contents.count) {
        [self configureDialogWithContentAtIndex:self.selectedIndex + 1];
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight && self.selectedIndex > 0) {
        [self configureDialogWithContentAtIndex:self.selectedIndex - 1];
    }
}

@end
