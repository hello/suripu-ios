//
//  HEMWiFiDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 10/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMWiFiDataSource : NSObject <UITableViewDataSource>

/**
 * @method ssidOfWiFiAtIndexPath:
 *
 * @discussion
 * Retrieve the ssid of the WiFi at index path specified
 *
 * @param indexPath: the indexPath of the cell used to display the ssid
 * @return ssid of the wifi, or nil if no wifi was detected at that path
 */
- (NSString*)ssidOfWiFiAtIndexPath:(NSIndexPath*)indexPath;

/**
 * @method isWiFiSecureAtIndexPath:
 *
 * @discussion
 * Determine if the WiFi a the specified indexpath is secure or not
 *
 * @param indexPath: the indexPath of the cell that is used to display the WiFi
 * @return YES if secure, NO otherwise.
 */
- (BOOL)isWiFiSecureAtIndexPath:(NSIndexPath*)indexPath;

/**
 * @method rssiOfWifiAtIndexPath:
 *
 * @discussion
 * Determine if the rssi value of the WiFi at the specified indexPath
 *
 * @param indexPath: the indexPath of the cell that is used to display the WiFi
 * @return the RSSI value of the WiFi, if WiFi exists at that path
 */
- (long)rssiOfWifiAtIndexPath:(NSIndexPath*)indexPath;

/**
 * @method scan:
 *
 * @discussion
 * Trigger Sense to start a single scan for the networks.  Usually it takes at
 * 2 scans to retrieve all of the WiFis nearby, but 1 may be sufficient
 *
 * @param completion: block to invoke when scan is done
 */
- (void)scan:(void(^)(NSError* error))completion;

/**
 * @method clearDetectedWifis
 *
 * @discussion
 * Clear the list of detected WiFis so that a reload of the table will not show
 * any WiFis
 */
- (void)clearDetectedWifis;

@end
