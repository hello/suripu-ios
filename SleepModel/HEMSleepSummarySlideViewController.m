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
#import "HelloStyleKit.h"

@interface HEMSleepSummarySlideViewController ()

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
    HEMSleepGraphViewController* controller
    = (HEMSleepGraphViewController*)[HEMMainStoryboard instantiateSleepGraphController];
    [controller setDateForNightOfSleep:date];
    [self reloadDataWithController:controller];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTopShadow];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)reloadData {
    if ([self isViewLoaded] && self.view.window)
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
