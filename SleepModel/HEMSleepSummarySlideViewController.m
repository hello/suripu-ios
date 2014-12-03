//
//  HEMSleepSummarySlideViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>

#import "UIImage+ImageEffects.h"
#import "UIView+HEMSnapshot.h"

#import "HEMSleepSummarySlideViewController.h"
#import "HEMSleepGraphViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSlideViewController+Protected.h"
#import "HEMColorUtils.h"
#import "HEMSleepSummaryPagingDataSource.h"
#import "HelloStyleKit.h"

@interface HEMSleepSummarySlideViewController () <
    FCDynamicPaneViewController
>

@property (nonatomic, weak) CAGradientLayer* bgGradientLayer;
@property (nonatomic, strong) HEMSleepSummaryPagingDataSource* data;

@end

@implementation HEMSleepSummarySlideViewController

- (id)init {
    NSTimeInterval startTime = -86400; // -(60 * 60 * 24)
    NSDate* startDate = [NSDate dateWithTimeInterval:startTime sinceDate:[NSDate date]];
    HEMSleepGraphViewController* controller
        = (HEMSleepGraphViewController*)[HEMMainStoryboard instantiateSleepGraphController];
    [controller setDateForNightOfSleep:startDate];
    
    if (self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                        navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil]) {
        [self reloadDataWithController:controller];
        [self setData:[[HEMSleepSummaryPagingDataSource alloc] init]];
        [self setDataSource:[self data]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackgroundGradientLayer];
    [self addTopShadow];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)reloadData {
    [self reloadDataWithController:[[self viewControllers] firstObject]];
}

- (void)reloadDataWithController:(UIViewController*)controller {
    if (!controller)
        return;
    [self setViewControllers:@[controller]
                   direction:UIPageViewControllerNavigationDirectionForward
     | UIPageViewControllerNavigationDirectionReverse
                    animated:NO
                  completion:nil];
}

- (void)addBackgroundGradientLayer {
    CAGradientLayer* layer = [CAGradientLayer layer];
    [layer setFrame:[[self view] bounds]];
    [HEMColorUtils configureLayer:layer forHourOfDay:24];
    [[[self view] layer] insertSublayer:layer atIndex:0];
    [self setBgGradientLayer:layer];
}

- (void)addTopShadow {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:[[self view] bounds]];
    CALayer* layer = [[self view] layer];
    [layer setMasksToBounds:NO];
    [layer setShadowColor:[[UIColor blackColor] CGColor]];
    [layer setShadowOffset:CGSizeMake(0.0f, 5.0f)];
    [layer setShadowOpacity:0.6f];
    [layer setShadowRadius:5.0f];
    [layer setShadowPath:[shadowPath CGPath]];
}

#pragma mark - FCDynamicPaneViewController

- (void)viewDidPop {
    [self setNeedsStatusBarAppearanceUpdate];
    for (UIViewController* viewController in [self childViewControllers]) {
        if ([viewController respondsToSelector:@selector(viewDidPop)]) {
            [(UIViewController<FCDynamicPaneViewController>*)viewController viewDidPop];
        }
    }
    // disable scrolling
    [self setDataSource:nil];
}

- (void)viewDidPush {
    [self setNeedsStatusBarAppearanceUpdate];
    for (UIViewController* viewController in [self childViewControllers]) {
        if ([viewController respondsToSelector:@selector(viewDidPush)]) {
            [(UIViewController<FCDynamicPaneViewController>*)viewController viewDidPush];
        }
    }
    // enable scrolling
    [self setDataSource:[self data]];
}

#pragma mark - Cleanup

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setDataSource:nil];
}

@end
