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
#import "UIFont+HEMStyle.h"
#import "HelloStyleKit.h"

static CGFloat   const HEMAccountMaxDetailWidth = 160.0f;
static CGFloat   const HEMAccountDetailPadding = 35.0f;
static NSInteger const HEMAccountRowEmail = 0;
static NSInteger const HEMAccountRowPassword = 1;

@interface HEMAccountViewController() <UITableViewDelegate, UITableViewDataSource>

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
    
    switch ([indexPath row]) {
        case HEMAccountRowEmail: {
            text = NSLocalizedString(@"settings.account.email", nil);
            detail = [SENAuthorizationService emailAddressOfAuthorizedUser];
            break;
        }
        case HEMAccountRowPassword: {
            text = NSLocalizedString(@"settings.account.password", nil);
            break;
        }
        default:
            break;
    }
    
    [[cell textLabel] setText:text];
    [[cell textLabel] setTextColor:[HelloStyleKit backViewTextColor]];
    [[cell textLabel] setFont:[UIFont settingsTitleFont]];
    
    [[cell detailTextLabel] setText:detail];
    [[cell detailTextLabel] setTextColor:[HelloStyleKit backViewDetailTextColor]];
    [[cell detailTextLabel] setFont:[UIFont settingsTableCellDetailFont]];
    [[cell detailTextLabel] setTextAlignment:NSTextAlignmentRight];
    [[cell detailTextLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
    [[cell detailTextLabel] sizeToFit];
    
    CGRect detailFrame = [[cell detailTextLabel] frame];
    CGFloat width = MIN(HEMAccountMaxDetailWidth, CGRectGetWidth(detailFrame));
    CGFloat height = CGRectGetHeight(detailFrame);
    detailFrame.origin.x = CGRectGetWidth([cell bounds]) - width - HEMAccountDetailPadding;
    detailFrame.origin.y = (CGRectGetHeight([cell bounds]) - height)/2;
    detailFrame.size.width = width;
    [[cell detailTextLabel] setFrame:detailFrame];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
