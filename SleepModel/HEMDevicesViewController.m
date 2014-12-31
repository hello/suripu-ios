//
//  HEMDevicesViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENDevice.h>
#import <SenseKit/SENServiceDevice.h>

#import "UIFont+HEMStyle.h"
#import "NSDate+HEMRelative.h"

#import "HEMDevicesViewController.h"
#import "HEMPillViewController.h"
#import "HEMSenseViewController.h"
#import "HEMNoPillViewController.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"

@interface HEMDevicesViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak,   nonatomic) IBOutlet UITableView *devicesTableView;
@property (strong, nonatomic) NSError* loadError;
@property (assign, nonatomic) BOOL loaded;

@end

@implementation HEMDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self devicesTableView] setDelegate:self];
    [[self devicesTableView] setDataSource:self];
    [[self devicesTableView] setTableFooterView:[[UIView alloc] init]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // only load devices again on appearance if user is coming back, not when
    // coming to, and only if devices are not configured so that we can check
    // if it has happened.
    if ([self loaded]) {
        if ([[SENServiceDevice sharedService] pillInfo] == nil
            || [[SENServiceDevice sharedService] senseInfo] == nil) {
            [self loadDevices];
        } else {
            [[self devicesTableView] reloadData];
        }
    } else {
        [self loadDevices];
    }
    
}

- (void)loadDevices {
    __weak typeof(self) weakSelf = self;
    // always load device information.  previous bug was that it will never reload
    // to show updated "Last Seen" unless you killed the app because data is always
    // loaded after once
    [[SENServiceDevice sharedService] loadDeviceInfo:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error != nil && [error code] != SENServiceDeviceErrorInProgress) {
                [strongSelf setLoadError:error];
            }
            // if loading in progress, will re-call itself.  otherwise, just update
            [strongSelf updateTableWhenDoneLoadingInfo];
        }
    }];
    [[self devicesTableView] reloadData];
    [self setLoaded:YES];
}

- (void)updateTableWhenDoneLoadingInfo {
    if ([[SENServiceDevice sharedService] isLoadingInfo]) {
        [self performSelector:@selector(updateTableWhenDoneLoadingInfo)
                   withObject:nil
                   afterDelay:0.1f];
        return;
    }
    
    [[self devicesTableView] reloadSections:[NSIndexSet indexSetWithIndex:0]
                           withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSString*)lastSeen:(SENDevice*)device {
    NSString* desc = nil;
    if ([device lastSeen] != nil) {
        NSString* lastSeen = NSLocalizedString(@"settings.device.last-seen", nil);
        desc = [NSString stringWithFormat:@"%@ %@", lastSeen, [[device lastSeen] timeAgo]];
    } else {
        desc = NSLocalizedString(@"settings.device.never-seen", nil);
    }
    return desc;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2; // even if you don't have either a Sense or a Pill, show 2
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = [HEMMainStoryboard deviceCellReuseIdentifier];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseId];
        [cell setIndentationLevel:1];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SENServiceDevice* service = [SENServiceDevice sharedService];
    
    SENDevice* deviceInfo
        = [indexPath row] == 0
        ? [service senseInfo]
        : [service pillInfo];
    
    CGFloat alpha = 1.0f;
    NSString* status = nil;
    UIActivityIndicatorView* activity = nil;
    UITableViewCellSelectionStyle selectionStyle = UITableViewCellSelectionStyleNone;
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([[SENServiceDevice sharedService] isLoadingInfo] || ![self loaded]) {
        status = NSLocalizedString(@"empty-data", nil);
        activity =
            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activity startAnimating];
    } else if ([self loadError] != nil) {
        status = NSLocalizedString(@"settings.device.info-failed-to-load", nil);
        alpha = 0.5f;
        selectionStyle = UITableViewCellSelectionStyleNone;
        accessoryType = UITableViewCellAccessoryNone;
    } else {
        status
            = deviceInfo == nil
            ? NSLocalizedString(@"settings.device.status.not-paired", nil)
            : [self lastSeen:deviceInfo];
        selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    NSString* name
        = [indexPath row] == 0
        ? NSLocalizedString(@"settings.device.sense", nil)
        : NSLocalizedString(@"settings.device.pill", nil);
    
    UIImage* icon
        = [indexPath row] == 0
        ? [HelloStyleKit senseIcon]
        : [HelloStyleKit pillIcon];
    
    [[cell textLabel] setText:name];
    [[cell textLabel] setTextColor:[HelloStyleKit backViewTextColor]];
    [[cell textLabel] setFont:[UIFont settingsTitleFont]];
    
    [[cell detailTextLabel] setText:status];
    [[cell detailTextLabel] setTextColor:[HelloStyleKit backViewTextColor]];
    [[cell detailTextLabel] setFont:[UIFont settingsTableCellDetailFont]];
    
    [[cell imageView] setImage:icon];
    [[cell contentView] setAlpha:alpha];
    [cell setAccessoryView:activity];
    [cell setAccessoryType:accessoryType];
    [cell setSelectionStyle:selectionStyle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[SENServiceDevice sharedService] isLoadingInfo] || [self loadError] != nil) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString* segueId = nil;
    if ([indexPath row] == 0) {
        segueId = [HEMMainStoryboard senseSegueIdentifier];
    } else if ([[SENServiceDevice sharedService] pillInfo] == nil){
        segueId = [HEMMainStoryboard noSleepPillSegueIdentifier];
    } else {
        segueId = [HEMMainStoryboard pillSegueIdentifier];
    }
    
    [self performSegueWithIdentifier:segueId sender:self];
}

#pragma mark - Cleanup

- (void)dealloc {
    [[self devicesTableView] setDelegate:nil];
    [[self devicesTableView] setDataSource:nil];
}

@end
