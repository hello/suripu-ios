//
//  HEMDevicesDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 9/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENAPIDevice.h>
#import <SenseKit/SENDevice.h>
#import <SenseKit/SENSense.h>

#import "HEMDevicesDataSource.h"
#import "HEMMainStoryboard.h"

@interface HEMDevicesDataSource()

@property (nonatomic, strong) SENSense* sense;
@property (nonatomic, strong) SENDevice* senseInfo;
@property (nonatomic, strong) SENDevice* pillInfo;
@property (nonatomic, assign) BOOL pillLoading;
@property (nonatomic, assign) BOOL senseLoading;

@end

@implementation HEMDevicesDataSource

- (void)loadDevices:(void(^)(void))completion {
    [self setPillLoading:YES];
    [self setSenseLoading:YES];
    
    __weak typeof(self) weakSelf = self;
    [SENAPIDevice getPairedDevices:^(NSArray* devices, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setPillLoading:NO];
            [strongSelf processDevices:devices];
            
            if ([strongSelf senseInfo] != nil) {
                [strongSelf scanForActualDeviceWithInfo:[strongSelf senseInfo]];
            } else {
                [strongSelf setSenseLoading:NO];
            }
        }
        if (completion) completion();
    }];
}

- (void)refresh:(void(^)(void))completion {
    [self setSenseInfo:nil];
    [self setPillInfo:nil];
    [self setSense:nil];
    [self loadDevices:completion];
}

- (void)processDevices:(NSArray*)devices {
    // TODO (jimmy): for now, let's find the last Sense and last Pill, if any,
    // and assume these are the actual devices the user is using in case there
    // are multiple.  What we probably want to do is to sort the list by last
    // seen and take the most recently last seen of both the Sense and Pill
    SENDevice* device = nil;
    NSInteger i = [devices count] - 1;
    while (i >= 0 && ([self senseInfo] == nil || [self pillInfo] == nil)) {
        device = [devices objectAtIndex:i];
        if ([self pillInfo] == nil && [device type] == SENDeviceTypePill) {
            [self setPillInfo:device];
        } else if ([self senseInfo] == nil && [device type] == SENDeviceTypeSense) {
            [self setSenseInfo:device];
        }
        i--;
    }
}

#pragma mark - BLE

- (void)scanForActualDeviceWithInfo:(SENDevice*)senseInfo {
    __weak typeof(self) weakSelf = self;
    [SENSenseManager scanForSense:^(NSArray *senses) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([senses count] > 0) {
                for (SENSense* sense in senses) {
                    if ([[sense deviceId] isEqualToString:[senseInfo deviceId]]) {
                        [strongSelf setSense:sense];
                        break;
                    }
                }
            }
            [strongSelf setSenseLoading:NO];
        }
    }];
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

#pragma mark - Cleanup

- (void)dealloc {
    [SENSenseManager stopScan]; // in case it's still scanning
}

@end
