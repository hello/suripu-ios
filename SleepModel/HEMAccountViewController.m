//
//  HEMAccountViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAuthorizationService.h>

#import "HEMAccountViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMMainStoryboard.h"
#import "UIFont+HEMStyle.h"
#import "HelloStyleKit.h"
#import "HEMUpdatePasswordViewController.h"

static NSInteger const HEMAccountRowEmail = 0;
static NSInteger const HEMAccountRowPassword = 1;

@interface HEMAccountViewController() <
    UITableViewDelegate, UITableViewDataSource, HEMUpdatePasswordDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;

@end

@implementation HEMAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self infoTableView] setTableFooterView:[[UIView alloc] init]];
    [[self infoTableView] setDataSource:self];
    [[self infoTableView] setDelegate:self];
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
    UITableViewCellAccessoryType accessory = UITableViewCellAccessoryNone;
    
    switch ([indexPath row]) {
        case HEMAccountRowEmail: {
            text = NSLocalizedString(@"settings.account.email", nil);
            detail = [SENAuthorizationService emailAddressOfAuthorizedUser];
            break;
        }
        case HEMAccountRowPassword: {
            accessory = UITableViewCellAccessoryDisclosureIndicator;
            text = NSLocalizedString(@"settings.account.password", nil);
            break;
        }
        default:
            break;
    }
    
    [cell setAccessoryType:accessory];
    
    [[cell textLabel] setText:text];
    [[cell textLabel] setTextColor:[HelloStyleKit backViewTextColor]];
    [[cell textLabel] setFont:[UIFont settingsTitleFont]];
    
    [[cell detailTextLabel] setText:detail];
    [[cell detailTextLabel] setTextColor:[HelloStyleKit backViewDetailTextColor]];
    [[cell detailTextLabel] setFont:[UIFont settingsTableCellDetailFont]];
    [[cell detailTextLabel] setTextAlignment:NSTextAlignmentRight];
    [[cell detailTextLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString* segueId = nil;
    switch ([indexPath row]) {
        case HEMAccountRowPassword:
            segueId = [HEMMainStoryboard updatePasswordSegueSegueIdentifier];
            break;
            
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
        }
    }
}

#pragma mark - Password Update Delegate

- (void)didUpdatePassword:(BOOL)updated from:(HEMUpdatePasswordViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
