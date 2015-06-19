//
//  HEMTimelineContainerViewController.m
//  Sense
//
//  Created by Delisa Mason on 6/11/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTimelineContainerViewController.h"
#import "HEMSleepHistoryViewController.h"
#import "HEMZoomAnimationTransitionDelegate.h"
#import "HEMRootViewController.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"
#import "NSDate+HEMRelative.h"

@interface HEMTimelineContainerViewController ()
@property (nonatomic, weak) IBOutlet UIButton *drawerButton;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIButton *alarmButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *alarmButtonTrailing;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *centerTitleTop;
@property (nonatomic, weak) IBOutlet UIButton *centerTitleButton;
@property (nonatomic, weak) IBOutlet UILabel *centerTitleLabel;
@property (nonatomic, weak) IBOutlet UIView *topBarView;

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDateFormatter *weekdayDateFormatter;
@property (nonatomic, strong) NSDateFormatter *rangeDateFormatter;
@property (nonatomic, strong) HEMSleepHistoryViewController *historyViewController;
@property (nonatomic, strong) HEMZoomAnimationTransitionDelegate *animationDelegate;
@property (nonatomic, strong) CAGradientLayer *topGradientLayer;
@end

@implementation HEMTimelineContainerViewController

CGFloat const HEMAlarmShortcutDefaultTrailing = -16.f;
CGFloat const HEMAlarmShortcutHiddenTrailing = 60.f;
CGFloat const HEMCenterTitleDrawerClosedTop = 20.f;
CGFloat const HEMCenterTitleDrawerOpenTop = 10.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.animationDelegate = [HEMZoomAnimationTransitionDelegate new];
    self.transitioningDelegate = self.animationDelegate;
    self.rangeDateFormatter = [NSDateFormatter new];
    self.rangeDateFormatter.dateFormat = @"MMMM d";
    self.weekdayDateFormatter = [NSDateFormatter new];
    self.weekdayDateFormatter.dateFormat = @"EEEE";
    self.calendar = [NSCalendar autoupdatingCurrentCalendar];
    [self registerForNotifications];
    [self configureGradientLayer];
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerDidOpen)
                                                 name:HEMRootDrawerMayOpenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerDidClose)
                                                 name:HEMRootDrawerMayCloseNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerDidOpen)
                                                 name:HEMRootDrawerDidOpenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerDidClose)
                                                 name:HEMRootDrawerDidCloseNotification
                                               object:nil];
}

- (void)configureGradientLayer {
    self.topGradientLayer = [CAGradientLayer layer];
    self.topGradientLayer.colors =
        @[ (id)[UIColor whiteColor].CGColor, (id)[UIColor colorWithWhite:1.f alpha:0].CGColor ];
    self.topGradientLayer.startPoint = CGPointZero;
    self.topGradientLayer.endPoint = CGPointMake(0, 1);
    self.topGradientLayer.locations = @[ @0, @(0.8) ];
    self.topGradientLayer.bounds = CGRectZero;
    [self.view.layer insertSublayer:self.topGradientLayer below:self.topBarView.layer];
}

- (IBAction)alarmButtonTapped:(id)sender {
    HEMRootViewController *root = [HEMRootViewController rootViewControllerForKeyWindow];
    [root showSettingsDrawerTabAtIndex:HEMRootDrawerTabAlarms animated:YES];
}

- (NSString *)centerTitle {
    return self.centerTitleLabel.text;
}

- (void)setCenterTitleFromDate:(NSDate *)date {
    self.centerTitleLabel.text = [self titleTextForDate:date];
    [UIView animateWithDuration:0.2f
                     animations:^{
                       self.centerTitleLabel.alpha = 1;
                     }];
}

- (void)prepareForCenterTitleChange {
    [UIView animateWithDuration:0.2f
                     animations:^{
                       self.centerTitleLabel.alpha = 0;
                     }];
}

- (void)cancelCenterTitleChange {
    [UIView animateWithDuration:0.2f
                     animations:^{
                       self.centerTitleLabel.alpha = 1;
                     }];
}

- (NSString *)titleTextForDate:(NSDate *)date {
    NSDateComponents *diff =
        [self.calendar components:NSDayCalendarUnit fromDate:date toDate:[[NSDate date] previousDay] options:0];
    if (diff.day == 0)
        return NSLocalizedString(@"sleep-history.last-night", nil);
    else if (diff.day < 7)
        return [self.weekdayDateFormatter stringFromDate:date];
    else
        return [self.rangeDateFormatter stringFromDate:date];
}

