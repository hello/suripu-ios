//
//  HEMSupportViewController.m
//  Sense
//
//  Created by Jimmy Lu on 6/4/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMSupportViewController.h"
#import "HEMSettingsTableViewCell.h"
#import "HEMMainStoryboard.h"
#import "HEMZendeskService.h"
#import "HEMActivityCoverView.h"

// the offset is needed because ZDK native UI is not laid out correctly, causing
// it to be exactly 5 pixels behind the navigation bar
static CGFloat const HEMSupportZDKUIOffset = 5.0f;

static CGFloat const HEMSupportZDKUIHeightDiff = -50.0f;

typedef NS_ENUM(NSUInteger, HEMSupportRow) {
    HEMSupportRowIndexUserGuide = 0,
    HEMSupportRowIndexContactUs = 1,
    HEMSupportRowIndexTickets = 2,
    HEMSupportRows = 3
};

@interface HEMSupportViewController() <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) id<UINavigationControllerDelegate> origNavDelegate;

@end

@implementation HEMSupportViewController

+ (void)initialize {
    [[ZDKCreateRequestView appearance] setTextEntryFont:[UIFont supportTicketDescriptionFont]];
    [[ZDKSupportTableViewCell appearance] setTitleLabelFont:[UIFont settingsTableCellFont]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [[HEMZendeskService sharedService] configure:^(NSError *error) {
        if (error) {
            DDLogWarn(@"failed to configure zendesk with error %@", error);
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![self origNavDelegate]) {
        if ([[self navigationController] delegate] != self) {
            [self setOrigNavDelegate:[[self navigationController] delegate]];
        }
    } else {
        [[self navigationController] setDelegate:[self origNavDelegate]];
        [self setOrigNavDelegate:nil];
    }
}

- (void)configureTableView {
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    
    // header
    CGRect frame = CGRectZero;
    frame.size.height = HEMSettingsCellTableMargin;
    frame.size.width = width;
    [[self tableView] setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
}

#pragma mark - UITableViewDataSource / Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return HEMSupportRows;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = [HEMMainStoryboard supportCellReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:reuseId];
}

- (NSString*)titleForRowAtIndexPath:(NSIndexPath*)indexPath {
    switch ([indexPath row]) {
        case HEMSupportRowIndexUserGuide:
            return NSLocalizedString(@"settings.user-guide", nil);
        case HEMSupportRowIndexContactUs:
            return NSLocalizedString(@"settings.contact-us", nil);
        case HEMSupportRowIndexTickets:
            return NSLocalizedString(@"settings.my-tickets", nil);
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {

    HEMSettingsTableViewCell *supportCell = (HEMSettingsTableViewCell *)cell;
    [[supportCell titleLabel] setText:[self titleForRowAtIndexPath:indexPath]];
    
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
    
    switch ([indexPath row]) {
        case HEMSupportRowIndexUserGuide: {
            [[self navigationController] setDelegate:self];
            [ZDKHelpCenter showHelpCenterWithNavController:[self navigationController]
                                               layoutGuide:ZDKLayoutRespectNone];
            break;
        }
        case HEMSupportRowIndexContactUs:
            [self performSegueWithIdentifier:[HEMMainStoryboard topicsSegueIdentifier] sender:self];
            break;
        case HEMSupportRowIndexTickets:
            [ZDKRequests showRequestListWithNavController:[self navigationController]];
            break;
        default:
            break;
    }
    
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    [[viewController navigationItem] setRightBarButtonItems:nil];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    CGRect viewFrame = [[viewController view] frame];
    viewFrame.origin.y += HEMSupportZDKUIOffset;
    viewFrame.size.height += HEMSupportZDKUIHeightDiff;
    [[viewController view] setFrame:viewFrame];
}

#pragma mark - Clean up

- (void)dealloc {
    [_tableView setDelegate:nil];
    [_tableView setDataSource:nil];
}

@end
