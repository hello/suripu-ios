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
#import "HEMSettingsAccountDataSource.h"
#import "HEMSettingsTableViewCell.h"

static CGFloat const HEMAccountTableViewMargin = 20.0f;
static CGFloat const HEMAccountTableSectionHeaderHeight = 20.0f;

@interface HEMAccountViewController() <
    UITableViewDelegate, HEMUpdatePasswordDelegate, HEMUpdateEmailDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (strong, nonatomic) HEMSettingsAccountDataSource* dataSource;

@end

@implementation HEMAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTable];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self dataSource] reload];
}

- (void)configureTable {
    [self setDataSource:[[HEMSettingsAccountDataSource alloc] initWithTableView:[self infoTableView]]];
    
    CGRect frame = CGRectZero;
    frame.size.height = HEMAccountTableViewMargin;
    frame.size.width = CGRectGetWidth([[self infoTableView] bounds]);
    
    [[self infoTableView] setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
    [[self infoTableView] setTableFooterView:[[UIView alloc] initWithFrame:frame]];
    [[self infoTableView] setDataSource:[self dataSource]];
    [[self infoTableView] setDelegate:self];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0.0f : HEMAccountTableSectionHeaderHeight;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    HEMSettingsTableViewCell* settingsCell = (HEMSettingsTableViewCell*)cell;
    
    NSString* title = [[self dataSource] titleForCellAtIndexPath:indexPath];
    NSString* value = [[self dataSource] valueForCellAtIndexPath:indexPath];
    
    [[settingsCell titleLabel] setText:title];
    [[settingsCell valueLabel] setText:value];
    
    if ([indexPath row] == 0) {
        [settingsCell showTopCorners];
    } else if ([[self dataSource] isLastRow:indexPath]) {
        [settingsCell showBottomCorners];
    } else {
        [settingsCell showNoCorners];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    NSString* segueId = nil;
//    switch ([indexPath row]) {
//        case HEMAccountRowPassword:
//            segueId = [HEMMainStoryboard updatePasswordSegueIdentifier];
//            break;
//        case HEMAccountRowEmail:
//            segueId = [HEMMainStoryboard updateEmailSegueIdentifier];
//        default:
//            break;
//    }
//    
//    if (segueId != nil) {
//        [self performSegueWithIdentifier:segueId sender:nil];
//    }
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
