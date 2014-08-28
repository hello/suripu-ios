//
//  HEMSlideViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSlideViewController.h"
#import "HEMSlideViewController+Protected.h"
#import "HelloStyleKit.h"

@interface HEMSlideViewController () <
    UIGestureRecognizerDelegate
>

@property (nonatomic, strong) UIViewController* initialViewController;
@property (nonatomic, strong) NSMutableArray* mutableViewControllers;
@property (nonatomic, strong) UIPanGestureRecognizer* slideGesture;
@property (nonatomic, strong) UIViewController* currentController;
@property (nonatomic, strong) UIViewController* nextController;
@property (nonatomic, assign) NSInteger currentControllerIndex;
@property (nonatomic, assign) NSInteger nextControllerIndex;
@property (nonatomic, assign, getter=isSliding) BOOL sliding;

@end

@implementation HEMSlideViewController

- (id)initWithInitialController:(UIViewController*)controller {
    self = [super init];
    if (self) {
        [self setInitialViewController:controller];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self addSlideGestures];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self currentController] != nil) {
        [[self currentController] beginAppearanceTransition:YES animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self currentController] != nil) {
        [[self currentController] endAppearanceTransition];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self currentController] != nil) {
        [[self currentController] beginAppearanceTransition:NO animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self currentController] != nil) {
        [[self currentController] endAppearanceTransition];
    }
}

- (void)setup {
    [[self view] setUserInteractionEnabled:YES];
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    [self setMutableViewControllers:[[NSMutableArray alloc] init]];
    
    if ([self initialViewController] != nil) {
        [self setCurrentController:[self initialViewController]];
        [self setCurrentControllerIndex:0];
        [self pushViewController:[self initialViewController] intoSpot:0];
        [self setInitialViewController:nil];
    }
}

- (void)beginSliding {
    SEL beginSelector = @selector(slideViewControllerDidBeginSliding:);
    if ([self.delegate respondsToSelector:beginSelector]) {
        [self.delegate slideViewControllerDidBeginSliding:self];
    }
}

- (void)endSliding {
    SEL beginSelector = @selector(slideViewControllerDidEndSliding:);
    if ([self.delegate respondsToSelector:beginSelector]) {
        [self.delegate slideViewControllerDidEndSliding:self];
    }
    
    if ([self nextController] != nil) {
        [self popViewController:[self nextController]];
        [self setNextController:nil];
        [self setNextControllerIndex:0];
    }

    [self setSliding:NO];
}

#pragma mark - Child Controllers

