//
//  HEMSupportViewController.m
//  Sense
//
//  Created by Jimmy Lu on 6/4/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

#import "HEMSupportViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMZendeskService.h"
#import "HEMActivityCoverView.h"
#import "HEMScreenUtils.h"
#import "HEMSettingsHeaderFooterView.h"

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
    [[ZDKSupportTableViewCell appearance] setTitleLabelFont:[UIFont h6]];
    [[ZDKSupportArticleTableViewCell appearance] setTitleLabelFont:[UIFont h6]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [self listenToTicketCreationEvents];
    
    [[HEMZendeskService sharedService] configure:^(NSError *error) {
        if (error) {
            DDLogWarn(@"failed to configure zendesk with error %@", error);
            [SENAnalytics trackError:error];
        }
    }];
    
    [SENAnalytics track:HEMAnalyticsEventSupport];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self origNavDelegate]) {
        [[self navigationController] setDelegate:[self origNavDelegate]];
        [self setOrigNavDelegate:nil];
    }

}

- (void)configureTableView {
    UIView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:YES];
    UIView* footer = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:YES bottomBorder:NO];
    [[self tableView] setTableHeaderView:header];
    [[self tableView] setTableFooterView:footer];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
}

- (void)overrideNavigationDelegate {
    // FIXME jimmy: setting the navigationController is a total hack.  Until we
    // begin giving child controllers of the back view full height or ZDK gives
    // us more control over their UI.
    [self setOrigNavDelegate:[[self navigationController] delegate]];
    
    __weak typeof(self) weakSelf = self;
    [[self navigationController] setDelegate:weakSelf];
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
    [SENAnalytics track:HEMAnalyticsEventSupportTicketSubmitted];
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
    [[cell textLabel] setFont:[UIFont settingsTableCellFont]];
    [[cell textLabel] setText:[self titleForRowAtIndexPath:indexPath]];
    [[cell textLabel] setTextColor:[UIColor textColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([indexPath row]) {
        case HEMSupportRowIndexUserGuide: {
            [SENAnalytics track:HEMAnalyticsEventSupportUserGuide];
            
            [self overrideNavigationDelegate];
            [ZDKHelpCenter showHelpCenterWithNavController:[self navigationController]
                                               layoutGuide:ZDKLayoutRespectNone];
            break;
        }
        case HEMSupportRowIndexContactUs:
            [SENAnalytics track:HEMAnalyticsEventSupportContactUs];
            [self performSegueWithIdentifier:[HEMMainStoryboard topicsSegueIdentifier] sender:self];
            break;
        case HEMSupportRowIndexTickets: {
            [SENAnalytics track:HEMAnalyticsEventSupportTickets];
            [self overrideNavigationDelegate];
            [ZDKRequests showRequestListWithNavController:[self navigationController]];
            break;
        }
        default:
            break;
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[self shadowView] updateVisibilityWithContentOffset:[scrollView contentOffset].y];
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
    [[navigationController interactivePopGestureRecognizer] setEnabled:YES];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_tableView setDelegate:nil];
    [_tableView setDataSource:nil];
    
    if (_origNavDelegate) {
        [[self navigationController] setDelegate:_origNavDelegate];
    }
}

@end
