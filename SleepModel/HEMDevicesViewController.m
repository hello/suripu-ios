//
//  HEMDevicesViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENDevice.h>
#import <SenseKit/SENSense.h>
#import <SenseKit/SENSenseManager.h>

#import "HEMDevicesViewController.h"
#import "HEMDevicesDataSource.h"
#import "HEMPillViewController.h"
#import "HEMSenseViewController.h"
#import "HEMNoPillViewController.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"

@interface HEMDevicesViewController() <UITableViewDelegate>

@property (weak,   nonatomic) IBOutlet UITableView *devicesTableView;
@property (strong, nonatomic)          HEMDevicesDataSource* deviceDataSource;
@property (strong, nonatomic)          SENSenseManager* senseManager;

@end

@implementation HEMDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setDeviceDataSource:[[HEMDevicesDataSource alloc] init]];
    
    [[self devicesTableView] setDelegate:self];
    [[self devicesTableView] setDataSource:[self deviceDataSource]];
    [[self devicesTableView] setTableFooterView:[[UIView alloc] init]];
    
    __weak typeof(self) weakSelf = self;
    [[self deviceDataSource] refresh:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [[strongSelf devicesTableView] reloadData];
            
            SENSense* sense = [[strongSelf deviceDataSource] sense];
            if (sense != nil) {
                [strongSelf setSenseManager:[[SENSenseManager alloc] initWithSense:sense]];
            }
        }
    }];
}

- (NSString*)lastSeen:(SENDevice*)device {
    return NSLocalizedString(@"settings.device.last-seen", nil);
}

- (BOOL)isLoading:(NSIndexPath*)indexPath {
    return ([[self deviceDataSource] isSenseLoading] && [indexPath row] == 0)
        || ([[self deviceDataSource] isPillLoading] && [indexPath row] == 1);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIActivityIndicatorView* activity = nil;
    
    SENDevice* deviceInfo
        = [indexPath row] == 0
        ? [[self deviceDataSource] senseInfo]
        : [[self deviceDataSource] pillInfo];
    
    NSString* status = nil;
    
    if ([self isLoading:indexPath]) {
        status = NSLocalizedString(@"empty-data", nil);
        activity =
            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    } else {
        status
            = deviceInfo == nil
            ? NSLocalizedString(@"settings.device.status.not-paired", nil)
            : [self lastSeen:deviceInfo];
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

    if (activity != nil) {
        [activity startAnimating];
        [cell setAccessoryView:activity];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    } else {
        [cell setAccessoryView:nil];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isLoading:indexPath]) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString* segueId = nil;
    if ([indexPath row] == 0) {
        segueId = [HEMMainStoryboard senseSegueIdentifier];
    } else if ([[self deviceDataSource] pillInfo] == nil){
        segueId = [HEMMainStoryboard noSleepPillSegueIdentifier];
    } else {
        segueId = [HEMMainStoryboard pillSegueIdentifier];
    }
    
    [self performSegueWithIdentifier:segueId sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destVC = [segue destinationViewController];
    if ([destVC isKindOfClass:[HEMPillViewController class]]) {
        HEMPillViewController* pillVC = (HEMPillViewController*)destVC;
        [pillVC setPillInfo:[[self deviceDataSource] pillInfo]];
        [pillVC setSenseManager:[self senseManager]];
    } else if ([destVC isKindOfClass:[HEMSenseViewController class]]) {
        HEMSenseViewController* senseVC = (HEMSenseViewController*)destVC;
        [senseVC setSenseInfo:[[self deviceDataSource] senseInfo]];
        [senseVC setSenseManager:[self senseManager]];
    } else if ([destVC isKindOfClass:[HEMNoPillViewController class]]) {
        HEMNoPillViewController* noPillVC = (HEMNoPillViewController*)destVC;
        [noPillVC setSenseManager:[self senseManager]];
    }
}

#pragma mark - Cleanup

- (void)dealloc {
    [[self devicesTableView] setDelegate:nil];
    [[self devicesTableView] setDataSource:nil];
}

@end
