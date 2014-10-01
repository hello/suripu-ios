//
//  HEMSenseViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENDevice.h>
#import <SenseKit/SENSenseManager.h>

#import "HEMSenseViewController.h"
#import "HEMMainStoryboard.h"

@interface HEMSenseViewController() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *senseInfoTableView;
@property (weak, nonatomic) IBOutlet UIView *manageSenseView;
@property (copy, nonatomic) NSString* senseSignalStrength;

@end

@implementation HEMSenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self senseInfoTableView] setTableFooterView:[[UIView alloc] init]];
    [[self manageSenseView] setHidden:[self senseInfo] == nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadSenseRSSI];
}

- (void)loadSenseRSSI {
    if ([self senseManager] != nil) {
        __weak typeof(self) weakSelf = self;
        [[self senseManager] currentRSSI:^(NSNumber* rssi) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                NSInteger value = [rssi integerValue];
                NSString* strength = nil;
                if (value >= 80) {
                    strength = NSLocalizedString(@"settings.sense.signal.strong", nil);
                } else if (value >= 60) {
                    strength = NSLocalizedString(@"settings.sense.signal.good", nil);
                } else if (value > 0){
                    strength = NSLocalizedString(@"settings.sense.signal.weak", nil);
                }
                [strongSelf setSenseSignalStrength:strength];
                [[strongSelf senseInfoTableView] reloadData];
            }
        } failure:nil];
    }
}

#pragma mark - UITableViewDelegate / DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 1; // the info
    if ([[self senseInfo] state] == SENDeviceStateFirmwareUpdate) {
        sections++; // need to show firmware update cell / section
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 3 : 1;
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
        NSString* detail = NSLocalizedString(@"empty-data", nil); // TODO (jimmy): data not supported yet;
        
        switch ([indexPath row]) {
            case 0: {
                title = NSLocalizedString(@"settings.device.last-seen", nil);
                break;
            }
            case 1: {
                title = NSLocalizedString(@"settings.sense.signal", nil);
                if ([self senseSignalStrength] != nil) {
                    detail = [self senseSignalStrength];
                }
                break;
            }
            case 2: {
                title = NSLocalizedString(@"settings.device.firmware-version", nil);
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
