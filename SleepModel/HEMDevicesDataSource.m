//
//  HEMDevicesDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 9/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAPIDevice.h>
#import <SenseKit/SENDevice.h>

#import "HEMDevicesDataSource.h"
#import "HEMMainStoryboard.h"

@interface HEMDevicesDataSource()

@property (nonatomic, strong) SENDevice* sense;
@property (nonatomic, strong) SENDevice* pill;
@property (nonatomic, assign) BOOL loading;

@end

@implementation HEMDevicesDataSource

- (void)loadDevices:(void(^)(void))completion {
    [self setLoading:YES];
    
    __weak typeof(self) weakSelf = self;
    [SENAPIDevice getPairedDevices:^(NSArray* devices, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setLoading:NO];
            [strongSelf processDevices:devices];
        }
        if (completion) completion();
    }];
}

- (void)refresh:(void(^)(void))completion {
    [self setSense:nil];
    [self setPill:nil];
    [self loadDevices:completion];
}

- (void)processDevices:(NSArray*)devices {
    // TODO (jimmy): for now, let's find the last Sense and last Pill, if any,
    // and assume these are the actual devices the user is using in case there
    // are multiple.  What we probably want to do is to sort the list by last
    // seen and take the most recently last seen of both the Sense and Pill
    SENDevice* device = nil;
    NSInteger i = [devices count] - 1;
    while (i >= 0 && ([self sense] == nil || [self pill] == nil)) {
        device = [devices objectAtIndex:i];
        if ([self pill] == nil && [device type] == SENDeviceTypePill) {
            [self setPill:device];
        } else if ([self sense] == nil && [device type] == SENDeviceTypeSense) {
            [self setSense:device];
        }
        i--;
    }
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

@end
