//
//  HEMDevicesViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENDevice.h>

#import "HEMDevicesViewController.h"
#import "HEMDevicesDataSource.h"
#import "HEMPillViewController.h"
#import "HEMSenseViewController.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"

@interface HEMDevicesViewController() <UITableViewDelegate>

@property (weak,   nonatomic) IBOutlet UITableView *devicesTableView;
@property (strong, nonatomic)          HEMDevicesDataSource* deviceDataSource;

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
        }
    }];
}

- (NSString*)lastSeen:(SENDevice*)device {
    return NSLocalizedString(@"settings.device.last-seen", nil);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIActivityIndicatorView* activity = nil;
    
    SENDevice* device
        = [indexPath row] == 0
        ? [[self deviceDataSource] sense]
        : [[self deviceDataSource] pill];
    
    NSString* status = nil;
    
    if ([[self deviceDataSource] isLoading]) {
        status = NSLocalizedString(@"empty-data", nil);
        activity =
            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    } else {
        status
            = device == nil
            ? NSLocalizedString(@"settings.device.status.not-paired", nil)
            : [self lastSeen:device];
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
    if ([[self deviceDataSource] isLoading]) return;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString* segueId = nil;
    if ([indexPath row] == 0) {
        segueId = [HEMMainStoryboard senseSegueIdentifier];
    } else if ([[self deviceDataSource] pill] == nil){
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
        [pillVC setPill:[[self deviceDataSource] pill]];
        [pillVC setSense:[[self deviceDataSource] sense]];
    } else if ([destVC isKindOfClass:[HEMSenseViewController class]]) {
        HEMSenseViewController* senseVC = (HEMSenseViewController*)destVC;
        [senseVC setSense:[[self deviceDataSource] sense]];
    }
}

#pragma mark - Cleanup

- (void)dealloc {
    [[self devicesTableView] setDelegate:nil];
    [[self devicesTableView] setDataSource:nil];
}

@end