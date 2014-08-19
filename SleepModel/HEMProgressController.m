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
@property (nonatomic, assign) CGFloat prevStartScrollOffsetX;

@end

@implementation HEMProgressController

- (id)initWithRootViewController:(UIViewController*)controller
            backgroundImageNames:(NSArray*)imageNames {
    self = [super init];
    if (self) {
        [self setBgImageNames:imageNames];
        [self setRootViewController:controller];
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
    [self setPrevStartScrollOffsetX:0.0f];
    [self setPreviousPercentages:[NSMutableArray array]];
}

- (void)setupContentScrollView {
    [self setContentScrollView:[[UIScrollView alloc] initWithFrame:[[self view] bounds]]];
    [[self contentScrollView] setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [[self contentScrollView] setPagingEnabled:YES];
    [[self contentScrollView] setShowsHorizontalScrollIndicator:NO];
    [[self contentScrollView] setShowsVerticalScrollIndicator:NO];
    [[self contentScrollView] setBackgroundColor:[UIColor clearColor]];
    [[self contentScrollView] setDelegate:self];
    [[self contentScrollView] setBounces:NO];
    [self.view addSubview:[self contentScrollView]];
}

- (void)setupProgressView {
    CGRect bounds = [[self view] bounds];
    CGRect progressFrame = CGRectZero;
    progressFrame.size.height = 2.0f;
    progressFrame.origin.y = CGRectGetHeight(bounds) - CGRectGetHeight(progressFrame);
    progressFrame.size.width = CGRectGetWidth(bounds);
    
    [self setProgressView:[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar]];
    [[self progressView] setFrame:progressFrame];
    [[self progressView] setTintColor:[HelloStyleKit mediumBlueColor]];
    [[self progressView] setProgress:0.0f];
    [self.view addSubview:[self progressView]];
}

- (void)setupBgImages {
    if ([[self bgImageNames] count] > 0) {
        [self setBgScrollView:[[UIScrollView alloc] initWithFrame:[[self view] bounds]]];
        [[self bgScrollView] setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [[self bgScrollView] setShowsHorizontalScrollIndicator:NO];
        [[self bgScrollView] setShowsVerticalScrollIndicator:NO];
        
        CGSize contentSize = [[self bgScrollView] contentSize];
        UIImage* bgImage = nil;
        UIImageView* bgImageView = nil;
        
        for (NSString* imageName in [self bgImageNames]) {
            bgImage = [UIImage imageNamed:imageName];
            if (bgImage) {
                CGRect imageFrame = CGRectZero;
                imageFrame.origin.x = contentSize.width;
                imageFrame.size.width = bgImage.size.width;
                imageFrame.size.height = CGRectGetHeight([self bgScrollView].bounds);
                bgImageView = [[UIImageView alloc] initWithFrame:imageFrame];
                bgImageView.contentMode = UIViewContentModeCenter;
                [bgImageView setImage:bgImage];
                [bgImageView add3DEffectWithBorder:10.0f];
                [[self bgScrollView] addSubview:bgImageView];
                
                contentSize.width += CGRectGetWidth(imageFrame);
            }
        }
        
        [[self bgScrollView] setContentSize:contentSize];
        [self.view addSubview:[self bgScrollView]];
    }
}

- (void)setupRootViewController {
    if ([self rootViewController] != nil) {
        [self pushViewController:[self rootViewController] progress:0.0f animated:NO completion:nil];
    }
}

- (void)updateProgress:(float)progress animated:(BOOL)animated{
    CGFloat fullContentWidth = [[self bgScrollView] contentSize].width;
    CGFloat movableWidth = MAX(0, fullContentWidth - (CGRectGetWidth([[self bgScrollView] bounds])*2));
    CGPoint contentOffset = [[self bgScrollView] contentOffset];
    contentOffset.x = ceilf(movableWidth * progress);
    [[self bgScrollView] setContentOffset:contentOffset animated:animated];
    [[self progressView] setProgress:progress animated:animated];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:NO];
    [self setPrevStartScrollOffsetX:[scrollView contentOffset].x];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat boundWidth = CGRectGetWidth([scrollView bounds]);
    NSInteger numberOfChildren = [[self childViewControllers] count];
    CGFloat currentControllerOffset = (numberOfChildren-1) * boundWidth;
    CGFloat prevControllerOffset = currentControllerOffset - boundWidth;
    
    float currentPercentage = [[[self previousPercentages] lastObject] floatValue];
    float prevPercentage = numberOfChildren > 1 ? [[[self previousPercentages] objectAtIndex:numberOfChildren-2] floatValue] : 0.0f;
    float diff = currentPercentage - prevPercentage;
    float percentageScrolled = ([scrollView contentOffset].x - prevControllerOffset)/boundWidth;
    float actualPercentage = prevPercentage + (diff*percentageScrolled);
    [self updateProgress:actualPercentage animated:NO];
    
    if ([scrollView contentOffset].x <= prevControllerOffset
        && [scrollView contentOffset].x < [self prevStartScrollOffsetX]) {
        [self popViewController];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self setPrevStartScrollOffsetX:[scrollView contentOffset].x];
}

#pragma mark - managing child controllers

- (void)pushViewController:(UIViewController*)controller
                  progress:(float)progress
                  animated:(BOOL)animated
                completion:(void(^)(void))completion {
    
    if (controller == nil) return;
    [self.view endEditing:NO];
    
    CGSize contentSize = [[self contentScrollView] contentSize];
    [self setPrevStartScrollOffsetX:contentSize.width - CGRectGetWidth([_contentScrollView bounds])];
    
    CGRect controllerFrame = controller.view.frame;
    controllerFrame.origin.x = contentSize.width;
    contentSize.width += CGRectGetWidth(controller.view.bounds);
    [controller.view setFrame:controllerFrame];

    // if there are bg images set for the flow, then the only way
    // to actually see them is to have the controller's view be
    // transparent
    if ([[self bgImageNames] count] > 0) {
        [controller.view setBackgroundColor:[UIColor clearColor]];
    }
    
    [[self contentScrollView] setContentSize:contentSize];
    
    [self addChildViewController:controller];
    [[self contentScrollView] addSubview:[controller view]];
    [controller didMoveToParentViewController:self];
    
    [[self contentScrollView] setContentOffset:controllerFrame.origin animated:animated];
    [[self previousPercentages] addObject:@(progress)];
    [self updateProgress:progress animated:animated];
    
    if (completion) completion();
}

- (void)popViewController {
    UIViewController* lastController = [[self childViewControllers] lastObject];
    if (lastController != nil) {
        [lastController removeFromParentViewController];
        [lastController.view removeFromSuperview];
        [lastController didMoveToParentViewController:nil];
        
        CGSize contentSize = [[self contentScrollView] contentSize];
        contentSize.width -= CGRectGetWidth([[lastController view] bounds]);
        [[self contentScrollView] setContentSize:contentSize];
        
        NSNumber* previousPercentage = [[self previousPercentages] lastObject];
        if (previousPercentage != nil) {
            [[self previousPercentages] removeLastObject];
            [self updateProgress:[[[self previousPercentages] lastObject] floatValue] animated:NO];
        }
    }
}

#pragma mark - clean up

- (void)dealloc {
    [[self contentScrollView] setDelegate:nil];
}

@end
