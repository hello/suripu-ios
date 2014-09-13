//
//  HEMSleepSummarySlideViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>

#import <SenseKit/SENServiceQuestions.h>
#import <SenseKit/SENQuestion.h>

#import "UIImage+ImageEffects.h"

#import "HEMSleepSummarySlideViewController.h"
#import "HEMSleepGraphCollectionViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSlideViewController+Protected.h"
#import "HEMColorUtils.h"
#import "HEMSleepSummaryPagingDataSource.h"
#import "HEMInfoAlertView.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMZoomTransitionAnimator.h"
#import "HEMProgressNavigationController.h"

@interface HEMSleepSummarySlideViewController () <
    FCDynamicPaneViewController,
    UIViewControllerTransitioningDelegate
>

@property (nonatomic, weak) CAGradientLayer* bgGradientLayer;
@property (nonatomic, strong) HEMSleepSummaryPagingDataSource* data;
@property (nonatomic, strong) HEMInfoAlertView* qAlertView;
@property (nonatomic, strong) id qObserver;

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
    [self listenForSleepQuestions];
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

#pragma mark - Questions

- (void)listenForSleepQuestions {
    __weak typeof(self) weakSelf = self;
    self.qObserver =
        [[SENServiceQuestions sharedService] listenForNewQuestions:^(NSArray *questions) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf && [questions count] > 0) {
                [strongSelf performSelector:@selector(showQuestionAlertFor:)
                                 withObject:questions
                                 afterDelay:2.0f];
            }
        }];
}

- (void)showQuestionAlertFor:(NSArray*)questions {
    if ([questions count] == 0 || [self qAlertView] != nil) return;
    // just show the first question as an alert
    SENQuestion* question = questions[0];
    HEMInfoAlertView* alert =
        [[HEMInfoAlertView alloc] initWithInfo:[question question]];
    [alert addTarget:self action:@selector(showQuestions:)];
    [alert showInView:[[self view] superview] animated:YES completion:nil];
    [self setQAlertView:alert];
}

- (UIImage*)snapshot {
    UIGraphicsBeginImageContextWithOptions([[self view] bounds].size, NO, 0);
    
    [[self view] drawViewHierarchyInRect:[[self view] bounds] afterScreenUpdates:YES];
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}

- (void)showQuestions:(id)sender {
    if ([self presentedViewController] != nil) return;
    
    UIImage* snapshot = [[self snapshot] applyBlurWithRadius:10
                                                   tintColor:[UIColor colorWithWhite:1.0f alpha:0.4f]
                                       saturationDeltaFactor:1.2
                                                   maskImage:nil];
    
    [[self qAlertView] dismiss:YES completion:^{
        NSArray* questions = [[SENServiceQuestions sharedService] todaysQuestions];
        HEMSleepQuestionsViewController* questionsVC =
        (HEMSleepQuestionsViewController*)[HEMMainStoryboard instantiateSleepQuestionsViewController];
        [questionsVC setQuestions:questions];
        
        HEMProgressNavigationController* nav =
            [[HEMProgressNavigationController alloc] initWithRootViewController:questionsVC];
        [nav setTransitioningDelegate:self];
        [nav setModalPresentationStyle:UIModalPresentationCustom];
        [nav setNumberOfScreens:[questions count]];
        [nav setBgImage:snapshot];
        [self presentViewController:nav animated:YES completion:nil];
        
        [self setQAlertView:nil];
    }];
}

#pragma mark Transition

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [HEMZoomTransitionAnimator new];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [HEMZoomTransitionAnimator new];
}

#pragma mark - Cleanup

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setDataSource:nil];
    [[SENServiceQuestions sharedService] stopListening:[self qObserver]];
}

@end
