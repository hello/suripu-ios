//
//  HEMPillViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SORelativeDateTransformer/SORelativeDateTransformer.h>

#import <SenseKit/SENDevice.h>

#import "HEMPillViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMDeviceCenter.h"

@interface HEMPillViewController() <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *unpairView;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UITableView *pillInfoTableView;

@end

@implementation HEMPillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self pillInfoTableView] setTableFooterView:[[UIView alloc] init]];
    [[self unpairView] setHidden:[[HEMDeviceCenter sharedCenter] pillInfo] == nil];
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

    SENDevice* info = [[HEMDeviceCenter sharedCenter] pillInfo];
    NSString* title = nil;
    NSString* detail = NSLocalizedString(@"empty-data", nil);
    
    switch ([indexPath row]) {
        case 0: {
            title = NSLocalizedString(@"settings.device.battery", nil);
            break;
        }
        case 1: {
            title = NSLocalizedString(@"settings.device.last-seen", nil);
            if ([info lastSeen] != nil) {
                NSValueTransformer* transformer = [SORelativeDateTransformer registeredTransformer];
                detail = [transformer transformedValue:[info lastSeen]];
            }
            break;
        }
        case 2: {
            title = NSLocalizedString(@"settings.device.color", nil);
            if ([[info firmwareVersion] length] > 0) {
                detail = [info firmwareVersion];
            }
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

- (void)showActivity {
    [[self unpairView] setHidden:YES];
    [[self unpairView] setAlpha:0.0f];
    [[self activityView] setAlpha:0.0f];
    [[self activityView] setHidden:[[HEMDeviceCenter sharedCenter] pillInfo] == nil];
    
    if (![[self activityView] isHidden]) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             [[self activityView] setAlpha:1.0f];
                         }];
    }
    
}

- (void)hideActivity {
    [[self unpairView] setHidden:[[HEMDeviceCenter sharedCenter] pillInfo] == nil];
    
    if (![[self unpairView] isHidden]) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             [[self unpairView] setAlpha:1.0f];
                             [[self activityView] setAlpha:0.0f];
                         }
                         completion:^(BOOL finished) {
                             [[self activityView] setHidden:YES];
                         }];
    }
}

- (IBAction)showUnpairConfirmation:(id)sender {
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

- (void)showUnpairMessageForError:(NSError*)error {
    NSString* message = nil;
    switch ([error code]) {
        case HEMDeviceCenterErrorSenseUnavailable:
            message = NSLocalizedString(@"settings.pill.unpair-no-sense-found", nil);
            break;
        case HEMDeviceCenterErrorSenseNotPaired:
            message = NSLocalizedString(@"settings.pill.dialog.no-paired-sense-message", nil);
            break;
        case HEMDeviceCenterErrorUnpairPillFromSense:
            message = NSLocalizedString(@"settings.pill.dialog.unable-to-unpair-from-sense", nil);
            break;
        case HEMDeviceCenterErrorUnlinkPillFromAccount:
            message = NSLocalizedString(@"settings.pill.dialog.unable-to-unlink-from-account", nil);
            break;
        default:
            message = NSLocalizedString(@"settings.pill.dialog.unable-to-unpair", nil);
            break;
    }
    
    NSString* title = NSLocalizedString(@"settings.pill.unpair-error-title", nil);
    UIAlertView* messageDialog = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"actions.ok", nil)
                                                  otherButtonTitles:nil];
    [messageDialog show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        [self unpair];
        [self showActivity];
    }
}

- (void)unpair {
    [self showActivity];
    [[self activityLabel] setText:NSLocalizedString(@"settings.pill.unpairing-message", nil)];
    __weak typeof(self) weakSelf = self;
    [[HEMDeviceCenter sharedCenter] unpairSleepPill:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf hideActivity];
            if (error != nil) {
                [strongSelf showUnpairMessageForError:error];
            } else {
                UIViewController* nextVC = [HEMMainStoryboard instantiateNoSleepPillController];
                // pop then push no pill view controller
                [[strongSelf navigationController] popViewControllerAnimated:NO];
                [[strongSelf navigationController] pushViewController:nextVC animated:YES];
            }
        }
    }];
}

@end
