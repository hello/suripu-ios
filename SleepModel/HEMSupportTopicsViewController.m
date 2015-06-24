//
//  HEMSupportTopicsViewController.m
//  Sense
//
//  Created by Jimmy Lu on 6/15/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMSupportTopicsViewController.h"
#import "HEMSettingsTableViewCell.h"
#import "HEMZendeskService.h"
#import "HEMMainStoryboard.h"
#import "HEMBaseController+Protected.h"
#import "HEMAlertViewController.H"

@interface HEMSupportTopicsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDictionary* topicValuesByName;
@property (strong, nonatomic) NSArray* topicNames;
@property (weak, nonatomic) id previousResponder;

@end

@implementation HEMSupportTopicsViewController

+ (void)initialize {
    [[ZDKCreateRequestView appearance] setTextEntryFont:[UIFont supportTicketDescriptionFont]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [self loadTopics];
    [self listenToTicketCreationEvents];
}

- (void)configureTableView {
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    
    // header
    CGRect frame = CGRectZero;
    frame.size.height = HEMSettingsCellTableMargin;
    frame.size.width = width;
    [[self tableView] setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
    
    // footer
    [[self tableView] setTableFooterView:[[UIView alloc] initWithFrame:frame]];
}

- (void)loadTopics {
    [self setTopicNames:@[NSLocalizedString(@"settings.support.topic.sense-pairing", nil),
                          NSLocalizedString(@"settings.support.topic.pill-pairing", nil),
                          NSLocalizedString(@"settings.support.topic.wifi", nil),
                          NSLocalizedString(@"settings.support.topic.timeline", nil),
                          NSLocalizedString(@"settings.support.topic.room-conditions", nil),
                          NSLocalizedString(@"settings.support.topic.sleep-score", nil),
                          NSLocalizedString(@"settings.support.topic.smart-alarm", nil),
                          NSLocalizedString(@"settings.support.topic.hardware", nil),
                          NSLocalizedString(@"settings.support.topic.order", nil),
                          NSLocalizedString(@"settings.support.topic.return", nil),
                          NSLocalizedString(@"settings.support.topic.payment", nil),
                          NSLocalizedString(@"settings.support.topic.business-enquiry", nil),
                          NSLocalizedString(@"settings.support.topic.other", nil)]];
    
    [self setTopicValuesByName:@{NSLocalizedString(@"settings.support.topic.sense-pairing", nil) : @"pairing_sense",
                                 NSLocalizedString(@"settings.support.topic.pill-pairing", nil) : @"pairing_a_sleep_pill",
                                 NSLocalizedString(@"settings.support.topic.wifi", nil) : @"connect_to_wifi",
                                 NSLocalizedString(@"settings.support.topic.timeline", nil) : @"sleep_timeline",
                                 NSLocalizedString(@"settings.support.topic.room-conditions", nil) : @"room_conditions",
                                 NSLocalizedString(@"settings.support.topic.sleep-score", nil) : @"sleep_score",
                                 NSLocalizedString(@"settings.support.topic.smart-alarm", nil) : @"smart_alarm",
                                 NSLocalizedString(@"settings.support.topic.hardware", nil) : @"damanaged_hardware",
                                 NSLocalizedString(@"settings.support.topic.order", nil) : @"my_order",
                                 NSLocalizedString(@"settings.support.topic.return", nil) : @"return",
                                 NSLocalizedString(@"settings.support.topic.payment", nil) : @"payment",
                                 NSLocalizedString(@"settings.support.topic.business-enquiry", nil) : @"business_enquiry",
                                 NSLocalizedString(@"settings.support.topic.other", nil) : @"other"}];
}

#pragma mark - Notifications

- (void)listenToTicketCreationEvents {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(didCreateTicket)
                   name:ZDKAPI_RequestSubmissionSuccess
                 object:nil];
}

- (void)didCreateTicket {
    [[self navigationController] popViewControllerAnimated:NO];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self topicNames] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard topicCellReuseIdentifier]];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    HEMSettingsTableViewCell *supportCell = (HEMSettingsTableViewCell *)cell;
    [[supportCell titleLabel] setText:[self topicNames][[indexPath row]]];
    
    NSInteger numberOfRows = [tableView numberOfRowsInSection:[indexPath section]];
    
    if ([indexPath row] == 0 && [indexPath row] == numberOfRows - 1) {
        [supportCell showTopAndBottomCorners];
    } else if ([indexPath row] == 0) {
        [supportCell showTopCorners];
    } else if ([indexPath row] == numberOfRows - 1) {
        [supportCell showBottomCorners];
    } else {
        [supportCell showNoCorners];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* name = [self topicNames][[indexPath row]];
    NSString* value = [self topicValuesByName][name];
    [[HEMZendeskService sharedService] configureRequestWithTopic:value completion:^{
        [ZDKRequests showRequestCreationWithNavController:[self navigationController]];
    }];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tableView setDelegate:nil];
    [_tableView setDataSource:nil];
}

@end
