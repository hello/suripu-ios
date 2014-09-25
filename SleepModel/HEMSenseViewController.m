//
//  HEMSenseViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENDevice.h>

#import "HEMSenseViewController.h"
#import "HEMMainStoryboard.h"

@interface HEMSenseViewController() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *senseInfoTableView;

@end

@implementation HEMSenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self senseInfoTableView] setTableFooterView:[[UIView alloc] init]];
}

#pragma mark - UITableViewDelegate / DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 1; // the info
    if ([[self sense] state] == SENDeviceStateFirmwareUpdate) {
        sections++; // need to show firmware update cell / section
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 2 : 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId
        = [indexPath section] == 0
        ? [HEMMainStoryboard senseInfoCellReuseIdentifier]
        : [HEMMainStoryboard firmwareUpdateCellReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:cellId];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath section] == 0) {
        NSString* title = nil;
        NSString* detail = nil;
        
        switch ([indexPath row]) {
            case 0: {
                title = NSLocalizedString(@"settings.device.last-seen", nil);
                detail = @"--"; // TODO (jimmy): heartbeat data not supported yet
                break;
            }
            case 1: {
                title = NSLocalizedString(@"settings.device.firmware-version", nil);
                detail = @"--"; // TODO (jimmy): firmware version not supported yet
                break;
            }
            default:
                break;
        }
        
        [[cell textLabel] setText:title];
        [[cell detailTextLabel] setText:detail];
        
    } // else, look at the storyboard
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
