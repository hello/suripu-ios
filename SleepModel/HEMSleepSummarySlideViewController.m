//
//  HEMSleepSummarySlideViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>

#import "HEMSleepSummarySlideViewController.h"
#import "HEMSleepGraphCollectionViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSlideViewController+Protected.h"
#import "HEMColorUtils.h"
#import "HEMSleepSummaryPagingDataSource.h"

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
    HEMSleepGraphCollectionViewController* controller
        = (HEMSleepGraphCollectionViewController*)[HEMMainStoryboard instantiateSleepGraphController];
    [controller setDateForNightOfSleep:startDate];
    
    if (self = [super initWithInitialController:controller]) {
        [self setData:[[HEMSleepSummaryPagingDataSource alloc] init]];
        [self setDataSource:[self data]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackgroundGradientLayer];
}

- (void)addBackgroundGradientLayer {
    NSDate* now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSHourCalendarUnit
                                               fromDate:now];
    NSInteger hour = [components hour];
    
    CAGradientLayer* layer = [CAGradientLayer layer];
    [layer setFrame:[[self view] bounds]];
    [HEMColorUtils configureLayer:layer forHourOfDay:hour];
    [[[self view] layer] insertSublayer:layer atIndex:0];
    [self setBgGradientLayer:layer];
}

- (void)beginSliding {
    [[self panePanGestureRecognizer] setEnabled:NO];
    [super beginSliding];
}

- (void)endSliding {
    [[self panePanGestureRecognizer] setEnabled:YES];
    [super endSliding];
}

#pragma mark - FCDynamicPaneViewController

- (void)viewDidPop {
    for (UIViewController* viewController in [self childViewControllers]) {
        if ([viewController respondsToSelector:@selector(viewDidPop)]) {
            [(UIViewController<FCDynamicPaneViewController>*)viewController viewDidPop];
        }
    }
    [[self slideGesture] setEnabled:NO];
}

- (void)viewDidPush {
    for (UIViewController* viewController in [self childViewControllers]) {
        if ([viewController respondsToSelector:@selector(viewDidPush)]) {
            [(UIViewController<FCDynamicPaneViewController>*)viewController viewDidPush];
        }
    }
    [[self slideGesture] setEnabled:YES];
}

#pragma mark - Cleanup

- (void)dealloc {
    [self setDataSource:nil];
}

@end
