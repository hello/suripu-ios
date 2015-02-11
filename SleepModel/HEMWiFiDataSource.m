//
//  HEMWiFiDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 10/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENSenseMessage.pb.h>
#import <SenseKit/SENServiceDevice.h>

#import "HEMWiFiDataSource.h"
#import "HEMOnboardingCache.h"

NSString* const kHEMWifiOtherCellId = @"other";
NSString* const kHEMWifiNetworkCellId = @"network";

static NSString* const kHEMWifiNetworkErrorDomain = @"is.hello.ble.wifi";

@interface HEMWiFiDataSource()

@property (nonatomic, strong) NSMutableArray* wifisDetected;
/**
 * @property uniqueSSIDs
 *
 * @discussion
 * This is needed to not add networks that are already shown as multiple scans
 * are needed, but that will return possibly wifis that are already detected.
 * It would be easy enough to just use a NSOrderedSet to hold networks, but
 * those objects' isEquals: method also checks RSSI values, which unfortunately
 * we don't care if it doesn't match, as it likely won't
 */
@property (nonatomic, strong) NSMutableSet* uniqueSSIDs;
@property (nonatomic, assign, getter=isScanning) BOOL scanning;
@property (nonatomic, assign) BOOL scanned;

@end

@implementation HEMWiFiDataSource

- (id)init {
    self = [super init];
    if (self) {
        [self setWifisDetected:[NSMutableArray array]];
        [self setUniqueSSIDs:[NSMutableSet set]];
    }
    return self;
}

- (void)addDetectedNetworksFromArray:(NSArray*)networks {
    if ([networks count] == 0) return;
    
    NSInteger insertionIndex = 0;
    for (SENWifiEndpoint* network in networks) {
        if (![[self uniqueSSIDs] containsObject:[network ssid]]) {
            insertionIndex =
                [[self wifisDetected] indexOfObject:network
                                      inSortedRange:NSMakeRange(0, [[self wifisDetected] count])
                                            options:NSBinarySearchingInsertionIndex
                                    usingComparator:^NSComparisonResult(SENWifiEndpoint* wifi1, SENWifiEndpoint* wifi2) {
                                        NSComparisonResult result = NSOrderedSame;
                                        if ([wifi1 rssi] < [wifi2 rssi]) {
                                            result = NSOrderedDescending;
                                        } else if ([wifi1 rssi] > [wifi2 rssi]) {
                                            result = NSOrderedAscending;
                                        }
                                        return result;
                                    }];
            [[self wifisDetected] insertObject:network atIndex:insertionIndex];
            [[self uniqueSSIDs] addObject:[network ssid]];
        }
    }
}

- (SENSenseManager*)manager {
    SENSenseManager* manager = [[SENServiceDevice sharedService] senseManager];
    if (manager == nil) {
        manager = [[HEMOnboardingCache sharedCache] senseManager];
    }
    return manager;
}

- (void)clearDetectedWifis {
    [self setScanned:NO];
    [[self wifisDetected] removeAllObjects];
    [[self uniqueSSIDs] removeAllObjects];
}

- (void)keepLEDOnIfRequiredThen:(void(^)(void))next {
    SENSenseLEDState led = [self keepSenseLEDOn] ? SENSenseLEDStatePair : SENSenseLEDStateOff;
    [[self manager] setLED:led completion:^(id ledResponse, NSError *error) {
        next();
    }];
}

- (void)scan:(void(^)(NSError* error))completion {
    if (!completion) return;
    
    SENSenseManager* manager = [self manager];
    if (manager) {
        [self setScanning:YES];
        
        __weak typeof(self) weakSelf = self;

        [manager setLED:SENSenseLEDStateActivity completion:^(id response, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error != nil) {
                [strongSelf setScanning:NO];
                [strongSelf setScanned:YES];
                completion (error);
                return;
            }
            
            [[strongSelf manager] scanForWifiNetworks:^(id response) {
                __block id wifiResponse = response;
                
                [strongSelf keepLEDOnIfRequiredThen:^{
                    [strongSelf setScanning:NO];
                    [strongSelf setScanned:YES];
                    [strongSelf addDetectedNetworksFromArray:wifiResponse];
                    completion (nil);
                }];

                
            } failure:^(NSError *error) {
                
                [strongSelf keepLEDOnIfRequiredThen:^{
                    [strongSelf setScanning:NO];
                    [strongSelf setScanned:YES];
                    completion (error);
                }];

            }];
        }];
    } else {
        completion ([NSError errorWithDomain:kHEMWifiNetworkErrorDomain
                                        code:HEMWiFiErrorCodeInvalidArgument
                                    userInfo:nil]);
    }
}

- (SENWifiEndpoint*)endpointAtIndexPath:(NSIndexPath*)indexPath {
    SENWifiEndpoint* endpoint = nil;
    
    NSInteger row = [indexPath row];
    if (row < [[self wifisDetected] count]) {
        endpoint = [self wifisDetected][row];
    }
    
    return endpoint;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 1 for Other (Manual), but only if not scanning
    return [self isScanning] || ![self scanned] ? 0 : 1 + [[self wifisDetected] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = nil;
    if ([self endpointAtIndexPath:indexPath] == nil) {
        cellId = kHEMWifiOtherCellId;
    } else {
        cellId = kHEMWifiNetworkCellId;
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}

@end
