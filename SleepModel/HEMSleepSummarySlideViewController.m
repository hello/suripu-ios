//
//  HEMSleepSummarySlideViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIImage+ImageEffects.h"
#import "UIView+HEMSnapshot.h"
#import "NSDate+HEMRelative.h"

#import "HEMSleepSummarySlideViewController.h"
#import "HEMSleepGraphViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepSummaryPagingDataSource.h"
#import "HEMRootViewController.h"

@interface HEMSleepSummarySlideViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) CAGradientLayer* bgGradientLayer;
@property (nonatomic, strong) HEMSleepSummaryPagingDataSource* data;

@end

@implementation HEMSleepSummarySlideViewController

- (id)init {
    NSDate* startDate = [[NSDate date] previousDay];
    if (self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                        navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil]) {
        [self __initStackWithControllerForDate:startDate];
    }
    
    return self;
}

- (instancetype)initWithDate:(NSDate*)date
{
    if (self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                        navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil]) {
        [self __initStackWithControllerForDate:date];
    }

    return self;
}

- (void)__initStackWithControllerForDate:(NSDate*)date
{
    [self reloadDataWithController:[self timelineControllerForDate:date]];
    [self setData:[[HEMSleepSummaryPagingDataSource alloc] init]];
    [self setDataSource:[self data]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerDidOpen)
                                                 name:HEMRootDrawerDidOpenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerDidClose)
                                                 name:HEMRootDrawerDidCloseNotification
                                               object:nil];
}

- (UIViewController*)timelineControllerForDate:(NSDate*)date {
    HEMSleepGraphViewController* controller = (id)[HEMMainStoryboard instantiateSleepGraphController];
    [controller setDateForNightOfSleep:date];
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    UIGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(didPan)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
}

- (void)reloadData {
    if ([self isViewLoaded] && self.view.window) {
        UIViewController* firstController = [[self viewControllers] firstObject];
        if ([firstController isKindOfClass:[HEMSleepGraphViewController class]]) {
            HEMSleepGraphViewController* timelineVC = (id)firstController;
            if ([timelineVC isLastNight]) {
                NSDate* updatedLastNight = [[NSDate date] previousDay];
                if (![[timelineVC dateForNightOfSleep] isOnSameDay:updatedLastNight]) {
                    firstController = [self timelineControllerForDate:updatedLastNight];
                }
            }
        }
        [self reloadDataWithController:firstController];
    }
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

- (void)setSwipingEnabled:(BOOL)enabled {
    self.dataSource = enabled ? self.data : nil;
}

#pragma mark - Gesture Recognizers

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    if (velocity.x < 0 && fabs(velocity.x) > fabs(velocity.y)) {
        CGFloat const sliceWidth = 1;
        HEMSleepGraphViewController* controller = [self.viewControllers lastObject];
        CGFloat width = CGRectGetWidth(controller.view.bounds);
        CGRect slice = CGRectMake(width - sliceWidth, 0, sliceWidth, CGRectGetHeight(controller.view.bounds));
        UIImage* pattern = [controller.view snapshotOfRect:slice];
        self.view.backgroundColor = [UIColor colorWithPatternImage:pattern];
    }
    return YES;
}

- (void)didPan {
}

#pragma mark - Drawer Events

- (void)drawerDidOpen {
    [self setScrollingEnabled:NO];
}

- (void)drawerDidClose {
    [self setScrollingEnabled:YES];
}

- (void)setScrollingEnabled:(BOOL)isEnabled {
    [self setDataSource:isEnabled ? [self data] : nil];
}

#pragma mark - Cleanup

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setDataSource:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
