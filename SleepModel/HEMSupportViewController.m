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
    [[ZDKSupportTableViewCell appearance] setTitleLabelFont:[UIFont supportHelpCenterFont]];
    [[ZDKSupportArticleTableViewCell appearance] setTitleLabelFont:[UIFont supportHelpCenterFont]];
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
    
    if ([self origNavDelegate]) {
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
            // FIXME jimmy: setting the navigationController is a total hack, but
            // because ZDK does not provide direct access to the view controller
            // and their layout is a total mess, we need to hack around the mistakes.
            //
            // A ticket has been filed and an email has been sent to their team.
            // If they provide a solution to this problem, we will remove this, but
            // for now, this is required per design for this to be release-able
            [self setOrigNavDelegate:[[self navigationController] delegate]];
            
            __weak typeof(self) weakSelf = self;
            [[self navigationController] setDelegate:weakSelf];
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
    viewFrame.size.height += HEMSupportZDKUIHeightDiff;
    [[viewController view] setFrame:viewFrame];
    [[navigationController interactivePopGestureRecognizer] setEnabled:YES];
}

#pragma mark - Clean up

- (void)dealloc {
    [_tableView setDelegate:nil];
    [_tableView setDataSource:nil];
    
    if (_origNavDelegate) {
        [[self navigationController] setDelegate:_origNavDelegate];
    }
}

@end
