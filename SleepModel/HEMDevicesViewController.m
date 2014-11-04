//
//  HEMDevicesViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SORelativeDateTransformer/SORelativeDateTransformer.h>

#import <SenseKit/SENDevice.h>

#import "UIFont+HEMStyle.h"

#import "HEMDevicesViewController.h"
#import "HEMDeviceCenter.h"
#import "HEMPillViewController.h"
#import "HEMSenseViewController.h"
#import "HEMNoPillViewController.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"

@interface HEMDevicesViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak,   nonatomic) IBOutlet UITableView *devicesTableView;
@property (strong, nonatomic) NSError* loadError;

@end

@implementation HEMDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self devicesTableView] setDelegate:self];
    [[self devicesTableView] setDataSource:self];
    [[self devicesTableView] setTableFooterView:[[UIView alloc] init]];
    [self loadDevices];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self devicesTableView] reloadData];
    
    if ([[HEMDeviceCenter sharedCenter] pillInfo] == nil
        || [[HEMDeviceCenter sharedCenter] senseInfo] == nil) {
        [self loadDevices];
    }
    
}

- (void)loadDevices {
    __weak typeof(self) weakSelf = self;
    // always load device information.  previous bug was that it will never reload
    // to show updated "Last Seen" unless you killed the app because data is always
    // loaded after once
    [[HEMDeviceCenter sharedCenter] loadDeviceInfo:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error != nil && [error code] != HEMDeviceCenterErrorInProgress) {
                [strongSelf setLoadError:error];
            }
            // if loading in progress, will re-call itself.  otherwise, just update
            [strongSelf updateTableWhenDoneLoadingInfo];
        }
    }];
    [[self devicesTableView] reloadData];
}

- (void)updateTableWhenDoneLoadingInfo {
    if ([[HEMDeviceCenter sharedCenter] isLoadingInfo]) {
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
        NSValueTransformer* transformer = [SORelativeDateTransformer registeredTransformer];
        NSString* timeAgo = [transformer transformedValue:[device lastSeen]];
        NSString* lastSeen = NSLocalizedString(@"settings.device.last-seen", nil);
        desc = [NSString stringWithFormat:@"%@ %@", lastSeen, timeAgo];
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
    
    HEMDeviceCenter* deviceCenter = [HEMDeviceCenter sharedCenter];
    
    SENDevice* deviceInfo
        = [indexPath row] == 0
        ? [deviceCenter senseInfo]
        : [deviceCenter pillInfo];
    
    CGFloat alpha = 1.0f;
    NSString* status = nil;
    UIActivityIndicatorView* activity = nil;
    UITableViewCellSelectionStyle selectionStyle = UITableViewCellSelectionStyleNone;
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([[HEMDeviceCenter sharedCenter] isLoadingInfo]) {
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
    if ([[HEMDeviceCenter sharedCenter] isLoadingInfo] || [self loadError] != nil) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString* segueId = nil;
    if ([indexPath row] == 0) {
        segueId = [HEMMainStoryboard senseSegueIdentifier];
    } else if ([[HEMDeviceCenter sharedCenter] pillInfo] == nil){
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
