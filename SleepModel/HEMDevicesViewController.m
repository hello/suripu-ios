//
//  HEMDevicesViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENDevice.h>

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
@property (assign, nonatomic) BOOL loaded;

@end

@implementation HEMDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self devicesTableView] setDelegate:self];
    [[self devicesTableView] setDataSource:self];
    [[self devicesTableView] setTableFooterView:[[UIView alloc] init]];
    [self loadDevices];
}

- (void)loadDevices {
    if (![[HEMDeviceCenter sharedCenter] isInfoLoaded]) {
        __weak typeof(self) weakSelf = self;
        [[HEMDeviceCenter sharedCenter] loadDeviceInfo:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf setLoadError:error];
                [[strongSelf devicesTableView] reloadSections:[NSIndexSet indexSetWithIndex:0]
                                             withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
        [[self devicesTableView] reloadData];
    }
    [self setLoaded:YES];
}

- (NSString*)lastSeen:(SENDevice*)device {
    return NSLocalizedString(@"settings.device.last-seen", nil);
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
    
    if ([[HEMDeviceCenter sharedCenter] isLoadingInfo] || ![self loaded]) {
        status = NSLocalizedString(@"empty-data", nil);
        activity =
            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
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
    [[cell detailTextLabel] setText:status];
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
