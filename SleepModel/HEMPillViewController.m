//
//  HEMPillViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENDevice.h>

#import "HEMPillViewController.h"
#import "HEMMainStoryboard.h"

@interface HEMPillViewController() <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *unpairView;
@property (weak, nonatomic) IBOutlet UITableView *pillInfoTableView;

@end

@implementation HEMPillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self pillInfoTableView] setTableFooterView:[[UIView alloc] init]];
    [[self unpairView] setHidden:[self pill] == nil];
}

#pragma mark - UITableViewDelegate / DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard pillInfoCellReuseIdentifier]];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString* title = nil;
    NSString* detail = nil;
    
    switch ([indexPath row]) {
        case 0: {
            title = NSLocalizedString(@"settings.device.battery", nil);
            detail = @"--"; // TODO (jimmy): heartbeat data not yet implemented!
            break;
        }
        case 1: {
            title = NSLocalizedString(@"settings.device.last-seen", nil);
            detail = @"--"; // TODO (jimmy): heartbeat data not yet implemented!
            break;
        }
        case 2: {
            title = NSLocalizedString(@"settings.device.color", nil);
            detail = @"--"; // TODO (jimmy): color not yet supported
            break;
        }
        default:
            break;
    }
    
    [[cell textLabel] setText:title];
    [[cell detailTextLabel] setText:detail];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (IBAction)showUnpairConfirmation:(id)sender {
    if ([self sense] != nil) {
        [self showUnpairConfirmationAlert];
    } else {
        [self showNoSenseAlert];
    }
}

- (void)showUnpairConfirmationAlert {
    NSString* title = NSLocalizedString(@"settings.pill.dialog.unpair-title", nil);
    NSString* message = NSLocalizedString(@"settings.pill.dialog.unpair-message", nil);
    UIAlertView* confirmDialog = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"actions.no", nil)
                                                  otherButtonTitles:NSLocalizedString(@"actions.yes", nil), nil];
    [confirmDialog setDelegate:self];
    [confirmDialog show];
}

- (void)showNoSenseAlert {
    NSString* title = NSLocalizedString(@"settings.pill.dialog.unpair-no-sense-title", nil);
    NSString* message = NSLocalizedString(@"settings.pill.dialog.unpair-no-sense-message", nil);
    UIAlertView* messageDialog = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"actions.ok", nil)
                                                  otherButtonTitles:nil];
    [messageDialog show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        // TODO: (jimmy) issue an unpair command to Sense
    }
}

#pragma mark - Unpairing

- (void)unpair {
    __weak typeof(self) weakSelf = self;
    [self unpairPillFromSense:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (error == nil) {
            [strongSelf unlinkPillFromAccount:^(NSError *error) {
                // TODO (jimmy): handle response
            }];
        } else {
            // TODO (jimmy): what to do if we can't unpair pill from Sense?
        }
    }];
}

- (void)unpairPillFromSense:(void(^)(NSError* error))completion {
    // TODO (jimmy): we need to connect to the right Sense, then use the SenseManager
    // to unpill
    if (completion) completion(nil);
}

- (void)unlinkPillFromAccount:(void(^)(NSError* error))completion {
    if (completion) completion(nil);
}

@end