- (NSInteger)pushViewController:(UIViewController*)viewController
                       intoSpot:(NSInteger)spot {
    
    NSInteger totalControllers = [[self mutableViewControllers] count];
    NSInteger index = MAX(0, MIN(spot, totalControllers));
    
    CGRect vcFrame = [[self view] bounds];
    vcFrame.origin.x = spot * CGRectGetWidth(vcFrame);
    
    UIView* vcView = [viewController view];
    [vcView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [vcView setAutoresizingMask:UIViewAutoresizingFlexibleHeight
                                | UIViewAutoresizingFlexibleWidth];
    [vcView setFrame:vcFrame];
    
    [[self view] addSubview:vcView];
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
    
    [[self mutableViewControllers] insertObject:viewController atIndex:index];
    
    return index;
}

- (void)popViewController:(UIViewController*)viewController {
    [viewController willMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
    [[viewController view] removeFromSuperview];
    [[self mutableViewControllers] removeObject:viewController];
}

- (void)loadNextControllerFromOffset:(CGFloat)xOffset {
    UIViewController* nextVC = nil;
    NSInteger nextSpot = [self currentControllerIndex];
    
    if (xOffset < 0) {
        nextVC = [[self dataSource] slideViewController:self
                                        controllerAfter:[self currentController]];
        nextSpot++;
    } else if (xOffset > 0) {
        nextVC = [[self dataSource] slideViewController:self
                                       controllerBefore:[self currentController]];
        nextSpot--;
    }
    
    if (nextVC != nil) {
        NSInteger index = [self pushViewController:nextVC intoSpot:nextSpot];
        [self setNextController:nextVC];
        [self setNextControllerIndex:index];
    }
}

#pragma mark - Gestures

- (CGFloat)scaleAtXOffset:(CGFloat)xOffset {
    CGFloat x = fabs(xOffset);
    CGFloat minScaleDiff = 0.1f; // 0.9 scale is the minimum scale
    CGFloat bWidth = CGRectGetWidth([[self view] bounds]);
    CGFloat bounds = 0.1f * bWidth; // scale when within 10% of the width
    CGFloat boundedX = x > (bWidth - bounds) ? bWidth-x : x;
    CGFloat percentageMoved = 1 - ((bounds - boundedX) / bounds);
    CGFloat scale = (percentageMoved*minScaleDiff);
    return MIN(MAX(1 - scale, 1 - minScaleDiff), 1.0f);
}

- (void)moveController:(UIViewController*)controller
       withTranslation:(CGFloat)translationX
               xOrigin:(CGFloat)xOrigin
                  edge:(BOOL)edge {
    
    CGFloat elasticity = [self nextController] == nil ? 10.0f : 4.0f;
    CGFloat x = 2*(translationX / elasticity);
    UIView* cView = [controller view];
    
    CGPoint center = [cView center];
    center.x = (CGRectGetWidth([[self view] bounds])/2) + x + xOrigin;
    [cView setCenter:center];
    
    CGFloat scale = [self scaleAtXOffset:x];
    [cView setTransform:CGAffineTransformMakeScale(scale, scale)];
}

- (void)move:(CGFloat)translationX {
    if ([self nextController] == nil) {
        [self loadNextControllerFromOffset:translationX];
    }
    
    SEL didSlideSelector = @selector(slideviewController:didSlideByX:);
    if ([[self delegate] respondsToSelector:didSlideSelector]) {
        [[self delegate] slideviewController:self didSlideByX:translationX];
    }
    
    UIViewController* nextVC = [self nextController];
    
    [self moveController:[self currentController]
         withTranslation:translationX
                 xOrigin:0.0f
                    edge:nextVC == nil];
    
    if (nextVC != nil) {
        CGFloat width = CGRectGetWidth([[self view] bounds]);
        CGFloat xOrigin
            = [self nextControllerIndex] <= [self currentControllerIndex]
            ? -width
            : width;
        [self moveController:nextVC
             withTranslation:translationX
                     xOrigin:xOrigin
                        edge:NO];
    }
    
}

- (void)revert:(void(^)(void))completion {
    CGFloat nextX = 0.0f;
    CGFloat width = CGRectGetWidth([[self view] bounds]);
    CGFloat currentX = (CGRectGetWidth([[self view] bounds])/2);
    
    if ([self nextController] != nil) {
        CGFloat xOrigin = [self nextControllerIndex] <= [self currentControllerIndex]
                        ? -width
                        : width;
        nextX = (CGRectGetWidth([[self view] bounds])/2)+xOrigin;
    }
    
    [[self nextController] beginAppearanceTransition:NO animated:YES];
    [[self currentController] beginAppearanceTransition:YES animated:YES];
    [self snapCurrentWithCenter:currentX nextWithCenterX:nextX completion:^{
        [[self nextController] endAppearanceTransition];
        [[self currentController] endAppearanceTransition];
        if (completion) completion();
    }];
}

- (void)swapControllersFromOffset:(CGFloat)x completion:(void(^)(void))completion {
    CGFloat bWidth = CGRectGetWidth([[self view] bounds]);
    CGFloat halfWidth = bWidth/2.0f;
    CGFloat currentX = x < 0.0f ? (-bWidth + halfWidth) : bWidth + halfWidth;
    CGFloat nextX = halfWidth;
    
    [[self currentController] beginAppearanceTransition:NO animated:YES];
    [[self nextController] beginAppearanceTransition:YES animated:YES];
    [self snapCurrentWithCenter:currentX nextWithCenterX:nextX completion:^{
        // end transition before we swap
        [[self currentController] endAppearanceTransition];
        [[self nextController] endAppearanceTransition];
        // indices do not need to change since position wise, they are the same.
        // swapping the controllers however, means that next controller will get
        // popped
        UIViewController* tmpVC = [self currentController];
        [self setCurrentController:[self nextController]];
        [self setNextController:tmpVC];
        
        if (completion) completion();
    }];
}

- (void)snapCurrentWithCenter:(CGFloat)currentX
              nextWithCenterX:(CGFloat)nextX
                   completion:(void(^)(void))completion {
    UIView* cView = [[self currentController] view];
    UIView* nView = [[self nextController] view];
    
    [[self slideGesture] setEnabled:NO];
    [UIView animateWithDuration:0.25 animations:^{
        CGPoint center = [cView center];
        center.x = currentX;
        [cView setCenter:center];
        [cView setTransform:CGAffineTransformIdentity];
        
        if (nView != nil) {
            CGPoint center = [nView center];
            center.x = nextX;
            [nView setCenter:center];
            [nView setTransform:CGAffineTransformIdentity];
        }
    } completion:^(BOOL finished) {
        [[self slideGesture] setEnabled:YES];
        if (completion) completion();
    }];
}

- (void)snapFromCurrentOffset:(CGFloat)x completion:(void(^)(void))completion {
    CGFloat bWidth = CGRectGetWidth([[self view] bounds]);
    CGFloat percentageDragged = fabs(x)/bWidth;
    if (percentageDragged < 0.5f || [self nextController] == nil) {
        [self revert:completion];
    } else {
        [self swapControllersFromOffset:x completion:completion];
    }
}

- (void)addSlideGestures {
    // TODO (jimmy): add a custom gesture to detect only horizontal movements?
    UIPanGestureRecognizer* slideGesture = [[UIPanGestureRecognizer alloc] init];
    [slideGesture addTarget:self action:@selector(slide:)];
    [[self view] addGestureRecognizer:slideGesture];
    [self setSlideGesture:slideGesture];
}

- (void)slide:(UIPanGestureRecognizer*)gesture {
    CGPoint translation = [gesture translationInView:[gesture view]];
    
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        [self beginSliding];
    }
    
    if ([gesture state] == UIGestureRecognizerStateChanged) {
        [self move:translation.x];
        if (![self isSliding]) {
            [[self nextController] beginAppearanceTransition:YES animated:NO];
            [[self nextController] endAppearanceTransition];
            [self setSliding:YES];
        }
    }
    
    if ([gesture state] == UIGestureRecognizerStateEnded
        || [gesture state] == UIGestureRecognizerStateFailed) {
        [self snapFromCurrentOffset:translation.x completion:^{
            [self endSliding];
        }];
    }
}

@end