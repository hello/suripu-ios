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
#import "HEMAlertViewController.h"
#import "HEMSupportTopicDataSource.h"
#import "HEMActivityCoverView.h"

@interface HEMSupportTopicsViewController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) HEMSupportTopicDataSource* dataSource;

@end

@implementation HEMSupportTopicsViewController

+ (void)initialize {
    [[ZDKCreateRequestView appearance] setTextEntryFont:[UIFont supportTicketDescriptionFont]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [self listenToTicketCreationEvents];
}

- (void)configureTableView {
    [self setDataSource:[[HEMSupportTopicDataSource alloc] init]];
    [[self tableView] setDataSource:[self dataSource]];
    
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    
    // header
    CGRect frame = CGRectZero;
    frame.size.height = HEMSettingsCellTableMargin;
    frame.size.width = width;
    [[self tableView] setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
    
    // footer
    [[self tableView] setTableFooterView:[[UIView alloc] initWithFrame:frame]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[self dataSource] isLoaded]) {
        [self loadData];
    }
}

- (void)loadData {
    HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] init];
    NSString* loadingText = NSLocalizedString(@"activity.loading", nil);
    [activityView showInView:[self tableView] withText:loadingText activity:YES completion:nil];
    
    __weak typeof(self) weakSelf = self;
    [[self dataSource] reloadData:^(NSError *error) {
        [[weakSelf tableView] reloadData];
        [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:nil];
        if (error) {
            [SENAnalytics trackError:error];
        }
    }];
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    HEMSettingsTableViewCell *supportCell = (HEMSettingsTableViewCell *)cell;
    [[supportCell titleLabel] setText:[[self dataSource] displayNameForRowAtIndexPath:indexPath]];
    
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
    NSString* value = [[self dataSource] topicForRowAtIndexPath:indexPath];
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
