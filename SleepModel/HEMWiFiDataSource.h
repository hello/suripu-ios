//
//  HEMWiFiDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 10/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HEMWiFiErrorCode) {
    HEMWiFiErrorCodeInvalidArgument = -1
};

@class SENWifiEndpoint;

@interface HEMWiFiDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, assign) BOOL keepSenseLEDOn;

/**
 * @method endpointAtIndexPath:
 *
 * @discussion
 * Retrieve the wifi endpoint at the specified index path
 *
 * @param indexPath: indexPath of the cell used to display the wifi endpoint info
 * @return SENWifiEndpoint or nil if indexpath does not map to an endpoint
 */
- (SENWifiEndpoint*)endpointAtIndexPath:(NSIndexPath*)indexPath;

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