- (void)showBlurWithHeight:(CGFloat)blurHeight {
    self.topGradientLayer.frame
        = CGRectMake(0, CGRectGetHeight(self.topBarView.bounds), CGRectGetWidth(self.topBarView.bounds), blurHeight);
}

- (void)showAlarmButton:(BOOL)isVisible {
    CGFloat constant = isVisible ? HEMAlarmShortcutDefaultTrailing : HEMAlarmShortcutHiddenTrailing;
    [self moveAlarmButtonWithOffset:constant];
}

- (void)moveAlarmButtonWithOffset:(CGFloat)constant {
    if (self.alarmButtonTrailing.constant != constant) {
        if (constant < 0)
            self.alarmButton.hidden = NO;
        self.alarmButtonTrailing.constant = constant;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.3f
            delay:0
            usingSpringWithDamping:0.8
            initialSpringVelocity:0
            options:0
            animations:^{
              [self.view layoutIfNeeded];
            }
            completion:^(BOOL finished) {
              if (constant > 0)
                  self.alarmButton.hidden = YES;
            }];
    }
}

#pragma mark Drawer

- (void)drawerDidOpen {
    [UIView animateWithDuration:0.5f
                     animations:^{
                       [self updateTopBarWithDrawerOpenState:YES];
                     }];
}

- (void)drawerDidClose {
    [UIView animateWithDuration:0.5f
                     animations:^{
                       [self updateTopBarWithDrawerOpenState:NO];
                     }];
}

- (void)updateTopBarWithDrawerOpenState:(BOOL)isOpen {
    UIImage *image = [UIImage imageNamed:isOpen ? @"caret up" : @"Menu"];
    [self.drawerButton setImage:image forState:UIControlStateNormal];
    CGFloat auxButtonAlpha = isOpen ? 0 : 1;
    CGFloat constant = isOpen ? HEMCenterTitleDrawerOpenTop : HEMCenterTitleDrawerClosedTop;
    self.centerTitleTop.constant = constant;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2f
                     animations:^{
                       self.centerTitleLabel.textColor = isOpen ? [HelloStyleKit barButtonDisabledColor]
                                                                : [HelloStyleKit tintColor];
                       self.shareButton.alpha = auxButtonAlpha;
                       [self.view layoutIfNeeded];
                     }];
}

#pragma mark Top bar actions

- (IBAction)drawerButtonTapped:(UIButton *)button {
    HEMRootViewController *root = [HEMRootViewController rootViewControllerForKeyWindow];
    [root toggleSettingsDrawer];
}

- (IBAction)shareButtonTapped:(UIButton *)button {
    //    long score = [self.dataSource.sleepResult.score longValue];
    //    if (score > 0) {
    //        NSString *message;
    //        if (self.lastNight) {
    //            message = [NSString stringWithFormat:NSLocalizedString(@"activity.share.last-night.format", nil),
    //            score];
    //        } else {
    //            message = [NSString stringWithFormat:NSLocalizedString(@"activity.share.other-days.format", nil),
    //            score,
    //                       [self.dataSource titleTextForDate]];
    //        }
    //        UIActivityViewController *activityController =
    //        [[UIActivityViewController alloc] initWithActivityItems:@[ message ] applicationActivities:nil];
    //        [self presentViewController:activityController animated:YES completion:nil];
    //    }
}

- (void)zoomButtonTapped:(UIButton *)sender {
    self.historyViewController = (id)[HEMMainStoryboard instantiateSleepHistoryController];
    //    self.historyViewController.selectedDate = self.dateForNightOfSleep;
    self.historyViewController.transitioningDelegate = self.animationDelegate;
    [self presentViewController:self.historyViewController animated:YES completion:NULL];
}

- (void)checkForDateChanges {
    if (self.historyViewController.selectedDate) {
        HEMRootViewController *root = [HEMRootViewController rootViewControllerForKeyWindow];
        [root reloadTimelineSlideViewControllerWithDate:self.historyViewController.selectedDate];
    }

    self.historyViewController = nil;
}

- (void)loadDataSourceForDate:(NSDate *)date {
    //    self.dateForNightOfSleep = date;
    //    self.presleepExpanded = NO;
    //    self.dataSource =
    //    [[HEMSleepGraphCollectionViewDataSource alloc] initWithCollectionView:self.collectionView sleepDate:date];
    //    self.collectionView.dataSource = self.dataSource;
}

@end
