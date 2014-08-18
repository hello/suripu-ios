//
//  HEMProgressController.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMProgressController.h"

@interface HEMProgressController ()

@property (nonatomic, strong) UIViewController* rootViewController;
@property (nonatomic, strong) UIScrollView* contentScrollView;
@property (nonatomic, strong) UIView* progressView;
@property (nonatomic, assign) NSInteger numberOfScreens;

@end

@implementation HEMProgressController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContentScrollView];
    [self setupProgressView];
    [self setupRootViewController];
}

- (void)setupContentScrollView {
    _contentScrollView = [[UIScrollView alloc] initWithFrame:[[self view] bounds]];
    [_contentScrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [_contentScrollView setPagingEnabled:YES];
    [_contentScrollView setShowsHorizontalScrollIndicator:NO];
    [_contentScrollView setShowsVerticalScrollIndicator:NO];
    [_contentScrollView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_contentScrollView];
}

- (void)setupProgressView {
    
}

- (void)setupRootViewController {
    if ([self rootViewController] != nil) {
        [self pushViewController:[self rootViewController] animated:NO completion:nil];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollview did scroll %f", scrollView.contentOffset.x);
}

#pragma mark - public interfaces

- (id)initWithRootViewController:(UIViewController*)controller numberOfScreens:(NSInteger)numberOfScreens {
    self = [super init];
    if (self) {
        _numberOfScreens = numberOfScreens;
        [self setRootViewController:controller];
    }
    return self;
}

- (void)pushViewController:(UIViewController*)controller
                  animated:(BOOL)animated completion:(void(^)(void))completion {
    
    if (controller == nil) return;
    
    CGSize contentSize = _contentScrollView.contentSize;
    CGRect controllerFrame = controller.view.frame;
    controllerFrame.origin.x = contentSize.width;
    contentSize.width += CGRectGetWidth(controller.view.bounds);
    [controller.view setFrame:controllerFrame];
    [_contentScrollView setContentSize:contentSize];
    
    [self addChildViewController:controller];
    [_contentScrollView addSubview:[controller view]];
    [controller didMoveToParentViewController:self];

    [_contentScrollView setContentOffset:controllerFrame.origin animated:animated];
    if (completion) completion();
}

@end
