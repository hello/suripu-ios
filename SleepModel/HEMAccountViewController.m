//
//  HEMAccountViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENServiceAccount.h>

#import "UIFont+HEMStyle.h"

#import "HEMAccountViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"
#import "HEMUpdatePasswordViewController.h"
#import "HEMUpdateEmailViewController.h"

static NSInteger const HEMAccountRowEmail = 0;
static NSInteger const HEMAccountRowPassword = 1;

static CGFloat const HEMAccountMaxDetailWidth = 100.0f;
static CGFloat const HEMAccountDetailMargin = 35.0f;

@interface HEMAccountViewController() <
    UITableViewDelegate, UITableViewDataSource, HEMUpdatePasswordDelegate, HEMUpdateEmailDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (assign, nonatomic, getter=isLoading) BOOL loading;

@end

@implementation HEMAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTable];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshAccount];
}

- (void)configureTable {
    [[self infoTableView] setTableFooterView:[[UIView alloc] init]];
    [[self infoTableView] setDataSource:self];
    [[self infoTableView] setDelegate:self];
}

- (void)refreshAccount {
    [self setLoading:YES];
    
    __weak typeof(self) weakSelf = self;
    [[SENServiceAccount sharedService] refreshAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && error == nil) {
            [strongSelf setLoading:NO];
            [[strongSelf infoTableView] reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate / DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"info";
    return [tableView dequeueReusableCellWithIdentifier:cellId];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* text = nil;
    NSString* detail = nil;
    UIActivityIndicatorView* activityView = nil;
    UITableViewCellAccessoryType type = UITableViewCellAccessoryDisclosureIndicator;
    
    switch ([indexPath row]) {
        case HEMAccountRowEmail: {
            text = NSLocalizedString(@"settings.account.email", nil);
            
            SENAccount* account = [[SENServiceAccount sharedService] account];
            if (account != nil && [[account email] length] > 0 && ![self isLoading]) {
                detail = [account email];
            } else {
                activityView =
                    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [activityView hidesWhenStopped];
                [activityView startAnimating];
                type = UITableViewCellAccessoryNone;
            }
            
            break;
        }
        case HEMAccountRowPassword: {
            text = NSLocalizedString(@"settings.account.password", nil);
            break;
        }
        default:
            break;
    }
    
    [cell setAccessoryType:type];
    [cell setAccessoryView:activityView];
    
    [[cell textLabel] setText:text];
    [[cell textLabel] setTextColor:[HelloStyleKit backViewTextColor]];
    [[cell textLabel] setFont:[UIFont settingsTitleFont]];
    
    [[cell detailTextLabel] setText:detail];
    [[cell detailTextLabel] setTextColor:[HelloStyleKit backViewDetailTextColor]];
    [[cell detailTextLabel] setFont:[UIFont settingsTableCellDetailFont]];
    [[cell detailTextLabel] setTextAlignment:NSTextAlignmentRight];
    [[cell detailTextLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
    [[cell detailTextLabel] sizeToFit];
    
    CGSize constraint = CGSizeMake(HEMAccountMaxDetailWidth, CGRectGetHeight([cell bounds]));
    CGSize textSize = [[cell detailTextLabel] sizeThatFits:constraint];
    CGRect detailFrame = CGRectZero;
    detailFrame.origin.x = CGRectGetWidth([cell bounds]) - textSize.width - HEMAccountDetailMargin;
    detailFrame.origin.y = ceilf((CGRectGetHeight([cell bounds]) - textSize.height)/2);
    detailFrame.size.height = textSize.height;
    detailFrame.size.width = textSize.width;
    [[cell detailTextLabel] setFrame:detailFrame];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString* segueId = nil;
    switch ([indexPath row]) {
        case HEMAccountRowPassword:
            segueId = [HEMMainStoryboard updatePasswordSegueIdentifier];
            break;
        case HEMAccountRowEmail:
            segueId = [HEMMainStoryboard updateEmailSegueIdentifier];
        default:
            break;
    }
    
    if (segueId != nil) {
        [self performSegueWithIdentifier:segueId sender:nil];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = (UINavigationController*)[segue destinationViewController];
        [[nav navigationBar] setTitleTextAttributes:@{
             NSForegroundColorAttributeName : [HelloStyleKit backViewNavTitleColor],
             NSFontAttributeName : [UIFont settingsTitleFont]
        }];
        
        if ([[nav topViewController] isKindOfClass:[HEMUpdatePasswordViewController class]]) {
            HEMUpdatePasswordViewController* passVC
                = (HEMUpdatePasswordViewController*)[nav topViewController];
            [passVC setDelegate:self];
        } else if ([[nav topViewController] isKindOfClass:[HEMUpdateEmailViewController class]]) {
            HEMUpdateEmailViewController* emailVC
                = (HEMUpdateEmailViewController*)[nav topViewController];
            [emailVC setDelegate:self];
        }
    }
}

#pragma mark - Password Update Delegate

- (void)didUpdatePassword:(BOOL)updated from:(HEMUpdatePasswordViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Email Update Delegate

- (void)didUpdateEmail:(BOOL)updated from:(HEMUpdateEmailViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
