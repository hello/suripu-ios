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

@interface HEMTimelineContainerViewController ()
@property (nonatomic, weak) IBOutlet UIButton *alarmButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *alarmButtonTrailing;
@property (nonatomic, weak) IBOutlet UIButton *centerTitleButton;
@property (nonatomic, weak) IBOutlet UILabel *centerTitleLabel;

@property (nonatomic, strong) HEMSleepHistoryViewController *historyViewController;
@property (nonatomic, strong) HEMZoomAnimationTransitionDelegate *animationDelegate;
@end

@implementation HEMTimelineContainerViewController

static CGFloat const HEMAlarmShortcutDefaultTrailing = -16.f;
static CGFloat const HEMAlarmShortcutHiddenTrailing = 60.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.animationDelegate = [HEMZoomAnimationTransitionDelegate new];
    self.transitioningDelegate = self.animationDelegate;
    ;
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

- (NSString *)centerTitle {
    return self.centerTitleLabel.text;
}

- (void)setCenterTitle:(NSString *)title {
    self.centerTitleLabel.text = title;
}

- (void)showBorder:(BOOL)isVisible {
}

- (void)showBlurWithHeight:(CGFloat)blurHeight {
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
            animations:^{ [self.view layoutIfNeeded]; }
            completion:^(BOOL finished) {
              if (constant > 0)
                  self.alarmButton.hidden = YES;
            }];
    }
}

#pragma mark Drawer

- (void)drawerDidOpen {
    //    [UIView animateWithDuration:0.5f animations:^{ [self updateTopBarActionsWithState:NO]; }];
}

- (void)drawerDidClose {
    //    [UIView animateWithDuration:0.5f animations:^{ [self updateTopBarActionsWithState:YES]; }];
}

#pragma mark Top bar actions

- (void)toggleDrawer {
    HEMRootViewController *root = [HEMRootViewController rootViewControllerForKeyWindow];
    [root toggleSettingsDrawer];
}

- (IBAction)drawerButtonTapped:(UIButton *)button {
    [self toggleDrawer];
}

- (IBAction)shareButtonTapped:(UIButton *)button {
//    long score = [self.dataSource.sleepResult.score longValue];
//    if (score > 0) {
//        NSString *message;
//        if (self.lastNight) {
//            message = [NSString stringWithFormat:NSLocalizedString(@"activity.share.last-night.format", nil), score];
//        } else {
//            message = [NSString stringWithFormat:NSLocalizedString(@"activity.share.other-days.format", nil), score,
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
