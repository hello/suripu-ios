//
//  HEMTimelineFeedbackViewController.m
//  Sense
//
//  Created by Delisa Mason on 2/9/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENTimeline.h>
#import <SenseKit/SENAPITimeline.h>
#import "HEMTimelineFeedbackViewController.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMClockPickerView.h"
#import "HEMRootViewController.h"
#import "HEMAlertViewController.h"
#import "HEMBounceModalTransition.h"
#import "HelloStyleKit.h"
#import "HEMActivityCoverView.h"

NSString* const HEMTimelineFeedbackSuccessNotification = @"HEMTimelineFeedbackSuccessNotification";

@interface HEMTimelineFeedbackViewController ()
@property (nonatomic, weak) IBOutlet HEMClockPickerView* clockView;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* tinySeparatorHeight;
@property (nonatomic, weak) IBOutlet UIView* titleContainerView;
@property (nonatomic, weak) IBOutlet UIView *buttonContainerView;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) NSCalendar* calendar;
@property (nonatomic, assign, getter=isConfigured) BOOL configured;
@end

@implementation HEMTimelineFeedbackViewController

static NSString* const HEMTimelineFeedbackTitleFormat = @"sleep-event.feedback.title.%@";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.calendar = [NSCalendar autoupdatingCurrentCalendar];
    [self configureButtonContainer];
    [SENAnalytics track:HEMAnalyticsEventTimelineAdjustTime];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self isConfigured]) {
        [self configureSegmentViews];
        [self setConfigured:YES];
    }
}

- (void)configureButtonContainer {
    CALayer *layer = self.buttonContainerView.layer;
    layer.shadowRadius = 2.f;
    layer.shadowOffset = CGSizeMake(0, -2.f);
    layer.shadowOpacity = 0.05f;
}

- (void)configureSegmentViews
{
    if (!self.segment)
        return;
    self.calendar.timeZone = self.segment.timezone;
    NSDateComponents* components = [self.calendar components:(NSHourCalendarUnit|NSMinuteCalendarUnit)
                                                    fromDate:self.segment.date];
    [self.clockView updateTimeToHour:components.hour minute:components.minute];
    NSString* type = [SENTimelineSegmentTypeNameFromType(self.segment.type) lowercaseString];
    NSString* key = [NSString stringWithFormat:HEMTimelineFeedbackTitleFormat, type];
    NSString* title = NSLocalizedString(key, nil);
    if ([title isEqualToString:key]) {
        title = NSLocalizedString(@"sleep-event.feedback.title.generic", nil);
    }
    self.titleLabel.text = title;
    self.tinySeparatorHeight.constant = 0.5f;
}

- (IBAction)sendUpdatedTime:(UIButton*)sender
{
    sender.enabled = NO;
    
    [[self cancelButton] setEnabled:NO];

    NSString* activityText = NSLocalizedString(@"activity.saving.changes", nil);
    HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] init];
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(id, NSError *) = ^(SENTimeline* updatedTimeline, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                [[strongSelf cancelButton] setEnabled:YES];
                [sender setEnabled:YES];
                [HEMAlertViewController showInfoDialogWithTitle:NSLocalizedString(@"sleep-event.feedback.failed.title", nil)
                                                        message:NSLocalizedString(@"sleep-event.feedback.failed.message", nil)
                                                     controller:strongSelf];
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey : HEMAnalyticsEventTimelineAdjustTimeFailed};
                [SENAnalytics trackError:[NSError errorWithDomain:[error domain]
                                                             code:[error code]
                                                         userInfo:userInfo]
                           withEventName:kHEMAnalyticsEventError];
            }];

        } else {
            NSDictionary* properties = @{kHEMAnalyticsEventPropType : SENTimelineSegmentTypeNameFromType(self.segment.type) ?: @"undefined"};
            [SENAnalytics track:kHEMAnalyticsEventTimelineAdjustTimeSaved properties:properties];
            [updatedTimeline save];
            [[NSNotificationCenter defaultCenter] postNotificationName:HEMTimelineFeedbackSuccessNotification object:strongSelf];
            
            NSString* message = NSLocalizedString(@"sleep-event.feedback.success.message", nil);
            UIImage* icon = [HelloStyleKit check];
            [activityView updateText:message successIcon:icon hideActivity:YES completion:^(BOOL finished) {
                [activityView showSuccessMarkAnimated:YES completion:^(BOOL finished) {
                    NSTimeInterval delayInSeconds = 0.5f;
                    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
                        [strongSelf dismissViewControllerAnimated:YES completion:NULL];
                    });
                }];
            }];
        }
        
    };
    
    [activityView showInView:[self view] withText:activityText activity:YES completion:^{
        [SENAPITimeline amendSleepEvent:self.segment
                         forDateOfSleep:self.dateForNightOfSleep
                               withHour:@(self.clockView.hour)
                             andMinutes:@(self.clockView.minute)
                             completion:completion];
    }];

}

- (IBAction)cancelAndDismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
