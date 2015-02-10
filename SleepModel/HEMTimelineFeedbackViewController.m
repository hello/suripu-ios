//
//  HEMTimelineFeedbackViewController.m
//  Sense
//
//  Created by Delisa Mason on 2/9/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSleepResult.h>
#import "HEMTimelineFeedbackViewController.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMClockPickerView.h"

@interface HEMTimelineFeedbackViewController ()
@property (nonatomic, weak) IBOutlet HEMClockPickerView* clockView;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* tinyLineHeight;
@property (nonatomic, strong) NSCalendar* calendar;
@end

@implementation HEMTimelineFeedbackViewController

static NSString* const HEMTimelineFeedbackTitleFormat = @"sleep-event.feedback.title.%@";

+ (BOOL)canAdjustTimeForSegment:(SENSleepResultSegment *)segment {
    static NSArray* adjustableTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        adjustableTypes = @[HEMSleepEventTypeInBed, HEMSleepEventTypeWakeUp,
                            HEMSleepEventTypeOutOfBed, HEMSleepEventTypeFallAsleep];
    });
    return [adjustableTypes containsObject:segment.eventType];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.calendar = [NSCalendar autoupdatingCurrentCalendar];
    [self configureSegmentViews];
    [self configureBarButtonItems];
}

- (void)configureSegmentViews
{
    if (!self.segment)
        return;
    self.calendar.timeZone = self.segment.timezone;
    NSDateComponents* components = [self.calendar components:(NSHourCalendarUnit|NSMinuteCalendarUnit)
                                                    fromDate:self.segment.date];
    [self.clockView updateTimeToHour:components.hour minute:components.minute];
    NSString* key = [NSString stringWithFormat:HEMTimelineFeedbackTitleFormat, [self.segment.eventType lowercaseString]];
    self.titleLabel.text = NSLocalizedString(key, nil);
    self.tinyLineHeight.constant = 0.5f;
}

- (void)configureBarButtonItems
{
    static CGFloat const HEMFeedbackBarButtonSpace = 12.f;
    UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil];
    leftFixedSpace.width = HEMFeedbackBarButtonSpace;
    UIBarButtonItem *rightFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                     target:nil
                                                                                     action:nil];
    rightFixedSpace.width = HEMFeedbackBarButtonSpace;
    UIBarButtonItem* leftItem = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItems = @[leftFixedSpace, leftItem];
    UIBarButtonItem* rightItem = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItems = @[rightFixedSpace, rightItem];
}

- (IBAction)sendUpdatedTime:(id)sender
{

}

- (IBAction)cancelAndDismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
