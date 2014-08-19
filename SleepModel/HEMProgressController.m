//
//  HEMProgressController.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "HEMProgressController.h"
#import "HelloStyleKit.h"
#import "UIView+HEMMotionEffects.h"

@interface HEMProgressController ()

@property (nonatomic, strong) UIViewController* rootViewController;
@property (nonatomic, strong) UIScrollView* contentScrollView;
@property (nonatomic, strong) UIScrollView* bgScrollView;
@property (nonatomic, strong) NSArray* bgImageNames;
@property (nonatomic, strong) UIProgressView* progressView;
@property (nonatomic, strong) NSMutableArray* previousPercentages;
@property (nonatomic, assign) CGFloat prevScrollOffset;

@end

@implementation HEMProgressController

- (id)initWithRootViewController:(UIViewController*)controller
            backgroundImageNames:(NSArray*)imageNames {
    self = [super init];
    if (self) {
        _bgImageNames = imageNames;
        _rootViewController = controller;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCache];
    [self setupBgImages];
    [self setupContentScrollView];
    [self setupProgressView];
    [self setupRootViewController];
}

- (void)setupCache {
    _prevScrollOffset = -1.0f;
    _previousPercentages = [NSMutableArray array];
}

- (void)setupContentScrollView {
    _contentScrollView = [[UIScrollView alloc] initWithFrame:[[self view] bounds]];
    [_contentScrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [_contentScrollView setPagingEnabled:YES];
    [_contentScrollView setShowsHorizontalScrollIndicator:NO];
    [_contentScrollView setShowsVerticalScrollIndicator:NO];
    [_contentScrollView setBackgroundColor:[UIColor clearColor]];
    [_contentScrollView setDelegate:self];
    [_contentScrollView setBounces:NO];
    [self.view addSubview:_contentScrollView];
}

- (void)setupProgressView {
    CGRect bounds = [[self view] bounds];
    CGRect progressFrame = CGRectZero;
    progressFrame.size.height = 2.0f;
    progressFrame.origin.y = CGRectGetHeight(bounds) - CGRectGetHeight(progressFrame);
    progressFrame.size.width = CGRectGetWidth(bounds);
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [_progressView setFrame:progressFrame];
    [_progressView setTintColor:[HelloStyleKit mediumBlueColor]];
    [_progressView setProgress:0.0f];
    [self.view addSubview:_progressView];
}

- (void)setupBgImages {
    if ([_bgImageNames count] > 0) {
        _bgScrollView = [[UIScrollView alloc] initWithFrame:[[self view] bounds]];
        [_bgScrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_bgScrollView setShowsHorizontalScrollIndicator:NO];
        [_bgScrollView setShowsVerticalScrollIndicator:NO];
        
        CGSize contentSize = [_bgScrollView contentSize];
        UIImage* bgImage = nil;
        UIImageView* bgImageView = nil;
        
        for (NSString* imageName in _bgImageNames) {
            bgImage = [UIImage imageNamed:imageName];
            if (bgImage) {
                CGRect imageFrame = CGRectZero;
                imageFrame.origin.x = contentSize.width;
                imageFrame.size.width = bgImage.size.width;
                imageFrame.size.height = CGRectGetHeight(_bgScrollView.bounds);
                bgImageView = [[UIImageView alloc] initWithFrame:imageFrame];
                bgImageView.contentMode = UIViewContentModeCenter;
                [bgImageView setImage:bgImage];
                [bgImageView add3DEffectWithBorder:10.0f];
                [_bgScrollView addSubview:bgImageView];
                
                contentSize.width += CGRectGetWidth(imageFrame);
            }
        }
        
        [_bgScrollView setContentSize:contentSize];
        [self.view addSubview:_bgScrollView];
    }
}

- (void)setupRootViewController {
    if (_rootViewController != nil) {
        float progress = 0.0f;
        [_previousPercentages addObject:@(progress)];
        [self pushViewController:_rootViewController progress:progress animated:NO completion:nil];
    }
}

- (void)updateProgress:(float)progress animated:(BOOL)animated{
    CGFloat fullContentWidth = [_bgScrollView contentSize].width;
    CGFloat movableWidth = MAX(0, fullContentWidth - (CGRectGetWidth([_bgScrollView bounds])*2));
    CGPoint contentOffset = [_bgScrollView contentOffset];
    contentOffset.x = ceilf(movableWidth * progress);
    [_bgScrollView setContentOffset:contentOffset animated:animated];
    [_progressView setProgress:progress animated:animated];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat boundWidth = CGRectGetWidth([scrollView bounds]);
    NSInteger numberOfChildren = [[self childViewControllers] count];
    CGFloat currentControllerOffset = (numberOfChildren-1) * boundWidth;
    CGFloat prevControllerOffset = currentControllerOffset - boundWidth;
    
    float percentageScrolled = (scrollView.contentOffset.x - prevControllerOffset)/boundWidth;
    float actualPercentage = [[_previousPercentages lastObject] floatValue] * percentageScrolled;
    [self updateProgress:actualPercentage animated:NO];
    
    if (scrollView.contentOffset.x == prevControllerOffset
        && scrollView.contentOffset.x < _prevScrollOffset) {
        [self popViewController];
    }
    
    _prevScrollOffset = scrollView.contentOffset.x;
}

#pragma mark - managing child controllers

- (void)pushViewController:(UIViewController*)controller
                  progress:(float)progress
                  animated:(BOOL)animated
                completion:(void(^)(void))completion {
    
    if (controller == nil) return;
    
    CGSize contentSize = [_contentScrollView contentSize];
    
    CGRect controllerFrame = controller.view.frame;
    controllerFrame.origin.x = contentSize.width;
    contentSize.width += CGRectGetWidth(controller.view.bounds);
    [controller.view setFrame:controllerFrame];
    
    _prevScrollOffset = controllerFrame.origin.x;
    // if there are bg images set for the flow, then the only way
    // to actually see them is to have the controller's view be
    // transparent
    if ([_bgImageNames count] > 0) {
        [controller.view setBackgroundColor:[UIColor clearColor]];
    }
    
    [_contentScrollView setContentSize:contentSize];
    
    [self addChildViewController:controller];
    [_contentScrollView addSubview:[controller view]];
    [controller didMoveToParentViewController:self];
    
    [_contentScrollView setContentOffset:controllerFrame.origin animated:animated];
    [_previousPercentages addObject:@(progress)];
    [self updateProgress:progress animated:animated];
    
    if (completion) completion();
    
    NSLog(@"pushed view controller");
}

- (void)popViewController {
    UIViewController* lastController = [[self childViewControllers] lastObject];
    if (lastController != nil) {
        [lastController removeFromParentViewController];
        [lastController.view removeFromSuperview];
        [lastController didMoveToParentViewController:nil];
        
        CGSize contentSize = [_contentScrollView contentSize];
        contentSize.width -= CGRectGetWidth([[lastController view] bounds]);
        [_contentScrollView setContentSize:contentSize];
        
        NSNumber* previousPercentage = [_previousPercentages lastObject];
        if (previousPercentage != nil) {
            [_previousPercentages removeLastObject];
            [self updateProgress:[[_previousPercentages lastObject] floatValue] animated:NO];
        }
        
        NSLog(@"popped view controller");
    }
}

#pragma mark - clean up

- (void)dealloc {
    [_contentScrollView setDelegate:nil];
}

@end
