//
//  HEMSleepSummarySlideViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "Sense-Swift.h"

#import <SenseKit/SENTimeline.h>

#import "UIImage+ImageEffects.h"
#import "UIView+HEMSnapshot.h"
#import "NSDate+HEMRelative.h"
#import "UIView+HEMMotionEffects.h"

#import "HEMSleepSummarySlideViewController.h"
#import "HEMTimelineFeedbackViewController.h"
#import "HEMSleepGraphViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepSummaryPagingDataSource.h"
#import "HEMHandHoldingService.h"
#import "HEMTimelineService.h"
#import "HEMStyle.h"

@interface HEMSleepSummarySlideViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) CAGradientLayer* bgGradientLayer;
@property (nonatomic, strong) HEMSleepSummaryPagingDataSource* data;
@property (nonatomic, strong) HEMHandHoldingService* handHoldingService;
@property (nonatomic, assign) NSInteger lastNightSleepScore;

@end

@implementation HEMSleepSummarySlideViewController

- (id)init {
    if (self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                        navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil]) {
        [self __initStackWithControllerForDate:[NSDate timelineInitialDate]];
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
    _lastNightSleepScore = -1; // initialize to -1 to make update take affect for 0
    
    NSInteger lastNightSleepScore = 0;
    HEMSleepGraphViewController* timelineVC = (id) [self timelineControllerForDate:date];
    if ([timelineVC isLastNight]) {
        SENTimeline* timeline = [SENTimeline timelineForDate:date];
        lastNightSleepScore = [[timeline score] integerValue];
    }
    [self updateLastNightSleepScore:lastNightSleepScore];
    [self reloadDataWithController:timelineVC];
    [self setData:[[HEMSleepSummaryPagingDataSource alloc] init]];
    [self setDataSource:[self data]];
}

- (UIViewController*)timelineControllerForDate:(NSDate*)date {
    HEMSleepGraphViewController* controller = (id)[HEMMainStoryboard instantiateSleepGraphController];
    [controller setDateForNightOfSleep:date];
    return controller;
}

- (void)updateLastNightSleepScore:(NSInteger)sleepScore {
    if (sleepScore != [self lastNightSleepScore]) {
        [self setLastNightSleepScore:sleepScore];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage* sleepScoreImage = [UIImage iconFromSleepScoreWithSleepScore:sleepScore highlighted:NO];
            UIImage* sleepScoreImageHighlighted = [UIImage iconFromSleepScoreWithSleepScore:sleepScore highlighted:YES];
            sleepScoreImageHighlighted = [sleepScoreImageHighlighted imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.tabBarItem.image = sleepScoreImage;
                strongSelf.tabBarItem.selectedImage = sleepScoreImageHighlighted;
            });
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    [self setHandHoldingService:[HEMHandHoldingService new]];
    [self listenForTimelineChanges];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    UIGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(didPan)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
    
    static CGFloat parallaxDepth = 4.0f;
    [self.view add3DEffectWithBorder:parallaxDepth direction:HEMMotionEffectsDirectionVertical];
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

- (void)reloadWithDate:(NSDate*)date {
    UIViewController* timelineVC = [self timelineControllerForDate:date];
    [self reloadDataWithController:timelineVC];
}

- (void)reloadDataWithController:(UIViewController*)controller {
    if (controller) {
        [[controller view] setFrame:[[self view] bounds]];
        [self setViewControllers:@[controller]
                       direction:UIPageViewControllerNavigationDirectionForward
                                 | UIPageViewControllerNavigationDirectionReverse
                        animated:NO
                      completion:nil];
    }
}

- (void)setSwipingEnabled:(BOOL)enabled {
    self.dataSource = enabled ? self.data : nil;
}

#pragma mark - Notifications

- (void)listenForTimelineChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(timelineChanged:)
                   name:HEMTimelineFeedbackSuccessNotification
                 object:nil];
}

- (void)timelineChanged:(NSNotification*)note {
    NSDate* lastNight = [NSDate timelineInitialDate];
    SENTimeline* lastNightTimeline = [SENTimeline timelineForDate:lastNight];
    if (lastNightTimeline) {
        [self updateLastNightSleepScore:[[lastNightTimeline score] integerValue]];
    }
}

#pragma mark - Gesture Recognizers

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    if (fabs(velocity.x) > 0 && fabs(velocity.x) > fabs(velocity.y)) {
        CGFloat const sliceWidth = 1;
        HEMSleepGraphViewController* controller = [self.viewControllers lastObject];
        CGFloat width = CGRectGetWidth(controller.view.bounds);
        CGRect slice = CGRectMake(width - sliceWidth, 0, sliceWidth, CGRectGetHeight(controller.view.bounds));
        UIImage* pattern = [controller.view snapshotOfRect:slice];
        self.view.backgroundColor = [UIColor colorWithPatternImage:pattern];
        
        if (![[self handHoldingService] isComplete:HEMHandHoldingTimelineSwipe]) {
            [[self handHoldingService] completed:HEMHandHoldingTimelineSwipe];
        }
        
    }
    return YES;
}

- (void)didPan { }

#pragma mark - Cleanup

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setDataSource:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
